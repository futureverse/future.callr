## To be imported from 'future', if available
FutureRegistry <- NULL
assertOwner <- NULL
readImmediateConditions <- NULL
signalEarly <- NULL
evalFuture <- NULL
getFutureData <- NULL
getFutureBackendConfigs <- NULL
cancel <- NULL
sQuoteLabel <- NULL
.debug <- NULL

## Import private functions from 'future'
import_future_functions <- function() {
  FutureRegistry <<- import_future("FutureRegistry")
  assertOwner <<- import_future("assertOwner")
  readImmediateConditions <<- import_future("readImmediateConditions")
  signalEarly <<- import_future("signalEarly")
  
  ## future (>= 1.40.0)
  prune_fcn <<- import_future("prune_fcn")
  evalFuture <<- import_future("evalFuture")
  getFutureData <<- import_future("getFutureData")
  getFutureBackendConfigs <<- import_future("getFutureBackendConfigs")
  registerS3method("getFutureBackendConfigs", "CallrFuture", getFutureBackendConfigs.CallrFuture)

  ## future (>= 1.49.0)
  cancel <<- import_future("cancel")
  sQuoteLabel <<- import_future("sQuoteLabel")

  .debug <<- import_future(".debug", mode = "environment", default = new.env(parent = emptyenv()))
}

