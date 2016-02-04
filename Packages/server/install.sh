#!/bin/sh
#
# Copyright (c) 2012, 2013, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#      install.sh - ORE server installation script
#
#    DESCRIPTION
#      ORE server installation script
#
#    NOTES
#
#    MODIFIED   (MM/DD/YY)
#    demukhin    03/26/13 - bug 16536750: missing grants when upgrading 1.1
#    demukhin    03/19/13 - ORE version 1.3.1
#    demukhin    02/05/13 - bug 16268465: instance check
#    demukhin    02/05/13 - forward merge from 1.2
#    demukhin    01/30/13 - bug 16239534: multi-node mode
#    qinwan      12/17/12 - use correct ore package name on solaris
#    qinwan      12/06/12 - port install.sh to solaris
#    qinwan      11/19/12 - ore use sunperf on Solaris
#    demukhin    11/09/12 - add a note about supporting packages
#    demukhin    11/06/12 - use MKL
#    demukhin    10/19/12 - prj: no roles
#    demukhin    08/29/12 - ORE version 1.3
#    demukhin    07/25/12 - ORE version 1.2 (minor fixes)
#    demukhin    07/13/12 - ORE version 1.2
#    surikuma    05/25/12 - aix fixes
#    surikuma    05/04/12 - port ore on aix
#    qinwan      04/16/12 - Modify install.sh script for Solaris platform
#    demukhin    03/14/12 - Creation
#

ORE_VER=1.3.1

echo " "
echo "Oracle R Enterprise $ORE_VER Server Installation."
echo " "
echo "Copyright (c) 2012, 2013 Oracle and/or its affiliates. All rights reserved."
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

if [ $ostype = SunOS ]; then
  RBLAS_LIBS=""
else
  RBLAS_LIBS="$R_HOME/lib/libRblas.so
$R_HOME/lib/libRlapack.so"
fi

echo $nr1 "Checking R libraries ......... $nr2"
R_FILES="$R_HOME/lib/libR.so
$RBLAS_LIBS"
for f in $R_FILES
do
  if [ ! -f $f ]; then
    echo "Fail"
    echo "  ERROR: $f not found"
    echo "         R should have been configured with --enable-R-shlib"
    exit 1
  fi
done
echo "Pass"

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
LIBORE=$ORACLE_HOME/lib/ore.so
LIBRQE=$ORACLE_HOME/lib/librqe.so
ORE_LIBS_USER=$ORACLE_HOME/R/library
if [ -z "$R_LIBS_USER" ]; then
  R_LIBS_USER="$ORE_LIBS_USER"
else
  R_LIBS_USER="$ORE_LIBS_USER:$R_LIBS_USER"
fi
export R_LIBS_USER
echo "Pass"

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
set serveroutput on
set timing off
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

cat >tmpdn.sql <<EOF
set echo off
set heads off
set heading off
set feedback off
set timing off
select 1
from   dba_objects
where  owner = 'SYS'
and    object_name = 'RQCONFIGSET';
exit;
EOF
$SQLPLUS_LS @tmpdn.sql >outdn.log
if [ "`wc -l <outdn.log`" -eq "0" ]; then
  has_code=0
else
  has_code=1
fi
rm -f outdn.log
rm -f tmpdn.sql

instdata=0
instcode=1
upgrade=0
downgrade=0
case $ver in
  1.3.1 )
    if [ $has_code = 1 ]; then
      ORE_INS="'ORE' %in% rownames(installed.packages())"
      ORE_CHK="if ($ORE_INS) packageVersion('ORE') == '$ORE_VER' else FALSE"
      HAS_ORE=`R --vanilla --slave -e "$ORE_CHK" | cut -f2 -d' '`
      if [ $HAS_ORE = TRUE ]; then
        echo "Fail"
        echo "  ERROR: ORE $ver is already installed"
        exit 1
      else
        instcode=0
      fi
    else
      downgrade=1
    fi

    echo "Pass"
    ;;
  1.3 )
    echo "Pass"
    upgrade=4
    ;;
  1.2 )
    echo "Pass"
    upgrade=3
    ;;
  1.1 )
    echo "Pass"
    upgrade=2
    ;;
  1.0 )
    echo "Pass"
    upgrade=1
    ;;
  0.0 )
    echo "Pass"
    instdata=1
    ;;
  * ) 
    echo "Fail"
    echo "  ERROR: a later version of ORE $ver is already installed"
    exit 1
    ;;
