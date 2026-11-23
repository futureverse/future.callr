

<div id="badges"><!-- pkgdown markup -->
<a href="https://CRAN.R-project.org/web/checks/check_results_future.callr.html"><img border="0" src="https://www.r-pkg.org/badges/version/future.callr" alt="CRAN check status"/></a> <a href="https://github.com/futureverse/future.callr/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/futureverse/future.callr/actions/workflows/R-CMD-check.yaml/badge.svg?branch=develop" alt="R CMD check status"/></a>  <a href="https://github.com/futureverse/future.callr/actions?query=workflow%3Afuture_tests"><img border="0" src="https://github.com/futureverse/future.callr/actions/workflows/future_tests.yaml/badge.svg?branch=develop" alt="future.tests checks status"/></a>   <a href="https://app.codecov.io/gh/futureverse/future.callr"><img border="0" src="https://codecov.io/gh/futureverse/future.callr/branch/develop/graph/badge.svg" alt="Coverage Status"/></a> 
</div>

# future.callr: Parallel Future Backend using 'callr' 

## Introduction

The **[future.callr]** package is a backend for the **[future]**
framework, also known as the [Futureverse]. The Futureverse makes it
easy to parallelize existing R code - often with only a minor change
of code. Most users interact with it via higher-level packages such
as **[futurize]**, **[future.apply]**, **[furrr]**, and
**[doFuture]**, and you choose _where_ and _how_ the code runs by
setting a future backend with `plan()`. This package adds the `callr`
backend, which runs each future in a fresh background R process on
the local machine using the **[callr]** package.

```r
library(futurize)
plan(future.callr::callr)  # parallelize on the current machine

# A slow function
slow_fcn <- function(x) {
  Sys.sleep(1.0)
  x^2
}

# Example data
xs <- 1:10

# Sequential and parallel base R apply
ys <- lapply(xs, slow_fcn)
ys <- lapply(xs, slow_fcn) |> futurize()

# Sequential and parallel purrr map
library(purrr)
ys <- xs |> map(slow_fcn)
ys <- xs |> map(slow_fcn) |> futurize()

# Sequential and parallel foreach calls
library(foreach)
ys <- foreach(x = xs) %do% slow_fcn(x)
ys <- foreach(x = xs) %do% slow_fcn(x) |> futurize()
```

The only thing that differs from using [any other future backend](https://www.futureverse.org/backends.html) is
the `plan()` call. The code does not have to change, it gives
identical results, and it behaves exactly the same.


## The callr backend

| Backend | Description                                                      | Alternative in future package
|:--------|:-----------------------------------------------------------------|:------------------------------
| `callr` | parallel evaluation in a separate R process (on current machine) | `plan(multisession)`

Each `callr` future is resolved in a fresh background R process, which
ends as soon as the value of the future has been collected. In
contrast, `multisession` futures are resolved by R workers that stay
alive and serve many futures over their life spans.


### Advantages

* Each future starts from a clean R session. Futures cannot affect
  each other via memory allocations, finalizers, modified options, or
  loaded and attached packages.

* More than 125 futures can run in parallel. The `multisession` and
  `cluster` backends use one R connection per worker, and R has a
  default limit of 125 connections per session. **callr** does not
  use R connections, so this limit does not apply.

* No ports are used, which means there are no port clashes with other
  processes, and no firewall alerts on Windows.


### Limitations

* Launching a new R process for each future adds overhead. This makes
  the `callr` backend less suited for many small futures, where
  `plan(multisession)` might be faster.

* The R processes always run on the local machine. For workers on
  other machines, or on a high-performance compute (HPC) cluster, use
  another future backend, e.g. `plan(cluster)` or
  **[future.batchtools]**.


[Futureverse]: https://www.futureverse.org
[future]: https://future.futureverse.org
[future.callr]: https://future.callr.futureverse.org
[future.apply]: https://future.apply.futureverse.org
[future.batchtools]: https://future.batchtools.futureverse.org
[furrr]: https://furrr.futureverse.org
[doFuture]: https://doFuture.futureverse.org
[futurize]: https://futurize.futureverse.org
[callr]: https://cran.r-project.org/package=callr

## Installation

R package future.callr is available on [CRAN](https://cran.r-project.org/package=future.callr) and can be installed in R as:

```r
install.packages("future.callr")
```


### Pre-release version

To install the pre-release version, use:

```r
install.packages("future.callr", repos = c("https://futureverse-devel.r-universe.dev", "https://cloud.r-project.org"))
```


<!-- pkgdown-drop-below -->

