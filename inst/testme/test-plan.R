message("*** plan() ...")

message("*** future::plan(future.callr::callr)")
oplan <- future::plan(future.callr::callr)
print(future::plan())
future::plan(oplan)
print(future::plan())


library(future)
library(future.callr)
plan(future.callr::callr)

for (type in c("callr")) {
  mdebugf("*** plan('%s') ...", type)

  plan(type)
  stopifnot(inherits(plan("next"), "callr"))

  a <- 0
  f <- future({
    b <- 3
    c <- 2
    a * b * c
  })
  a <- 7  ## Make sure globals are frozen
  v <- value(f)
  print(v)
  stopifnot(v == 0)

  mdebugf("*** plan('%s') ... DONE", type)
} # for (type ...)


message("*** Assert that default backend can be overridden ...")

mpid <- Sys.getpid()
print(mpid)

plan(future.callr::callr)
pid %<-% { Sys.getpid() }
print(pid)
stopifnot(pid != mpid)


message("*** plan() ... DONE")

