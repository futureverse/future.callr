#' future.callr: Parallel Future Backend using 'callr'
#'
#' The \pkg{future.callr} package implements the Future API
#' on top of \pkg{callr}.
#' The Future API is defined by the \pkg{future} package.
#'
#' To use callr futures, attach \pkg{future}, and
#' select the type of future you wish to use, e.g.
#' `plan(future.callr::callr)`.
#'
#' @section Example:
#' ```r
#' library(futurize)          # also attaches 'future'
#' plan(future.callr::callr)  # parallelize on the current machine
#'
#' # A slow function
#' slow_fcn <- function(x) {
#'   Sys.sleep(1.0)
#'   x^2
#' }
#'
#' # Example data
#' xs <- 1:10
#'
#' # Sequential and parallel base R apply
#' ys <- lapply(xs, slow_fcn)
#' ys <- lapply(xs, slow_fcn) |> futurize()
#'
#' # Sequential and parallel purrr map
#' library(purrr)
#' ys <- xs |> map(slow_fcn)
#' ys <- xs |> map(slow_fcn) |> futurize()
#'
#' # Sequential and parallel foreach calls
#' library(foreach)
#' ys <- foreach(x = xs) %do% slow_fcn(x)
#' ys <- foreach(x = xs) %do% slow_fcn(x) |> futurize()
#' ```
#'
#' @aliases future.callr-package
#' @name future.callr
"_PACKAGE"
