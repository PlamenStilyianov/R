Rem
Rem Copyright (c) 2012, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqproc.sql - RQuery PROCedures, functions and packages
Rem
Rem    DESCRIPTION
Rem      RQuery procedures, functions and packages.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/26/12 - bug 14802813: init R in one place
Rem    qinwan      10/25/12 - fix bug 14808516
Rem    demukhin    10/15/12 - Created
Rem

--***************************************************************************--
--*  (*) TABLE FUNCTION: rqEval                                             *--
--***************************************************************************--

CREATE TYPE rqObject AS OBJECT (
  name  VARCHAR2(4000),
  total NUMBER,
  chunk NUMBER,
  value RAW(2000)
);
/
CREATE TYPE rqObjSet AS TABLE OF rqObject;
/

CREATE TYPE rqXMLObj AS OBJECT (
  name  VARCHAR2(4000),
  value CLOB
);
/
CREATE TYPE rqXMLSet AS TABLE OF rqXMLObj;
/

CREATE TYPE rqImgObj AS OBJECT (
  name  VARCHAR2(4000),
  id    NUMBER,
  image BLOB
);
/
CREATE TYPE rqImgSet AS TABLE OF rqImgObj;
/

---------------------------------- rqEvalImpl ---------------------------------
--
CREATE TYPE rqEvalImpl AUTHID CURRENT_USER AS OBJECT (
  typ                            SYS.AnyType,
  key                            RAW(4),

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT rqEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT rqEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT rqEvalImpl,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT rqEvalImpl,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT rqEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT rqEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           rqEvalImpl)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableClose(
    self                           rqEvalImpl)
  RETURN PLS_INTEGER
);
/
SHOW ERRORS;

CREATE TYPE BODY rqEvalImpl AS

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqEvalImpl.StubTableDescribe(typ1, par_cur, out_qry, exp_nam);
  END;

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetNilDescribe"
  WITH CONTEXT
  PARAMETERS (context, typ1, typ1 INDICATOR, par_cur, par_cur INDICATOR,
              out_qry STRING, out_qry INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT rqEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqEvalImpl.StubTablePrepare(sctx, tf_info, par_cur, out_qry,
                                       exp_nam);
  END;

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT rqEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetNilPrepare"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT,
              tf_info, tf_info INDICATOR STRUCT, par_cur, par_cur INDICATOR,
              out_qry STRING, out_qry INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT rqEvalImpl,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqEvalImpl.StubTableStart(sctx, par_cur, out_qry, exp_nam);
  END;

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT rqEvalImpl,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetNilStart"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT, par_cur, par_cur INDICATOR,
              out_qry STRING, out_qry INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT rqEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN self.StubTableFetch(nrows, rws);
  END;

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT rqEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetNilFetch"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, nrows,
              rws, rws INDICATOR, rws DURATION OCIDuration, RETURN INT);

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           rqEvalImpl)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN self.StubTableClose();
  END;

  MEMBER FUNCTION StubTableClose(
    self                           rqEvalImpl)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetNilClose"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, RETURN INT);

END;
/
SHOW ERRORS;

------------------------------------ rqEval -----------------------------------
--
CREATE FUNCTION rqEval(par_cur SYS_REFCURSOR, out_qry VARCHAR2,
                       exp_nam VARCHAR2)
RETURN SYS.AnyDataSet
PIPELINED USING rqEvalImpl;
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) TABLE FUNCTION: rqTableEval                                        *--
--***************************************************************************--

-------------------------------- rqTableEvalImpl ------------------------------
--
CREATE TYPE rqTableEvalImpl AUTHID CURRENT_USER AS OBJECT (
  typ                            SYS.AnyType,
  key                            RAW(4),

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT rqTableEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT rqTableEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT rqTableEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT rqTableEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT rqTableEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT rqTableEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           rqTableEvalImpl)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableClose(
    self                           rqTableEvalImpl)
  RETURN PLS_INTEGER
);
/
SHOW ERRORS;

CREATE TYPE BODY rqTableEvalImpl AS

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqTableEvalImpl.StubTableDescribe(typ1, inp_cur, par_cur, out_qry,
                                             exp_nam);
  END;

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetTabDescribe"
  WITH CONTEXT
  PARAMETERS (context, typ1, typ1 INDICATOR, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              exp_nam STRING, exp_nam INDICATOR, RETURN INT);

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT rqTableEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqTableEvalImpl.StubTablePrepare(sctx, tf_info, inp_cur, par_cur,
                                            out_qry, exp_nam);
  END;

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT rqTableEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetTabPrepare"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT,
              tf_info, tf_info INDICATOR STRUCT, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              exp_nam STRING, exp_nam INDICATOR, RETURN INT);

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT rqTableEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqTableEvalImpl.StubTableStart(sctx, inp_cur, par_cur, out_qry,
                                          exp_nam);
  END;

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT rqTableEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetTabStart"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              exp_nam STRING, exp_nam INDICATOR, RETURN INT);

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT rqTableEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN self.StubTableFetch(nrows, rws);
  END;

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT rqTableEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetTabFetch"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, nrows,
              rws, rws INDICATOR, rws DURATION OCIDuration, RETURN INT);

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           rqTableEvalImpl)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN self.StubTableClose();
  END;

  MEMBER FUNCTION StubTableClose(
    self                           rqTableEvalImpl)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetTabClose"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, RETURN INT);

END;
/
SHOW ERRORS;

---------------------------------- rqTableEval --------------------------------
--
CREATE FUNCTION rqTableEval(inp_cur SYS_REFCURSOR, par_cur SYS_REFCURSOR,
                            out_qry VARCHAR2, exp_nam VARCHAR2)
RETURN SYS.AnyDataSet
PIPELINED USING rqTableEvalImpl;
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) TABLE FUNCTION: rqGroupEval                                        *--
--***************************************************************************--

-------------------------------- rqGroupEvalImpl ------------------------------
--
CREATE TYPE rqGroupEvalImpl AUTHID CURRENT_USER AS OBJECT (
  typ                            SYS.AnyType,
  key                            RAW(4),

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT rqGroupEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT rqGroupEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT rqGroupEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT rqGroupEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT rqGroupEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT rqGroupEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           rqGroupEvalImpl)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableClose(
    self                           rqGroupEvalImpl)
  RETURN PLS_INTEGER
);
/
SHOW ERRORS;

CREATE TYPE BODY rqGroupEvalImpl AS

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqGroupEvalImpl.StubTableDescribe(typ1, inp_cur, par_cur, out_qry,
                                             grp_col, exp_nam);
  END;

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetGrpDescribe"
  WITH CONTEXT
  PARAMETERS (context, typ1, typ1 INDICATOR, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              grp_col STRING, grp_col INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT rqGroupEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqGroupEvalImpl.StubTablePrepare(sctx, tf_info, inp_cur, par_cur,
                                            out_qry, grp_col, exp_nam);
  END;

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT rqGroupEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetGrpPrepare"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT,
              tf_info, tf_info INDICATOR STRUCT, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              grp_col STRING, grp_col INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT rqGroupEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqGroupEvalImpl.StubTableStart(sctx, inp_cur, par_cur, out_qry,
                                          grp_col, exp_nam);
  END;

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT rqGroupEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    grp_col                        VARCHAR2,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetGrpStart"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              grp_col STRING, grp_col INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT rqGroupEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN self.StubTableFetch(nrows, rws);
  END;

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT rqGroupEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetGrpFetch"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, nrows,
              rws, rws INDICATOR, rws DURATION OCIDuration, RETURN INT);

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           rqGroupEvalImpl)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN self.StubTableClose();
  END;

  MEMBER FUNCTION StubTableClose(
    self                           rqGroupEvalImpl)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetGrpClose"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, RETURN INT);

END;
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) TABLE FUNCTION: rqRowEval                                          *--
--***************************************************************************--

--------------------------------- rqRowEvalImpl -------------------------------
--
CREATE TYPE rqRowEvalImpl AUTHID CURRENT_USER AS OBJECT (
  typ                            SYS.AnyType,
  key                            RAW(4),

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT rqRowEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT rqRowEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT rqRowEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT rqRowEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER,

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT rqRowEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT rqRowEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER,

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           rqRowEvalImpl)
  RETURN PLS_INTEGER,

  MEMBER FUNCTION StubTableClose(
    self                           rqRowEvalImpl)
  RETURN PLS_INTEGER
);
/
SHOW ERRORS;

