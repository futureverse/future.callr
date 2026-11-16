#' @tags listFutures

library(future)

message("*** listFutures() ...")

plan(future.callr::callr, workers = 2L)

backend <- plan("backend")

futures <- listFutures(backend)
print(futures)
stopifnot(nrow(futures) == 0L)

## An active future should be listed
f <- future({ Sys.sleep(3); 42 })
futures <- listFutures(backend)
print(futures)
stopifnot(nrow(futures) == 1L)

v <- value(f)
stopifnot(identical(v, 42))

## A collected future should no longer be listed
futures <- listFutures(backend)
print(futures)
stopifnot(nrow(futures) == 0L)

plan(sequential)

message("*** listFutures() ... DONE")
