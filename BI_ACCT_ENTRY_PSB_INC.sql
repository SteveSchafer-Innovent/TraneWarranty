/* $Workfile: BI_ACCT_ENTRY_PSB_INC.sql $
*  $Revision: 4 $
*  $Archive: /DRTRNT_or_P/PeopleSoft Billing and RCPO - 115/Tables/OTR_BI_ACCT_ENTRY_PSB/BI_ACCT_ENTRY_PSB_INC.sql $
*  $Author: Laiqi $
*  $Date: 12/31/11 12:10p $
*
* Description: This table is loaded from Peoplesoft databases FSTRNx.  It is an incremental load that does a truncate/insert
*     on the current partition (NO Archive) which holds the curren year plus two previous years of data.  This was implemented to improve
*     load performance.  An extra check is performed during the month of January to move the oldest year into the non-current
*     (YES Archive) partition.
*
* Destination table = DRTRNx.DBO.OTR_BI_ACCT_ENTRY_PSB
* Source table = FSTRNx.SYSADM.PS_BI_ACCT_ENTRY
* 
* Revisions: 
* 
*   change Date    Description 
*   -------------------    --------------- 
*   06/16/2009     Neeraja V,Cognizant - Self-running script. TTP #7915.
*   03/29/2010     Chinnathambi S,Cognizant- Add all the columns from source- ED to DR migration - TTP 7578
*   07/08/2010     Andrew Wiersma,Trane- Added our index manip code- TTP 7915
*   06/16/2011     Nithin Raj,Cognizant- Modified to incremental load to reload present year and past two year data - TTP 10014
*   12/14/2011     Bhavani,Cognizant - Modified the script to move data from non-archive partition into archive partition if more than 3years in
*                                                     january month- TTP 10014
*   12/27/2011	   Prasanth V,Cognizant - Removed the condition on archive data having NULL journal date - TTP 10014
******************************************************************************************************************/ 

set timing on
set pause off
set feedback on
set echo on

spool bi_acct_entry_psb_inc.log  
whenever sqlerror exit failure;

prompt User and Database Connected To:
select user, name from v$database;


prompt inserting data into OTR_BI_ACCT_ENTRY_PSB
DECLARE

V_START_DATE DATE:=ADD_MONTHS (TRUNC (SYSDATE, 'YYYY'), -24);

BEGIN
/* Perform this check all of Jan to avoid losing data if the module is not run for some reason.
  Checks the data warehouse table to see if there is any data in the No Archive partition that is older than the 3 years that
  will be loaded daily.  If there is, it is moved to the Yes Archive partition before the truncate so that it will not be lost.  The only
  time this can occur is in January of a new year. */
