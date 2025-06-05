# dipsaus

<details>

* Version: 0.3.1
* GitHub: https://github.com/dipterix/dipsaus
* Source code: https://github.com/cran/dipsaus
* Date/Publication: 2025-04-03 16:50:02 UTC
* Number of recursive dependencies: 62

Run `revdepcheck::revdep_details(, "dipsaus")` for more info

</details>

## In both

*   checking compiled code ... NOTE
    ```
    File ‘dipsaus/libs/dipsaus.so’:
      Found non-API calls to R: ‘CLOENV’, ‘ENCLOS’
    
    Compiled code should not call non-API entry points in R.
    
    See ‘Writing portable packages’ in the ‘Writing R Extensions’ manual,
    and section ‘Moving into C API compliance’ for issues with the use of
    non-API entry points.
    ```

# iml

<details>

* Version: 0.11.4
* GitHub: https://github.com/giuseppec/iml
* Source code: https://github.com/cran/iml
* Date/Publication: 2025-02-24 12:50:02 UTC
* Number of recursive dependencies: 174

Run `revdepcheck::revdep_details(, "iml")` for more info

</details>

## In both

*   checking examples ... ERROR
    ```
    Running examples in ‘iml-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: Predictor
    > ### Title: Predictor object
    > ### Aliases: Predictor
    > 
    > ### ** Examples
    > 
    > library("mlr")
    Error in library("mlr") : there is no package called ‘mlr’
    Execution halted
    ```

*   checking re-building of vignette outputs ... ERROR
    ```
    Error(s) in re-building vignettes:
    --- re-building ‘intro.Rmd’ using rmarkdown
    Warning in png(..., res = dpi, units = "in") :
      unable to open connection to X11 display ''
    
    Quitting from intro.Rmd:139-142 [unnamed-chunk-11]
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    <error/rlang_error>
    Error in `initialize()`:
    ! Please install the partykit package.
    ...
    --- re-building ‘parallel.Rmd’ using rmarkdown
    Warning in png(..., res = dpi, units = "in") :
      unable to open connection to X11 display ''
    --- finished re-building ‘parallel.Rmd’
    
    SUMMARY: processing the following file failed:
      ‘intro.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

# mlr3spatial

<details>

* Version: 0.5.0
* GitHub: https://github.com/mlr-org/mlr3spatial
* Source code: https://github.com/cran/mlr3spatial
* Date/Publication: 2024-03-09 13:00:02 UTC
* Number of recursive dependencies: 91

Run `revdepcheck::revdep_details(, "mlr3spatial")` for more info

</details>

## In both

*   checking package dependencies ... ERROR
    ```
    Package required but not available: ‘terra’
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# netShiny

<details>

* Version: 1.0
* GitHub: NA
* Source code: https://github.com/cran/netShiny
* Date/Publication: 2022-08-22 09:30:02 UTC
* Number of recursive dependencies: 135

Run `revdepcheck::revdep_details(, "netShiny")` for more info

</details>

## In both

*   checking package dependencies ... ERROR
    ```
    Packages required but not available:
      'ggVennDiagram', 'ipc', 'Matrix', 'netgwas'
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# projpred

<details>

* Version: 2.8.0
* GitHub: https://github.com/stan-dev/projpred
* Source code: https://github.com/cran/projpred
* Date/Publication: 2023-12-15 00:00:02 UTC
* Number of recursive dependencies: 160

Run `revdepcheck::revdep_details(, "projpred")` for more info

</details>

## In both

*   checking package dependencies ... ERROR
    ```
    Packages required but not available: 'loo', 'ordinal', 'mclogit'
    
    Packages suggested but not available for checking:
      'rstanarm', 'brms', 'cmdstanr', 'bayesplot', 'posterior'
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# SpaDES.core

<details>

* Version: 2.1.0
* GitHub: https://github.com/PredictiveEcology/SpaDES.core
* Source code: https://github.com/cran/SpaDES.core
* Date/Publication: 2024-06-02 11:02:47 UTC
* Number of recursive dependencies: 133

Run `revdepcheck::revdep_details(, "SpaDES.core")` for more info

</details>

## In both

*   checking package dependencies ... ERROR
    ```
    Packages required but not available: 'quickPlot', 'reproducible'
    
    Packages suggested but not available for checking:
      'DiagrammeR', 'ggplotify', 'NLMR', 'SpaDES.tools'
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

