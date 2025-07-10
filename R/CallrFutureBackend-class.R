#' A callr future is a future whose value will be resolved via callr
#'
#' @param workers (optional) The maximum number of workers the callr
#' backend may use at any time.
#'
#' @param supervise (optional) Argument passed to [callr::r_bg()].
#'
#' @param \ldots Additional arguments passed to [future::FutureBackend()].
#'
#' @return A CallrFutureBackend object
#'
#' @importFrom future FutureBackend
#' @keywords internal
#' @export
CallrFutureBackend <- function(workers = availableCores(), supervise = FALSE, ...) {
  if (is.function(workers)) workers <- workers()
  stop_if_not(length(workers) == 1L)
  if (is.numeric(workers)) {
    workers <- as.integer(workers)
    stop_if_not(!anyNA(workers), all(workers >= 1))
  } else {
    stop("Argument 'workers' should be numeric: ", mode(workers))
  }

  stop_if_not(length(supervise) == 1L, is.logical(supervise), !is.na(supervise))

  core <- FutureBackend(
    reg = "workers-callr",
    workers = workers,
    supervise = supervise,
    future.wait.timeout = getOption("future.wait.timeout", 30 * 24 * 60 * 60),
    future.wait.interval = getOption("future.wait.interval", 0.01),
    future.wait.alpha = getOption("future.wait.alpha", 1.01),
    ...
  )
  core[["futureClasses"]] <- c("CallrFuture", core[["futureClasses"]])
  core <- structure(core, class = c("CallrFutureBackend", "MultiprocessFutureBackend", "FutureBackend", class(core)))
  core
}


#' @importFrom future run FutureError
#' @importFrom callr r_bg
#' @keywords internal
#' @importFrom future launchFuture
#' @export
launchFuture.CallrFutureBackend <- local({
  ## MEMOIZATION
  evalFuture <- import_future("evalFuture")
  getFutureData <- import_future("getFutureData")
  with_stealth_rng <- import_future("with_stealth_rng")
  
  cmdargs <- NULL

  function(backend, future, ...) {
    debug <- isTRUE(getOption("future.debug"))
    if (debug) {
      mdebugf_push("launchFuture() for %s ...", class(backend)[1])
      on.exit(mdebugf_pop())
    }
  
    ## Memoization
    if (identical(cmdargs, NULL)) {
      cmdargs <- eval(formals(r_bg)[["cmdargs"]])
    }

    if (future[["state"]] != "created") {
      label <- sQuoteLabel(future)
      msg <- sprintf("A future ('%s') can only be launched once", label)
      stop(FutureError(msg, future = future))
    }

    ## Assert that the process that created the future is
    ## also the one that evaluates/resolves/queries it.
    assertOwner(future)
  
    ## Temporarily disable callr output?
    ## (i.e. messages and progress bars)
  
    ## Get future expression
    stdout <- if (isTRUE(future[["stdout"]])) TRUE else NA
  
    ## Get globals
    globals <- future[["globals"]]
    
    ## Make a callr::r_bg()-compatible function
    func <- function(data) { future:::evalFuture(data) }
    data <- getFutureData(future, mc.cores = 1L)
    r_bg_args <- list(data)

    ## 0. Record backend for now
    future[["backend"]] <- backend

    ## 1. Wait for an available worker
    workers <- backend[["workers"]]
    supervise <- backend[["supervise"]]

    timeout = backend[["future.wait.timeout"]]
    delta   = backend[["future.wait.interval"]]
    alpha   = backend[["future.wait.alpha"]]

    waitForWorker(type = "callr", workers = workers, debug = debug)

    ## 2. Allocate future to worker
    reg <- backend[["reg"]]
    FutureRegistry(reg, action = "add", future = future, earlySignal = FALSE)
  
    ## Discard standard output? (as soon as possible)
    stdout <- if (isTRUE(stdout)) "|" else NULL

    ## Discard standard error
    ## WORKAROUND: https://github.com/HenrikBengtsson/future.callr/issues/14
    ## For unknown reasons, process$is_alive() will always return TRUE if
    ## we capture stderr, which means that await() will never return.
    ## Since we don't capture and relay stderr in other backends, it's safe
    ## to discard all standard error output. /HB 2021-04-05
    stderr <- NULL

    ## Add future label to process call?
    if (!is.null(future[["label"]])) {
      ## Ideally this comes after a '--args' argument to R, but that is
      ## not possible with the current r_bg() because it will *append*
      ## '-f a-file.R' after these. /HB 2018-11-10
      cmdargs <- c(cmdargs, sprintf("--future-label=%s", shQuote(future[["label"]])))
    }


    ## Launch
    ## WORKAROUND: callr::r_bg() updates the RNG state
    with_stealth_rng({
      future[["process"]] <- r_bg(func, args = r_bg_args, stdout = stdout, stderr = stderr, cmdargs = cmdargs, supervise = supervise)
    })
    if (debug) mdebugf("Launched future (PID=%d)", future[["process"]]$get_pid())
  
    ## 3. Running
    future[["state"]] <- "running"
  
    invisible(future)
  } ## run()
})


