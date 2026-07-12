library(future)

message("*** callr() - releasing processx connections ...")

plan(future.callr::callr, workers = 2L)

f1 <- future({ Sys.sleep(0.1); 1 })
f2 <- future({ Sys.sleep(0.1); 2 })

v1 <- value(f1)
v2 <- value(f2)

stopifnot(v1 == 1, v2 == 2)

p1 <- f1[["process"]]
p2 <- f2[["process"]]

if (inherits(p1, "process")) {
  for (conn_name in c("input", "output", "error", "poll")) {
    has_conn_fn <- p1[[sprintf("has_%s_connection", conn_name)]]
    get_conn_fn <- p1[[sprintf("get_%s_connection", conn_name)]]
    if (is.function(has_conn_fn) && has_conn_fn() && is.function(get_conn_fn)) {
      con <- get_conn_fn()
      if (inherits(con, "processx_connection")) {
        fileno <- processx::conn_get_fileno(con)
        stopifnot(fileno == -1)
      }
    }
  }
}

if (inherits(p2, "process")) {
  for (conn_name in c("input", "output", "error", "poll")) {
    has_conn_fn <- p2[[sprintf("has_%s_connection", conn_name)]]
    get_conn_fn <- p2[[sprintf("get_%s_connection", conn_name)]]
    if (is.function(has_conn_fn) && has_conn_fn() && is.function(get_conn_fn)) {
      con <- get_conn_fn()
      if (inherits(con, "processx_connection")) {
        fileno <- processx::conn_get_fileno(con)
        stopifnot(fileno == -1)
      }
    }
  }
}

message("*** callr() - releasing processx connections ... DONE")
