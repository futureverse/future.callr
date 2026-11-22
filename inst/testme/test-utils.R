library(future.callr)

message("*** Utility functions ...")

message("- is_na() ...")
stopifnot(is_na(NA), !is_na(TRUE), !is_na(FALSE), !is_na(1),
          !is_na(NULL), !is_na(1:2), !is_na(rep(NA, times = 3)),
          !is_na(rep(TRUE, 3)), !is_na(letters))

message("- stop_if_not() ...")
stop_if_not <- future.callr:::stop_if_not
stopifnot(is.null(stop_if_not(TRUE, 1 == 1)))
res <- tryCatch(stop_if_not(1 == 2), error = identity)
stopifnot(inherits(res, "error"))
## A call that deparses to more than one line (width.cutoff = 60L)
res <- tryCatch(
  stop_if_not(nchar("a") == 1 && nchar("a") == 1 && nchar("a") == 1 && nchar("a") == 1 && nchar("a") == 2),
  error = identity
)
stopifnot(inherits(res, "error"))

message("- printf() ...")
printf("x = %s.\n", paste(1:3, collapse = ", "))

message("- mdebug(), mdebugf() and mstr() ...")
mdebug("Hello world!")
mdebugf("Hello %s!", "world")
mstr("Hello world!")

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import_future()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
message("*** import_future() ...")

future <- import_future("future")
stopifnot(identical(future, future::future))

future <- import_future("<unknown function>", default = future::future)
stopifnot(identical(future, future::future))

res <- tryCatch(import_future("<unknown function>"), error = identity)
stopifnot(inherits(res, "error"))

message("*** import_future() ... DONE")

message("*** Utility functions ... DONE")

