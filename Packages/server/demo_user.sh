#!/bin/sh
#
# Copyright (c) 2012, 2013, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#      demo_user.sh - demo script creating an ORE user
#
#    DESCRIPTION
#      A demo script creating an ORE user.
#
#    NOTES
#
#    MODIFIED   (MM/DD/YY)
#    demukhin    03/19/13 - ORE version 1.3.1
#    demukhin    02/05/13 - bug 16268465: instance check
#    demukhin    02/05/13 - forward merge from 1.2
#    qinwan      12/06/12 - port to solaris
#    demukhin    08/29/12 - ORE version 1.3
#    demukhin    07/25/12 - ORE version 1.2 (minor fixes)
#    demukhin    07/18/12 - ORE version 1.2
#    demukhin    03/16/12 - Creation
#

ORE_VER=1.3.1

echo " "
echo "Oracle R Enterprise $ORE_VER Server User Creation."
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

echo $nr1 "Checking ORACLE_HOME ......... $nr2"
if [ -z "${ORACLE_HOME}" ]; then
  echo "Fail"
  echo "  ERROR: ORACLE_HOME is not set"
  exit 1
fi
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

case $ver in
  1.3.1 )
    echo "Pass"
    ;;
  * ) 
    echo "Fail"
    echo "  ERROR: ORE $ORE_VER is not installed"
    exit 1
    ;;
esac

echo " "
echo "Current configuration"
echo "  ORACLE_HOME          = $ORACLE_HOME"
echo "  ORACLE_SID           = $ORACLE_SID"

echo " "
while true; do
  echo $nr1 "Do you wish to create an ORE user? [yes] $nr2"
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
echo "Choosing tablespaces"
RQUSER_PERM="USERS"
RQUSER_TEMP="TEMP"
RQUSER_TS="USERS|PERMANENT
TEMP|TEMPORARY"
for f in $RQUSER_TS
do
  TS_NAME=`echo $f | cut -f1 -d'|'`
  TS_TYPE=`echo $f | cut -f2 -d'|'`
  while true; do
    echo $nr1 "  $TS_TYPE tablespace to use [$TS_NAME]: $nr2"
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
    RQUSER_PERM=$TS_NAME
  else
    RQUSER_TEMP=$TS_NAME
  fi
  rm -f tmpts.sql
  rm -f outts.log
done

echo " "
echo "Choosing user"
RQ_USER="rquser"
while true; do
  echo $nr1 "  ORE user to use [$RQ_USER]: $nr2"
  read RQUSR
  if [ -z "$RQUSR" ]; then
    RQUSR=$RQ_USER
  fi
  RQUSR_UP=`echo $RQUSR | awk '{ print toupper($1) }'`

  cat >tmpusr.sql <<EOF
set echo off
set heads off
set heading off
set feedback off
set timing off
select 1 
from   dba_users
where  username = '$RQUSR'
or     username = '$RQUSR_UP';
exit;
EOF
  $SQLPLUS_LS @tmpusr.sql >outusr.log
  if [ "`wc -l <outusr.log`" -eq "0" ]; then
    RQ_USER=$RQUSR
    break
  else
    if [ $RQUSR = $RQUSR_UP ]; then
      echo "  ERROR: user $RQUSR already exists"
    else
      echo "  ERROR: user $RQUSR or $RQUSR_UP already exists"
    fi
  fi
done
rm -f tmpusr.sql
rm -f outusr.log

while true; do
  echo $nr1 "  Password to use for user $RQ_USER: $nr2"
  stty_orig=`stty -g`
  stty -echo
  read RQ_PASSW
  stty $stty_orig
  echo " "
  if [ -n "$RQ_PASSW" ]; then
    break
  fi
done

echo " "
echo "Tablespaces and user summary"
echo "  PERMANENT tablespace = $RQUSER_PERM"
echo "  TEMPORARY tablespace = $RQUSER_TEMP"
echo "  ORE user             = $RQ_USER"

echo " "
echo  $nr1 "Creating ORE user ............ $nr2"
cat >tmpuser.sql <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
@@rquser $RQ_USER $RQ_PASSW $RQUSER_PERM $RQUSER_TEMP unlimited
exit;
EOF

$SQLPLUS @tmpuser.sql >rquser.log

if [ $? -ne 0 ]; then
  echo "Fail"
  echo "  ERROR: cannot create ORE user"
  echo "         see rquser.log for details"
  rm -f tmpuser.sql
  exit 1
fi
rm -f tmpuser.sql
echo "Pass"

echo " "
echo "Done"
