Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rquser.sql - RQuery create USER schema
Rem
Rem    DESCRIPTION
Rem      Creates RQUSER schema.
Rem
Rem    NOTES
Rem      The script takes four parameters:
Rem        arg1 - user name (RQUSER)
Rem        arg2 - user password
Rem        arg3 - default tablespace (USER)
Rem        arg4 - tempopary tablespace (TEMP)
Rem        arg5 - quota on default tablespace (unlimited)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/03/12 - prj: no roles
Rem    qinwan      09/25/12 - persistence R prj
Rem    demukhin    09/01/12 - prj: BLOB image
Rem    qinwan      08/20/12 - modify datastore table schema
Rem    qinwan      07/25/12 - update name length
Rem    qinwan      07/19/12 - add rqTableEval2
Rem    schakrab    04/05/12 - Add rqRFuncEval synonyms
Rem    demukhin    11/23/11 - Created
Rem

-- create RQUSER user
create user &&1 identified by &&2
default tablespace &&3
temporary tablespace &&4 
quota &&5 on &&3;

-- grant privileges
grant create session, create table, create view, create procedure,
      create mining model
to &&1;

--***************************************************************************--
--* end of file rquser.sql                                                  *--
--***************************************************************************--
