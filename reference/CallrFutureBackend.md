# A callr future is a future whose value will be resolved via callr

A callr future is a future whose value will be resolved via callr

## Usage

``` r
CallrFutureBackend(workers = availableCores(), supervise = FALSE, ...)
```

## Arguments

- workers:

  (optional) The maximum number of workers the callr backend may use at
  any time.

- supervise:

  (optional) Argument passed to
  [`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html).

- ...:

  Additional arguments passed to
  [`future::FutureBackend()`](https://future.futureverse.org/reference/FutureBackend-class.html).

## Value

A CallrFutureBackend object
