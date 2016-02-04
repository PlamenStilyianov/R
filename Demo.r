library(ORE)
# Connect to Oracle RDBMS
# Change the connection information below
ore.connect(user = "rquser", sid = "ORCL", host = "suse13.orajava.com", password = "rquser", port = 1521, all = TRUE)
ore.is.connected()
demo(package = "ORE")

demo("aggregate", package = "ORE")

demo("row_apply", package="ORE")


demo ("cor")

demo("basic", package = "ORE")
