Rem
Rem Copyright (c) 2012, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqd0302000.sql - RQuery downgrade script from version 1.3 to 1.2
Rem
Rem    DESCRIPTION
Rem      Drops all system objects present in 1.3 but not in 1.2
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    03/22/13 - bug 16536750: missing grants when upgrading 1.1
Rem    qinwan      11/02/12 - predefined R/package version script
Rem    demukhin    10/16/12 - prj: no roles
Rem    qinwan      10/11/12 - Embedded R memory limits
Rem    qinwan      09/26/12 - persistence R prj
Rem    demukhin    08/31/12 - prj: BLOB image
Rem    demukhin    08/29/12 - Created
Rem

--***************************************************************************--
--*  (*) UPDATE CONFIG OPTIONS                                              *--
--***************************************************************************--

update rq$config set value = '1.2'
where  name = 'VERSION';

delete from rq$config where name = 'MAX_VSIZE';
delete from rq$config where name = 'MIN_VSIZE';
delete from rq$config where name = 'MAX_NSIZE';
delete from rq$config where name = 'MIN_NSIZE';
commit;

--***************************************************************************--
--*  (*) UPDATE R SCRIPTS                                                   *--
--***************************************************************************--

delete from rq$script where name = 'RQG$plot1d';
delete from rq$script where name = 'RQG$plot2d';
delete from rq$script where name = 'RQG$hist';
delete from rq$script where name = 'RQG$boxplot';
delete from rq$script where name = 'RQG$smoothScatter';
delete from rq$script where name = 'RQG$cdplot';
delete from rq$script where name = 'RQG$pairs';
delete from rq$script where name = 'RQG$matplot';

delete from rq$script where name = 'RQ$R.Version';
delete from rq$script where name = 'RQ$getRversion';
delete from rq$script where name = 'RQ$packageVersion';
delete from rq$script where name = 'RQ$installed.packages';
commit;

--***************************************************************************--
--*  (*) OBJECT PRIVILEGES                                                  *--
--***************************************************************************--

grant select on rq_scripts to rqrole;
revoke select on rq_scripts from public;

grant select on rq_config to rqrole;
revoke select on rq_config from public;

--***************************************************************************--
--*  (*) GRANTS AND ROLES                                                   *--
--***************************************************************************--

grant create library, create procedure, create type, create sequence,
      create table
to    rqsys;

grant create table, create view, create procedure 
to    rqrole;

grant rqrole 
to    rqadmin;

--***************************************************************************--
--*  (*) RQSYS                                                              *--
--***************************************************************************--

alter session set current_schema = "RQSYS";

--***************************************************************************--
--*  (*) DROP SYNONYMS                                                      *--
--***************************************************************************--

drop public synonym RQ$DATASTORE;
drop public synonym RQ$DATASTOREOBJECT;
drop public synonym RQ$DATASTOREREFDBOBJECT; 
drop public synonym RQUSER_DATASTORELIST;
drop public synonym RQUSER_DATASTORECONTENTS; 

--***************************************************************************--
--*  (*) DROP VIEWS                                                         *--
--***************************************************************************--

drop view RQUSER_DATASTORECONTENTS;
drop view RQUSER_DATASTORELIST;
drop view RQ$DATASTORESUMMARY;
drop view RQ$DATASTORELIST;

--***************************************************************************--
--*  (*) DROP TABLES                                                        *--
--***************************************************************************--

drop table RQ$DATASTOREREFDBOBJECT purge;
drop table RQ$DATASTOREOBJECT purge;
drop table RQ$DATASTORE purge;

--***************************************************************************--
--*  (*) DROP SEQUENCES                                                     *--
--***************************************************************************--

drop sequence rq$datastore_seq;

--***************************************************************************--
--*  (*) DROP PUBLIC SYNONYMS                                               *--
--***************************************************************************--

drop public synonym rqForeach;
drop public synonym rq$object_seq;

--***************************************************************************--
--*  (*) OBJECT PRIVILEGES                                                  *--
--***************************************************************************--

grant select on rqForeach to rqrole;
revoke select on rqforeach from public;

grant select on rq$object_seq to rqrole;
revoke select on rq$object_seq from public;

--***************************************************************************--
--*  end of file rqd0302000.sql                                             *--
--***************************************************************************--
