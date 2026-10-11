# SpaDES.core (3.2.1)

* GitHub: <https://github.com/PredictiveEcology/SpaDES.core>
* Email: <mailto:eliot.mcintire@canada.ca>
* GitHub mirror: <https://github.com/cran/SpaDES.core>

Run `revdepcheck::revdep_details(, "SpaDES.core")` for more info

## In both

*   checking examples ... ERROR
     ```
     Running examples in ‘SpaDES.core-Ex.R’ failed
     The error most likely occurred in:
     
     > ### Name: convertToPackage
     > ### Title: Convert standard module code into an R package
     > ### Aliases: convertToPackage
     > 
     > ### ** Examples
     > 
     > if (requireNamespace("ggplot2") && requireNamespace("pkgload") ) {
     +   tmpdir <- tempdir2()
     +   newModule("test", tmpdir, open = FALSE)
     +   convertToPackage("test", path = tmpdir)
     + }
     Loading required namespace: pkgload
     New module test created at /scratch/hb/RtmpygLAuh/working_dir/RtmpwQ07Ay/reproducible/U3C0xYmG
     ```

