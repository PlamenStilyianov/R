Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqdrp.sql - RQuery DRoP rqsys schema
Rem
Rem    DESCRIPTION
Rem      Drops RQSYS schema.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/12/12 - prj: no roles
Rem    demukhin    03/27/12 - add config changes
Rem    demukhin    12/05/11 - embedded layer security review changes
Rem    demukhin    11/23/11 - security review changes
Rem    demukhin    09/28/11 - Created
Rem

--***************************************************************************--
--*  (*) RQUSER                                                             *--
--***************************************************************************--

declare
  cursor c1 is
    select owner
    from   dba_tables
    where  table_name = 'RQ$DATASTOREINVENTORY';

  v_owner  VARCHAR2(30);
begin
  open c1;
  loop
    fetch c1 into v_owner;
    exit when c1%NOTFOUND;
    begin
      execute immediate 'drop table '||v_owner||'.RQ$DATASTOREINVENTORY purge';
    exception
      when others then
        null;
    end;
  end loop;
  close c1;
end;
/

--***************************************************************************--
--*  (*) PUBLIC                                                             *--
--***************************************************************************--

drop public synonym rqForeach;
drop public synonym rq$object_seq;
drop public synonym RQ$DATASTORE;
drop public synonym RQ$DATASTOREOBJECT;
drop public synonym RQ$DATASTOREREFDBOBJECT; 
drop public synonym RQUSER_DATASTORELIST;
drop public synonym RQUSER_DATASTORECONTENTS;

--***************************************************************************--
--*  (*) RQSYS                                                              *--
--***************************************************************************--

drop user rqsys cascade;

--***************************************************************************--
--*  (*) SYS                                                                *--
--***************************************************************************--

drop view rq_config;
drop table rq$config purge;

drop view rq_scripts;
drop table rq$script purge;

drop role rqadmin cascade;
drop role rqrole cascade;

--***************************************************************************--
--* end of file rqdrp.sql                                                   *--
--***************************************************************************--