CREATE TYPE BODY rqRowEvalImpl AS

  -- ODCITableDescribe --------------------------------------------------------
  --
  STATIC FUNCTION ODCITableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqRowEvalImpl.StubTableDescribe(typ1, inp_cur, par_cur, out_qry,
                                           row_num, exp_nam);
  END;

  STATIC FUNCTION StubTableDescribe(
    typ1                           OUT SYS.AnyType,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetRowDescribe"
  WITH CONTEXT
  PARAMETERS (context, typ1, typ1 INDICATOR, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              row_num OCINUMBER, row_num INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITablePrepare ---------------------------------------------------------
  --
  STATIC FUNCTION ODCITablePrepare(
    sctx                           OUT rqRowEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqRowEvalImpl.StubTablePrepare(sctx, tf_info, inp_cur, par_cur,
                                          out_qry, row_num, exp_nam);
  END;

  STATIC FUNCTION StubTablePrepare(
    sctx                           OUT rqRowEvalImpl,
    tf_info                        SYS.ODCITabFuncInfo,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetRowPrepare"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT,
              tf_info, tf_info INDICATOR STRUCT, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              row_num OCINUMBER, row_num INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(
    sctx                           IN OUT rqRowEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN rqRowEvalImpl.StubTableStart(sctx, inp_cur, par_cur, out_qry,
                                        row_num, exp_nam);
  END;

  STATIC FUNCTION StubTableStart(
    sctx                           IN OUT rqRowEvalImpl,
    inp_cur                        SYS_REFCURSOR,
    par_cur                        SYS_REFCURSOR,
    out_qry                        VARCHAR2,
    row_num                        NUMBER,
    exp_nam                        VARCHAR2)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetRowStart"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT, inp_cur, inp_cur INDICATOR,
              par_cur, par_cur INDICATOR, out_qry STRING, out_qry INDICATOR,
              row_num OCINUMBER, row_num INDICATOR, exp_nam STRING,
              exp_nam INDICATOR, RETURN INT);

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(
    self                           IN OUT rqRowEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN self.StubTableFetch(nrows, rws);
  END;

  MEMBER FUNCTION StubTableFetch(
    self                           IN OUT rqRowEvalImpl,
    nrows                          NUMBER,
    rws                            OUT SYS.AnyDataSet)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetRowFetch"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, nrows,
              rws, rws INDICATOR, rws DURATION OCIDuration, RETURN INT);

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(
    self                           rqRowEvalImpl)
  RETURN PLS_INTEGER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    RETURN self.StubTableClose();
  END;

  MEMBER FUNCTION StubTableClose(
    self                           rqRowEvalImpl)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rqeLib
  NAME "rqetRowClose"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, RETURN INT);

END;
/
SHOW ERRORS;

----------------------------------- rqRowEval ---------------------------------
--
CREATE FUNCTION rqRowEval(inp_cur SYS_REFCURSOR, par_cur SYS_REFCURSOR,
                          out_qry VARCHAR2, row_num NUMBER, exp_nam VARCHAR2)
RETURN SYS.AnyDataSet
PIPELINED PARALLEL_ENABLE (PARTITION inp_cur BY ANY) USING rqRowEvalImpl;
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) TABLE FUNCTION: rqCrossprod                                        *--
--***************************************************************************--

CREATE TYPE rqNumericElt AS OBJECT (
  name NUMBER, 
  val  NUMBER
);
/
CREATE TYPE rqNumericEltSet AS TABLE OF rqNumericElt;
/

-------------------------------- rqCrossprodImpl ------------------------------
--
CREATE TYPE rqCrossprodImpl AS OBJECT (
  key                            RAW(4),

  -- ODCITableStart -----------------------------------------------------------
  --
  STATIC FUNCTION ODCITableStart(sctx    OUT    rqCrossprodImpl,
                                 p_cur          SYS_REFCURSOR,
                                 p_ncolb        PLS_INTEGER)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rq$lib
  NAME "rqCrossprodTableStart"
  WITH CONTEXT
  PARAMETERS (context, sctx, sctx INDICATOR STRUCT, p_cur, p_ncolb,
              RETURN INT),

  -- ODCITableFetch -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableFetch(self    IN OUT rqCrossprodImpl,
                                 nrows          NUMBER,
                                 rws     OUT    rqNumericEltSet)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rq$lib
  NAME "rqCrossprodTableFetch"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, nrows,
              rws, rws INDICATOR, RETURN INT),

  -- ODCITableClose -----------------------------------------------------------
  --
  MEMBER FUNCTION ODCITableClose(self           rqCrossprodImpl)
  RETURN PLS_INTEGER
  AS LANGUAGE C
  LIBRARY rq$lib
  NAME "rqCrossprodTableClose"
  WITH CONTEXT
  PARAMETERS (context, self, self INDICATOR STRUCT, RETURN INT)
);
/
SHOW ERRORS;

------------------------------- rqCrossprod -----------------------------------
--
CREATE FUNCTION rqCrossprod(p_cur SYS_REFCURSOR, p_ncolb PLS_INTEGER)
RETURN rqNumericEltSet
PIPELINED PARALLEL_ENABLE (PARTITION p_cur BY ANY) USING rqCrossprodImpl;
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) TABLE FUNCTION: rqStepwise                                         *--
--***************************************************************************--

CREATE TYPE rqStepwiseType AS OBJECT (
    layer         NUMBER,
    name          NUMBER,
    estimate      NUMBER,
    column_ok     NUMBER,
    std_error     NUMBER,
    t_value       NUMBER,
    prob_t        NUMBER
);
/
CREATE TYPE rqStepwiseTypeSet AS TABLE OF rqStepwiseType;
/

-------------------------------- rqStepwiseImpl -------------------------------
--
CREATE TYPE rqStepwiseImpl AUTHID CURRENT_USER AS OBJECT (
    key RAW(4),

    STATIC FUNCTION ODCITableStart(
        sctx            OUT RqStepwiseImpl,
        cur             SYS_REFCURSOR,
        colStatus       VARCHAR2,
        maxSteps        PLS_INTEGER,
        direction       PLS_INTEGER,
        bestKModels     PLS_INTEGER,
        enterThreshold  DOUBLE PRECISION,
        leaveThreshold  DOUBLE PRECISION)
    RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY rq$lib
    NAME "rqStepwiseTableStart"
    WITH CONTEXT
    PARAMETERS (context, sctx, sctx INDICATOR STRUCT, cur, colStatus, maxSteps,
        direction, bestKModels, enterThreshold, leaveThreshold, RETURN INT),

    MEMBER FUNCTION ODCITableFetch(
        self            IN OUT RqStepwiseImpl,
        nrows           NUMBER,
        outSet          OUT RqStepwiseTypeSet)
    RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY rq$lib
    NAME "rqStepwiseTableFetch"
    WITH CONTEXT
    PARAMETERS (context, self, self INDICATOR STRUCT, nrows, outSet, outSet
        INDICATOR, RETURN INT),

    MEMBER FUNCTION ODCITableClose(self IN RqStepwiseImpl)
    RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY rq$lib
    NAME "rqStepwiseTableClose"
    WITH CONTEXT
    PARAMETERS (context, self, self INDICATOR STRUCT, RETURN INT)
);
/
SHOW ERRORS

-------------------------------- rqStepwise -----------------------------------
--
CREATE FUNCTION rqStepwise(
    cur                 SYS_REFCURSOR,
    colStatus           VARCHAR2,
    maxSteps            PLS_INTEGER,
    direction           PLS_INTEGER,
    bestKModels         PLS_INTEGER,
    enterThreshold      DOUBLE PRECISION,
    leaveThreshold      DOUBLE PRECISION)
RETURN RqStepwiseTypeSet
PIPELINED USING rqStepwiseImpl;
/
SHOW ERRORS;

--***************************************************************************--
-- Neural Network package                                                   *--
--***************************************************************************--
CREATE TYPE rqNeuralType AS OBJECT (
    neuralIndex NUMBER,
    neuralValue NUMBER
);
/
SHOW ERRORS;

