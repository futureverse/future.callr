library(future.callr)

message("*** Futures - lazy ...")

strategies <- c("callr")

for (strategy in strategies) {
  mdebugf("- plan('%s') ...", strategy)
  plan(strategy)

  a <- 42
  f <- future(2 * a, lazy = TRUE)
  a <- 21
  v <- value(f)
  stopifnot(v == 84)

  a <- 42
  v %<-% { 2 * a } %lazy% TRUE
  a <- 21
  stopifnot(v == 84)

  mdebugf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

message("*** Futures - lazy ... DONE")

