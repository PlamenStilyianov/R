Rem
Rem Copyright (c) 2012, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqu0203000.sql - RQuery upgrade script from version 1.2 to 1.3
Rem
Rem    DESCRIPTION
Rem      Creates all system objects present in version 1.3 but not in 1.2
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    03/22/13 - bug 16536750: missing grants for upgrade to 1.3
Rem    qinwan      11/02/12 - predefined R/package version script
Rem    qinwan      10/26/12 - bug fix 14808516
Rem    qinwan      10/16/12 - raise min R memory limits for R-2.15
Rem    demukhin    10/16/12 - prj: no roles
Rem    qinwan      10/11/12 - Embedded R memory limits
Rem    qinwan      09/26/12 - persistence R prj
Rem    demukhin    08/31/12 - prj: BLOB image
Rem    demukhin    08/29/12 - Created
Rem

--***************************************************************************--
--*  (*) UPDATE CONFIG OPTIONS                                              *--
--***************************************************************************--

update rq$config set value = '1.3'
where  name = 'VERSION';

insert into rq$config (name, value) 
       values ('MIN_VSIZE', '32M');
insert into rq$config (name, value) 
       values ('MAX_VSIZE', '4G');
insert into rq$config (name, value) 
       values ('MIN_NSIZE', '1M');
insert into rq$config (name, value) 
       values ('MAX_NSIZE', '20M');
commit;

--***************************************************************************--
--*  (*) UPDATE R SCRIPTS                                                   *--
--***************************************************************************--

-- predefined R/package version scripts
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

-- predifined graphical scripts
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

--***************************************************************************--
--*  (*) OBJECT PRIVILEGES                                                  *--
--***************************************************************************--

revoke select on rq_scripts from rqrole;
grant select on rq_scripts to public;

revoke select on rq_config from rqrole;
grant select on rq_config to public;

--***************************************************************************--
--*  (*) GRANTS AND ROLES                                                   *--
--***************************************************************************--

revoke create library, create procedure, create type, create sequence,
       create table
from   rqsys;

revoke create table, create view, create procedure
from   rqrole;

revoke rqrole 
from   rqadmin;

--***************************************************************************--
--*  (*) RQSYS                                                              *--
--***************************************************************************--

alter session set current_schema = "RQSYS";

--***************************************************************************--
--*  (*) CREATE SEQUENCES                                                   *--
--***************************************************************************--

CREATE SEQUENCE rq$datastore_seq start with 1001;

--***************************************************************************--
--*  (*) CREATE TABLES                                                      *--
--***************************************************************************--

CREATE TABLE RQ$DATASTORE (
   dsID                  NUMBER
            CONSTRAINT pk_dsid PRIMARY KEY,  -- datastore ID
   dsowner               VARCHAR2(128),      -- schema name
   dsname                VARCHAR2(128),      -- datastore name
   cdate                 DATE,               -- datastore creation date
   description           VARCHAR2(2000),     -- datastore description
       CONSTRAINT uk_dsname UNIQUE (dsowner, dsname)  -- primary key
);

CREATE TABLE RQ$DATASTOREOBJECT (
   objID                 NUMBER
            CONSTRAINT pk_objid PRIMARY KEY,  -- R object ID
   dsID                  NUMBER
            CONSTRAINT fk_dsid REFERENCES RQ$DATASTORE ON DELETE CASCADE,
   objname               VARCHAR2(128),    -- R object name
   class                 VARCHAR2(128),    -- R object class
   objsize               NUMBER,           -- R object size
   length                NUMBER,           -- R object length
   nrow                  NUMBER,           -- number of row if data.frame
   ncol                  NUMBER,           -- number of columns if data.frame
       CONSTRAINT uk_dsobjname UNIQUE (dsID, objname)  -- primary key
);

CREATE TABLE RQ$DATASTOREREFDBOBJECT (
   objID                NUMBER
     CONSTRAINT fk_refdb REFERENCES RQ$DATASTOREOBJECT ON DELETE CASCADE,
   refobjname           VARCHAR2(128),
   refobjtype           VARCHAR2(128),
   refobjparm           VARCHAR2(128),
   refobjowner          VARCHAR2(128)
);

--***************************************************************************--
--*  (*) CREATE VIEWS                                                       *--
--***************************************************************************--

create view RQ$DATASTORELIST AS
   select   dsowner, dsname, count(objname) as nobj, sum(objsize) as dssize,
            cdate, description
   from     RQ$DATASTORE ds, RQ$DATASTOREOBJECT obj
   where    ds.dsID = obj.dsID
   group by dsowner, dsname, cdate, description;

create view RQ$DATASTORESUMMARY AS
   select   dsowner, dsname, objname, class, objsize, length, nrow, ncol
   from     RQ$DATASTORE ds, RQ$DATASTOREOBJECT obj
   where    ds.dsID = obj.dsID
   order by dsowner, dsname, objname;

create view RQUSER_DATASTORELIST AS
   select   dsname, nobj, dssize, cdate, description
   from     RQ$DATASTORELIST
   where    dsowner=(select user from dual);

create view RQUSER_DATASTORECONTENTS AS
   select   dsname, objname, class, objsize, length, nrow, ncol
   from     RQ$DATASTORESUMMARY
   where    dsowner=(select user from dual);

--***************************************************************************--
--*  (*) OBJECT PRIVILEGES                                                  *--
--***************************************************************************--

revoke select on rqForeach from rqrole;
grant select on rqforeach to public;

