/* $Workfile: TRNCO_CM_DIST_PSB.sql $
*  $Revision: 5 $
*  $Archive: /DRTRNT_or_P/PeopleSoft/Tables/OTR_TRNCO_CM_DIST_PSB/TRNCO_CM_DIST_PSB.sql $
*  $Author: Lbdbk $
*  $Date: 7/26/10 11:16a $
*
* Description: This table is loaded from Peoplesoft databases FSTRNx into DRTRNx with a Truncate/Insert.
* Destination table = DRTRNx.DBO.OTR_TRNCO_CM_DIST_PSB
* Source table = FSTRNx.SYSADM.PS_TRNCO_CM_DIST
* 
* Revisions: 
* 
*   change Date    Description 
*   ------------------    ----------------- 
*   06/22/2009     Neeraja V,Cognizant - Self running script. TTP #7924.
* 
***********************************************************************************/ 

set timing on
set pause off
set feedback on
set echo on

spool trnco_cm_dist_psb.log  
whenever sqlerror exit failure;

prompt User and Database Connected To:
select user, name from v$database;

prompt Truncating OTR_TRNCO_CM_DIST_PSB
exec p_truncate_listed_table('dbo','OTR_TRNCO_CM_DIST_PSB');

prompt Altering Session SORT_AREA_SIZE
ALTER SESSION SET SORT_AREA_SIZE = 20971520;

prompt Inserting data into OTR_TRNCO_CM_DIST_PSB
insert /*+ APPEND */ into OTR_TRNCO_CM_DIST_PSB
(BUSINESS_UNIT
, TRNCO_TRAN_SRC_TYP
, TRNCO_TRAN_SRC_ID
, TRNCO_TRAN_LN_SEQ
, TRNCO_CM_HDR_SEQ
, TRNCO_CM_LN_SEQ
, TRNCO_CM_EVT_SEQ
, TRNCO_CM_DST_SEQ
, TRNCO_CM_DIST_ID
, CREATE_DATE
, CREATED_BY_USER
, LAST_MAINT_DTTM
, LAST_MAINT_OPRID
, BUSINESS_UNIT_GL
, ACCOUNT
, DEPTID
, PRODUCT
, DEBIT_AMT
, CREDIT_AMOUNT
, ACCOUNTING_DT
, JOURNAL_ID
, JOURNAL_DATE
, JOURNAL_LINE
, ACCOUNTING_PERIOD
, FISCAL_YEAR
, LEDGER_GROUP
, LEDGER
, GL_DISTRIB_STATUS
, CURRENCY_CD
, FOREIGN_CURRENCY
, FOREIGN_AMOUNT
, PROCESS_INSTANCE) 
SELECT 
BUSINESS_UNIT,
TRNCO_TRAN_SRC_TYP,
TRNCO_TRAN_SRC_ID,
TRNCO_TRAN_LN_SEQ,
TRNCO_CM_HDR_SEQ,
TRNCO_CM_LN_SEQ,
TRNCO_CM_EVT_SEQ,
TRNCO_CM_DST_SEQ,
TRNCO_CM_DIST_ID,
CREATE_DATE,
CREATED_BY_USER,
LAST_MAINT_DTTM,
LAST_MAINT_OPRID,
BUSINESS_UNIT_GL,
ACCOUNT,
DEPTID,
PRODUCT,
DEBIT_AMT,
CREDIT_AMOUNT,
ACCOUNTING_DT,
JOURNAL_ID,
JOURNAL_DATE,
JOURNAL_LINE,
ACCOUNTING_PERIOD,
FISCAL_YEAR,
LEDGER_GROUP,
LEDGER,
GL_DISTRIB_STATUS,
CURRENCY_CD,
FOREIGN_CURRENCY,
FOREIGN_AMOUNT,
PROCESS_INSTANCE
FROM PS_TRNCO_CM_DIST;
COMMIT;

prompt Updating OTR_LOAD_CONTROL
Declare
    count1 number :=0;
    tablename varchar2(30) := 'OTR_TRNCO_CM_DIST_PSB';
    comment_prod varchar2(400) := 'BEFORE6;';
    comment_test varchar2(400) := 'BEFORE6; Not in production yet.';

BEGIN
    SELECT count(*) into count1
    FROM OTR_LOAD_CONTROL olc
    WHERE olc.TABLE_NAME=tablename;

    If count1=0 then
    INSERT into OTR_LOAD_CONTROL
      VALUES(tablename, sysdate, comment_test);
    end if;
    
  IF '&production_variable' = 'Y' then
    UPDATE OTR_LOAD_CONTROL olc 
    SET LOAD_COMMENT=comment_prod,
        LAST_LOAD_DATE=sysdate 
    WHERE olc.TABLE_NAME=tablename;
  ELSIF '&production_variable' = 'N' THEN
    UPDATE OTR_LOAD_CONTROL olc 
    SET LOAD_COMMENT=comment_test,
        LAST_LOAD_DATE=sysdate 
    WHERE olc.TABLE_NAME=tablename;
  ELSE /* Do not change load_comment */
    UPDATE OTR_LOAD_CONTROL olc 
    SET LAST_LOAD_DATE=sysdate
    WHERE olc.TABLE_NAME=tablename;
  END if;

    COMMIT;
    
END;
/

 
