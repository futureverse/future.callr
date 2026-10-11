library(future)

options(future.debug = TRUE)

message("*** callr() - timeouts ...")

message("- await() times out while the callr worker is still running")
options(future.wait.timeout = 0.5)
plan(future.callr::callr, workers = 1L)

f <- future({ Sys.sleep(5); 1 })
res <- tryCatch(value(f), error = identity)
print(res)
stopifnot(inherits(res, "error"), inherits(res, "FutureError"))

## The worker is still sleeping; shutting down the plan cancels
## and interrupts it so the test does not hang.
plan(sequential)

message("- waitForWorker() times out while all workers are occupied")
options(future.wait.timeout = 0.3)
plan(future.callr::callr, workers = 1L)

## Starts immediately - no worker is occupied yet
f1 <- future({ Sys.sleep(3); 1 })

## Should timeout when there are no free workers
res <- tryCatch(future(2), error = identity)
print(res)
stopifnot(inherits(res, "error"), inherits(res, "FutureError"))

## Shut down workers before all futures have been collected (here 'f1')
plan(sequential)

message("*** callr() - timeouts ... DONE")