CREATE TYPE rqNeuralTypeSet AS TABLE OF rqNeuralType;
/
SHOW ERRORS;

CREATE TYPE rqNeuralImpl AUTHID CURRENT_USER AS OBJECT (
    key RAW(4),

    STATIC FUNCTION ODCITableStart(
        sctx            OUT RqNeuralImpl,
        cur             SYS_REFCURSOR,
        inputSize       PLS_INTEGER,
        hiddenSize      PLS_INTEGER,
        outputSize      PLS_INTEGER,
        relTolerance    DOUBLE PRECISION)
    RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY rq$lib
    NAME "rqNeuralTableStart"
    WITH CONTEXT
    PARAMETERS (context, sctx, sctx INDICATOR STRUCT, cur,
        inputSize, hiddenSize, outputSize, relTolerance,
        RETURN INT),

    MEMBER FUNCTION ODCITableFetch(
        self            IN OUT RqNeuralImpl,
        nrows           NUMBER,
        outSet          OUT RqNeuralTypeSet)
    RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY rq$lib
    NAME "rqNeuralTableFetch"
    WITH CONTEXT
    PARAMETERS (context, self, self INDICATOR STRUCT, nrows, outSet, outSet
        INDICATOR, RETURN INT),

    MEMBER FUNCTION ODCITableClose(self IN RqNeuralImpl)
    RETURN PLS_INTEGER
    AS LANGUAGE C
    LIBRARY rq$lib
    NAME "rqNeuralTableClose"
    WITH CONTEXT
    PARAMETERS (context, self, self INDICATOR STRUCT, RETURN INT)
);
/
SHOW ERRORS

CREATE FUNCTION rqNeural(
    cur             SYS_REFCURSOR,
    inputSize       PLS_INTEGER,
    hiddenSize      PLS_INTEGER,
    outputSize      PLS_INTEGER,
    relTolerance    DOUBLE PRECISION)
RETURN RqNeuralTypeSet
PIPELINED USING rqNeuralImpl;
/
SHOW ERRORS;
--***************************************************************************--

--***************************************************************************--
--*  (*) TABLE FUNCTION: rqUnlistTable                                      *--
--***************************************************************************--

CREATE FUNCTION rqUnlistTable(
  dataQry   IN  CLOB,                    -- data query
  nrow      IN  PLS_INTEGER,             -- matrix e1 number of rows
  ncol      IN  PLS_INTEGER,             -- matrix e1 number of columns
  maxfetch  IN  PLS_INTEGER DEFAULT 500  -- max number of rows to bulk fetch
)
RETURN rqNumericEltSet
PIPELINED
AUTHID CURRENT_USER
IS
  vcursor     PLS_INTEGER;                -- cursor
  numtab      DBMS_SQL.NUMBER_TABLE;      -- number table
  totfetch    PLS_INTEGER;                -- total number of rows fetched
  nfetch      PLS_INTEGER;                -- number of rows fetched
  fetchlim    PLS_INTEGER;                -- max number of rows to bulk fetch
  idx         PLS_INTEGER;                -- array index
  rowout      rqNumericElt := rqNumericElt(NULL, NULL);
BEGIN
  IF (nrow < maxfetch) THEN
    fetchlim := nrow;
  ELSE
    fetchlim := maxfetch;
  END IF;

  -- Use DBMS_SQL for reading data
  -- Open cursor
  vcursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(vcursor, dataQry, DBMS_SQL.NATIVE);
  nfetch := DBMS_SQL.EXECUTE(vcursor);

  -- Define array types for each column
  FOR j IN 1..ncol LOOP
    DBMS_SQL.DEFINE_ARRAY(vcursor, j, numtab, fetchlim, 1);
  END LOOP;

  totfetch := 0;
  LOOP
    nfetch := DBMS_SQL.FETCH_ROWS(vcursor);
    EXIT WHEN nfetch = 0;
    FOR j in 1..ncol LOOP
      DBMS_SQL.COLUMN_VALUE(vcursor, j, numtab);
      FOR i in 1..nfetch LOOP
        idx := i + totfetch;
        rowout.name := idx + (j - 1) * nrow;
        rowout.val  := numtab(idx);
        PIPE ROW(rowout);
      END LOOP;
    END LOOP;
    totfetch := totfetch + nfetch;
    EXIT WHEN totfetch = nrow;
  END LOOP;

  -- Close cursor
  DBMS_SQL.CLOSE_CURSOR(vcursor);

  RETURN;

EXCEPTION WHEN OTHERS THEN
  -- Close cursor, if open
  IF DBMS_SQL.IS_OPEN(vcursor) THEN
    DBMS_SQL.CLOSE_CURSOR(vcursor);
  END IF;
  RAISE;
  RETURN;

END rqUnlistTable;
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) FUNCTIONS: rqRFuncEval family                                      *--
--***************************************************************************--

CREATE TYPE RQ_ELEM_T AS OBJECT (
  NAME    VARCHAR2(4000), 
  NUMVAL  BINARY_DOUBLE,
  STRVAL  VARCHAR2(4000)
);
/
CREATE TYPE RQ_PARAM_T AS TABLE OF RQ_ELEM_T;
/
                  
-------------------------------- rqRFuncEvalNum -------------------------------
--
CREATE FUNCTION rqRFuncEvalNum(exp_nam VARCHAR2, paramlst RQ_PARAM_T)
RETURN BINARY_DOUBLE 
AUTHID CURRENT_USER
AS LANGUAGE C
LIBRARY rqeLib
NAME "rqFuncEvalReal"
WITH CONTEXT
PARAMETERS (context, exp_nam, exp_nam INDICATOR, paramlst, paramlst INDICATOR,
            RETURN BY REFERENCE);
/
SHOW ERRORS

-------------------------------- rqRFuncEvalChr -------------------------------
--
CREATE FUNCTION rqRFuncEvalChr(exp_nam VARCHAR2, paramlst RQ_PARAM_T)
RETURN VARCHAR2
AUTHID CURRENT_USER 
AS LANGUAGE C
LIBRARY rqeLib
NAME "rqFuncEvalStr"
WITH CONTEXT
PARAMETERS (context, exp_nam, exp_nam INDICATOR, paramlst, paramlst INDICATOR);
/
SHOW ERRORS

--***************************************************************************--
--*  (*) FUNCTIONS: Math                                                    *--
--***************************************************************************--

---------------------------------- rqBesselI ----------------------------------
--
CREATE FUNCTION rqBesselI(
  x    DOUBLE PRECISION,
  nu   DOUBLE PRECISION,
  exp  DOUBLE PRECISION)