revoke select on rq$object_seq from rqrole;
grant select on rq$object_seq to public;

grant select on rq$datastore_seq TO PUBLIC;
grant select on RQ$DATASTORE to public;
grant select on RQ$DATASTOREOBJECT to public;
grant select on RQ$DATASTOREREFDBOBJECT to public;
grant select on RQUSER_DATASTORELIST to public;
grant select on RQUSER_DATASTORECONTENTS to public;

--***************************************************************************--
--*  (*) PUBLIC SYNONYMS                                                    *--
--***************************************************************************--

create public synonym rqForeach for rqsys.rqForeach;
create public synonym rq$object_seq for rqsys.rq$object_seq;

create public synonym RQ$DATASTORE for rqsys.RQ$DATASTORE;
create public synonym RQ$DATASTOREOBJECT for rqsys.RQ$DATASTOREOBJECT;
create public synonym RQ$DATASTOREREFDBOBJECT 
                  for rqsys.RQ$DATASTOREREFDBOBJECT;
create public synonym RQUSER_DATASTORELIST for rqsys.RQUSER_DATASTORELIST;
create public synonym RQUSER_DATASTORECONTENTS 
                  for rqsys.RQUSER_DATASTORECONTENTS;

--***************************************************************************--
--*  (*) RQUSER                                                             *--
--***************************************************************************--

declare
  cursor c1 is
    select owner, synonym_name 
    from   dba_synonyms 
    where  owner != 'PUBLIC'
      and  synonym_name in (
'ORE_FREQ_CPIPE',
'RQ$OBJECT_SEQ',
'RQBESSELI',
'RQBESSELJ',
'RQBESSELK',
'RQBESSELY',
'RQCROSSPROD',
'RQCROSSPRODIMPL',
'RQCVMP',
'RQDBETA',
'RQDBINOM',
'RQDCAUCHY',
'RQDCHISQ',
'RQDEXP',
'RQDF',
'RQDGAMMA',
'RQDIGAMMA',
'RQDNBINOM',
'RQDNORM',
'RQDPOIS',
'RQDSIGNRANK',
'RQDT',
'RQDWEIBULL',
'RQERF',
'RQERFC',
'RQEVAL',
'RQEVALIMPL',
'RQFOREACH',
'RQFOREACHUPDATE',
'RQGAMMA',
'RQGROUPEVALIMPL',
'RQHARMONIC',
'RQKSTESTPEXP',
'RQKSTESTPNORM',
'RQKSTESTPPOIS',
'RQKSTESTPUNIF',
'RQKSTESTPWEIBULL',
'RQLARGESTEP',
'RQLARGESTEPIMPL',
'RQLARGESTEPTYPE',
'RQLARGESTEPTYPESET',
'RQLGAMMA',
'RQNUMERICELTSET',
'RQOBJECT',
'RQOBJSET',
'RQPBETA',
'RQPBINOM',
'RQPCAUCHY',
'RQPCHISQ',
'RQPEXP',
'RQPF',
'RQPGAMMA',
'RQPNBINOM',
'RQPNORM',
'RQPPOIS',
'RQPSIGNRANK',
'RQPT',
'RQPWEIBULL',
'RQQBETA',
'RQQBINOM',
'RQQCAUCHY',
'RQQCHISQ',
'RQQEXP',
'RQQF',
'RQQGAMMA',
'RQQNBINOM',
'RQQNORM',
'RQQPOIS',
'RQQSIGNRANK',
'RQQT',
'RQQWEIBULL',
'RQREGRESSION',
'RQREGRESSIONIMPL',
'RQREGRESSIONTYPE',
'RQREGRESSIONTYPESET',
'RQRFUNCEVALCHR',
'RQRFUNCEVALNUM',
'RQRNORM',
'RQROWEVAL',
'RQROWEVALIMPL',
'RQSIGNP',
'RQSTEP',
'RQSTEPIMPL',
'RQSTEPTYPE',
'RQSTEPTYPESET',
'RQSTEPWISE',
'RQSTEPWISEIMPL',
'RQSTEPWISETYPE',
'RQSTEPWISETYPESET',
'RQTABLEEVAL',
'RQTABLEEVALIMPL',
'RQTRIGAMMA',
'RQUNLISTTABLE',
'RQXMLOBJ',
'RQXMLSET',
'RQ_ELEM_T',
'RQ_PARAM_T'
    );

  cursor c2 is
    select grantee 
    from   dba_role_privs 
    where  granted_role = 'RQROLE'
    and    grantee != 'SYS';

  v_owner  VARCHAR2(30);
  v_name   VARCHAR2(30);
begin
  -- remove private synonyms
  open c1;
  loop
    fetch c1 into v_owner, v_name;
    exit when c1%NOTFOUND;
    begin
      execute immediate 'drop synonym '||v_owner||'.'||v_name;
    exception
      when others then
        null;
    end;
  end loop;
  close c1;

  -- remove rqrole and grant rqrole privileges directly
  open c2;
  loop
    fetch c2 into v_name;
    exit when c2%NOTFOUND;
    begin
      execute immediate 'revoke rqrole from "'||v_name||'"';
    exception
      when others then
        null;
    end;
    begin
      execute immediate 'grant create table, create view, create procedure, '||
                        'create mining model to "'||v_name||'"';
    exception
      when others then
        null;
    end;
  end loop;
  close c2;
end;
/

--***************************************************************************--
--*  end of file rqu0203000.sql                                             *--
--***************************************************************************--
