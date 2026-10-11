library(future)

message("*** callr() - terminating workers ...")

plan(future.callr::callr, workers = 2L)

all <- nbrOfWorkers()
free <- nbrOfFreeWorkers()
stopifnot(
  nbrOfWorkers() == 2L,
  nbrOfFreeWorkers() == 2L
)

## Force R worker to quit
f <- future({ tools::pskill(pid = Sys.getpid()) })
res <- tryCatch(value(f), error = identity)
print(res)
stopifnot(inherits(res, "FutureError"))

stopifnot(
  nbrOfWorkers() == all,
  nbrOfFreeWorkers() == free
)

## FutureError:s should be re-throw
res2 <- tryCatch(result(f), error = identity)
print(res2)
stopifnot(inherits(res2, "FutureError"), identical(conditionMessage(res2), conditionMessage(res)))

plan(sequential)

## Repeat with debug enabled
oopts <- options(future.debug = TRUE)
plan(future.callr::callr, workers = 1L)
f <- future({ tools::pskill(pid = Sys.getpid()) })
res <- tryCatch(value(f), error = identity)
print(res)
stopifnot(inherits(res, "FutureError"))
plan(sequential)
options(oopts)

message("*** callr() - terminating workers ... DONE")