RETURN DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rqeLib
NAME "rqefBesselI"
WITH CONTEXT
PARAMETERS (CONTEXT, x DOUBLE, x INDICATOR SHORT, nu DOUBLE,
            nu INDICATOR SHORT, exp DOUBLE, exp INDICATOR SHORT,
            RETURN INDICATOR BY REFERENCE SHORT, RETURN DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqBesselK ----------------------------------
--
CREATE FUNCTION rqBesselK(
  x    DOUBLE PRECISION,
  nu   DOUBLE PRECISION,
  exp  DOUBLE PRECISION)
RETURN DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rqeLib
NAME "rqefBesselK"
WITH CONTEXT
PARAMETERS (CONTEXT, x DOUBLE, x INDICATOR SHORT, nu DOUBLE,
            nu INDICATOR SHORT, exp DOUBLE, exp INDICATOR SHORT,
            RETURN INDICATOR BY REFERENCE SHORT, RETURN DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqBesselJ ----------------------------------
--
CREATE FUNCTION rqBesselJ(
  x   DOUBLE PRECISION,
  nu  DOUBLE PRECISION)
RETURN DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rqeLib
NAME "rqefBesselJ"
WITH CONTEXT
PARAMETERS (CONTEXT, x DOUBLE, x INDICATOR SHORT, nu DOUBLE,
            nu INDICATOR SHORT, RETURN INDICATOR BY REFERENCE SHORT,
            RETURN DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqBesselY ----------------------------------
--
CREATE FUNCTION rqBesselY(
  x   DOUBLE PRECISION,
  nu  DOUBLE PRECISION)
RETURN DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rqeLib
NAME "rqefBesselY"
WITH CONTEXT
PARAMETERS (CONTEXT, x DOUBLE, x INDICATOR SHORT, nu DOUBLE,
            nu INDICATOR SHORT, RETURN INDICATOR BY REFERENCE SHORT,
            RETURN DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqGamma -----------------------------------
--
CREATE FUNCTION rqGamma(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_gamma"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqLgamma ----------------------------------
--
CREATE FUNCTION rqLgamma(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_lgamma"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqDigamma ---------------------------------
--
CREATE FUNCTION rqDigamma(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_digamma"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqTrigamma ---------------------------------
--
CREATE FUNCTION rqTrigamma(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_trigamma"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqErf ------------------------------------
--
CREATE FUNCTION rqErf(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_erf"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqErfc -----------------------------------
--
CREATE FUNCTION rqErfc(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_erfc"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqDbeta ----------------------------------
--
CREATE FUNCTION rqDbeta(
    a           DOUBLE PRECISION,
    b           DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_beta"
PARAMETERS (
    a           DOUBLE,
    a           INDICATOR SHORT,
    b           DOUBLE,
    b           INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;
----------------------------------- rqPbeta -----------------------------------
--
CREATE FUNCTION rqPbeta(
    a           DOUBLE PRECISION,
    b           DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_beta"
PARAMETERS (
    a           DOUBLE,
    a           INDICATOR SHORT,
    b           DOUBLE,
    b           INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqQbeta -----------------------------------
--
CREATE FUNCTION rqQbeta(
    a           DOUBLE PRECISION,
    b           DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_beta"
PARAMETERS (
    a           DOUBLE,
    a           INDICATOR SHORT,
    b           DOUBLE,
    b           INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqDbinom ----------------------------------
--
CREATE FUNCTION rqDbinom(
    n           DOUBLE PRECISION,
    prob        DOUBLE PRECISION,
    logP        PLS_INTEGER,
    k           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_binomial"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    prob        DOUBLE,
    prob        INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    k           DOUBLE,
    k           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqPbinom ----------------------------------
--
CREATE FUNCTION rqPbinom(
    n           DOUBLE PRECISION,
    prob        DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    k           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_binomial"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    prob        DOUBLE,
    prob        INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    k           DOUBLE,
    k           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqQbinom ----------------------------------
--
CREATE FUNCTION rqQbinom(
    n           DOUBLE PRECISION,
    prob        DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    p           DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_binomial"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    prob        DOUBLE,
    prob        INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    p           DOUBLE,
    p           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqQcauchy ----------------------------------
--
CREATE FUNCTION rqQcauchy(
    x       DOUBLE PRECISION,
    loc     DOUBLE PRECISION,
    scale   DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_cauchy"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    loc     DOUBLE,
    loc     INDICATOR SHORT,
    scale   DOUBLE,
    scale   INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqPcauchy ----------------------------------
--
CREATE FUNCTION rqPcauchy(
    x       DOUBLE PRECISION,
    loc     DOUBLE PRECISION,
    scale   DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_cauchy"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    loc     DOUBLE,
    loc     INDICATOR SHORT,
    scale   DOUBLE,
    scale   INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqDchisq ----------------------------------
--
CREATE FUNCTION rqDchisq(
    df          DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_chi_square"
PARAMETERS (
    df          DOUBLE,
    df          INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqPchisq ----------------------------------
--
CREATE FUNCTION rqPchisq(
    df          DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_chi_square"
PARAMETERS (
    df          DOUBLE,
    df          INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqQchisq ----------------------------------
--
CREATE FUNCTION rqQchisq(
    df          DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_chi_square"
PARAMETERS (
    df          DOUBLE,
    df          INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqPexp -----------------------------------
--
CREATE FUNCTION rqPexp(
    lambda  DOUBLE PRECISION,
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_exponential"
PARAMETERS (
    lambda  DOUBLE,
    lambda  INDICATOR SHORT,
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqQexp -----------------------------------
--
CREATE FUNCTION rqQexp(
    lambda  DOUBLE PRECISION,
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_exponential"
PARAMETERS (
    lambda  DOUBLE,
    lambda  INDICATOR SHORT,
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

------------------------------------- rqDf ------------------------------------
--
CREATE FUNCTION rqDf(
    df1         DOUBLE PRECISION,
    df2         DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_f"
PARAMETERS (
    df1         DOUBLE,
    df1         INDICATOR SHORT,
    df2         DOUBLE,
    df2         INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

------------------------------------- rqPf ------------------------------------
--
CREATE FUNCTION rqPf(
    df1         DOUBLE PRECISION,
    df2         DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_f"
PARAMETERS (
    df1         DOUBLE,
    df1         INDICATOR SHORT,
    df2         DOUBLE,
    df2         INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqQf -------------------------------------
--
CREATE FUNCTION rqQf(
    df1         DOUBLE PRECISION,
    df2         DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_f"
PARAMETERS (
    df1         DOUBLE,
    df1         INDICATOR SHORT,
    df2         DOUBLE,
    df2         INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqDgamma ----------------------------------
--
CREATE FUNCTION rqDgamma(
    a           DOUBLE PRECISION,
    b           DOUBLE PRECISION,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_gamma"
PARAMETERS (
    a           DOUBLE,
    a           INDICATOR SHORT,
    b           DOUBLE,
    b           INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqQgamma ----------------------------------
--
CREATE FUNCTION rqQgamma(
    a           DOUBLE PRECISION,
    b           DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_gamma"
PARAMETERS (
    a           DOUBLE,
    a           INDICATOR SHORT,
    b           DOUBLE,
    b           INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqPgamma ----------------------------------
--
CREATE FUNCTION rqPgamma(
    a           DOUBLE PRECISION,
    b           DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_gamma"
PARAMETERS (
    a           DOUBLE,
    a           INDICATOR SHORT,
    b           DOUBLE,
    b           INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqDnbinom ---------------------------------
--
CREATE FUNCTION rqDnbinom(
    n           DOUBLE PRECISION,
    prob        DOUBLE PRECISION,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_nbinom"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    prob        DOUBLE,
    prob        INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqPnbinom ---------------------------------
--
CREATE FUNCTION rqPnbinom(
    n           DOUBLE PRECISION,
    prob        DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_nbinom"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    prob        DOUBLE,
    prob        INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqQnbinom ---------------------------------
--
CREATE FUNCTION rqQnbinom(
    n           DOUBLE PRECISION,
    prob        DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_nbinom"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    prob        DOUBLE,
    prob        INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqPnorm -----------------------------------
--
CREATE FUNCTION rqPnorm(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_normal"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqQnorm -----------------------------------
--
CREATE FUNCTION rqQnorm(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_normal"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqDpois ----------------------------------
--
CREATE FUNCTION rqDpois(
    lambda      DOUBLE PRECISION,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_poisson"
PARAMETERS (
    lambda      DOUBLE,
    lambda      INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqPpois -----------------------------------
--
CREATE FUNCTION rqPpois(
    lambda      DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           PLS_INTEGER)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_poisson"
PARAMETERS (
    lambda      DOUBLE,
    lambda      INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           INT,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqQpois ----------------------------------
--
CREATE FUNCTION rqQpois(
    lambda      DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_poisson"
PARAMETERS (
    lambda      DOUBLE,
    lambda      INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

------------------------------------- rqQt ------------------------------------
--
CREATE FUNCTION rqQt(
    df          DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_student"
PARAMETERS (
    df          DOUBLE,
    df          INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

------------------------------------- rqPt ------------------------------------
--
CREATE FUNCTION rqPt(
    df          DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_student"
PARAMETERS (
    df          DOUBLE,
    df          INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqPweibull ---------------------------------
--
CREATE FUNCTION rqPweibull(
    shape   DOUBLE PRECISION,
    scale   DOUBLE PRECISION,
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_weibull"
PARAMETERS (
    shape   DOUBLE,
    shape   INDICATOR SHORT,
    scale   DOUBLE,
    scale   INDICATOR SHORT,
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqQweibull ---------------------------------
--
CREATE FUNCTION rqQweibull(
    shape   DOUBLE PRECISION,
    scale   DOUBLE PRECISION,
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_weibull"
PARAMETERS (
    shape   DOUBLE,
    shape   INDICATOR SHORT,
    scale   DOUBLE,
    scale   INDICATOR SHORT,
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqDweibull ---------------------------------
--
CREATE FUNCTION rqDweibull(
    shape   DOUBLE PRECISION,
    scale   DOUBLE PRECISION,
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_weibull"
PARAMETERS (
    shape   DOUBLE,
    shape   INDICATOR SHORT,
    scale   DOUBLE,
    scale   INDICATOR SHORT,
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqHarmonic ---------------------------------
--
CREATE FUNCTION rqHarmonic(
  n IN PLS_INTEGER)
RETURN DOUBLE PRECISION AS
  LANGUAGE C
  LIBRARY rq$lib
  NAME "rqHarmonic"
  PARAMETERS (
    n LONG,
    n INDICATOR SHORT,
    RETURN INDICATOR SHORT,
    RETURN DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqSignP ------------------------------------
--
CREATE FUNCTION rqSignP(
  np IN PLS_INTEGER,
  nn IN PLS_INTEGER)
RETURN DOUBLE PRECISION AS
  LANGUAGE C
  LIBRARY rq$lib
  NAME "rqSignP"
  PARAMETERS (
    np LONG,
    np INDICATOR SHORT,
    nn LONG,
    nn INDICATOR SHORT,
    RETURN INDICATOR SHORT,
    RETURN DOUBLE);
/
SHOW ERRORS;

---------------------------------- rqCvmP -------------------------------------
--
CREATE FUNCTION rqCvmP(
  w IN DOUBLE PRECISION,
  n IN PLS_INTEGER)
RETURN DOUBLE PRECISION AS
  LANGUAGE C
  LIBRARY rq$lib
  NAME "rqCvmP"
  PARAMETERS (
    w DOUBLE,
    w INDICATOR SHORT,
    n LONG,
    n INDICATOR SHORT,
    RETURN INDICATOR SHORT,
    RETURN DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqDcauchy ---------------------------------
--
CREATE FUNCTION rqDcauchy(
    x       DOUBLE PRECISION,
    loc     DOUBLE PRECISION,
    scale   DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_cauchy"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    loc     DOUBLE,
    loc     INDICATOR SHORT,
    scale   DOUBLE,
    scale   INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

------------------------------------- rqDt ------------------------------------
--
CREATE FUNCTION rqDt(
    df          DOUBLE PRECISION,
    ncp         DOUBLE PRECISION,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_student"
PARAMETERS (
    df          DOUBLE,
    df          INDICATOR SHORT,
    ncp         DOUBLE,
    ncp         INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

----------------------------------- rqDnorm -----------------------------------
--
CREATE FUNCTION rqDnorm(
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_normal"
PARAMETERS (
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

------------------------------------ rqDexp -----------------------------------
--
CREATE FUNCTION rqDexp(
    lambda  DOUBLE PRECISION,
    x       DOUBLE PRECISION)
RETURN      DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_exponential"
PARAMETERS (
    lambda  DOUBLE,
    lambda  INDICATOR SHORT,
    x       DOUBLE,
    x       INDICATOR SHORT,
    RETURN  INDICATOR SHORT,
    RETURN  DOUBLE);
/
SHOW ERRORS;

--------------------------------- rqDsignrank ---------------------------------
--
CREATE FUNCTION rqDsignrank(
    n           DOUBLE PRECISION,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_pdf_signrank"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

-------------------------------- rqPsignrank ----------------------------------
--
CREATE FUNCTION rqPsignrank(
    n           DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_prob_signrank"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

-------------------------------- rqQsignrank ----------------------------------
--
CREATE FUNCTION rqQsignrank(
    n           DOUBLE PRECISION,
    lowerTail   PLS_INTEGER,
    logP        PLS_INTEGER,
    x           DOUBLE PRECISION)
RETURN          DOUBLE PRECISION
AS LANGUAGE C
LIBRARY rq$lib
NAME "rqss_quantile_signrank"
PARAMETERS (
    n           DOUBLE,
    n           INDICATOR SHORT,
    lowerTail   INT,
    lowerTail   INDICATOR SHORT,
    logP        INT,
    logP        INDICATOR SHORT,
    x           DOUBLE,
    x           INDICATOR SHORT,
    RETURN      INDICATOR SHORT,
    RETURN      DOUBLE);
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) FUNCTIONS: Kolmogorov-Smirnov                                      *--
--***************************************************************************--

-- EXPONENTIAL DISTRIBUTION ---------------------------------------------------
--
CREATE FUNCTION rqKstestPexp(
  ownername  IN VARCHAR2,
  tablename  IN VARCHAR2,
  columnname IN VARCHAR2,
  rate       IN NUMBER
)
RETURN rqNumericEltSet
AUTHID CURRENT_USER
IS
  lambda    NUMBER;
  mu        NUMBER;
  d         NUMBER;
  sig       NUMBER;
  line      VARCHAR2(255);
  status    INTEGER;
  output    rqNumericEltSet;
BEGIN
  lambda := rate;
  mu     := 0;
  DBMS_OUTPUT.ENABLE(1000000);
  DBMS_STAT_FUNCS.EXPONENTIAL_DIST_FIT (
    ownername  => DBMS_ASSERT.ENQUOTE_NAME(ownername, FALSE),
    tablename  => DBMS_ASSERT.ENQUOTE_NAME(tablename, FALSE),
    columnname => DBMS_ASSERT.ENQUOTE_NAME(columnname, FALSE),
    test_type  => 'KOLMOGOROV_SMIRNOV',
    lambda     => lambda,
    mu         => mu,
    sig        => sig);
  DBMS_OUTPUT.GET_LINE(line, status);
  DBMS_OUTPUT.DISABLE;
  d := TO_NUMBER(SUBSTR(line, 11));

  output := rqNumericEltSet();
  output.EXTEND(2);
  output(1) := rqNumericElt(1, d);
  output(2) := rqNumericElt(2, sig);

  RETURN output;
END rqKstestPexp;
/
SHOW ERRORS;

-- NORMAL DISTRIBUTION --------------------------------------------------------
--
CREATE FUNCTION rqKstestPnorm(
  ownername  IN VARCHAR2,
  tablename  IN VARCHAR2,
  columnname IN VARCHAR2,
  mean       IN NUMBER,
  sd         IN NUMBER
)
RETURN rqNumericEltSet
AUTHID CURRENT_USER
IS
  meann     NUMBER;
  stdev     NUMBER;
  d         NUMBER;
  sig       NUMBER;
  line      VARCHAR2(255);
  status    INTEGER;
  output    rqNumericEltSet;
BEGIN
  meann := mean;
  stdev := sd;
  DBMS_OUTPUT.ENABLE(1000000);
  DBMS_STAT_FUNCS.NORMAL_DIST_FIT (
    ownername  => DBMS_ASSERT.ENQUOTE_NAME(ownername, FALSE),
    tablename  => DBMS_ASSERT.ENQUOTE_NAME(tablename, FALSE),
    columnname => DBMS_ASSERT.ENQUOTE_NAME(columnname, FALSE),
    test_type  => 'KOLMOGOROV_SMIRNOV',
    mean       => meann,
    stdev      => stdev,
    sig        => sig);
  DBMS_OUTPUT.GET_LINE(line, status);
  DBMS_OUTPUT.DISABLE;
  d := TO_NUMBER(SUBSTR(line, 11));

  output := rqNumericEltSet();
  output.EXTEND(2);
  output(1) := rqNumericElt(1, d);
  output(2) := rqNumericElt(2, sig);

  RETURN output;
END rqKstestPnorm;
/
SHOW ERRORS;

-- POISSON DISTRIBUTION -------------------------------------------------------
--
CREATE FUNCTION rqKstestPpois(
  ownername  IN VARCHAR2,
  tablename  IN VARCHAR2,
  columnname IN VARCHAR2,
  lambda     IN NUMBER
)
RETURN rqNumericEltSet
AUTHID CURRENT_USER
IS
  lambdaa   NUMBER;
  d         NUMBER;
  sig       NUMBER;
  line      VARCHAR2(255);
  status    INTEGER;
  output    rqNumericEltSet;
BEGIN
  lambdaa := lambda;
  DBMS_OUTPUT.ENABLE(1000000);
  DBMS_STAT_FUNCS.POISSON_DIST_FIT (
    ownername  => DBMS_ASSERT.ENQUOTE_NAME(ownername, FALSE),
    tablename  => DBMS_ASSERT.ENQUOTE_NAME(tablename, FALSE),
    columnname => DBMS_ASSERT.ENQUOTE_NAME(columnname, FALSE),
    test_type  => 'KOLMOGOROV_SMIRNOV',
    lambda     => lambdaa,
    sig        => sig);
  DBMS_OUTPUT.GET_LINE(line, status);
  DBMS_OUTPUT.DISABLE;
  d := TO_NUMBER(SUBSTR(line, 11));

  output := rqNumericEltSet();
  output.EXTEND(2);
  output(1) := rqNumericElt(1, d);
  output(2) := rqNumericElt(2, sig);

  RETURN output;
END rqKstestPpois;
/
SHOW ERRORS;

-- UNIFORM DISTRIBUTION -------------------------------------------------------
--
CREATE FUNCTION rqKstestPunif(
  ownername  IN VARCHAR2,
  tablename  IN VARCHAR2,
  columnname IN VARCHAR2,
  minx       IN NUMBER,
  maxx       IN NUMBER
)
RETURN rqNumericEltSet
AUTHID CURRENT_USER
IS
  paramA    NUMBER;
  paramB    NUMBER;
  d         NUMBER;
  sig       NUMBER;
  line      VARCHAR2(255);
  status    INTEGER;
  output    rqNumericEltSet;
BEGIN
  paramA := minx;
  paramB := maxx;
  DBMS_OUTPUT.ENABLE(1000000);
  DBMS_STAT_FUNCS.UNIFORM_DIST_FIT (
    ownername  => DBMS_ASSERT.ENQUOTE_NAME(ownername, FALSE),
    tablename  => DBMS_ASSERT.ENQUOTE_NAME(tablename, FALSE),
    columnname => DBMS_ASSERT.ENQUOTE_NAME(columnname, FALSE),
    var_type   => 'CONTINUOUS',
    test_type  => 'KOLMOGOROV_SMIRNOV',
    paramA     => paramA,
    paramB     => paramB,
    sig        => sig);
  DBMS_OUTPUT.GET_LINE(line, status);
  DBMS_OUTPUT.DISABLE;
  d := TO_NUMBER(SUBSTR(line, 11));

  output := rqNumericEltSet();
  output.EXTEND(2);
  output(1) := rqNumericElt(1, d);
  output(2) := rqNumericElt(2, sig);

  RETURN output;
END rqKstestPunif;
/
SHOW ERRORS;

-- WEIBULL DISTRIBUTION -------------------------------------------------------
--
CREATE FUNCTION rqKstestPweibull(
  ownername  IN VARCHAR2,
  tablename  IN VARCHAR2,
  columnname IN VARCHAR2,
  shape      IN NUMBER,
  scale      IN NUMBER
)
RETURN rqNumericEltSet
AUTHID CURRENT_USER
IS
  alpha     NUMBER;
  mu        NUMBER;
  beta      NUMBER;
  d         NUMBER;
  sig       NUMBER;
  line      VARCHAR2(255);
  status    INTEGER;
  output    rqNumericEltSet;
BEGIN
  alpha := scale;
  mu    := 0;
  beta  := shape;
  DBMS_OUTPUT.ENABLE(1000000);
  DBMS_STAT_FUNCS.WEIBULL_DIST_FIT (
    ownername  => DBMS_ASSERT.ENQUOTE_NAME(ownername, FALSE),
    tablename  => DBMS_ASSERT.ENQUOTE_NAME(tablename, FALSE),
    columnname => DBMS_ASSERT.ENQUOTE_NAME(columnname, FALSE),
    test_type  => 'KOLMOGOROV_SMIRNOV',
    alpha      => alpha,
    mu         => mu,
    beta       => beta,
    sig        => sig);
  DBMS_OUTPUT.GET_LINE(line, status);
  DBMS_OUTPUT.DISABLE;
  d := TO_NUMBER(SUBSTR(line, 11));

  output := rqNumericEltSet();
  output.EXTEND(2);
  output(1) := rqNumericElt(1, d);
  output(2) := rqNumericElt(2, sig);

  RETURN output;
END rqKstestPweibull;
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) PROCEDURE: rqForeachUpdate                                         *--
--***************************************************************************--

CREATE PROCEDURE rqForeachUpdate(
  num                            NUMBER)
AUTHID DEFINER
AS
BEGIN
  MERGE INTO rqForeach D
  USING (SELECT id
         FROM   (select 1 id, 1 val from dual)
         MODEL DIMENSION BY  (id)
         MEASURES            (val)
         RULES               (val[FOR id FROM 1 TO num INCREMENT 1] 
                              = CV(id))) S
  ON    (D.id = S.id)
  WHEN NOT MATCHED THEN INSERT (D.id) VALUES (S.id);
  COMMIT;
END;
/
SHOW ERRORS

--***************************************************************************--
--*  (*) PROCEDURES: Data Store                                             *--
--***************************************************************************--

CREATE PROCEDURE rq$AddDataStoreImpl(
   ds_owner IN VARCHAR2, 
   ds_name  IN VARCHAR2, 
   ds_desc  IN VARCHAR2,
   ds_append  IN integer
) 
IS 
      v_dsID number(20);
      v_dsexists integer;
BEGIN
      -- get new dsID from sequence
      select rq$datastore_seq.nextval into v_dsID from sys.dual;
      -- create datastore record
      insert into RQ$DATASTORE(dsID, dsowner, dsname, cdate, description)
      values(v_dsID, ds_owner, ds_name, sysdate, ds_desc);
      COMMIT;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    IF ds_append = 0  THEN
      raise_application_error(-20101, 'DataStore already exists');
    END IF;
  RETURN;
END;
/
SHOW ERRORS;

CREATE PROCEDURE rq$AddDataStore(
   ds_name  IN VARCHAR2, 
   ds_desc  IN VARCHAR2,
   ds_append  IN integer
)
AUTHID CURRENT_USER 
IS
   ds_owner VARCHAR2(128);
BEGIN
   select user into ds_owner from dual;
   rq$AddDataStoreImpl(ds_owner, ds_name, ds_desc, ds_append);
END;
/
SHOW ERRORS;

CREATE PROCEDURE rq$AddDataStoreObjectImpl(
    ds_owner   IN VARCHAR2, 
    ds_name    IN VARCHAR2, 
    obj_name   IN VARCHAR2, 
    obj_class  IN VARCHAR2,
    obj_size   IN integer,
    obj_length IN integer,
    obj_nrow   IN integer,
    obj_ncol   IN integer
)
IS 
    v_dsID number(20);
    v_objID number(20);
    v_objexists integer;
BEGIN
     -- get dsID from named datastore
      select dsID into v_dsID
      from rq$datastore
      where dsowner = ds_owner AND dsname = ds_name;

     -- check if objname aleardy exist in named datastore
     select count(*) into v_objexists
     from rq$datastoreobject
     where dsID = v_dsID AND objname = obj_name;

     IF v_objexists > 0 THEN 
        raise_application_error(-20101, 
                    'Object already exists in named datastore');
     END IF;
    
     -- get a new objID from sequence
     select rq$datastore_seq.nextval into v_objID from sys.dual;
     -- insert object meta data
     insert into rq$datastoreobject
      values(v_objID, v_dsID, obj_name, obj_class, obj_size, 
             obj_length, obj_nrow, obj_ncol);

     return;

EXCEPTION
  WHEN OTHERS THEN
       RAISE;
       RETURN;
END;
/
SHOW ERRORS;

CREATE PROCEDURE rq$AddDataStoreObject(
    ds_name    IN VARCHAR2, 
    obj_name   IN VARCHAR2, 
    obj_class  IN VARCHAR2,
    obj_size   IN integer,
    obj_length IN integer,
    obj_nrow   IN integer,
    obj_ncol   IN integer
)
AUTHID CURRENT_USER
IS
   ds_owner VARCHAR2(128);
BEGIN
   select user into ds_owner from dual;
   rq$AddDataStoreObjectImpl(ds_owner, ds_name, obj_name, 
               obj_class, obj_size, obj_length, obj_nrow, obj_ncol);
END;
/
SHOW ERRORS;

CREATE PROCEDURE rq$AddDataStoreRefDBObjectImpl(
    ds_owner     IN VARCHAR2, 
    ds_name      IN VARCHAR2, 
    obj_name     IN VARCHAR2, 
    refobj_name  IN VARCHAR2,
    refobj_type  IN VARCHAR2,
    refobj_parm  IN VARCHAR2,
    refobj_owner IN VARCHAR2
)
IS 
    v_objID number(20);
BEGIN
    -- get objID
    select objID into v_objID 
    from RQ$DATASTORE a, RQ$DATASTOREOBJECT b
    where a.dsowner = ds_owner AND a.dsname = ds_name AND
          b.objname = obj_name AND a.dsID = b.dsID;

    insert into RQ$DATASTOREREFDBOBJECT
    values(v_objID, refobj_name, refobj_type, refobj_parm, refobj_owner);

EXCEPTION
   WHEN OTHERS THEN
     raise_application_error(-20101, 
                 'Object does not exist in named datrastore');
     RETURN;
END;
/
SHOW ERRORS;

CREATE PROCEDURE rq$AddDataStoreRefDBObject(
    ds_name      IN VARCHAR2, 
    obj_name     IN VARCHAR2, 
    refobj_name  IN VARCHAR2,
    refobj_type  IN VARCHAR2,
    refobj_parm  IN VARCHAR2,
    refobj_owner IN VARCHAR2
)
AUTHID CURRENT_USER
IS
   ds_owner VARCHAR2(128);
BEGIN
   select user into ds_owner from dual;
   rq$AddDataStoreRefDBObjectImpl(ds_owner, ds_name, obj_name, 
                                 refobj_name, refobj_type,
                                 refobj_parm, refobj_owner);
END;
/
SHOW ERRORS;

CREATE PROCEDURE rq$DropDataStoreImpl(
   ds_owner IN VARCHAR2,
   ds_name  IN VARCHAR2
)
IS
      v_dsID number(20);
      v_dsexists integer;
BEGIN
      -- check if named datastore already exists
      select count(*) into v_dsexists
      from RQ$DATASTORE
      where dsowner = ds_owner AND dsname = ds_name;

      IF v_dsexists = 0 THEN
          raise_application_error(-20101, 'DataStore does not exist');
      END IF;

      -- delete datastore record
      delete from RQ$DATASTORE where dsowner = ds_owner AND dsname = ds_name;
      COMMIT;
      return;

EXCEPTION
  WHEN OTHERS THEN
  RAISE;
  RETURN;
END;
/
SHOW ERRORS;

CREATE PROCEDURE rqDropDataStore(
   ds_name  IN VARCHAR2
)
AUTHID CURRENT_USER
IS
   ds_owner VARCHAR2(128);
BEGIN
   select user into ds_owner from dual;
   -- remove from rq$datastoreinventory
   execute immediate 
   'delete from RQ$DATASTOREINVENTORY c where EXISTS '||
         '(select b.objID from RQ$DATASTORE a, RQ$DATASTOREOBJECT b '||
          'where a.dsowner = :ds_owner AND a.dsname = :ds_name AND '||
                'a.dsID = b.dsID AND b.objID = c.objID)'
   using ds_owner, ds_name;

   rq$DropDataStoreImpl(ds_owner, ds_name);
END;
/
SHOW ERRORS;

--***************************************************************************--
--*  (*) OBJECT PRIVILEGES                                                  *--
--***************************************************************************--

GRANT EXECUTE ON rqObject TO PUBLIC;
GRANT EXECUTE ON rqObjSet TO PUBLIC;
GRANT EXECUTE ON rqXMLObj TO PUBLIC;
GRANT EXECUTE ON rqXMLSet TO PUBLIC;
GRANT EXECUTE ON rqImgObj TO PUBLIC;
GRANT EXECUTE ON rqImgSet TO PUBLIC;

GRANT EXECUTE ON rq$AddDataStore TO PUBLIC;
GRANT EXECUTE ON rq$AddDataStoreObject TO PUBLIC;
GRANT EXECUTE ON rq$AddDataStoreRefDBObject TO PUBLIC;
GRANT EXECUTE ON rqDropDataStore TO PUBLIC;
GRANT EXECUTE ON rqEvalImpl TO PUBLIC;
GRANT EXECUTE ON rqEval TO PUBLIC;
GRANT EXECUTE ON rqTableEvalImpl TO PUBLIC;
GRANT EXECUTE ON rqTableEval TO PUBLIC;
GRANT EXECUTE ON rqGroupEvalImpl TO PUBLIC;
GRANT EXECUTE ON rqRowEvalImpl TO PUBLIC;
GRANT EXECUTE ON rqRowEval TO PUBLIC;
GRANT EXECUTE ON RQ_ELEM_T TO PUBLIC;
GRANT EXECUTE ON RQ_PARAM_T TO PUBLIC;
GRANT EXECUTE ON rqRFuncEvalChr TO PUBLIC;
GRANT EXECUTE ON rqRFuncEvalNum TO PUBLIC;
GRANT EXECUTE ON rqForeachUpdate to PUBLIC;
GRANT EXECUTE ON rqBesselI TO PUBLIC;
GRANT EXECUTE ON rqBesselK TO PUBLIC;
GRANT EXECUTE ON rqBesselJ TO PUBLIC;
GRANT EXECUTE ON rqBesselY TO PUBLIC;
GRANT EXECUTE ON rqNumericEltSet TO PUBLIC;
GRANT EXECUTE ON rqKstestPexp TO PUBLIC;
GRANT EXECUTE ON rqKstestPnorm TO PUBLIC;
GRANT EXECUTE ON rqKstestPpois TO PUBLIC;
GRANT EXECUTE ON rqKstestPunif TO PUBLIC;
GRANT EXECUTE ON rqKstestPweibull TO PUBLIC;
GRANT EXECUTE ON rqCrossprodImpl TO PUBLIC;
GRANT EXECUTE ON rqCrossprod TO PUBLIC;
GRANT EXECUTE ON rqUnlistTable TO PUBLIC;
GRANT EXECUTE ON rqGamma TO PUBLIC;
GRANT EXECUTE ON rqLgamma TO PUBLIC;
GRANT EXECUTE ON rqDigamma TO PUBLIC;
GRANT EXECUTE ON rqTrigamma TO PUBLIC;
GRANT EXECUTE ON rqErf TO PUBLIC;
GRANT EXECUTE ON rqErfc TO PUBLIC;
GRANT EXECUTE ON rqPbeta TO PUBLIC;
GRANT EXECUTE ON rqQbeta TO PUBLIC;
GRANT EXECUTE ON rqQcauchy TO PUBLIC;
GRANT EXECUTE ON rqPcauchy TO PUBLIC;
GRANT EXECUTE ON rqDchisq TO PUBLIC;
GRANT EXECUTE ON rqPchisq TO PUBLIC;
GRANT EXECUTE ON rqQchisq TO PUBLIC;
GRANT EXECUTE ON rqPexp TO PUBLIC;
GRANT EXECUTE ON rqQexp TO PUBLIC;
GRANT EXECUTE ON rqDgamma TO PUBLIC;
GRANT EXECUTE ON rqQgamma TO PUBLIC;
GRANT EXECUTE ON rqPgamma TO PUBLIC;
GRANT EXECUTE ON rqDnbinom TO PUBLIC;
GRANT EXECUTE ON rqPnbinom TO PUBLIC;
GRANT EXECUTE ON rqQnbinom TO PUBLIC;
GRANT EXECUTE ON rqPnorm TO PUBLIC;
GRANT EXECUTE ON rqQnorm TO PUBLIC;
GRANT EXECUTE ON rqPpois TO PUBLIC;
GRANT EXECUTE ON rqQpois TO PUBLIC;
GRANT EXECUTE ON rqQt TO PUBLIC;
GRANT EXECUTE ON rqPt TO PUBLIC;
GRANT EXECUTE ON rqPweibull TO PUBLIC;
GRANT EXECUTE ON rqQweibull TO PUBLIC;
GRANT EXECUTE ON rqDweibull TO PUBLIC;
GRANT EXECUTE ON rqHarmonic TO PUBLIC;
GRANT EXECUTE ON rqSignP TO PUBLIC;
GRANT EXECUTE ON rqCvmP TO PUBLIC;
GRANT EXECUTE ON rqDcauchy TO PUBLIC;
GRANT EXECUTE ON rqDpois TO PUBLIC;
GRANT EXECUTE ON rqDt TO PUBLIC;
GRANT EXECUTE ON rqDnorm TO PUBLIC;
GRANT EXECUTE ON rqDexp TO PUBLIC;
GRANT EXECUTE ON rqDbeta TO PUBLIC;

GRANT EXECUTE ON rqStepwiseType TO PUBLIC;
GRANT EXECUTE ON rqStepwiseTypeSet TO PUBLIC;
GRANT EXECUTE ON rqStepwiseImpl TO PUBLIC;
GRANT EXECUTE ON rqStepwise TO PUBLIC;

GRANT EXECUTE ON rqNeuralType TO PUBLIC;
GRANT EXECUTE ON rqNeuralTypeSet TO PUBLIC;
GRANT EXECUTE ON rqNeuralImpl TO PUBLIC;
GRANT EXECUTE ON rqNeural TO PUBLIC;

GRANT EXECUTE ON rqDf TO PUBLIC;
GRANT EXECUTE ON rqPf TO PUBLIC;
GRANT EXECUTE ON rqQf TO PUBLIC;

GRANT EXECUTE ON rqDsignrank TO PUBLIC;
GRANT EXECUTE ON rqPsignrank TO PUBLIC;
GRANT EXECUTE ON rqQsignrank TO PUBLIC;

GRANT EXECUTE ON rqDbinom TO PUBLIC;
GRANT EXECUTE ON rqPbinom TO PUBLIC;
GRANT EXECUTE ON rqQbinom TO PUBLIC;

--***************************************************************************--
--*  (*) PUBLIC SYNONYMS                                                    *--
--***************************************************************************--

create public synonym rqObject for rqsys.rqObject;
create public synonym rqObjSet for rqsys.rqObjSet;
create public synonym rqXMLObj for rqsys.rqXMLObj;
create public synonym rqXMLSet for rqsys.rqXMLSet;
create public synonym rqImgObj for rqsys.rqImgObj;
create public synonym rqImgSet for rqsys.rqImgSet;

create public synonym rq$AddDataStore for rqsys.rq$AddDataStore;
create public synonym rq$AddDataStoreObject for rqsys.rq$AddDataStoreObject;
create public synonym rq$AddDataStoreRefDBObject for 
                      rqsys.rq$AddDataStoreRefDBObject;
create public synonym rqDropDataStore for rqsys.rqDropDataStore;
create public synonym rqEvalImpl for rqsys.rqEvalImpl;
create public synonym rqEval for rqsys.rqEval;
create public synonym rqTableEvalImpl for rqsys.rqTableEvalImpl;
create public synonym rqTableEval for rqsys.rqTableEval;
create public synonym rqGroupEvalImpl for rqsys.rqGroupEvalImpl;
create public synonym rqRowEvalImpl for rqsys.rqRowEvalImpl;
create public synonym rqRowEval for rqsys.rqRowEval;
create public synonym rq_elem_t for rqsys.rq_elem_t;
create public synonym rq_param_t for rqsys.rq_param_t;
create public synonym rqRFuncEvalChr for rqsys.rqRFuncEvalChr;
create public synonym rqRFuncEvalNum for rqsys.rqRFuncEvalNum;
create public synonym rqForeachUpdate for rqsys.rqForeachUpdate;
create public synonym rqBesselI for rqsys.rqBesselI;
create public synonym rqBesselK for rqsys.rqBesselK;
create public synonym rqBesselJ for rqsys.rqBesselJ;
create public synonym rqBesselY for rqsys.rqBesselY;
create public synonym rqNumericEltSet for rqsys.rqNumericEltSet;
create public synonym rqKstestPexp for rqsys.rqKstestPexp;
create public synonym rqKstestPnorm for rqsys.rqKstestPnorm;
create public synonym rqKstestPpois for rqsys.rqKstestPpois;
create public synonym rqKstestPunif for rqsys.rqKstestPunif;
create public synonym rqKstestPweibull for rqsys.rqKstestPweibull;
create public synonym rqCrossprodImpl for rqsys.rqCrossprodImpl;
create public synonym rqCrossprod for rqsys.rqCrossprod;
create public synonym rqUnlistTable for rqsys.rqUnlistTable;
create public synonym rqGamma for rqsys.rqGamma;
create public synonym rqLgamma for rqsys.rqLgamma;
create public synonym rqDigamma for rqsys.rqDigamma;
create public synonym rqTrigamma for rqsys.rqTrigamma;
create public synonym rqErf for rqsys.rqErf;
create public synonym rqErfc for rqsys.rqErfc;
create public synonym rqPbeta for rqsys.rqPbeta;
create public synonym rqQbeta for rqsys.rqQbeta;
create public synonym rqQcauchy for rqsys.rqQcauchy;
create public synonym rqPcauchy for rqsys.rqPcauchy;
create public synonym rqDchisq for rqsys.rqDchisq;
create public synonym rqPchisq for rqsys.rqPchisq;
create public synonym rqQchisq for rqsys.rqQchisq;
create public synonym rqPexp for rqsys.rqPexp;
create public synonym rqQexp for rqsys.rqQexp;
create public synonym rqDf for rqsys.rqDf;
create public synonym rqPf for rqsys.rqPf;
create public synonym rqQf for rqsys.rqQf;
create public synonym rqDgamma for rqsys.rqDgamma;
create public synonym rqQgamma for rqsys.rqQgamma;
create public synonym rqPgamma for rqsys.rqPgamma;
create public synonym rqDnbinom for rqsys.rqDnbinom;
create public synonym rqPnbinom for rqsys.rqPnbinom;
create public synonym rqQnbinom for rqsys.rqQnbinom;
create public synonym rqPnorm for rqsys.rqPnorm;
create public synonym rqQnorm for rqsys.rqQnorm;
create public synonym rqPpois for rqsys.rqPpois;
create public synonym rqQpois for rqsys.rqQpois;
create public synonym rqQt for rqsys.rqQt;
create public synonym rqPt for rqsys.rqPt;
create public synonym rqPweibull for rqsys.rqPweibull;
create public synonym rqQweibull for rqsys.rqQweibull;
create public synonym rqDweibull for rqsys.rqDweibull;
create public synonym rqHarmonic for rqsys.rqHarmonic;
create public synonym rqSignP for rqsys.rqSignP;
create public synonym rqCvmP for rqsys.rqCvmP;
create public synonym rqDcauchy for rqsys.rqDcauchy;
create public synonym rqDpois for rqsys.rqDpois;
create public synonym rqDt for rqsys.rqDt;
create public synonym rqDnorm for rqsys.rqDnorm;
create public synonym rqDexp for rqsys.rqDexp;
create public synonym rqDbeta for rqsys.rqDbeta;

create public synonym rqStepwiseType for rqsys.rqStepwiseType;
create public synonym rqStepwiseTypeSet for rqsys.rqStepwiseTypeSet;
create public synonym rqStepwiseImpl for rqsys.rqStepwiseImpl;
create public synonym rqStepwise for rqsys.rqStepwise;

create public synonym rqNeuralType for rqsys.rqNeuralType;
create public synonym rqNeuralTypeSet for rqsys.rqNeuralTypeSet;
create public synonym rqNeuralImpl for rqsys.rqNeuralImpl;
create public synonym rqNeural for rqsys.rqNeural;

create public synonym rqPsignrank for rqsys.rqPsignrank;
create public synonym rqQsignrank for rqsys.rqQsignrank;
create public synonym rqDsignrank for rqsys.rqDsignrank;

create public synonym rqDbinom for rqsys.rqDbinom;
create public synonym rqPbinom for rqsys.rqPbinom;
create public synonym rqQbinom for rqsys.rqQbinom;

--***************************************************************************--
--*  end of file rqproc.sql                                                 *--
--***************************************************************************--
