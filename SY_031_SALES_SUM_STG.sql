/* $Workfile: SY_031_SALES_SUM_STG.sql $
*  $Revision: 6 $
*  $Archive: /DRTRNT_or_P/Retrofit Reserve/Tables/SY_031_SALES_SUM_STG/SY_031_SALES_SUM_STG.sql $
*  $Author: Irfhmz $
*  $Date: 7/29/16 3:04p $
*
* Description: This table, DBO.SY_031_SALES_SUM_STG is loaded with 3 different
*      types of data into DRTRNT/DRTRNP.
*              RCPO and Billing (PSB) data is sourced from DRTRNx warehouse.
*              PUEBLO Gross Margin data is sourced from DRTRNx warehouse.
*            This load will run on the 3rd business day of the month and will
*      truncate and load data for the past 24 months except current month.
*
* Destination table = DBO.SY_031_SALES_SUM_STG
* 
* Revisions: 
* 
*   change Date    Description 
*   -----------    ----------- 
*   10/07/2008      Jaishankar SP, Cognizant - Initial Creation
*   3/5/2010        Jill Blank, TTP 9315 - add to_char to credit_job_id
*   3/9/2010        Jill Blank TTP 9315 - Changed 'Pueblo' query to use all ED tables and an index hint 
*                   (tuning)
*   08/26/2010      Neeraja V,Cognizant - TTP# 10231 ED objects are replaced with DR objects(PUEBLO part)
*   07/29/2016      Epuru Amarnath Reedy - TTP #14843 Add P21 revenue to Retrofit Reserve Model
**************************************************************************************************/ 

set timing on
set pause OFF
set feedback on
set echo on

spool sy_031_sales_sum_stg.log  
whenever sqlerror exit failure;

prompt User and Database Connected To:
select user, name from v$database;

prompt Truncating SY_031_SALES_SUM_STG
exec p_truncate_listed_table ('dbo', 'SY_031_SALES_SUM_STG');

prompt Altering Session SORT_AREA_SIZE
ALTER SESSION SET SORT_AREA_SIZE = 20971520;

prompt inserting into SY_031_SALES_SUM_STG

