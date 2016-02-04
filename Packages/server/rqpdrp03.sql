Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      rqpdrp03.sql - RQuery Proc DRoP version 3
Rem
Rem    DESCRIPTION
Rem      Drops RQuery PL/SQL procedures, functions and packages for 1.3.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    demukhin    10/26/12 - bug 14802813: init R in one place
Rem    demukhin    10/18/12 - Created
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

DROP PUBLIC SYNONYM rqQbinom;
DROP PUBLIC SYNONYM rqPbinom;
DROP PUBLIC SYNONYM rqDbinom;
DROP PUBLIC SYNONYM rqDsignrank;
DROP PUBLIC SYNONYM rqQsignrank;
DROP PUBLIC SYNONYM rqPsignrank;
DROP PUBLIC SYNONYM rqNeural;
DROP PUBLIC SYNONYM rqNeuralImpl;
DROP PUBLIC SYNONYM rqNeuralTypeSet;
DROP PUBLIC SYNONYM rqNeuralType;
DROP PUBLIC SYNONYM rqStepwise;
DROP PUBLIC SYNONYM rqStepwiseImpl;
DROP PUBLIC SYNONYM rqStepwiseTypeSet;
DROP PUBLIC SYNONYM rqStepwiseType;
DROP PUBLIC SYNONYM rqDbeta;
DROP PUBLIC SYNONYM rqDexp;
DROP PUBLIC SYNONYM rqDnorm;
DROP PUBLIC SYNONYM rqDt;
DROP PUBLIC SYNONYM rqDpois;
DROP PUBLIC SYNONYM rqDcauchy;
DROP PUBLIC SYNONYM rqCvmP;
DROP PUBLIC SYNONYM rqSignP;
DROP PUBLIC SYNONYM rqHarmonic;
DROP PUBLIC SYNONYM rqDweibull;
DROP PUBLIC SYNONYM rqQweibull;
DROP PUBLIC SYNONYM rqPweibull;
DROP PUBLIC SYNONYM rqPt;
DROP PUBLIC SYNONYM rqQt;
DROP PUBLIC SYNONYM rqQpois;
DROP PUBLIC SYNONYM rqPpois;
DROP PUBLIC SYNONYM rqQnorm;
DROP PUBLIC SYNONYM rqPnorm;
DROP PUBLIC SYNONYM rqQnbinom;
DROP PUBLIC SYNONYM rqPnbinom;
DROP PUBLIC SYNONYM rqDnbinom;
DROP PUBLIC SYNONYM rqPgamma;
DROP PUBLIC SYNONYM rqQgamma;
DROP PUBLIC SYNONYM rqDgamma;
DROP PUBLIC SYNONYM rqQf;
DROP PUBLIC SYNONYM rqPf;
DROP PUBLIC SYNONYM rqDf;
DROP PUBLIC SYNONYM rqQexp;
DROP PUBLIC SYNONYM rqPexp;
DROP PUBLIC SYNONYM rqQchisq;
DROP PUBLIC SYNONYM rqPchisq;
DROP PUBLIC SYNONYM rqDchisq;
DROP PUBLIC SYNONYM rqPcauchy;
DROP PUBLIC SYNONYM rqQcauchy;
DROP PUBLIC SYNONYM rqQbeta;
DROP PUBLIC SYNONYM rqPbeta;
DROP PUBLIC SYNONYM rqErfc;
DROP PUBLIC SYNONYM rqErf;
DROP PUBLIC SYNONYM rqTrigamma;
DROP PUBLIC SYNONYM rqDigamma;
DROP PUBLIC SYNONYM rqLgamma;
DROP PUBLIC SYNONYM rqGamma;
DROP PUBLIC SYNONYM rqUnlistTable;
DROP PUBLIC SYNONYM rqCrossprod;
DROP PUBLIC SYNONYM rqCrossprodImpl;
DROP PUBLIC SYNONYM rqKstestPweibull;
DROP PUBLIC SYNONYM rqKstestPunif;
DROP PUBLIC SYNONYM rqKstestPpois;
DROP PUBLIC SYNONYM rqKstestPnorm;
DROP PUBLIC SYNONYM rqKstestPexp;
DROP PUBLIC SYNONYM rqNumericEltSet;
DROP PUBLIC SYNONYM rqBesselY;
DROP PUBLIC SYNONYM rqBesselJ;
DROP PUBLIC SYNONYM rqBesselK;
DROP PUBLIC SYNONYM rqBesselI;
DROP PUBLIC SYNONYM rqForeachUpdate;
DROP PUBLIC SYNONYM rqRFuncEvalNum;
DROP PUBLIC SYNONYM rqRFuncEvalChr;
DROP PUBLIC SYNONYM rq_param_t;
DROP PUBLIC SYNONYM rq_elem_t;
DROP PUBLIC SYNONYM rqRowEval;
DROP PUBLIC SYNONYM rqRowEvalImpl;
DROP PUBLIC SYNONYM rqGroupEvalImpl;
DROP PUBLIC SYNONYM rqTableEval;
DROP PUBLIC SYNONYM rqTableEvalImpl;
DROP PUBLIC SYNONYM rqEval;
DROP PUBLIC SYNONYM rqEvalImpl;
DROP PUBLIC SYNONYM rqDropDataStore;
DROP PUBLIC SYNONYM rq$AddDataStoreRefDBObject;
DROP PUBLIC SYNONYM rq$AddDataStoreObject;
DROP PUBLIC SYNONYM rq$AddDataStore;
DROP PUBLIC SYNONYM rqImgSet;
DROP PUBLIC SYNONYM rqImgObj;
DROP PUBLIC SYNONYM rqXMLSet;
DROP PUBLIC SYNONYM rqXMLObj;
DROP PUBLIC SYNONYM rqObjSet;
DROP PUBLIC SYNONYM rqObject;
DROP PROCEDURE rqDropDataStore;
DROP PROCEDURE rq$DropDataStoreImpl;
DROP PROCEDURE rq$AddDataStoreRefDBObject;
DROP PROCEDURE rq$AddDataStoreRefDBObjectImpl;
DROP PROCEDURE rq$AddDataStoreObject;
DROP PROCEDURE rq$AddDataStoreObjectImpl;
DROP PROCEDURE rq$AddDataStore;
DROP PROCEDURE rq$AddDataStoreImpl;
DROP PROCEDURE rqForeachUpdate;
DROP FUNCTION rqKstestPweibull;
DROP FUNCTION rqKstestPunif;
DROP FUNCTION rqKstestPpois;
DROP FUNCTION rqKstestPnorm;
DROP FUNCTION rqKstestPexp;
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
DROP FUNCTION rqBesselY;
DROP FUNCTION rqBesselJ;
DROP FUNCTION rqBesselK;
DROP FUNCTION rqBesselI;
DROP FUNCTION rqRFuncEvalChr;
DROP FUNCTION rqRFuncEvalNum;
DROP TYPE RQ_PARAM_T;
DROP TYPE RQ_ELEM_T;
DROP FUNCTION rqUnlistTable;
DROP FUNCTION rqNeural;
DROP TYPE rqNeuralImpl;
DROP TYPE rqNeuralTypeSet;
DROP TYPE rqNeuralType;
DROP FUNCTION rqStepwise;
DROP TYPE rqStepwiseImpl;
DROP TYPE rqStepwiseTypeSet;
DROP TYPE rqStepwiseType;
DROP FUNCTION rqCrossprod;
DROP TYPE rqCrossprodImpl;
DROP TYPE rqNumericEltSet;
DROP TYPE rqNumericElt;
DROP FUNCTION rqRowEval;
DROP TYPE BODY rqRowEvalImpl;
DROP TYPE rqRowEvalImpl;
DROP TYPE BODY rqGroupEvalImpl;
DROP TYPE rqGroupEvalImpl;
DROP FUNCTION rqTableEval;
DROP TYPE BODY rqTableEvalImpl;
DROP TYPE rqTableEvalImpl;
DROP FUNCTION rqEval;
DROP TYPE BODY rqEvalImpl;
DROP TYPE rqEvalImpl;
DROP TYPE rqImgSet;
DROP TYPE rqImgObj;
DROP TYPE rqXMLSet;
DROP TYPE rqXMLObj;
DROP TYPE rqObjSet;
DROP TYPE rqObject;

--***************************************************************************--
--* end of file rqpdrp03.sql                                                *--
--***************************************************************************--