IF TO_NUMBER(TO_CHAR(TRUNC(SYSDATE),'MMDD')) BETWEEN  0101 AND 0131 THEN
insert /*+ APPEND */ into OTR_BI_ACCT_ENTRY_PSB
(BUSINESS_UNIT
, INVOICE
, LINE_SEQ_NUM
, ACCOUNTING_DT
, ACCT_ENTRY_TYPE
, DISC_SUR_LVL
, DISC_SUR_ID
, LINE_DST_SEQ_NUM
, TAX_AUTHORITY_CD
, PROCESS_INSTANCE
, DISC_SUR_INDICATOR
, BUSINESS_UNIT_GL
, LEDGER_GROUP
, LEDGER
, ACCOUNTING_PERIOD
, FISCAL_YEAR
, ACCOUNT
, ALTACCT
, OPERATING_UNIT
, DEPTID
, PRODUCT
, PROJECT_ID
, AFFILIATE
, STATISTICS_CODE
, MONETARY_AMOUNT
, STATISTIC_AMOUNT
, JRNL_LN_REF
, LINE_DESCR
, USER1
, USER2
, USER3
, USER4
, USER5
, JOURNAL_ID
, JOURNAL_DATE
, JOURNAL_LINE
, BUDGET_HDR_STATUS
, BUDGET_LINE_STATUS
, KK_TRAN_OVER_FLAG
, KK_TRAN_OVER_OPRID
, GL_DISTRIB_STATUS
, APPL_JRNL_ID
, CURRENCY_CD
, FOREIGN_CURRENCY
, FOREIGN_AMOUNT
, RT_TYPE
, DOC_TYPE
, DOC_SEQ_NBR
, DOC_SEQ_DATE
, RATE_MULT
, RATE_DIV
, FROM_ACCRUAL
, BUSINESS_UNIT_PC
, ACTIVITY_ID
, RESOURCE_TYPE
, RESOURCE_CATEGORY
, RESOURCE_SUB_CAT
,AFFILIATE_INTRA1
,AFFILIATE_INTRA2
,BUDGET_DT
,BUDGET_REF
,CHARTFIELD1
,CHARTFIELD2
,CHARTFIELD3
,CLASS_FLD
,ENTRY_EVENT
,FUND_CODE
,KK_TRAN_OVER_DTTM
,PROGRAM_CODE
,ED_CREATE_DATE
,ED_CREATE_ID
,ARCHIVE_FLAG
)
SELECT 
BUSINESS_UNIT
, INVOICE
, LINE_SEQ_NUM
, ACCOUNTING_DT
, ACCT_ENTRY_TYPE
, DISC_SUR_LVL
, DISC_SUR_ID
, LINE_DST_SEQ_NUM
, TAX_AUTHORITY_CD
, PROCESS_INSTANCE
, DISC_SUR_INDICATOR
, BUSINESS_UNIT_GL
, LEDGER_GROUP
, LEDGER
, ACCOUNTING_PERIOD
, FISCAL_YEAR
, ACCOUNT
, ALTACCT
, OPERATING_UNIT
, DEPTID
, PRODUCT
, PROJECT_ID
, AFFILIATE
, STATISTICS_CODE
, MONETARY_AMOUNT
, STATISTIC_AMOUNT
, JRNL_LN_REF
, LINE_DESCR
, USER1
, USER2
, USER3
, USER4
, USER5
, JOURNAL_ID
, JOURNAL_DATE
, JOURNAL_LINE
, BUDGET_HDR_STATUS
, BUDGET_LINE_STATUS
, KK_TRAN_OVER_FLAG
, KK_TRAN_OVER_OPRID
, GL_DISTRIB_STATUS
, APPL_JRNL_ID
, CURRENCY_CD
, FOREIGN_CURRENCY
, FOREIGN_AMOUNT
, RT_TYPE
, DOC_TYPE
, DOC_SEQ_NBR
, DOC_SEQ_DATE
, RATE_MULT
, RATE_DIV
, FROM_ACCRUAL
, BUSINESS_UNIT_PC
, ACTIVITY_ID
, RESOURCE_TYPE
, RESOURCE_CATEGORY
, RESOURCE_SUB_CAT
,AFFILIATE_INTRA1
,AFFILIATE_INTRA2
,BUDGET_DT
,BUDGET_REF
,CHARTFIELD1
,CHARTFIELD2
,CHARTFIELD3
,CLASS_FLD
,ENTRY_EVENT
,FUND_CODE
,KK_TRAN_OVER_DTTM
,PROGRAM_CODE
,SYSDATE AS ED_CREATE_DATE,
 'BI_ACCT_ENTRY_PSB_INC.sql' as ED_CREATE_ID,
'Y' AS ARCHIVE_FLAG
FROM
  OTR_BI_ACCT_ENTRY_PSB
WHERE JOURNAL_DATE < V_START_DATE
AND ARCHIVE_FLAG='N'
;
COMMIT;
END IF;


-- Truncating the Non-archived partition
dbo.p_truncate_listed_partition('DBO','OTR_BI_ACCT_ENTRY_PSB','PART_NO');

-- Making Indexes unusable on dbo.OTR_BI_ACCT_ENTRY_PSB
dbo.Pkg_Mass_Load_par_Index_Manip.p_make_tbl_inds_unusable('DBO', 'OTR_BI_ACCT_ENTRY_PSB', TRUE, 'PART_NO');

