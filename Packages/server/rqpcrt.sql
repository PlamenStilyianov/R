Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      rqpcrt.sql -  RQuery Proc CReaTe
Rem
Rem    DESCRIPTION
Rem      Creates RQuery PL/SQL procedures, functions and packages.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/18/12 - Created
Rem

--***************************************************************************--
--*  (*) SYS                                                                *--
--***************************************************************************--

@@rqadmin.sql

--***************************************************************************--
--*  (*) RQSYS                                                              *--
--***************************************************************************--

alter session set current_schema = "RQSYS";

@@rqproc.sql

--***************************************************************************--
--* end of file rqpcrt.sql                                                  *--
--***************************************************************************--
