library(future)

message("*** callr() - condition handling ...")

plan(future.callr::callr, workers = 1)

message("- future(..., conditions = NULL)")
f <- future(1 + 1, conditions = NULL)
v <- value(f)
stopifnot(identical(v, 2))

message("- relay immediateCondition:s while polling resolved()")
immediateMessage <- function(..., domain = NULL, appendLF = TRUE) {
  msg <- .makeMessage(..., domain = domain, appendLF = appendLF)
  call <- sys.call()
  m <- simpleMessage(msg, call)
  class(m) <- c(class(m), "immediateCondition")
  message(m)
  invisible(m)
}

f <- future({
  immediateMessage("hello from worker")
  Sys.sleep(1)
  42L
})

## Wait a bit, because immediateCondition:s are relayed via the file system
Sys.sleep(2.0)
r <- suppressMessages(resolved(f))
stopifnot(is.logical(r))

v <- suppressMessages(value(f))
stopifnot(identical(v, 42L))

plan(sequential)

message("*** callr() - condition handling ... DONE")