insert /*+ APPEND */ into OTR_BI_ACCT_ENTRY_PSB
( BUSINESS_UNIT
, INVOICE
, LINE_SEQ_NUM
, ACCOUNTING_DT
, ACCT_ENTRY_TYPE
, DISC_SUR_LVL
, DISC_SUR_ID
, LINE_DST_SEQ_NUM
, TAX_AUTHORITY_CD
, PROCESS_INSTANCE
, DISC_SUR_INDICATOR
, BUSINESS_UNIT_GL
, LEDGER_GROUP
, LEDGER
, ACCOUNTING_PERIOD
, FISCAL_YEAR
, ACCOUNT
, ALTACCT
, OPERATING_UNIT
, DEPTID
, PRODUCT
, PROJECT_ID
, AFFILIATE
, STATISTICS_CODE
, MONETARY_AMOUNT
, STATISTIC_AMOUNT
, JRNL_LN_REF
, LINE_DESCR
, USER1
, USER2
, USER3
, USER4
, USER5
, JOURNAL_ID
, JOURNAL_DATE
, JOURNAL_LINE
, BUDGET_HDR_STATUS
, BUDGET_LINE_STATUS
, KK_TRAN_OVER_FLAG
, KK_TRAN_OVER_OPRID
, GL_DISTRIB_STATUS
, APPL_JRNL_ID
, CURRENCY_CD
, FOREIGN_CURRENCY
, FOREIGN_AMOUNT
, RT_TYPE
, DOC_TYPE
, DOC_SEQ_NBR
, DOC_SEQ_DATE
, RATE_MULT
, RATE_DIV
, FROM_ACCRUAL
, BUSINESS_UNIT_PC
, ACTIVITY_ID
, RESOURCE_TYPE
, RESOURCE_CATEGORY
, RESOURCE_SUB_CAT
,AFFILIATE_INTRA1
,AFFILIATE_INTRA2
,BUDGET_DT
,BUDGET_REF
,CHARTFIELD1
,CHARTFIELD2
,CHARTFIELD3
,CLASS_FLD
,ENTRY_EVENT
,FUND_CODE
,KK_TRAN_OVER_DTTM
,PROGRAM_CODE
,ED_CREATE_DATE
,ED_CREATE_ID
,ARCHIVE_FLAG
)
SELECT 
BUSINESS_UNIT,
INVOICE,
LINE_SEQ_NUM,
ACCOUNTING_DT,
ACCT_ENTRY_TYPE,
DISC_SUR_LVL,
DISC_SUR_ID,
LINE_DST_SEQ_NUM,
TAX_AUTHORITY_CD,
PROCESS_INSTANCE,
DISC_SUR_INDICATOR,
BUSINESS_UNIT_GL,
LEDGER_GROUP,
LEDGER,
NVL(to_char(JOURNAL_DATE,'MM'),0) as ACCOUNTING_PERIOD,
NVL(to_char(JOURNAL_DATE,'YYYY'),0) as FISCAL_YEAR,
ACCOUNT,
ALTACCT,
OPERATING_UNIT,
DEPTID,
PRODUCT,
PROJECT_ID,
AFFILIATE,
STATISTICS_CODE,
MONETARY_AMOUNT,
STATISTIC_AMOUNT,
JRNL_LN_REF,
LINE_DESCR,
USER1,
USER2,
USER3,
USER4,
USER5,
JOURNAL_ID,
JOURNAL_DATE,
JOURNAL_LINE,
BUDGET_HDR_STATUS,
BUDGET_LINE_STATUS,
KK_TRAN_OVER_FLAG,
KK_TRAN_OVER_OPRID,
GL_DISTRIB_STATUS,
APPL_JRNL_ID,
CURRENCY_CD,
FOREIGN_CURRENCY,
FOREIGN_AMOUNT,
RT_TYPE,
DOC_TYPE,
DOC_SEQ_NBR,
DOC_SEQ_DATE,
RATE_MULT,
RATE_DIV,
FROM_ACCRUAL,
BUSINESS_UNIT_PC,
ACTIVITY_ID,
RESOURCE_TYPE,
RESOURCE_CATEGORY,
RESOURCE_SUB_CAT
,AFFILIATE_INTRA1
,AFFILIATE_INTRA2
,BUDGET_DT
,BUDGET_REF
,CHARTFIELD1
,CHARTFIELD2
,CHARTFIELD3
,CLASS_FLD
,ENTRY_EVENT
,FUND_CODE
,KK_TRAN_OVER_DTTM
,PROGRAM_CODE
,SYSDATE as ED_CREATE_DATE
,'BI_ACCT_ENTRY_PSB_INC.sql' as ED_CREATE_ID
,'N' AS ARCHIVE_FLAG
FROM 
PS_BI_ACCT_ENTRY 
WHERE JOURNAL_DATE >= V_START_DATE OR JOURNAL_DATE is null
;
COMMIT;

--Rebuilding Indexes on dbo.OTR_BI_ACCT_ENTRY_PSB
dbo.Pkg_Mass_Load_par_Index_Manip.p_rebuild_tbl_inds('DBO', 'OTR_BI_ACCT_ENTRY_PSB', FALSE, 'PART_NO');
END;
/

prompt Updating OTR_LOAD_CONTROL
Declare
    count1 number :=0;
    tablename varchar2(30) := 'OTR_BI_ACCT_ENTRY_PSB';
    comment_prod varchar2(400) := 'BEFORE6; Incremental Truncates NO Archive partition and loads current year and two previous years only.';
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

EXIT
 
