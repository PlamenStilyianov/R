Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqd0201000.sql - RQuery downgrade script from version 1.2 to 1.1
Rem
Rem    DESCRIPTION
Rem      Drops all system objects present in 1.2 but not in 1.1
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

update rq$config set value = '1.1'
where  name = 'VERSION';
commit;

--***************************************************************************--
--*  (*) UPDATE R SCRIPTS                                                   *--
--***************************************************************************--

delete from rq$script where name = 'RQ$FITDISTR';

insert into rq$script (name, script) values ('RQ$DNORM',
'function(x, mean, sd, log)
{
  x <- stats::dnorm(x, mean = mean, sd = sd, log = log)
  x[is.nan(x)] <- NA_real_
  data.frame(x = x)
}');
commit;

--***************************************************************************--
--*  end of file rqd0201000.sql                                             *--
--***************************************************************************--
