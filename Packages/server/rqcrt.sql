Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqcrt.sql - RQuery CReaTe rqsys schema
Rem
Rem    DESCRIPTION
Rem      Creates an RQSYS schema.
Rem
Rem    NOTES
Rem      The script takes the following parameters:
Rem        arg1 - default tablespace (SYSAUX)
Rem        arg2 - tempopary tablespace (TEMP)
Rem        arg3 - R_HOME
Rem        arg4 - R_LIBS_USER
Rem        arg5 - ORE version
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    03/22/13 - bug 16536750: missing grants when upgrading 1.1
Rem    qinwan      11/02/12 - predefined R/package version script
Rem    qinwan      10/16/12 - raise min R memory limits for R-2.15
Rem    demukhin    10/03/12 - prj: no roles
Rem    qinwan      09/18/12 - add memory limit control
Rem    demukhin    08/30/12 - prj: BLOB image
Rem    demukhin    08/29/12 - ORE version 1.3
Rem    demukhin    07/13/12 - ORE version 1.2
Rem    mhornick    07/06/12 - add 'create mining model' priv to rqrole
Rem    paboyoun    04/24/12 - add script for fitdistr
Rem    schakrab    04/11/12 - fix bug 13631447
Rem    demukhin    03/19/12 - add VERSION
Rem    demukhin    01/17/12 - add R_HOME config option
Rem    demukhin    12/07/11 - named script support
Rem    demukhin    12/05/11 - embedded layer security review changes
Rem    demukhin    11/22/11 - password expire; account lock
Rem    demukhin    09/27/11 - Created
Rem

--***************************************************************************--
--*  (*) USER                                                               *--
--***************************************************************************--

create user rqsys identified by rqsys 
default tablespace &&1 
temporary tablespace &&2 
quota 250M on &&1
password expire account lock;

--***************************************************************************--
--*  (*) ROLES                                                              *--
--***************************************************************************--

-- user role (deprecated)
--
create role rqrole;

-- admin role
--
create role rqadmin;

--***************************************************************************--
--*  (*) R SCRIPTS                                                          *--
--***************************************************************************--

create table rq$script(
  name    varchar2(128),
  script  clob,
constraint rq$script_pk primary key (name));

