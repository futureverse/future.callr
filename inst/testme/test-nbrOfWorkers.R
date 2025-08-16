library(future)

message("*** nbrOfWorkers() ...")

ncores <- availableCores()
n <- nbrOfWorkers(future.callr::callr)
message("Number of workers: ", n)
stopifnot(n == ncores)

message("*** nbrOfWorkers() ... DONE")

