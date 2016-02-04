Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      rqu0101000.sql - RQuery upgrade script from version 1.0 to 1.1
Rem
Rem    DESCRIPTION
Rem      Creates all system objects present in version 1.1 but not in 1.0
Rem
Rem    NOTES
Rem      The script takes the following parameters:
Rem        arg1 - R_LIBS_USER
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/16/12 - prj: no roles
Rem    demukhin    03/20/12 - add VERSION
Rem    schakrab    02/21/12 - added upgrade for FreqType
Rem    schakrab    02/14/12 - Created
Rem

--***************************************************************************--
--*  (*) UPDATE CONFIG OPTIONS                                              *--
--***************************************************************************--

insert into rq$config (name, value) 
       values ('R_LIBS_USER', '&&1');
insert into rq$config (name, value) 
       values ('VERSION', '1.1');
commit;

--***************************************************************************--
--*  end of file rqu0001000.sql                                             *--
--***************************************************************************--