#' @importFrom future cancel stopWorkers
#' @export
stopWorkers.CallrFutureBackend <- function(backend, ...) {
  debug <- isTRUE(getOption("future.debug"))
  if (debug) {
    mdebugf_push("stopWorkers() for %s ...", class(backend)[1])
    on.exit(mdebugf_pop())
  }
  
  reg <- backend[["reg"]]
  futures <- FutureRegistry(reg, action = "list", earlySignal = FALSE)
  
  ## Nothing to do?
  if (length(futures) == 0L) return(backend)

  ## Enable interrupts temporarily, if disabled
  if (!isTRUE(backend[["interrupts"]])) {
    backend[["interrupts"]] <- TRUE
    on.exit({ backend[["interrupts"]] <- FALSE }, add = TRUE)
  }

  ## Cancel and interrupt all futures, which terminates the workers
  futures <- lapply(futures, FUN = cancel, interrupt = TRUE)

  ## Erase registry
  futures <- FutureRegistry(reg, action = "reset")

  backend
}



#' @importFrom future nbrOfWorkers
#' @export
nbrOfWorkers.CallrFutureBackend <- function(evaluator) {
  backend <- evaluator
  workers <- backend[["workers"]]
  stop_if_not(length(workers) == 1L, !is.na(workers), workers >= 0L, is.finite(workers))
  workers
}


#' @importFrom future nbrOfFreeWorkers
#' @export
nbrOfFreeWorkers.CallrFutureBackend <- function(evaluator = NULL, background = FALSE, ...) {
  backend <- evaluator
  workers <- backend[["workers"]]
  reg <- backend[["reg"]]
  usedWorkers <- length(FutureRegistry(reg, action = "list",
                        earlySignal = FALSE))
  workers <- workers - usedWorkers
  stop_if_not(length(workers) == 1L, !is.na(workers), workers >= 
      0L, is.finite(workers))
  workers
}



#' @exportS3Method getFutureBackendConfigs CallrFuture
getFutureBackendConfigs.CallrFuture <- local({
  immediateConditionsPath <- import_future("immediateConditionsPath")
  fileImmediateConditionHandler <- import_future("fileImmediateConditionHandler")
  
  function(future, ..., debug = isTRUE(getOption("future.debug"))) {
    conditionClasses <- future[["conditions"]]
    if (is.null(conditionClasses)) {
      capture <- list()
    } else {
      path <- immediateConditionsPath(rootPath = tempdir())
      capture <- list(
        immediateConditionHandlers = list(
          immediateCondition = function(cond) {
            fileImmediateConditionHandler(cond, path = path)
          }
        )
      )
    }
  
    list(
      capture = capture
    )
  }
})


