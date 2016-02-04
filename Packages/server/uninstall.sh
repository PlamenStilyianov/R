#!/bin/sh
#
# Copyright (c) 2012, 2013, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#      uninstall.sh - ORE server uninstallation script
#
#    DESCRIPTION
#      ORE server uninstallation script
#
#    NOTES
#
#    MODIFIED   (MM/DD/YY)
#    demukhin    03/19/13 - ORE version 1.3.1
#    demukhin    02/05/13 - bug 16268465: instance check
#    demukhin    02/05/13 - forward merge from 1.2
#    qinwan      12/06/12 - port to solaris
#    qinwan      11/19/12 - ore use sunperf on Solaris
#    demukhin    11/06/12 - use MKL
#    demukhin    10/19/12 - prj: no roles
#    demukhin    08/29/12 - ORE version 1.3
#    demukhin    07/26/12 - ORE version 1.2 (minor fixes)
#    demukhin    07/18/12 - ORE version 1.2
#    surikuma    05/25/12 - aix fixes
#    qinwan      04/16/12 - Modify uninstall.sh script for Solaris platform
#    demukhin    03/16/12 - Creation
#

ORE_VER=1.3.1

echo " "
echo "Oracle R Enterprise $ORE_VER Server Uninstallation."
echo " "
echo "Copyright (c) 2012, 2013, Oracle and/or its affiliates. All rights reserved."
echo " "

ostype=`uname`
if [ $ostype = Linux ]; then
  nr1="-n"
  nr2=""
else
  nr1=""
  nr2="\c"
fi

echo $nr1 "Checking R ................... $nr2"
which R > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Fail"
  echo "  ERROR: R not found"
  exit 1
fi
echo "Pass"
R_HOME=`R RHOME`

echo $nr1 "Checking ORACLE_HOME ......... $nr2"
if [ -z "${ORACLE_HOME}" ]; then
  echo "Fail"
  echo "  ERROR: ORACLE_HOME is not set"
  exit 1
fi
if [ ! -d ${ORACLE_HOME}/lib ]; then
  echo "Fail"
  echo "  ERROR: $ORACLE_HOME/lib not found"
  exit 1
fi
if [ ! -d ${ORACLE_HOME}/bin ]; then
  echo "Fail"
  echo "  ERROR: $ORACLE_HOME/bin not found"
  exit 1
fi
ORE_LIBS_USER=$ORACLE_HOME/R/library
if [ -z "$R_LIBS_USER" ]; then
  R_LIBS_USER="$ORE_LIBS_USER"
else
  R_LIBS_USER="$ORE_LIBS_USER:$R_LIBS_USER"
fi
echo "Pass"

if [ $ostype = SunOS ]; then
  RBLAS_LIBS=""
else
  RBLAS_LIBS="$ORACLE_HOME/lib/libRblas.so
$ORACLE_HOME/lib/libRlapack.so"
fi

echo $nr1 "Checking ORACLE_SID .......... $nr2"
if [ -z "${ORACLE_SID}" ]; then
  echo "Fail"
  echo "  ERROR: ORACLE_SID is not set"
  exit 1
fi
echo "Pass"

echo $nr1 "Checking sqlplus ............. $nr2"
cat >tmpexit.sql <<EOF
exit;
EOF
$ORACLE_HOME/bin/sqlplus -L -S /nolog @tmpexit.sql >outexit.log
if [ $? -ne 0 ]; then
  echo "Fail"
  echo "  ERROR: sqlplus not found"

  rm -f tmpexit.sql
  rm -f outexit.log
  exit 1
fi

SQLPLUS="$ORACLE_HOME/bin/sqlplus / as sysdba"
SQLPLUS_LS="$ORACLE_HOME/bin/sqlplus -L -S / as sysdba"
$SQLPLUS_LS @tmpexit.sql >outexit.log
if [ $? -ne 0 ]; then
  echo "Fail"
  echo "  ERROR: cannot run sqlplus as SYSDBA with OS authentication"

  while true; do
    echo $nr1 "  Enter SYS password: $nr2"
    stty_orig=`stty -g`
    stty -echo
    read SYS_PASSW
    stty $stty_orig
    echo " "
    if [ -n "$SYS_PASSW" ]; then
      echo $nr1 "Checking sqlplus ............. $nr2"
      SQLPLUS="$ORACLE_HOME/bin/sqlplus sys/$SYS_PASSW as sysdba"
      SQLPLUS_LS="$ORACLE_HOME/bin/sqlplus -L -S sys/$SYS_PASSW as sysdba"
      $SQLPLUS_LS @tmpexit.sql >outexit.log
      if [ $? -ne 0 ]; then
        echo "Fail"
        echo "  ERROR: invalid password"
      else
        echo "Pass"
        break
      fi
    fi
  done
