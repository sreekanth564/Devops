####################################################################################
#       Title:         : vector_annual_planrenewal.sh
##      Description    : PR_VECTOR_ANNUAL_PLANRENEWAL  pl/sql procedure
##      Author         : Prabu M
##      Date           : 22-03-2017
##      Revision Date  :
##      Script to call :
####################################################################################
. ${VECTOR_FILES_ROOT}/bin/setfl.sh
SQL_USERNAME="${VECTOR_BATCH_REF_USERNAME}"
SQL_PASSWORD="${VECTOR_BATCH_REF_PASSWORD}"
DB_REF="${VECTOR_REF}"

CREATEDATE=$(date +%Y%m%d)
CREATETIME=$(date +%H%M%S)

export OUTPUT_FILE_NAME="${VECTOR_LOG}/vector_annual_planrenewal_${CREATEDATE}${CREATETIME}.log"
export TCS_LOG="${VECTOR_LOG}/vector_annual_planrenewal_${CREATEDATE}${CREATETIME}.log"

function ON_ERROR
{
   STAGE="vector_annual_planrenewal.sh Job Failed: ${CREATEDATE} ${CREATETIME} ."
   echo "$STAGE"
   date
   exit 1
}

function ON_SUCCESS
{
    echo "           vector_annual_planrenewal.sh Completed Successfully "
    Success_header1="vector_annual_planrenewal.sh Completed Successfully "
    Success_header2="Execution date: ${CREATEDATE}  ${CREATETIME}"
    date
    STAGE="Sending mail to distribution list"
    exit 0
}
if [ $# -gt 0 ]
then
     echo " "
     echo "---------------------------------------------------------------------"
     echo "           Error: No Arguments Required                              "
     echo "           Usage: vector_annual_planrenewal.sh                       "
     echo "---------------------------------------------------------------------"
     ON_ERROR ${OUTPUT_FILE_NAME}
fi

if [ $# -eq 0 ]
then
echo "------------------ Starting executing vector_annual_planrenewal----------- "
STAGE="Starting vector_annual_planrenewal ${DATE}"
sqlplus -S ${SQL_USERNAME}/${SQL_PASSWORD}@${DB_REF}>>${TCS_LOG}<<ENDOFSQL
WHENEVER SQLERROR EXIT 1;
whenever oserror exit 1;
set serveroutput on;
declare
run_date date := sysdate;
run_frequency number := 0;
begin
 begin
 select nvl(max(run_freq),0)+1
 into run_frequency
 from t_tracelog
 where module_name like 'ANNUAL_PLANRENEWAL%'
 and to_date(to_char(time,'dd-mon-yyyy'),'dd-mon-yyyy') = trunc(sysdate);
exception
 when no_data_found then
   run_frequency := 0;
end;
PR_VECTOR_ANNUAL_PLANRENEWAL(run_date,run_frequency);
end;
/
ENDOFSQL
  if [ $? -eq 1 ]
  then
     echo " "
     echo "---------------------------------------------------------------------"
     echo "           Error executing vector_annual_planrenewal"
     echo "---------------------------------------------------------------------"
     ON_ERROR ${OUTPUT_FILE_NAME}
   else
     echo "------------------ Completed executing vector_annual_planrenewal-----"
     date
  fi
ON_SUCCESS  ${OUTPUT_FILE_NAME}
fi
