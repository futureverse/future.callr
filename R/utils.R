is_na <- function(x) {
  if (length(x) != 1L) return(FALSE)
  is.na(x)
}

## Adopted R.utils 2.1.0 (2015-06-15)
#' @importFrom utils capture.output
capture_output <- function(expr, envir = parent.frame(), ...) {
  res <- eval({
    file <- rawConnection(raw(0L), open = "w")
    on.exit(close(file))
    capture.output(expr, file = file)
    rawToChar(rawConnectionValue(file))
  }, envir = envir, enclos = baseenv())
  unlist(strsplit(res, split = "\n", fixed = TRUE), use.names = FALSE)
}

printf <- function(...) cat(sprintf(...))

