Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      rqadmin.sql - RQADMIN role procedures
Rem
Rem    DESCRIPTION
Rem      Pocedures, functions and packages for RQADMIN role.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/16/12 - Created
Rem

--***************************************************************************--
--*  (*) R SCRIPTS                                                          *--
--***************************************************************************--

-------------------------------- rqScriptCreate -------------------------------
--
CREATE PROCEDURE rqScriptCreate(
  v_name                         VARCHAR2,
  v_script                       CLOB)
AUTHID DEFINER
AS
  CONSTRAINT_VIOLATION EXCEPTION;
  PRAGMA EXCEPTION_INIT(CONSTRAINT_VIOLATION , -1);
BEGIN
  COMMIT;

  IF REGEXP_INSTR(v_name, '^RQ.?\$', 1, 1) = 1 THEN
    RAISE_APPLICATION_ERROR(-20000, 
      'cannot create a script with a reserved name');
  END IF;

  IF v_script IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'script is NULL');
  END IF;

  INSERT INTO rq$script (name, script)
         VALUES (v_name, v_script);
  COMMIT;
EXCEPTION
  WHEN CONSTRAINT_VIOLATION THEN
    RAISE_APPLICATION_ERROR(-20000, 
      'script name conflict detected, use a different script name');
END;
/
SHOW ERRORS
GRANT EXECUTE ON rqScriptCreate TO rqadmin;

--------------------------------- rqScriptDrop --------------------------------
--
CREATE PROCEDURE rqScriptDrop(
  v_name                         VARCHAR2)
AUTHID DEFINER
AS
BEGIN
  COMMIT;

  IF REGEXP_INSTR(v_name, '^RQ.?\$', 1, 1) = 1 THEN
    RAISE_APPLICATION_ERROR(-20000,
      'cannot drop a script with a reserved name');
  END IF;

  DELETE FROM rq$script WHERE name = v_name;
  COMMIT;
END;
/
SHOW ERRORS
GRANT EXECUTE ON rqScriptDrop TO rqadmin;

--***************************************************************************--
--*  (*) CONFIGURATION OPTIONS                                              *--
--***************************************************************************--

--------------------------------- rqConfigSet ---------------------------------
--
CREATE PROCEDURE rqConfigSet(
  v_name                         VARCHAR2,
  v_value                        VARCHAR2)
AUTHID DEFINER
AS
BEGIN
  UPDATE rq$config SET value = v_value WHERE name = v_name;
  COMMIT;
END;
/
SHOW ERRORS
GRANT EXECUTE ON rqConfigSet TO rqadmin;

--***************************************************************************--
--* end of file rqadmin.sql                                                 *--
--***************************************************************************--
