## Private functions imported from 'future'
FutureRegistry <- import_future("FutureRegistry")
assertOwner <- import_future("assertOwner")
readImmediateConditions <- import_future("readImmediateConditions")
signalEarly <- import_future("signalEarly")
evalFuture <- import_future("evalFuture")
getFutureData <- import_future("getFutureData")
getFutureBackendConfigs <- import_future("getFutureBackendConfigs")
sQuoteLabel <- import_future("sQuoteLabel")
immediateConditionsPath <- import_future("immediateConditionsPath")
fileImmediateConditionHandler <- import_future("fileImmediateConditionHandler")
assert_no_references <- import_future("assert_no_references")
summarize_size_of_globals <- import_future("summarize_size_of_globals")

## An environment must be imported when the package is loaded, otherwise
## we would get a copy and not share the state with 'future'
.debug <- NULL

import_future_functions <- function() {
  .debug <<- import_future(".debug", mode = "environment")

  ## The generic is a private function in 'future', so the S3method()
  ## entry in NAMESPACE is not enough to register the method
  registerS3method("getFutureBackendConfigs", "CallrFuture", getFutureBackendConfigs.CallrFuture)
}