#' Prints a callr future
#'
#' @param x An CallrFuture object
#' 
#' @param \ldots Not used.
#'
#' @export
#' @keywords internal
print.CallrFuture <- function(x, ...) {
  NextMethod()

  ## Ask for the callr status
  process <- x[["process"]]
  if (inherits(process, "r_process")) {
    status <- if (process$is_alive()) "running" else "finished"
  } else {
    status <- NA_character_
  }
  printf("callr status: %s\n", paste(sQuote(status), collapse = ", "))

  if (is_na(status)) {
    printf("callr %s: Not found (happens when finished and deleted)\n",
           class(process)[1])
  } else {
    printf("callr information: PID=%d, %s\n",
           process$get_pid(), capture_output(print(process)))
  }

  invisible(x)
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Future API
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#' @importFrom future resolved
#' @keywords internal
#' @export
resolved.CallrFuture <- function(x, .signalEarly = TRUE, ...) {
  resolved <- NA
  
  debug <- isTRUE(getOption("future.debug"))
  if (debug) {
    mdebugf_push("resolved() for %s ...", class(x)[1])
    on.exit({
      mdebugf("Future state: %s", sQuote(x[["state"]]))
      mdebugf("Resolved: %s", resolved)
      mdebugf_pop()
    })
  }

  ## Already resolved?
  resolved <- NextMethod()
  if (debug) mdebugf("Future state: %s", sQuote(x[["state"]]))
  if (resolved) return(TRUE)

  process <- x[["process"]]
  alive <- local({
    alive <- NA
    if (debug) {
      mdebugf_push("Querying process ...")
      mdebugf("Process is alive: %s", alive)
      on.exit(mdebug_pop())
    }
    if (inherits(process, "r_process")) {
      alive <- process$is_alive()
    }
    alive
  })
  resolved <- (!is.na(alive) && !alive)
  
  ## Collect and relay immediateCondition if they exists
  if (debug) mdebugf_push("Collect immediate conditions ...")
  conditions <- readImmediateConditions(signal = TRUE)
  ## Record conditions as signaled
  if (length(conditions) > 0) {
    signaled <- c(x[[".signaledConditions"]], conditions)
    x[[".signaledConditions"]] <- signaled
  }
  if (debug) mdebug_pop()

  ## Signal conditions early? (happens only iff requested)
  if (.signalEarly) signalEarly(x, ...)

  resolved
}

#' @importFrom future result UnexpectedFutureResultError
#' @keywords internal
#' @export
result.CallrFuture <- function(future, ...) {
  debug <- isTRUE(getOption("future.debug"))
  if (debug) {
    mdebugf_push("result() for %s ...", class(future)[1])
    on.exit(mdebugf_pop())
  }
  
  result <- future[["result"]]
  if (!is.null(result)) {
    if (inherits(result, "FutureError")) stop(result)
    return(result)
  }
  
  if (future[["state"]] == "created") {
    future <- run(future)
  }

  result <- await(future, cleanup = FALSE)

  ## Collect and relay immediateCondition if they exists
  conditions <- readImmediateConditions()
  ## Record conditions as signaled
  signaled <- c(future[[".signaledConditions"]], conditions)
  future[[".signaledConditions"]] <- signaled

  if (!inherits(result, "FutureResult")) {
    if (inherits(result, "FutureLaunchError")) {
    } else {
      ex <- UnexpectedFutureResultError(future)
      future[["result"]] <- ex
      stop(ex)
    }
  }

  future[["result"]] <- result
  future[["state"]] <- "finished"
  
  result
}


#' @importFrom utils tail
#' @importFrom future FutureError FutureWarning FutureInterruptError
await <- function(future, ...) {
  backend <- future[["backend"]]
  timeout <- backend[["future.wait.timeout"]]
  delta <- backend[["future.wait.interval"]]
  alpha <- backend[["future.wait.alpha"]]

  stop_if_not(is.finite(timeout), timeout >= 0)
  stop_if_not(is.finite(alpha), alpha > 0)
  
  debug <- isTRUE(getOption("future.debug"))
  if (debug) {
    mdebug_push("await() ...")
    mdebugf("Future state: %s", sQuote(future[["state"]]))
    on.exit(mdebug_pop())
  }

  expr <- future[["expr"]]
  process <- future[["process"]]

  if (debug) mdebug_push("callr::wait() ...")

  ## Control callr info output
  oopts <- options(callr.verbose = debug)
  on.exit(options(oopts), add = TRUE)

  ## Sleep function - increases geometrically as a function of iterations
  sleep_fcn <- function(i) delta * alpha ^ (i - 1)

  ## Poll process
  t_timeout <- Sys.time() + timeout
  ii <- 1L
  while (process$is_alive()) {
    ## Timed out?
    if (Sys.time() > t_timeout) break
    timeout_ii <- sleep_fcn(ii)
    if (debug && ii %% 100 == 0) {
      mdebugf("iteration %d: callr::wait(timeout = %g)", ii, timeout_ii)
    }
    res <- process$wait(timeout = timeout_ii)
    ii <- ii + 1L
  }

  if (process$is_alive()) {
    if (debug) mdebug("callr process: running")
    label <- sQuoteLabel(future)
    msg <- sprintf("AsyncNotReadyError: Polled for results for %s seconds every %g seconds, but asynchronous evaluation for %s future (%s) is still running: %s", timeout, delta, class(future)[1], label, process$get_pid()) #nolint
    if (debug) {
      mdebug(msg)
      mdebug_pop()
    }
    stop(FutureError(msg, future = future))
  }

  if (debug) {
    mdebug("callr process: finished")
    mdebug_pop()
  }

  ## callr:::get_result() assert that "result" and "error" files exist
  ## based on file.exist().  In case there is a delay in the file system
  ## we might get a false-positive error:
  ## "Error: callr failed, could not start R, or it has crashed or was killed"
  ## If so, let's retry a few times before giving up.
  ## NOTE: This was observed, somewhat randomly, on R-devel (2018-04-20 r74620)
  ## on Linux (local and on Travis) with tests/demo.R /HB 2018-04-27
  if (debug) mdebug_push("callr:::get_result() ...")
  
  for (ii in 4:0) {
    result <- tryCatch({
      process$get_result()
    }, error = identity)
    if (!inherits(result, "error")) break
    if (ii > 0L) {
      if (debug) mdebug("process$get_result() failed; will retry after 0.1s")
      Sys.sleep(0.1)
    }
  }

  if (debug) mdebug_pop()

  ## Failed?
  if (inherits(result, "error")) {
    if (debug) {
      mdebugf_push("Received an %s ...", class(result)[1])
      mprint(result)
    }

    pid <- process$get_pid()
    exit_code <- tryCatch(process$get_exit_status(), error = function(e) NA_integer_)
    alive <- process$is_alive()
    if (debug) mdebugf("Process is alive: %s", alive)

    ## Remove future from FutureRegistry?
    if (!alive) {
      reg <- backend[["reg"]]
      if (FutureRegistry(reg, action = "contains", future = future)) {
        FutureRegistry(reg, action = "remove", future = future)
      }
    }

    ## Failed to launch?
    if (inherits(result, "FutureLaunchError")) {
      future[["result"]] <- result
      if (debug) mdebugf_pop()
      stop(result)
    }

    state <- future[["state"]]
    stop_if_not(state %in% c("canceled", "interrupted", "running"))
    
    if (state %in% "running") {
      event <- sprintf("failed for unknown reason while %s", state)
      port_mortem <- post_mortem_failure(result, future = future)
      future[["state"]] <- "interrupted"
    } else {
      event <- sprintf("was %s", state)
      port_mortem <- NULL
    }

    label <- sQuoteLabel(future)

    msg <- sprintf("Future (%s) of class %s %s, while running on localhost (pid %d; exit code %d)", label, class(future)[1], event, pid, exit_code)
    if (!is.null(port_mortem)) msg <- sprintf("%s. %s", msg, port_mortem)
    if (debug) mdebug(msg)
    result <- FutureInterruptError(msg, future = future)
    future[["result"]] <- result
    if (debug) mdebug_pop()
    stop(result)
  }
  
  if (debug) {
    mdebugf("Done after %d attempts", ii)
    mdebugf_pop()
    mdebug("Results:")
    mstr(result)
  }

  ## Retrieve any logged standard output and standard error
  process <- future[["process"]]

  ## PROTOTYPE RESULTS BELOW:
  prototype_fields <- NULL
  
  ## Has 'stderr' already been collected (by the future package)?
  ## Comment: This is unlikely to ever happen because you cannot
  ## capture stderr reliably in R, cf.
  ## https://github.com/HenrikBengtsson/Wishlist-for-R/issues/55
  ## /2021-04-05
  if (is.null(result[["stderr"]]) && FALSE) {
    prototype_fields <- c(prototype_fields, "stderr")
    result[["stderr"]] <- tryCatch({
      res <- process$read_all_error()
      res
    }, error = function(ex) {
      label <- sQuoteLabel(future)
      warning(FutureWarning(sprintf("Failed to retrieve standard error from %s (%s). The reason was: %s", class(future)[1], label, conditionMessage(ex)), future = future))
      NULL
    })
  }

  if (length(prototype_fields) > 0) {
    result[["PROTOTYPE_WARNING"]] <- sprintf("WARNING: The fields %s should be considered internal and experimental for now, that is, until the Future API for these additional features has been settled. For more information, please see https://github.com/HenrikBengtsson/future/issues/172", hpaste(sQuote(prototype_fields), max_head = Inf, collapse = ", ", last_collapse  = " and "))
  }

  future[["result"]] <- result
  
  reg <- backend[["reg"]]
  FutureRegistry(reg, action = "remove", future = future)
  
  result
} # await()



post_mortem_failure <- function(reason, future) {
  assert_no_references <- import_future("assert_no_references")
  summarize_size_of_globals <- import_future("summarize_size_of_globals")

  stop_if_not(inherits(future, "Future"))
  
  ## (1) Trimmed error message
  if (inherits(reason, "error")) reason <- conditionMessage(reason)

  ## (2) Information on the future
  label <- sQuoteLabel(future)

  ## (3) POST-MORTEM ANALYSIS:
  postmortem <- list()
                 
  process <- future[["process"]]
  pid <- tryCatch(process$get_pid(), error = function(e) NA_integer_)
  start_time <- tryCatch(format(process$get_start_time(), format = "%Y-%m-%dT%H:%M:%S%z"), error = function(e) NA_character_)
  msg2 <- sprintf("The parallel worker (PID %.0f) started at %s", pid, start_time)
  if (process$is_alive()) {
    msg2 <- sprintf("%s is still running", msg2)
  } else {
    exit_code <- tryCatch(process$get_exit_status(), error = function(e) NA_integer_)
    msg2 <- sprintf("%s finished with exit code %.0f", msg2, exit_code)
  }
  postmortem$alive <- msg2

  ## (c) Any non-exportable globals?
  globals <- future[["globals"]]
  postmortem$non_exportable <- assert_no_references(globals, action = "string")

  ## (d) Size of globals
  postmortem$global_sizes <- summarize_size_of_globals(globals)

  ## (4) The final error message
  msg <- sprintf("%s (%s) failed. The reason reported was %s",
                 class(future)[1], label, sQuote(reason))
  stop_if_not(length(msg) == 1L)
  if (length(postmortem) > 0) {
    postmortem <- unlist(postmortem, use.names = FALSE)
    msg <- sprintf("%s. Post-mortem diagnostic: %s",
                   msg, paste(postmortem, collapse = ". "))
    stop_if_not(length(msg) == 1L)
  }

  msg
} # post_mortem_failure()


#' @importFrom future interruptFuture
#' @importFrom parallelly killNode
#' @export
interruptFuture.CallrFutureBackend <- function(backend, future, ...) {
  debug <- isTRUE(getOption("future.debug"))
  if (debug) {
    mdebugf_push("interruptFuture() for %s ...", class(backend)[1])
    on.exit(mdebugf_pop())
  }
  
  ## Has interrupts been disabled by user?
  if (!backend[["interrupts"]]) return(future)
  process <- future[["process"]]
  pid <- process$get_pid()
  res <- tools::pskill(pid)
  future[["state"]] <- "interrupted"
  future
}


#' callr futures
#'
#' _WARNING: This function must never be called.
#'  It may only be used with [future::plan()]_
#'
#' A callr future is an asynchronous multiprocess
#' future that will be evaluated in a background R session.
#'
#' @inheritParams future::Future
#' @inheritParams CallrFutureBackend
#' 
#' @param workers The number of processes to be available for concurrent
#' callr futures.
#' 
#' @param \ldots Additional arguments passed to `Future()`.
#'
#' @return An object of class `CallrFuture`.
#'
#' @details
#' callr futures rely on the \pkg{callr} package, which is supported
#' on all operating systems.
#'
#' @importFrom parallelly availableCores
#' @importFrom future future
#' @export
callr <- function(..., workers = availableCores(), supervise = FALSE, envir = parent.frame()) {
  stop("INTERNAL ERROR: The future.callr::callr() must never be called directly")
}
class(callr) <- c("callr", "multiprocess", "future", "function")
attr(callr, "init") <- TRUE
attr(callr, "tweakable") <- "supervise"
attr(callr, "factory") <- CallrFutureBackend