## To be cached by .onLoad()
FutureRegistry <- NULL
assertOwner <- NULL

attr(callr, "backend") <- CallrFutureBackend

.onLoad <- function(libname, pkgname) {
  ## Import private functions from 'future'
  FutureRegistry <<- import_future("FutureRegistry")
  assertOwner <<- import_future("assertOwner")
}

