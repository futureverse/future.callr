library(future.callr)

message("*** Futures - labels ...")

strategies <- c("callr")

for (strategy in strategies) {
  mdebugf("- plan('%s') ...", strategy)
  plan(strategy)

  for (label in list(NULL, sprintf("strategy_%s", strategy))) {
    f <- future(42, label = label)
    print(f)
    stopifnot(identical(f$label, label))
    v <- value(f)
    stopifnot(v == 42)

    v %<-% { 42 } %label% label
    f <- futureOf(v)
    print(f)
    stopifnot(identical(f$label, label))
    stopifnot(v == 42)

  } ## for (label ...)

  mdebugf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

message("*** Futures - labels ... DONE")

