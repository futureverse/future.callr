#' @importFrom future FutureError nbrOfWorkers
waitForWorker <- function(backend, workers = nbrOfWorkers(backend), debug = FALSE) {
  ## FutureRegistry to use
  reg <- backend[["reg"]]

  timeout <- backend[["timeout"]]
  delta <- backend[["delta"]]
  alpha <- backend[["alpha"]]

  t0 <- Sys.time()
  dt <- 0
  iter <- 1L
  interval <- delta
  finished <- FALSE
  while (dt <= timeout) {
    ## Check for available workers
    used <- length(FutureRegistry(reg, action = "list", earlySignal = FALSE))
    finished <- (used < workers)
    if (finished) break

    if (debug) mdebugf("Poll #%d (%s): usedWorkers() = %d, workers = %d", iter, format(round(dt, digits = 2L)), used, workers)

    ## Wait
    Sys.sleep(interval)
    interval <- alpha * interval

    ## Finish/close workers, iff possible
    FutureRegistry(reg, action = "collect-first")

    iter <- iter + 1L
    dt <- difftime(Sys.time(), t0, units = "secs")
  }

  if (!finished) {
    msg <- sprintf("TIMEOUT: All %d workers are still occupied after %s (polled %d times)", workers, format(round(dt, digits = 2L)), iter)
    if (debug) mdebug(msg)
    stop(FutureError(msg))
  }
}
