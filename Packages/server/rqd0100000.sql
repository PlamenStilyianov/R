Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqd0100000.sql - RQuery downgrade script from version 1.1 to 1.0
Rem
Rem    DESCRIPTION
Rem      Drops all system objects present in 1.1 but not in 1.0
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/16/12 - prj: no roles
Rem    demukhin    03/20/12 - add VERSION
Rem    schakrab    02/21/12 - added downgrade for FreqType
Rem    schakrab    02/14/12 - Created
Rem

--***************************************************************************--
--*  (*) UPDATE CONFIG OPTIONS                                              *--
--***************************************************************************--

delete from rq$config where name = 'R_LIBS_USER';
delete from rq$config where name = 'VERSION';
commit;

--***************************************************************************--
--*  end of file rqd0100000.sql                                             *--
--***************************************************************************--
