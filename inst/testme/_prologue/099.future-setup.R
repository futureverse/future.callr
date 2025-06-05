## Use local callr futures by default
oplan <- local({
  oopts <- options(future.debug = FALSE)
  on.exit(options(oopts))
  future::plan(future.callr::callr)
})

all_strategies <- function() {
  strategies <- Sys.getenv("R_FUTURE_TESTS_STRATEGIES")
  strategies <- unlist(strsplit(strategies, split = ","))
  strategies <- gsub(" ", "", strategies)
  strategies <- strategies[nzchar(strategies)]
  strategies <- c(future:::supportedStrategies(), strategies)
  unique(strategies)
}

test_strategy <- function(strategy) {
  strategy %in% all_strategies()
}
