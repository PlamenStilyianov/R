Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      rqu0102000.sql - RQuery upgrade script from version 1.1 to 1.2
Rem
Rem    DESCRIPTION
Rem      Creates all system objects present in version 1.2 but not in 1.1
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/16/12 - prj: no roles
Rem    paboyoun    04/25/12 - modify R scripts for fitdistr
Rem    paboyoun    04/24/12 - linear stepwise regression cleanup
Rem    schakrab    04/05/12 - Created
Rem

--***************************************************************************--
--*  (*) UPDATE CONFIG OPTIONS                                              *--
--***************************************************************************--

update rq$config set value = '1.2'
where  name = 'VERSION';
commit;

--***************************************************************************--
--*  (*) UPDATE R SCRIPTS                                                   *--
--***************************************************************************--

delete from rq$script where name = 'RQ$DNORM';

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
commit;

--***************************************************************************--
--*  end of file rqu0102000.sql                                             *--
--***************************************************************************--