INSERT /*+ APPEND */ INTO DBO.SY_031_SALES_SUM_STG
  SELECT 
    JRNL_YEAR_MONTH as SHIP_PERIOD
    ,COUNTRY_INDICATOR
    ,NVL(SUM(REVENUE_AMOUNT),0) AS REVENUE_AMT
    ,SYSDATE AS ED_CREATE_DATE
    ,USER AS ED_CREATE_ID
    ,SYSDATE AS ED_UPDATE_DATE
    ,USER AS ED_UPDATE_ID
        FROM
        (
        SELECT /* 'RCPO' Source Query */
            SUM(PS.ORDER_AMOUNT * -1) AS REVENUE_AMOUNT
            ,CAST(TO_CHAR(JRNL_DATE,'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE,'MM') AS INTEGER) AS  JRNL_YEAR_MONTH
            ,NVL(AOL.NATION_CURR, PS.CURRENCY_CODE) AS COUNTRY_INDICATOR
        FROM 
            OTR_ORACLE_PS_REV_RCPO PS  
            ,OTR_PROD_CODE_XREF_RCPO PX
            ,ACTUATE_OFFICE_LOCATION AOL
        WHERE 
            PS.JRNL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-24),'MM') AND TRUNC(ADD_MONTHS(LAST_DAY(SYSDATE),-1))
            AND PS.PLNT_GL_BU = PX.GL_LEDGER(+)
            AND PS.PLNT_GL_PROD = PX.MANF_PROD_CODE(+)
            AND PS.GL_DPT_ID = AOL.DEPT_ID (+)
            AND PS.GL_BU_ID=AOL.BU_UNIT  (+)  
        GROUP BY
            CAST(TO_CHAR(PS.JRNL_DATE,'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(PS.JRNL_DATE,'MM') AS INTEGER)
            ,NVL(AOL.NATION_CURR, PS.CURRENCY_CODE)
    UNION ALL
        SELECT /*+ INDEX(AP_400_SEL_CRED_JB_CLSS_CD XIE2AP_400_SEL_CRED_JB_CLSS_CD) */
        /* 'PUEBLO' Source Query */
            (CD.RESOURCE_AMOUNT) AS REVENUE_AMOUNT
            ,TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT,'YYYY')) * 100 + TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT,'MM') )  AS  JRNL_YEAR_MONTH
            ,SEC.NATION_CURRENCY AS COUNTRY_INDICATOR
        FROM
            AP_135_PROJ_RESOURCE PR,
            AP_135_TRNPC_PROJ_RES RES,
            AP_400_SEL_CRED_JB_CLSS_CD JBCLSCD,
            AP_400_JOB_CODE JBCD,
            AP_135_TRNPC_COMM_DATA  CD,
            AP_400_COMM_CODE  CC,
            MD_SECURITY_ENTITY_DRV SEC,
            MD_PRODUCT_CODE MPC          
        WHERE 
            PR.BUSINESS_UNIT_GL = SEC.PS_GL
            AND PR.DEPTID = SEC.PS_DEPT_ID
            AND PR.BUSINESS_UNIT = RES.BUSINESS_UNIT
            AND PR.PROJECT_ID = RES.PROJECT_ID
            AND PR.RESOURCE_ID = RES.RESOURCE_ID
            AND PR.ACTIVITY_ID = RES.ACTIVITY_ID
            AND PR.PROJECT_ID = to_char(JBCLSCD.CREDIT_JOB_ID)
            AND JBCD.JOB_CODE_ID = JBCLSCD.JOB_CODE_ID
            AND PR.BUSINESS_UNIT = CD.BUSINESS_UNIT
            AND PR.PROJECT_ID = CD.PROJECT_ID
            AND PR.RESOURCE_ID = CD.RESOURCE_ID
            AND PR.ACTIVITY_ID = CD.ACTIVITY_ID
            AND CD.TRNPC_COMM_CODE = CC.COMM_CODE
            AND CD.SALES_OFFICE_ID = CC.SALES_OFFICE_ID
            AND RES.TRNPC_MFG_PROD_CD = MPC.PRODUCT_CODE_VALUE 
            AND PR.BUSINESS_UNIT IN ('PCGUS', 'PCGCN')
            AND PR.ANALYSIS_TYPE = 'REV'
            AND (PR.ACCOUNT = '700000' OR PR.ACCOUNT = '700020')
            AND PR.GL_DISTRIB_STATUS = 'G'
            AND JBCD.JOB_CLASS_ID = 38
            AND PR.ACCOUNTING_DT BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-24),'MM') AND TRUNC(ADD_MONTHS(LAST_DAY(SYSDATE),-1))
    UNION ALL
        SELECT /* 'PBS' Source Query. This query has split into 3 UNION ALL queries by runperiod range of 8 months each to 
improve performance*/ 
            SUM(P7_TOTAL * -1 ) AS REVENUE_AMOUNT
            ,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM')) AS JRNL_YEAR_MONTH
            ,NATION_CURR AS COUNTRY_INDICATOR
        FROM (
            SELECT 
                   D.BUSINESS_UNIT_GL AS BUSINESS_UNIT, 
                   D.JOURNAL_DATE AS JRNL_DATE, 
                   D.ACCOUNT AS GL_ACCOUNT, 
                   D.MONETARY_AMOUNT AS P7_TOTAL, 
                   D.CURRENCY_CD AS CURRENCY, 
                   AOL.NATION_CURR 
            FROM 
                   OTR_BI_LINE_PSB A,        
                   OTR_BI_ACCT_ENTRY_PSB D, 
                   OTR_PROD_CODE_XREF_RCPO X, 
                          OTR_TRANE_PRODUCTS_PS PR,         
                          ACTUATE_OFFICE_LOCATION AOL 
             WHERE 
                D.JOURNAL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-8),'MM') AND TRUNC(ADD_MONTHS(LAST_DAY(SYSDATE),-1))   
                 AND D.ACCOUNT = '700000' 
                   AND 'ACTUALS' = D.LEDGER 
                AND '804180' <> D.PRODUCT         
                AND '804120' <> D.PRODUCT       
                AND '804190' <> D.PRODUCT          
                AND D.LINE_SEQ_NUM = A.LINE_SEQ_NUM 
                AND D.INVOICE = A.INVOICE 
                AND D.BUSINESS_UNIT = A.BUSINESS_UNIT        
                AND D.BUSINESS_UNIT = X.GL_LEDGER (+) 
                AND D.PRODUCT = X.MANF_PROD_CODE (+) 
                   AND D.PRODUCT = PR.PRODUCT (+) 
                   AND D.DEPTID = AOL.DEPT_ID (+)   
                   AND D.BUSINESS_UNIT_GL = AOL.BU_UNIT  (+)   
                   AND EXISTS 
                    (SELECT 
                        'X' 
                             FROM 
                        OTR_BI_HDR_PSB B 
                            WHERE 
                        B.BILL_SOURCE_ID = 'PBS' 
                                  AND D.INVOICE = B.INVOICE 
                                  AND D.BUSINESS_UNIT = B.BUSINESS_UNIT) 
                   AND EXISTS 
                    (SELECT 
                        'X' 
                             FROM 
                        OTR_TRNBI_BI_HDR_PSB C 
                            WHERE 
                        '7' = C.TRNBI_PROJECT_TYPE 
                              AND 
                        D.INVOICE = C.INVOICE 
                              AND 
                        D.BUSINESS_UNIT = C.BUSINESS_UNIT)
            UNION ALL
                        SELECT 
                   D.BUSINESS_UNIT_GL AS BUSINESS_UNIT, 
                   D.JOURNAL_DATE AS JRNL_DATE, 
                   D.ACCOUNT AS GL_ACCOUNT, 
                   D.MONETARY_AMOUNT AS P7_TOTAL, 
                   D.CURRENCY_CD AS CURRENCY, 
                   AOL.NATION_CURR 
            FROM 
                   OTR_BI_LINE_PSB A,        
                   OTR_BI_ACCT_ENTRY_PSB D, 
                   OTR_PROD_CODE_XREF_RCPO X, 
                          OTR_TRANE_PRODUCTS_PS PR,         
                          ACTUATE_OFFICE_LOCATION AOL 
             WHERE 
                D.JOURNAL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-16),'MM') AND TRUNC(ADD_MONTHS(LAST_DAY(SYSDATE),-9))    
                 AND D.ACCOUNT = '700000' 
                   AND 'ACTUALS' = D.LEDGER 
                AND '804180' <> D.PRODUCT         
                AND '804120' <> D.PRODUCT       
                AND '804190' <> D.PRODUCT          
                AND D.LINE_SEQ_NUM = A.LINE_SEQ_NUM 
                AND D.INVOICE = A.INVOICE 
                AND D.BUSINESS_UNIT = A.BUSINESS_UNIT        
                AND D.BUSINESS_UNIT = X.GL_LEDGER (+) 
                AND D.PRODUCT = X.MANF_PROD_CODE (+) 
                   AND D.PRODUCT = PR.PRODUCT (+) 
                   AND D.DEPTID = AOL.DEPT_ID (+)   
                   AND D.BUSINESS_UNIT_GL = AOL.BU_UNIT  (+)   
                   AND EXISTS 
                    (SELECT 
                        'X' 
                             FROM 
                        OTR_BI_HDR_PSB B 
                            WHERE 
                        B.BILL_SOURCE_ID = 'PBS' 
                                  AND D.INVOICE = B.INVOICE 
                                  AND D.BUSINESS_UNIT = B.BUSINESS_UNIT) 
                   AND EXISTS 
                    (SELECT 
                        'X' 
                             FROM 
                        OTR_TRNBI_BI_HDR_PSB C 
                            WHERE 
                        '7' = C.TRNBI_PROJECT_TYPE 
                              AND 
                        D.INVOICE = C.INVOICE 
                              AND 
                        D.BUSINESS_UNIT = C.BUSINESS_UNIT)
             UNION ALL
                        SELECT 
                   D.BUSINESS_UNIT_GL AS BUSINESS_UNIT, 
                   D.JOURNAL_DATE AS JRNL_DATE, 
                   D.ACCOUNT AS GL_ACCOUNT, 
                   D.MONETARY_AMOUNT AS P7_TOTAL, 
                   D.CURRENCY_CD AS CURRENCY, 
                   AOL.NATION_CURR 
            FROM 
                   OTR_BI_LINE_PSB A,        
                   OTR_BI_ACCT_ENTRY_PSB D, 
                   OTR_PROD_CODE_XREF_RCPO X, 
                          OTR_TRANE_PRODUCTS_PS PR,         
                          ACTUATE_OFFICE_LOCATION AOL 
             WHERE 
                D.JOURNAL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-24),'MM') AND TRUNC(ADD_MONTHS(LAST_DAY(SYSDATE),-17))   
                 AND D.ACCOUNT = '700000' 
                   AND 'ACTUALS' = D.LEDGER 
                AND '804180' <> D.PRODUCT         
                AND '804120' <> D.PRODUCT       
                AND '804190' <> D.PRODUCT          
                AND D.LINE_SEQ_NUM = A.LINE_SEQ_NUM 
                AND D.INVOICE = A.INVOICE 
                AND D.BUSINESS_UNIT = A.BUSINESS_UNIT        
                AND D.BUSINESS_UNIT = X.GL_LEDGER (+) 
                AND D.PRODUCT = X.MANF_PROD_CODE (+) 
                   AND D.PRODUCT = PR.PRODUCT (+) 
                   AND D.DEPTID = AOL.DEPT_ID (+)   
                   AND D.BUSINESS_UNIT_GL = AOL.BU_UNIT  (+)   
                   AND EXISTS 
                    (SELECT 
                        'X' 
                             FROM 
                        OTR_BI_HDR_PSB B 
                            WHERE 
                        B.BILL_SOURCE_ID = 'PBS' 
                                  AND D.INVOICE = B.INVOICE 
                                  AND D.BUSINESS_UNIT = B.BUSINESS_UNIT) 
                   AND EXISTS 
                    (SELECT 
                        'X' 
                             FROM 
                        OTR_TRNBI_BI_HDR_PSB C 
                            WHERE 
                        '7' = C.TRNBI_PROJECT_TYPE 
                              AND 
                        D.INVOICE = C.INVOICE 
                              AND 
                        D.BUSINESS_UNIT = C.BUSINESS_UNIT)
                      )
            GROUP BY 
                TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM')) 
                ,NATION_CURR
	UNION ALL  /*TTP #14843 Add P21 revenue to Retrofit Reserve Model*/
	SELECT
         SUM (P7_TOTAL) * -1 AS REVENUE_AMOUNT,
         TO_NUMBER (TO_CHAR (TO_DATE (JRNL_DATE), 'YYYY')) * 100
         + TO_NUMBER (TO_CHAR (TO_DATE (JRNL_DATE), 'MM'))  AS JRNL_YEAR_MONTH,
         NATION_CURR AS COUNTRY_INDICATOR
    FROM (SELECT                                         /*+ NO_CPU_COSTING */
                D.BUSINESS_UNIT_GL AS BUSINESS_UNIT,
                 D.INVOICE AS INVOICE,
                 D.LINE_SEQ_NUM AS SEQ_NUM,
                 D.ACCT_ENTRY_TYPE AS ENTRY_TYPE,
                 D.JOURNAL_ID AS JRNL_ID,
                 D.JOURNAL_DATE AS JRNL_DATE,
                 D.ACCOUNT AS GL_ACCOUNT,
                 D.MONETARY_AMOUNT AS P7_TOTAL,
                 D.DEPTID AS DEPTID,
                 AOL.OFFICE_NAME AS DEPT_DESCR,
                 PR.DESCR AS PROD_DESCR,
                 X.PRODUCT_CATEGORY AS RESERVE_GROUP,
                 A.IDENTIFIER AS PRODCODE,
                 CASE WHEN D.PRODUCT = '0064' THEN '804155' ELSE D.PRODUCT END
                    AS GL_PRODCODE,
                 D.CURRENCY_CD AS CURRENCY,
                 AOL.NATION_CURR
            FROM OTR_BI_LINE_PSB A,
                 OTR_BI_ACCT_ENTRY_PSB D,
                 OTR_PROD_CODE_XREF_RCPO X,
                 OTR_TRANE_PRODUCTS_PS PR,
                 ACTUATE_OFFICE_LOCATION AOL
           WHERE D.JOURNAL_DATE BETWEEN TO_DATE ('01/11/2014', 'MM/DD/YYYY')
                                    AND LAST_DAY (ADD_MONTHS (SYSDATE, -1))
                 AND '700000' = D.ACCOUNT
                 AND 'ACTUALS' = D.LEDGER
                 AND '805100' <> D.PRODUCT
                 AND '802921' <> D.PRODUCT
                 AND '801270' <> D.PRODUCT
                 AND '803270' <> D.PRODUCT
                 AND '804140' <> D.PRODUCT
                 AND D.LINE_SEQ_NUM = A.LINE_SEQ_NUM
                 AND D.INVOICE = A.INVOICE
                 AND D.BUSINESS_UNIT = A.BUSINESS_UNIT
                 AND D.BUSINESS_UNIT = X.GL_LEDGER(+)
                 AND D.PRODUCT = X.MANF_PROD_CODE(+)
                 AND D.PRODUCT = PR.PRODUCT(+)
                 AND D.DEPTID = AOL.DEPT_ID(+)
                 AND D.BUSINESS_UNIT_GL = AOL.BU_UNIT(+)
                 AND EXISTS
                        (SELECT               /* index(b XPKOTR_BI_HDR_PSB) */
                               'X'
                           FROM OTR_BI_HDR_PSB B
                          WHERE     B.BILL_SOURCE_ID = 'P21'
                                AND D.INVOICE = B.INVOICE
                                AND D.BUSINESS_UNIT = B.BUSINESS_UNIT)
                 AND EXISTS
                        (SELECT         /* index(c XPKOTR_TRNBI_BI_HDR_PSB) */
                               'X'
                           FROM OTR_TRNBI_BI_HDR_PSB C
                          WHERE     '7' = C.TRNBI_PROJECT_TYPE
                                AND D.INVOICE = C.INVOICE
                                AND D.BUSINESS_UNIT = C.BUSINESS_UNIT))
GROUP BY 
         TO_NUMBER (TO_CHAR (TO_DATE (JRNL_DATE), 'YYYY')) * 100
         + TO_NUMBER (TO_CHAR (TO_DATE (JRNL_DATE), 'MM')),
         NATION_CURR
    )
    GROUP BY
    JRNL_YEAR_MONTH
    ,COUNTRY_INDICATOR
    ;
COMMIT;

prompt Updating OTR_LOAD_CONTROL
Declare
	count1 number :=0;
	tablename varchar2(30) := 'SY_031_SALES_SUM_STG';
	comment1 varchar2(400) := 'AFTER6; This table is loaded on 5th business day of each month';
BEGIN
	SELECT count(*) into count1
	FROM OTR_LOAD_CONTROL olc
	WHERE olc.TABLE_NAME=tablename;

	If count1=0 then
	INSERT into OTR_LOAD_CONTROL
		VALUES(tablename, sysdate, comment1);
	end if;

UPDATE OTR_LOAD_CONTROL olc
SET LAST_LOAD_DATE=sysdate
WHERE olc.TABLE_NAME=tablename;

   
COMMIT;
END;
/
EXIT
