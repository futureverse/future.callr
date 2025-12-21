# callr futures

*WARNING: This function must never be called. It may only be used with
[`future::plan()`](https://future.futureverse.org/reference/plan.html)*

## Usage

``` r
callr(
  ...,
  workers = availableCores(),
  supervise = FALSE,
  envir = parent.frame()
)
```

## Arguments

- workers:

  The number of processes to be available for concurrent callr futures.

- supervise:

  (optional) Argument passed to
  [`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html).

- envir:

  The [environment](https://rdrr.io/r/base/environment.html) from where
  global objects should be identified.

- ...:

  Additional arguments passed to
  [`Future()`](https://future.futureverse.org/reference/Future-class.html).

## Value

An object of class `CallrFuture`.

## Details

A callr future is an asynchronous multiprocess future that will be
evaluated in a background R session.

callr futures rely on the callr package, which is supported on all
operating systems.