esac

echo " "
echo "Current configuration"
echo "  R_HOME               = $R_HOME"
echo "  R_LIBS_USER          = $R_LIBS_USER"
echo "  ORACLE_HOME          = $ORACLE_HOME"
echo "  ORACLE_SID           = $ORACLE_SID"
if [ $downgrade = 1 ]; then
  echo "  Existing ORE catalog = $ver"
fi
if [ $upgrade -gt 0 ]; then
  echo "  Existing ORE version = $ver"
fi

if [ $instdata = 1 ]; then
  echo " "
  while true; do
    echo $nr1 "Do you wish to install ORE? [yes] $nr2"
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
  echo "Choosing RQSYS tablespaces"
  RQSYS_PERM="SYSAUX"
  RQSYS_TEMP="TEMP"
  RQSYS_TS="SYSAUX|PERMANENT
  TEMP|TEMPORARY"
  for f in $RQSYS_TS
  do
    TS_NAME=`echo $f | cut -f1 -d'|'`
    TS_TYPE=`echo $f | cut -f2 -d'|'`
    while true; do
      echo $nr1 "  $TS_TYPE tablespace to use for RQSYS [$TS_NAME]: $nr2"
      read TS
      if [ -z "$TS" ]; then
        TS=$TS_NAME
      fi

      cat >tmpts.sql <<EOF
set echo off
set heads off
set heading off
set feedback off
set timing off
select 1
from   dba_tablespaces
where  CONTENTS = '$TS_TYPE'
and    TABLESPACE_NAME = '$TS';
exit;
EOF
      $SQLPLUS_LS @tmpts.sql >outts.log
      if [ "`wc -l <outts.log`" -eq "0" ]; then
        echo "  ERROR: $TS_TYPE tablespace $TS not found"
      else
        TS_NAME=$TS
        break
      fi
    done

    if [ $TS_TYPE = "PERMANENT" ]; then
      RQSYS_PERM=$TS_NAME
    else
      RQSYS_TEMP=$TS_NAME
    fi
    rm -f tmpts.sql
    rm -f outts.log
  done

  echo " "
  echo "Tablespaces summary"
  echo "  PERMANENT tablespace = $RQSYS_PERM"
  echo "  TEMPORARY tablespace = $RQSYS_TEMP"
fi

if [ $downgrade = 1 ]; then
  echo " "
  while true; do
    echo      "  ORE catalog has been downgraded to ORE $ORE_VER"
    echo $nr1 "  Do you wish to complete the downgrade? [yes] $nr2" 
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
fi

if [ $upgrade -gt 0 ]; then
  echo " "
  while true; do
    echo      "  ORE $ver is already installed"
    echo $nr1 "  Do you wish to upgrade to ORE $ORE_VER? [yes] $nr2" 
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
fi

echo " "
if [ $upgrade -gt 0 ]; then
  echo  $nr1 "Removing libraries ........... $nr2"
  case $upgrade in
    4 )
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
        if [ $ostype = SunOS ]; then
          ORE_FILES="$ORACLE_HOME/lib/librqe.so
$ORACLE_HOME/lib/ore.so
$ORACLE_HOME/lib/libR.so"
        else
          ORE_FILES="$ORACLE_HOME/lib/librqe.so
