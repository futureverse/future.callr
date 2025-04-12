## To be cached by .onLoad()
FutureRegistry <- NULL
assertOwner <- NULL
readImmediateConditions <- NULL
signalEarly <- NULL
getFutureBackendConfigs <- NULL

.onLoad <- function(libname, pkgname) {
  ## Import private functions from 'future'
  FutureRegistry <<- import_future("FutureRegistry")
  assertOwner <<- import_future("assertOwner")
  readImmediateConditions <<- import_future("readImmediateConditions")
  signalEarly <<- import_future("signalEarly")
  getFutureBackendConfigs <<- import_future("getFutureBackendConfigs")
  registerS3method("getFutureBackendConfigs", "CallrFutureBackend", getFutureBackendConfigs.CallrFutureBackend)
}

