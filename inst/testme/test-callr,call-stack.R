library(future)

message("*** callr() - call stack should not embed 'data' by value ...")

## callr::r_bg() invokes the worker function via a do.call()-based
## wrapper, which embeds literal argument values into the call object.
## If the future's 'data' (globals, expression, etc.) were passed as a
## literal argument, every frame of that wrapper would carry the full
## 'data' object, making any inspection of sys.calls() - e.g. via a
## custom logger or traceback - extremely slow to deparse. 'data' must
## therefore be passed indirectly, e.g. wrapped in an environment.

plan(future.callr::callr)

x <- rep(1.2345, times = 2e4)  ## a non-trivial global (~160 KiB)

f <- future({
  length(x)  ## force 'x' to be identified and shipped as a global
  calls <- sys.calls()
  sum(vapply(calls, function(call) {
    nchar(paste(deparse(call), collapse = ""))
  }, FUN.VALUE = integer(1)))
})
chars <- value(f)
message(sprintf("Total number of characters needed to deparse sys.calls(): %d", chars))

## With 'x' embedded by value, this would be in the millions.
## Without it, it should stay small regardless of the size of 'x'.
stopifnot(chars < 5e4)

plan(sequential)

message("*** callr() - call stack should not embed 'data' by value ... DONE")
