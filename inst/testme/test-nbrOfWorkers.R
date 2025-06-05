library(future.callr)

message("*** nbrOfWorkers() ...")

ncores <- availableCores()
n <- nbrOfWorkers(callr)
message("Number of workers: ", n)
stopifnot(n == ncores)

message("*** nbrOfWorkers() ... DONE")

