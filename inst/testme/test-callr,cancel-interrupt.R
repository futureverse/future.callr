library(future)

message("*** callr() - cancel(interrupt = TRUE) ...")

plan(future.callr::callr, workers = 1L)

f <- future({ Sys.sleep(5); 1 })
Sys.sleep(1.0)  ## wait for worker to start

f <- cancel(f, interrupt = TRUE)
stopifnot(identical(f[["state"]], "canceled"))

res <- tryCatch(value(f), error = identity)
print(res)
stopifnot(inherits(res, "error"), inherits(res, "FutureError"))

plan(sequential)

message("*** callr() - cancel(interrupt = TRUE) ... DONE")


message("*** callr() - interruptFuture() when interrupts are disabled ...")

oopts <- options(future.debug = TRUE)
plan(future.callr::callr, workers = 1L, interrupts = FALSE)

f <- future({ Sys.sleep(5); 1 })
backend <- f[["backend"]]
stopifnot(identical(backend[["interrupts"]], FALSE))

## interruptFuture() should not do nothing when interrupts are disable
f2 <- future::interruptFuture(backend, future = f)
stopifnot(identical(f2[["state"]], "running"))

## ... except for when stopping workers
plan(sequential)
options(oopts)

message("*** callr() - interruptFuture() when interrupts are disabled ... DONE")


message("*** callr() - launchFuture() rejects an already-launched future ...")

plan(future.callr::callr, workers = 1L)
f <- future(42L)
v <- value(f)
stopifnot(identical(v, 42L))

backend <- f[["backend"]]
res <- tryCatch(future::launchFuture(backend, future = f), error = identity)
print(res)
stopifnot(inherits(res, "error"))

plan(sequential)

message("*** callr() - launchFuture() rejects an already-launched future ... DONE")
