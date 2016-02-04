Rem
Rem Copyright (c) 2012, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rqpdrp01.sql - RQuery Proc DRoP version 1
Rem
Rem    DESCRIPTION
Rem      Drops RQuery PL/SQL procedures, functions and packages for 1.1.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    03/26/13 - bug 16536750: missing grants when upgrading 1.1
Rem    demukhin    10/19/12 - Created
Rem

--***************************************************************************--
--*  (*) SYS                                                                *--
--***************************************************************************--

DROP PROCEDURE rqScriptCreate;
DROP PROCEDURE rqScriptDrop;
DROP PROCEDURE rqConfigSet;

--***************************************************************************--
--*  (*) RQSYS                                                              *--
--***************************************************************************--

ALTER SESSION SET CURRENT_SCHEMA = "RQSYS";

DROP FUNCTION rqLargeStep;
DROP TYPE rqLargeStepImpl;
DROP TYPE rqLargeStepTypeSet;
DROP TYPE rqLargeStepType;
DROP FUNCTION rqStep;
DROP TYPE rqStepImpl;
DROP TYPE rqStepTypeSet;
DROP TYPE rqStepType;
DROP FUNCTION rqQsignrank;
DROP FUNCTION rqPsignrank;
DROP FUNCTION rqDsignrank;
DROP FUNCTION rqDexp;
DROP FUNCTION rqDnorm;
DROP FUNCTION rqDt;
DROP FUNCTION rqDcauchy;
DROP FUNCTION rqCvmP;
DROP FUNCTION rqSignP;
DROP FUNCTION rqHarmonic;
DROP FUNCTION rqDweibull;
DROP FUNCTION rqQweibull;
DROP FUNCTION rqPweibull;
DROP FUNCTION rqPt;
DROP FUNCTION rqQt;
DROP FUNCTION rqQpois;
DROP FUNCTION rqPpois;
DROP FUNCTION rqDpois;
DROP FUNCTION rqQnorm;
DROP FUNCTION rqPnorm;
DROP FUNCTION rqQnbinom;
DROP FUNCTION rqPnbinom;
DROP FUNCTION rqDnbinom;
DROP FUNCTION rqPgamma;
DROP FUNCTION rqQgamma;
DROP FUNCTION rqDgamma;
DROP FUNCTION rqQf;
DROP FUNCTION rqPf;
DROP FUNCTION rqDf;
DROP FUNCTION rqQexp;
DROP FUNCTION rqPexp;
DROP FUNCTION rqQchisq;
DROP FUNCTION rqPchisq;
DROP FUNCTION rqDchisq;
DROP FUNCTION rqPcauchy;
DROP FUNCTION rqQcauchy;
DROP FUNCTION rqQbinom;
DROP FUNCTION rqPbinom;
DROP FUNCTION rqDbinom;
DROP FUNCTION rqQbeta;
DROP FUNCTION rqPbeta;
DROP FUNCTION rqDbeta;
DROP FUNCTION rqErfc;
DROP FUNCTION rqErf;
DROP FUNCTION rqTrigamma;
DROP FUNCTION rqDigamma;
DROP FUNCTION rqLgamma;
DROP FUNCTION rqGamma;
DROP FUNCTION rqUnlistTable;
DROP FUNCTION rqCrossprod;
DROP TYPE rqCrossprodImpl;
DROP FUNCTION rqRegression;
DROP TYPE rqRegressionImpl;
DROP TYPE rqRegressionTypeSet;
DROP TYPE rqRegressionType;
DROP FUNCTION rqKstestPweibull;
DROP FUNCTION rqKstestPunif;
DROP FUNCTION rqKstestPpois;
DROP FUNCTION rqKstestPnorm;
DROP FUNCTION rqKstestPexp;
DROP PACKAGE rqNumericEltPkg;
DROP TYPE rqNumericEltSet;
DROP TYPE rqNumericElt;
DROP FUNCTION ore_freq_reglst;
DROP FUNCTION ore_freq_cpipe;
DROP TYPE FreqCurImpl;
DROP TYPE FreqTypeSet;
DROP TYPE FreqType;
DROP FUNCTION rqRnorm;
DROP FUNCTION rqBesselY;
DROP FUNCTION rqBesselJ;
DROP FUNCTION rqBesselK;
DROP FUNCTION rqBesselI;
DROP PROCEDURE rqForeachUpdate;
DROP FUNCTION rqRowEval;
DROP TYPE rqRowEvalImpl;
DROP TYPE rqGroupEvalImpl;
DROP FUNCTION rqTableEval;
DROP TYPE rqTableEvalImpl;
DROP FUNCTION rqEval;
DROP TYPE rqEvalImpl;
DROP TYPE rqXMLSet;
DROP TYPE rqXMLObj;
DROP TYPE rqObjSet;
DROP TYPE rqObject;
DROP FUNCTION libPath;

--***************************************************************************--
--* end of file rqpdrp01.sql                                                *--
--***************************************************************************--
