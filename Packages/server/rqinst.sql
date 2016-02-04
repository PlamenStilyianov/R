Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqinst.sql - RQuery INSTall db objects
Rem
Rem    DESCRIPTION
Rem      Creates RQSYS schema and loads RQuery metadata.
Rem
Rem    NOTES
Rem      The script takes the following parameters:
Rem        arg1 - default tablespace (SYSAUX)
Rem        arg2 - tempopary tablespace (TEMP)
Rem        arg3 - R_HOME
Rem        arg4 - R_LIBS_USER
Rem        arg5 - ORE version
Rem        arg6 - LIBORE path
Rem        arg7 - LIBRQE path
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/16/12 - prj: no roles
Rem    vsharanh    03/14/12 - ported to Windows
Rem    demukhin    11/23/11 - security review changes
Rem    demukhin    09/26/11 - Created
Rem

--***************************************************************************--
--*  (*) SYS                                                                *--
--***************************************************************************--

@@rqcrt.sql &&1 &&2 &&3 &&4 &&5

--***************************************************************************--
--*  (*) RQSYS                                                              *--
--***************************************************************************--

alter session set current_schema = "RQSYS";

@@rqsys.sql &&6 &&7

--***************************************************************************--
--* end of file rqinst.sql                                                  *--
--***************************************************************************--