else
  echo "Pass"
fi
rm -f tmpexit.sql
rm -f outexit.log

echo $nr1 "Checking ORACLE instance ..... $nr2"
cat >tmpidle.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
select * from dual;
exit;
EOF
$SQLPLUS_LS @tmpidle.sql >outidle.log
if [ $? -ne 0 ]; then
  echo "Fail"
  echo "  ERROR: \"$ORACLE_SID\" is not up"

  rm -f tmpidle.sql
  rm -f outidle.log
  exit 1
fi
echo "Pass"
rm -f tmpidle.sql
rm -f outidle.log

echo $nr1 "Checking ORE ................. $nr2"
cat >tmpver.sql <<EOF
set echo off
set heads off
set heading off
set feedback off
set timing off
set serveroutput on
declare
  res number;
  ver varchar2(100);
  ore boolean;
begin
  begin
    select 1 into res
    from   dba_users
    where  username = 'RQSYS';

    ore := TRUE;
  exception
    when no_data_found then
      ore := FALSE;
  end;

  if ore then
    begin
      execute immediate
        'select value '||
        'from   sys.rq_config '||
        'where  name = :ver'
      into ver using 'VERSION';
    exception
      when no_data_found then
        ver := '1.0';
    end;
  else
    ver := '0.0';
  end if;
  dbms_output.put_line(ver);
end;
/
exit;
EOF
$SQLPLUS_LS @tmpver.sql >outver.log
ver=`cat outver.log`
rm -f outver.log
rm -f tmpver.sql

uninstall=0
case $ver in
  1.3.1 )
    echo "Pass"
    uninstall=1
    ;;
  1.3 )
    echo "Fail"
    echo "  ERROR: an earlier version of ORE $ver is installed"
    echo "         To uninstall use the script that came with ORE $ver"
    exit 1
    ;;
  1.2 )
    echo "Fail"
    echo "  ERROR: an earlier version of ORE $ver is installed"
    echo "         To uninstall use the script that came with ORE $ver"
    exit 1
    ;;
  1.1 )
    echo "Fail"
    echo "  ERROR: an earlier version of ORE $ver is installed"
    echo "         To uninstall use the script that came with ORE $ver"
    exit 1
    ;;
  1.0 )
    echo "Fail"
    echo "  ERROR: an earlier version of ORE $ver is installed"
    echo "         To uninstall use the script that came with ORE $ver"
    exit 1
    ;;
  0.0 )
    echo "Pass"
    ;;
  * ) 
    echo "Fail"
    echo "  ERROR: a later version of ORE $ver is installed"
    echo "         To uninstall use the script that came with ORE $ver"
    exit 1
    ;;
esac

echo " "
echo "Current configuration"
echo "  R_HOME               = $R_HOME"
echo "  R_LIBS_USER          = $R_LIBS_USER"
echo "  ORACLE_HOME          = $ORACLE_HOME"
echo "  ORACLE_SID           = $ORACLE_SID"

echo " "
while true; do
  echo $nr1 "Do you wish to uninstall ORE? [yes] $nr2"
  read yn
  if [ ! -n "$yn" ]; then
    yn="yes"
  fi
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit 1;;
    * ) echo "Please answer yes or no.";;
  esac
done

echo " "
echo $nr1 "Removing ORE script .......... $nr2"
rm -f $ORACLE_HOME/bin/ORE > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Fail"
  echo "  ERROR: cannot remove $ORACLE_HOME/bin/ORE"
else
  echo "Pass"
fi

echo $nr1 "Removing ORE packages ........ $nr2"
ORE_PACKAGES="ORE
ORExml
OREdm
OREeda
OREpredict
OREgraphics
OREstats
OREbase"
fail=0
for f in $ORE_PACKAGES
do
  R --vanilla CMD REMOVE --library=$ORE_LIBS_USER $f > outr.log 2>&1
  if [ $? -ne 0 ]; then
    if [ $fail = 0 ]; then
      fail=1
      echo "Fail"
    fi
    echo "  ERROR: cannot remove $f from $ORE_LIBS_USER"
    rm -f outr.log
  fi