$ORACLE_HOME/lib/ore.so
$ORACLE_HOME/lib/libRblas.so
$ORACLE_HOME/lib/libRlapack.so
$ORACLE_HOME/lib/libR.so"
        fi
      fi
      ;;
    3 )
      if [ $ostype = Linux ]; then
        ORE_FILES="$ORACLE_HOME/lib/librqe.so
$ORACLE_HOME/lib/ore.so
$ORACLE_HOME/lib/libiomp5.so
$ORACLE_HOME/lib/libRblas.so
$ORACLE_HOME/lib/libRlapack.so
$ORACLE_HOME/lib/libR.so"
      else
        ORE_FILES="$ORACLE_HOME/lib/librqe.so
$ORACLE_HOME/lib/ore.so
$ORACLE_HOME/lib/libRblas.so
$ORACLE_HOME/lib/libRlapack.so
$ORACLE_HOME/lib/libR.so"
      fi
      ;;
    2 )
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
$ORACLE_HOME/lib/libRblas.so
$ORACLE_HOME/lib/libRlapack.so
$ORACLE_HOME/lib/libR.so"
      fi
      ;;
    1 )
      ORE_FILES="$ORACLE_HOME/lib/librqe.so
$ORACLE_HOME/lib/ore.so
$ORACLE_HOME/lib/libiomp5.so
$ORACLE_HOME/lib/libRblas.so
$ORACLE_HOME/lib/libRlapack.so
$ORACLE_HOME/lib/libR.so"
      ;;
  esac
  for f in $ORE_FILES
  do
    rm -f $f > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "Fail"
      echo "  ERROR: cannot remove $f"
      exit 1
    fi
  done
  echo "Pass"
fi

echo  $nr1 "Installing libraries ......... $nr2"
if [ $ostype = Linux ]; then
  ORE_FILES="librqe.so
ore.so
libimf.so
libintlc.so
libiomp5.so
libiompprof5.so
libiompstubs5.so
libirc.so
libomp_db.so
libsvml.so
libmkl_avx.so
libmkl_cdft_core.so
libmkl_core.so
libmkl_def.so
libmkl_gf_ilp64.so
libmkl_gf_lp64.so
libmkl_gnu_thread.so
libmkl_intel_ilp64.so
libmkl_intel_lp64.so
libmkl_intel_sp2dp.so
libmkl_intel_thread.so
libmkl_mc.so
libmkl_mc3.so
libmkl_p4n.so
libmkl_pgi_thread.so
libmkl_rt.so
libmkl_sequential.so
libmkl_vml_avx.so
libmkl_vml_def.so
libmkl_vml_mc.so
libmkl_vml_mc2.so
libmkl_vml_mc3.so
libmkl_vml_p4n.so
$R_HOME/lib/libRblas.so
$R_HOME/lib/libRlapack.so
$R_HOME/lib/libR.so"
else
  ORE_FILES="librqe.so
ore.so
$RBLAS_LIBS
$R_HOME/lib/libR.so"
fi
for f in $ORE_FILES
do
  cp $f $ORACLE_HOME/lib > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Fail"
    echo "  ERROR: cannot copy $f to $ORACLE_HOME/lib"
    exit 1
  fi
done
echo "Pass"

if [ $upgrade -gt 0 ]; then
  echo  $nr1 "Removing RQSYS code .......... $nr2"
  case $upgrade in
    4 )
      cat >tmppdrp.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqpdrp03
exit;
EOF
      ;;
    3 )
      cat >tmppdrp.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqpdrp02
exit;
EOF
      ;;
    2 )
      cat >tmppdrp.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqpdrp01
exit;
EOF
      ;;
    1 )
      cat >tmppdrp.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqpdrp00
exit;
EOF
      ;;
  esac
  $SQLPLUS @tmppdrp.sql >rqpdrp.log
  if [ $? -ne 0 ]; then
    echo "Fail"
    echo "  ERROR: cannot drop RQSYS code"
    echo "         see rqpdrp.log for details"
    rm -f tmppdrp.sql
    exit 1
  fi
  rm -f tmppdrp.sql
  echo "Pass"
