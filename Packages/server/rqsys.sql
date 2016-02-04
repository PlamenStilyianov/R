Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqsys.sql - RQuery create SYStem objects
Rem
Rem    DESCRIPTION
Rem      Creates system objects for RQuery
Rem
Rem    NOTES
Rem      The script takes the following parameters:
Rem        arg1 - LIBORE path
Rem        arg2 - LIBRQE path
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qinwan      10/26/12 - bug fix 14808516
Rem    demukhin    10/03/12 - prj: no roles
Rem    qinwan      09/25/12 - persistence R prj
Rem    demukhin    09/10/12 - prj: auto connect
Rem    demukhin    08/27/12 - prj: BLOB image
Rem    qinwan      08/20/12 - update datastore table schema
Rem    qinwan      07/25/12 - update name length
Rem    qinwan      07/18/12 - add object type rqROBJECT
Rem    schakrab    04/05/12 - add objects for rqRFuncEval
Rem    vsharanh    03/08/12 - ported to Windows
Rem    schakrab    02/14/12 - change attribute types of FreqType 
Rem                           to BINARY_DOUBLE 
Rem    schakrab    02/14/12 - add ore_freq_reglst
Rem    demukhin    12/06/11 - embedded layer security review changes
Rem    demukhin    11/23/11 - security review changes
Rem    paboyoun    11/15/11 - enquote names in DBMS_STAT_FUNCS
Rem    demukhin    09/27/11 - merge tmrqsys.sql and rqesys.sql into rqsys.sql
Rem    demukhin    09/21/11 - scrollable cursor
Rem    demukhin    09/14/11 - XML output
Rem    demukhin    09/02/11 - multitable support for regression
Rem    vsharanh    09/01/11 - fixed rqCvmP(w,n), w is double now
Rem    vsharanh    08/29/11 - merging back Windows installed changes
Rem    demukhin    07/15/11 - remove rqEval
Rem    paboyoun    07/12/11 - add matrix OCI operations
Rem    paboyoun    07/11/11 - create faster union all functionality for
Rem                           ore.frame
Rem    vsharanh    07/06/11 - fixing SQL defs for oreStat*.c defined fns
Rem    vsharanh    07/05/11 - add new stat rqHarmonic function
Rem    demukhin    06/30/11 - chunking for serialiazed objects
Rem    dgolovas    06/28/11 - add new stat functions
Rem    paboyoun    06/27/11 - use cursor for crossproduct
Rem    paboyoun    06/24/11 - pipeline crossprod function
Rem    paboyoun    06/23/11 - refactor to new matrix framework
Rem    vsharanh    06/23/11 - changing output signature of ore_freq_*pipe
Rem                           functions
Rem    paboyoun    06/21/11 - add DBMS_STAT_FUNCS for ks tests
Rem    dgolovas    06/15/11 - add new stat functions
Rem    demukhin    05/26/11 - grouping rqEval
Rem    paboyoun    04/25/11 - add crossprod support
Rem    demukhin    04/13/11 - add rq metadata tables
Rem    vsharanh    04/07/11 - update for pipeline FREQ functions
Rem    demukhin    03/29/11 - add rqPredict
Rem    demukhin    03/26/11 - add rqRow table function
Rem    demukhin    03/17/11 - add ore_freq
Rem    demukhin    03/01/11 - add norm family
Rem    demukhin    02/25/11 - add apply support
Rem    demukhin    01/28/11 - Created
Rem

--***************************************************************************--
--*  (*) SEQUENCES                                                          *--
--***************************************************************************--

CREATE SEQUENCE rq$object_seq;
CREATE SEQUENCE rq$datastore_seq start with 1001;

--***************************************************************************--
--*  (*) TABLES                                                             *--
--***************************************************************************--

CREATE GLOBAL TEMPORARY TABLE rqForeach (
  id NUMBER)
ON COMMIT PRESERVE ROWS PARALLEL;

-- create user Meta Data Table for persistent R object
-- datastore attributes
CREATE TABLE RQ$DATASTORE (
   dsID                  NUMBER    
           CONSTRAINT pk_dsid PRIMARY KEY,   -- datastore ID
   dsowner               VARCHAR2(128),      -- schema name
   dsname                VARCHAR2(128),      -- datastore name
   cdate                 DATE,               -- datastore creation date
   description           VARCHAR2(2000),     -- datastore description
           CONSTRAINT uk_dsname UNIQUE (dsowner, dsname)  -- unique key
); 

-- R object attributes and association with datastore
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
           CONSTRAINT uk_dsobjname UNIQUE (dsID, objname)  -- unique key
);

-- relation b/w R object and referenced db objects
CREATE TABLE RQ$DATASTOREREFDBOBJECT (
   objID                NUMBER     
           CONSTRAINT fk_refdb REFERENCES RQ$DATASTOREOBJECT ON DELETE CASCADE,
   refobjname           VARCHAR2(128),
   refobjtype           VARCHAR2(128),
   refobjparm           VARCHAR2(128),
   refobjowner          VARCHAR2(128)
);

--***************************************************************************--
--*  (*) VIEWS                                                              *--
--***************************************************************************--

-- db-wide datastore info
create view RQ$DATASTORELIST AS
   select   dsowner, dsname, count(objname) as nobj, sum(objsize) as dssize,
            cdate, description
   from     RQ$DATASTORE ds, RQ$DATASTOREOBJECT obj
   where    ds.dsID = obj.dsID
   group by dsowner, dsname, cdate, description;

-- db-wide object info in each datastore
create view RQ$DATASTORESUMMARY AS
   select   dsowner, dsname, objname, class, objsize, length, nrow, ncol
   from     RQ$DATASTORE ds, RQ$DATASTOREOBJECT obj
   where    ds.dsID = obj.dsID
   order by dsowner, dsname, objname;

-- current user datastore info
create view RQUSER_DATASTORELIST AS
   select   dsname, nobj, dssize, cdate, description
   from     RQ$DATASTORELIST
   where    dsowner=(select user from dual);

-- object info in current user datastore
create view RQUSER_DATASTORECONTENTS AS
   select   dsname, objname, class, objsize, length, nrow, ncol
   from     RQ$DATASTORESUMMARY
   where    dsowner=(select user from dual);

--***************************************************************************--
--*  (*) LIBRARIES                                                          *--
--***************************************************************************--

CREATE LIBRARY rq$lib AS '&&1';
/
CREATE LIBRARY rqeLib AS '&&2';
/

--***************************************************************************--
--*  (*) OBJECT PRIVILEGES                                                  *--
--***************************************************************************--

GRANT SELECT ON rqForeach TO PUBLIC;
GRANT SELECT ON rq$object_seq TO PUBLIC;
GRANT SELECT ON rq$datastore_seq TO PUBLIC;

GRANT SELECT ON RQ$DATASTORE TO PUBLIC;
GRANT SELECT ON RQ$DATASTOREOBJECT TO PUBLIC;
GRANT SELECT ON RQ$DATASTOREREFDBOBJECT TO PUBLIC;
GRANT SELECT ON RQUSER_DATASTORELIST TO PUBLIC;
GRANT SELECT ON RQUSER_DATASTORECONTENTS TO PUBLIC;

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
--* end of file rqsys.sql                                                   *--
--***************************************************************************--