done
rm -f outr.log
rm -f -r $ORACLE_HOME/R > /dev/null 2>&1
if [ $? -ne 0 ]; then
  if [ $fail = 0 ]; then
    fail=1
    echo "Fail"
  fi
  echo "  ERROR: cannot remove $ORACLE_HOME/R"
fi
if [ $fail = 0 ]; then
  echo "Pass"
fi

if [ $uninstall = 1 ]; then
  echo $nr1 "Removing RQSYS code .......... $nr2"
  cat >tmppdrp.sql <<EOF
@@rqpdrp04
exit;
EOF
  $SQLPLUS @tmppdrp.sql >rqpdrop.log
  if [ $? -ne 0 ]; then
    echo "Fail"
    echo "  ERROR: cannot remove RQSYS code"
    echo "         see rqpdrop.log for details"
  else
    echo "Pass"
  fi
  rm -f tmppdrp.sql

  echo $nr1 "Removing RQSYS data .......... $nr2"
  cat >tmpdrp.sql <<EOF
@@rqdrp
exit;
EOF
  $SQLPLUS @tmpdrp.sql >rqdrop.log
  if [ $? -ne 0 ]; then
    echo "Fail"
    echo "  ERROR: cannot remove RQSYS data"
    echo "         see rqdrop.log for details"
  else
    echo "Pass"
  fi
  rm -f tmpdrp.sql
fi

echo $nr1 "Removing libraries ........... $nr2"
if [ $ostype = Linux ]; then
  ORE_FILES="$ORACLE_HOME/lib/librqe.so
$ORACLE_HOME/lib/ore.so
$ORACLE_HOME/lib/libimf.so
$ORACLE_HOME/lib/libintlc.so
$ORACLE_HOME/lib/libiomp5.so
$ORACLE_HOME/lib/libiompprof5.so
$ORACLE_HOME/lib/libiompstubs5.so
$ORACLE_HOME/lib/libirc.so
$ORACLE_HOME/lib/libomp_db.so
$ORACLE_HOME/lib/libsvml.so
$ORACLE_HOME/lib/libmkl_avx.so
$ORACLE_HOME/lib/libmkl_cdft_core.so
$ORACLE_HOME/lib/libmkl_core.so
$ORACLE_HOME/lib/libmkl_def.so
$ORACLE_HOME/lib/libmkl_gf_ilp64.so
$ORACLE_HOME/lib/libmkl_gf_lp64.so
$ORACLE_HOME/lib/libmkl_gnu_thread.so
$ORACLE_HOME/lib/libmkl_intel_ilp64.so
$ORACLE_HOME/lib/libmkl_intel_lp64.so
$ORACLE_HOME/lib/libmkl_intel_sp2dp.so
$ORACLE_HOME/lib/libmkl_intel_thread.so
$ORACLE_HOME/lib/libmkl_mc.so
$ORACLE_HOME/lib/libmkl_mc3.so
$ORACLE_HOME/lib/libmkl_p4n.so
$ORACLE_HOME/lib/libmkl_pgi_thread.so
$ORACLE_HOME/lib/libmkl_rt.so
$ORACLE_HOME/lib/libmkl_sequential.so
$ORACLE_HOME/lib/libmkl_vml_avx.so
$ORACLE_HOME/lib/libmkl_vml_def.so
$ORACLE_HOME/lib/libmkl_vml_mc.so
$ORACLE_HOME/lib/libmkl_vml_mc2.so
$ORACLE_HOME/lib/libmkl_vml_mc3.so
$ORACLE_HOME/lib/libmkl_vml_p4n.so
$ORACLE_HOME/lib/libRblas.so
$ORACLE_HOME/lib/libRlapack.so
$ORACLE_HOME/lib/libR.so"
else
  ORE_FILES="$ORACLE_HOME/lib/librqe.so
$ORACLE_HOME/lib/ore.so
$RBLAS_LIBS
$ORACLE_HOME/lib/libR.so"
fi

fail=0
for f in $ORE_FILES
do
  rm -f $f > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    if [ $fail = 0 ]; then
      fail=1
      echo "Fail"
    fi
    echo "  ERROR: cannot remove $f"
  fi
done
if [ $fail = 0 ]; then
  echo "Pass"
fi

echo " "
echo "Done"