fi

if [ $instdata = 1 ]; then
  echo  $nr1 "Installing RQSYS data ........ $nr2"

  cat >tmpinst.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqinst $RQSYS_PERM $RQSYS_TEMP $R_HOME $R_LIBS_USER $ORE_VER $LIBORE $LIBRQE
exit;
EOF
  $SQLPLUS @tmpinst.sql >rqinst.log
  if [ $? -ne 0 ]; then
    echo "Fail"
    echo "  ERROR: cannot install RQSYS data"
    echo "         see rqinst.log for details"
    rm -f tmpinst.sql
    exit 1
  fi
  rm -f tmpinst.sql
  echo "Pass"
fi

if [ $upgrade -gt 0 ]; then
  if [ $upgrade -le 1 ]; then
    echo  $nr1 "Upgrading to RQSYS 1.1 ....... $nr2"
    cat >tmpinst.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqu0001000 $R_LIBS_USER
exit;
EOF
    $SQLPLUS @tmpinst.sql >rqinst1.log
    if [ $? -ne 0 ]; then
      echo "Fail"
      echo "  ERROR: cannot upgrade RQSYS schema"
      echo "         see rqinst1.log for details"
      rm -f tmpinst.sql
      exit 1
    fi
    rm -f tmpinst.sql
    echo "Pass"
  fi

  if [ $upgrade -le 2 ]; then
    echo  $nr1 "Upgrading to RQSYS 1.2 ....... $nr2"
    cat >tmpinst.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqu0102000
exit;
EOF
    $SQLPLUS @tmpinst.sql >rqinst2.log
    if [ $? -ne 0 ]; then
      echo "Fail"
      echo "  ERROR: cannot upgrade RQSYS schema"
      echo "         see rqinst2.log for details"
      rm -f tmpinst.sql
      exit 1
    fi
    rm -f tmpinst.sql
    echo "Pass"
  fi

  if [ $upgrade -le 3 ]; then
    echo  $nr1 "Upgrading to RQSYS 1.3 ....... $nr2"
    cat >tmpinst.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqu0203000
exit;
EOF
    $SQLPLUS @tmpinst.sql >rqinst3.log
    if [ $? -ne 0 ]; then
      echo "Fail"
      echo "  ERROR: cannot upgrade RQSYS schema"
      echo "         see rqinst3.log for details"
      rm -f tmpinst.sql
      exit 1
    fi
    rm -f tmpinst.sql
    echo "Pass"
  fi

  if [ $upgrade -le 4 ]; then
    echo  $nr1 "Upgrading to RQSYS 1.3.1 ..... $nr2"
    cat >tmpinst.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqu0304000
exit;
EOF
    $SQLPLUS @tmpinst.sql >rqinst4.log
    if [ $? -ne 0 ]; then
      echo "Fail"
      echo "  ERROR: cannot upgrade RQSYS schema"
      echo "         see rqinst4.log for details"
      rm -f tmpinst.sql
      exit 1
    fi
    rm -f tmpinst.sql
    echo "Pass"
  fi
fi

if [ $instcode = 1 ]; then
  echo  $nr1 "Installing RQSYS code ........ $nr2"

  cat >tmpproc.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rqpcrt
exit;
EOF
  $SQLPLUS @tmpproc.sql >rqproc.log
  if [ $? -ne 0 ]; then
    echo "Fail"
    echo "  ERROR: cannot install RQSYS code"
    echo "         see rqproc.log for details"
    rm -f tmpproc.sql
    exit 1
  fi
  rm -f tmpproc.sql
  echo "Pass"
fi

if [ $upgrade -gt 0 ]; then
  echo  $nr1 "Removing ORE packages ........ $nr2"

  case $upgrade in
    4 )
      ORE_PACKAGES="ORE
