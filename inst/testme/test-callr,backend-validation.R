library(future.callr)

message("*** CallrFutureBackend() - argument validation ...")

message("- workers as a function")
backend <- CallrFutureBackend(workers = function() 2L)
stopifnot(inherits(backend, "CallrFutureBackend"), identical(backend[["workers"]], 2L))

message("- workers of length != 1")
res <- tryCatch(CallrFutureBackend(workers = 1:2), error = identity)
stopifnot(inherits(res, "error"))

message("- non-numeric workers")
res <- tryCatch(CallrFutureBackend(workers = "two"), error = identity)
stopifnot(inherits(res, "error"))

message("- workers is NA")
res <- tryCatch(CallrFutureBackend(workers = NA_integer_), error = identity)
stopifnot(inherits(res, "error"))

message("- workers < 1")
res <- tryCatch(CallrFutureBackend(workers = 0L), error = identity)
stopifnot(inherits(res, "error"))

message("- supervise of length != 1")
res <- tryCatch(CallrFutureBackend(workers = 1L, supervise = c(TRUE, FALSE)), error = identity)
stopifnot(inherits(res, "error"))

message("- supervise is NA")
res <- tryCatch(CallrFutureBackend(workers = 1L, supervise = NA), error = identity)
stopifnot(inherits(res, "error"))

message("- non-logical supervise")
res <- tryCatch(CallrFutureBackend(workers = 1L, supervise = "yes"), error = identity)
stopifnot(inherits(res, "error"))

message("- valid construction")
backend <- CallrFutureBackend(workers = 2L, supervise = TRUE)
stopifnot(
  inherits(backend, "CallrFutureBackend"),
  inherits(backend, "MultiprocessFutureBackend"),
  inherits(backend, "FutureBackend"),
  identical(backend[["workers"]], 2L),
  isTRUE(backend[["supervise"]]),
  "CallrFuture" %in% backend[["futureClasses"]]
)

message("*** CallrFutureBackend() - argument validation ... DONE")


message("*** callr() must never be called directly ...")
res <- tryCatch(future.callr::callr(), error = identity)
stopifnot(inherits(res, "error"), grepl("INTERNAL ERROR", conditionMessage(res)))
message("*** callr() must never be called directly ... DONE")
