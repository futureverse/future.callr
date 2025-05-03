## To be imported from 'future', if available
FutureRegistry <- NULL
assertOwner <- NULL
readImmediateConditions <- NULL
signalEarly <- NULL
evalFuture <- NULL
getFutureData <- NULL
getFutureBackendConfigs <- NULL
cancel <- NULL

## Import private functions from 'future'
import_future_functions <- function() {
  FutureRegistry <<- import_future("FutureRegistry")
  assertOwner <<- import_future("assertOwner")
  readImmediateConditions <<- import_future("readImmediateConditions")
  signalEarly <<- import_future("signalEarly")
  
  ## future (>= 1.40.0)
  prune_fcn <<- import_future("prune_fcn", default = prune_fcn)
  evalFuture <<- import_future("evalFuture", default = NULL)
  getFutureData <<- import_future("getFutureData", default = NULL)
  getFutureBackendConfigs <<- import_future("getFutureBackendConfigs")
  registerS3method("getFutureBackendConfigs", "CallrFuture", getFutureBackendConfigs.CallrFuture)

  ## Until future (>= 1.49.0) is on CRAN
  cancel <<- import_future("cancel", default = NA)
  if (!is.function(cancel)) {
    interrupt <- import_future("interrupt")
    cancel <<- function(x, interrupt = TRUE, ...) {
      if (!interrupt) return(x)
      interrupt(x, ...)
    }
  }
}