-- predifined R scripts -------------------------------------------------------
--
insert into rq$script (name, script) values ('RQ$FITDISTR',
'function(x, densfun, start, ...)
{
  # construct hopefully unique id
  id <- sprintf("%s:%s:%s", Sys.getpid(),
                (1000 * proc.time()[3L]) %% 2147483647,
                sample.int(32767L, 1L))
  # fit distribution
  require(MASS)
  if (missing(start))
    x <- fitdistr(x, densfun, ...)
  else
    x <- fitdistr(x, densfun, start, ...)
  k <- length(x$estimate)
  rbind(data.frame(id       = id,
                   element  = "estimate",
                   position = seq_len(k),
                   name1    = names(x$estimate),
                   name2    = NA_character_,
                   value    = unname(x$estimate),
                   stringsAsFactors = FALSE),
        data.frame(id       = id,
                   element  = "sd",
                   position = seq_len(k),
                   name1    = names(x$sd),
                   name2    = NA_character_,
                   value    = unname(x$sd),
                   stringsAsFactors = FALSE),
        data.frame(id       = id,
                   element  = "vcov",
                   position = seq_len(length(x$vcov)),
                   name1    = rep(rownames(x$vcov), k),
                   name2    = rep(colnames(x$vcov), each = k),
                   value    = c(x$vcov),
                   stringsAsFactors = FALSE),
        data.frame(id       = c(id,            id),
                   element  = c("loglik",      "n"),
                   position = c(NA_integer_,   NA_integer_),
                   name1    = c(NA_character_, NA_character_),
                   name2    = c(NA_character_, NA_character_),
                   value    = c(x$loglik,      x$n),
                   stringsAsFactors = FALSE))
}');

-- predefined R/package version scripts ---------------------------------------
--
insert into rq$script (name, script) values ('RQ$R.Version',
'function()
{
  v <- as.character(R.Version())
  v[v == ""] <- NA_character_ 
  data.frame(name=names(R.Version()), value=unname(v),
             stringsAsFactors=FALSE)
}');
insert into rq$script (name, script) values ('RQ$getRversion',
'function()
{
  data.frame(Version=as.character(getRversion()),
             stringsAsFactors=FALSE)
}');
insert into rq$script (name, script) values ('RQ$installed.packages',
'function()
{
  colnames <- c("Package", "Version", "LibPath")
  df <- as.data.frame(installed.packages(), stringsAsFactors=FALSE)
  df[, colnames]
}');
insert into rq$script (name, script) values ('RQ$packageVersion',
'function(pkg)
{
  data.frame(Version=as.character(packageVersion(pkg=pkg)),
             stringsAsFactors=FALSE)
}');

-- predifined graphical scripts -----------------------------------------------
--
insert into rq$script (name, script) values ('RQG$plot1d',
'function(x, ...)
{
  if (is.data.frame(x))
    x <- x[[1L]]
  if (is.character(x))
    x <- as.factor(x)
  plot(x, ...)
  invisible(NULL)
}');
insert into rq$script (name, script) values ('RQG$plot2d',
'function(x, ...)
{
  if (NCOL(x) < 2L)
    stop("script RQG$plot2d requires 2 columns to produce graphic")
  x <- x[1:2]
  if (is.character(x[[1L]]))
    x[[1L]] <- as.factor(x[[1L]])
  if (is.character(x[[2L]]))
    x[[2L]] <- as.factor(x[[2L]])
  plot(x[1:2], ...)
  invisible(NULL)
}');
insert into rq$script (name, script) values ('RQG$hist',
'function(x, ...)
{
  if (is.data.frame(x))
    x <- x[[1L]]
  hist(x, ...)
  invisible(NULL)
}');
insert into rq$script (name, script) values ('RQG$boxplot',
'function(x, ...)
{
  boxplot(x, ...)
  invisible(NULL)
}');
insert into rq$script (name, script) values ('RQG$smoothScatter',
'function(x, ...)
{
  if (NCOL(x) < 2L)
    stop("script RQG$smoothScatter requires 2 columns to produce graphic")
  x <- x[1:2]
  if (is.character(x[[1L]]))
    x[[1L]] <- as.factor(x[[1L]])
  if (is.character(x[[2L]]))
    x[[2L]] <- as.factor(x[[2L]])
  smoothScatter(x[1:2], ...)
  invisible(NULL)
}');
insert into rq$script (name, script) values ('RQG$cdplot',
'function(x, ...)
{
  if (NCOL(x) < 2L)
    stop("script RQG$cdplot requires 2 columns to produce graphic")
  x[[2L]] <- as.factor(x[[2L]])
  cdplot(x[[1L]], x[[2L]], ...)
  invisible(NULL)
}');
insert into rq$script (name, script) values ('RQG$pairs',
'function(x, ...)
{
  if (NCOL(x) < 2L)
    stop("script RQG$pairs requires at least 2 columns to produce graphic")
  pairs(x, ...)
  invisible(NULL)
}');
insert into rq$script (name, script) values ('RQG$matplot',
'function(x, ...)
{
  matplot(x, ...)
  invisible(NULL)
}');
commit;

-- rq_scripts -----------------------------------------------------------------
--
create view rq_scripts as
select name, script
from   rq$script;

grant select on rq_scripts to public;

--***************************************************************************--
--*  (*) CONFIGURATION OPTIONS                                              *--
--***************************************************************************--

create table rq$config(
  name    varchar2(128),
  value   varchar2(4000),
constraint rq$config_pk primary key (name));

insert into rq$config (name, value) 
       values ('R_HOME', '&&3');
insert into rq$config (name, value) 
       values ('R_LIBS_USER', '&&4');
insert into rq$config (name, value) 
       values ('VERSION', '&&5');
insert into rq$config (name, value) 
       values ('MIN_VSIZE', '32M');
insert into rq$config (name, value) 
       values ('MAX_VSIZE', '4G');
insert into rq$config (name, value) 
       values ('MIN_NSIZE', '1M');
insert into rq$config (name, value) 
       values ('MAX_NSIZE', '20M');
commit;

-- rq_config ------------------------------------------------------------------
--
create view rq_config as
select name, value
from   rq$config;

grant select on rq_config to public;

--***************************************************************************--
--* end of file rqcrt.sql                                                   *--
--***************************************************************************--