ORExml
OREdm
OREeda
OREpredict
OREgraphics
OREstats
OREbase"
      ;;
    3 )
      ORE_PACKAGES="ORE
ORExml
OREeda
OREpredict
OREgraphics
OREstats
OREbase"
      ;;
    2 )
      ORE_PACKAGES="ORE
ORExml
OREeda
OREgraphics
OREstats
OREbase"
      ;;
    1 )
      ORE_PACKAGES="ORE
ORExml
OREeda
OREgraphics
OREstats
OREbase"
      ;;
  esac
  for f in $ORE_PACKAGES
  do
    R --vanilla CMD REMOVE $f > outr.log 2>&1
    if [ $? -ne 0 ]; then
      echo "Fail"
      echo "  ERROR: cannot remove $f"
      rm -f outr.log
      exit 1
    fi
  done
  rm -f outr.log
  echo "Pass"
fi

echo $nr1 "Installing ORE packages ...... $nr2"
mkdir -p $ORE_LIBS_USER > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Fail"
  echo "  ERROR: cannot create $ORE_LIBS_USER"
  exit 1
fi

if [ $ostype = Linux ]; then
  ORE_PLATFORM="x86_64-unknown-linux-gnu"
elif  [ $ostype = AIX ]; then
  ORE_PLATFORM="ppc64-unknown-aix"
else
  MACH=`uname -p`
  if [ $MACH = sparc ]; then
    ORE_PLATFORM="sparc_64-unknown-solaris-sun"
  else
    ORE_PLATFORM="x86_64-unknown-solaris-sun"
  fi 
fi

ORE_PACKAGES="OREbase_${ORE_VER}_R_${ORE_PLATFORM}.tar.gz
OREstats_${ORE_VER}_R_${ORE_PLATFORM}.tar.gz
OREgraphics_${ORE_VER}_R_${ORE_PLATFORM}.tar.gz
OREpredict_${ORE_VER}_R_${ORE_PLATFORM}.tar.gz
OREeda_${ORE_VER}_R_${ORE_PLATFORM}.tar.gz
OREdm_${ORE_VER}_R_${ORE_PLATFORM}.tar.gz
ORExml_${ORE_VER}_R_${ORE_PLATFORM}.tar.gz
ORE_${ORE_VER}_R_${ORE_PLATFORM}.tar.gz"
for f in $ORE_PACKAGES
do
  R --vanilla CMD INSTALL --library=$ORE_LIBS_USER $f > outr.log 2>&1
  if [ $? -ne 0 ]; then
    echo "Fail"
    echo "  ERROR: cannot install $f to $ORE_LIBS_USER"
    rm -f outr.log
    exit 1
  fi
done
echo "Pass"
rm -f outr.log

if [ $upgrade -ge 2 ]; then
  echo $nr1 "Removing ORE script .......... $nr2"
  rm -f $ORACLE_HOME/bin/ORE > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Fail"
    echo "  ERROR: cannot remove $ORACLE_HOME/bin/ORE"
  else
    echo "Pass"
  fi
fi

echo  $nr1 "Creating ORE script .......... $nr2"
cat >$ORACLE_HOME/bin/ORE <<EOF
#!/bin/sh
R_LIBS_USER="$R_LIBS_USER"
export R_LIBS_USER
R \$@
EOF
chmod +x $ORACLE_HOME/bin/ORE
echo "Pass"

echo " "
echo "NOTE: ORE has been enabled for all database users. Next, install the"
echo "      supporting packages."
echo " "
echo "      You may create an ORE user with the demo_user.sh script, which"
echo "      automatically grants the required privileges. A complete list of"
echo "      privileges is available in the script rquser.sql."
echo " "
echo "      To use ORE Embedded R Execution functionality, grant the user"
echo "      the RQADMIN role."
echo " "
echo "      Please, consult the documentation for more information."

echo " "
echo "Done"
