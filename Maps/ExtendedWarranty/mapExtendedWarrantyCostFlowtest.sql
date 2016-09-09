SELECT 
MLR.CLAIM_NBR AS CLAIM_NUMBER, 
MLR.STEP_NBR AS STEP_NUMBER, 
GLA.R12_ENTITY /* -SS- COMPANY */ AS BUSINESS_UNIT, 
PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
CTYPES.CLAIM_TYPE_DESCR AS CLAIM_TYPE, 
SUM(MLR.EXP_TYPE_AMOUNT*-1) AS EXPENSE_AMOUNT, 
--SUM(MLR.EXP_TYPE_AMOUNT) AS EXPENSE_AMOUNT, 
SUM(100*(MLR.EXP_TYPE_AMOUNT*-1-TRUNC(MLR.EXP_TYPE_AMOUNT*-1))) AS EXPENSE_AMOUNT_DEC,
RES_PCT.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
GLA.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
ETS.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR, 
SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME, 
CASE WHEN GLA.R12_PRODUCT /* -SS- PROD_CODE */ is null or GLA.R12_PRODUCT /* -SS- PROD_CODE */ = '' then  PCS.PROD_CODE else GLA.R12_PRODUCT /* -SS- PROD_CODE */ end AS GL_PROD_CODE,
PCS.PROD_CODE AS MANF_PROD_CODE, 
SOS.COMPANY_OWNED_IND AS COMPANY_OWNED, 
CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER, 
CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME, 
(CASE WHEN CACCT.CUST_CREDIT_CATG_CODE='Z1' THEN 'Y' ELSE 'N' END) AS INTERNAL_EXTERNAL, 
TD3.FULL_DATE AS TRX_DATE,  
TO_CHAR(TD3.YEAR) AS TRX_YEAR,
TO_CHAR(TD3.MONTH) AS TRX_MONTH, 
CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1))))+1 AS INTMONTHS_TRX_TO_BASE,
CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1))))+1 AS INTMONTHS_SHIP_TO_BASE,
TD2.FULL_DATE AS SHIP_DATE, 
( TD2.YEAR * 100 + TD2.MONTH ) AS SHIP_YEAR_MONTH, 
CEIL( ( (TD3.TIME_KEY - TD2.TIME_KEY) / 30.42 ) ) + 1 AS INTMONTHS_SHIP_TO_TRX, 
TD.FULL_DATE AS START_DATE, 
( (TD3.TIME_KEY - TD.TIME_KEY) / 30.42 ) AS INTMONTHS_START_TO_TRX, 
TD1.FULL_DATE AS FAIL_DATE, 
( (TD3.TIME_KEY - TD1.TIME_KEY) / 30.42 ) AS INTMONTHS_FAIL_TO_TRX, 
/* PER JACKIE'S REQUEST ON 5/24/07 IF FAIL DATE = 1/1/1900 OR NULL THEN SET WARRANTY TYPE TO NO. */
(CASE WHEN TD1.FULL_DATE=TO_DATE('1/1/1900','MM/DD/YYYY') OR TD1.FULL_DATE IS NULL THEN 'NO'  ELSE  FCW.WA_POLICY_TYPE  END) AS WARRANTY_TYPE, 
(case when FCW.WA_RANGE='1'  then '1st Year Standard Warranty'
    when FCW.WA_RANGE= '2' then '2nd-5th Year Standard Warranty'
    when FCW.WA_RANGE='5' then '> 5th Year Standard Warranty'
    else 'Out of Standard Warranty' 
 end) AS WARRANTY_DURATION, 
MLR.TRX_CURRENCY AS CURRENCY
,(
	CASE
	WHEN GLA.R12_ENTITY IN ('5773', '5588') /* -SS- ASX.NATION_CURR='USD' */ THEN 'USA'
	ELSE 'CAN'
	/* -SS-
	WHEN ASX.NATION_CURR='CAD' THEN 'CAN' 
	ELSE 'CURRENCY: ' || ASX.NATION_CURR 
	*/
	END
) AS COUNTRY_INDICATOR
/* NEW FIELDS ADDED 5/21/07 */
,MLR.RETRO_ID AS RETROFIT_ID
,GLA.R12_COST_CENTER /* -SS- COST_CENTER */ AS GL_DEPT
/* 2-5Year Specific */  
,10000*(
CASE WHEN (PCS.PROD_CODE='0061' and CTYPES.CLAIM_TYPE_DESCR='MATERIAL') /* BR6 */
or (PCS.PROD_CODE in ('0054','0197')) /* BR4 */
or (NVL(FCW.WA_RANGE,'0') NOT IN ( '2' , '5') )/* BR3 */  
OR (ROUND((TD3.FULL_DATE - TD2.FULL_DATE)/30.42)>91) /* BR5 */ 
OR (ROUND((TD.FULL_DATE - TD2.FULL_DATE)/30.42)>24)
THEN 0 ELSE RES_PCT.RESERVE_PCT  END) AS IN_RESERVE_PERCENT

--, 10000*(CASE WHEN PCS.PROD_CODE='0061'  or FCW.WA_RANGE<>'1' THEN 0 ELSE RES_PCT.RESERVE_PCT  END) AS IN_RESERVE_PERCENT
, ROUND((TD3.FULL_DATE - TD2.FULL_DATE)/30.42) AS TRX_LAG
, ROUND((TD.FULL_DATE - TD2.FULL_DATE)/30.42) AS Start_Lag
, 100*TD3.YEAR+TD3.MONTH AS TRXYEARMONTH
--,MLR.EXP_TYPE_AMOUNT *(CASE WHEN PCS.PROD_CODE='0061' then 0 ELSE RES_PCT.RESERVE_PCT  END)*-1  AS EXPENSE_AMT_IN_RES
, 0 AS EXPENSE_AMT_IN_RES
--,MLR.EXP_TYPE_AMOUNT *(1-(CASE WHEN PCS.PROD_CODE='0061' then 0 ELSE RES_PCT.RESERVE_PCT  END))*-1  AS EXPENSE_AMT_NOT_IN_RES
, 0 AS EXPENSE_AMT_NOT_IN_RES
,TD2.MONTH AS Ship_month
,TD2.YEAR  as Ship_year
,PSA.descr as description
FROM
WC_MAT_LBR_ROLLUP MLR
, EXPENSE_TYPE_SCD ET
,DM_FAL_CLAIMS_WARRANTY_XRF FCW
,TIME_DAY TD3
,TIME_DAY TD2
,TIME_DAY TD1
,TIME_DAY TD
,CLAIM_TASK_SCD CTASKS
,CLAIM_TYPE_SCD CTYPES
, R12_GL_ACCOUNT_SCD /* -SS- */ GLA
,EXPENSE_TYPE_SCD ETS
,PROD_CODE_SCD PCS
,CUST_ACCOUNT_SCD CACCT
,SUBMIT_OFFICE_SCD SOS
, OTR_PROD_CODE_XREF_RCPO PRODGRP -- -SS- @DR_INTFC_DW.LAX.TRANE.COM
/* -SS- ,ACTUATE_SEC_XREF ASX */
, DM_WAR_CSN_RSV_PCT_REF RES_PCT
, R12_TRANE_ACCOUNTS_PS /* -SS- OTR @DR_INTFC_DW.LAX.TRANE.COM */ PSA
WHERE 1=1 
--and MLR.CLAIM_NBR =1617369
/*  this portion for 'MATERIAL','RETROFIT MATERIAL'  */
--and (MLR.CLAIM_TYPE_SCD_KEY= 9 or MLR.CLAIM_TYPE_SCD_KEY= 10)
and MLR.CLAIM_TYPE_SCD_KEY <> 11
AND MLR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY 
AND MLR.CLAIM_NBR=FCW.CLAIM_NBR (+)
AND MLR.DETAIL_NBR=FCW.DETAIL_NBR (+)
AND MLR.STEP_NBR=FCW.STEP_NBR(+)
/* TD3 FOR TRX DATE */
AND MLR.CCN_TRX_DATE_KEY=TD3.TIME_KEY
/* TD2 FOR ORIGINAL SHIP DATE */
AND MLR.ORIGINAL_SHIP_DATE_KEY= TD2.TIME_KEY
/* TD1 FOR FAIL DATE */
AND MLR.FAIL_DATE_KEY=TD1.TIME_KEY 
/* TD FOR START DATE */
AND MLR.START_DATE_KEY= TD.TIME_KEY
AND MLR.CLAIM_TASK_SCD_KEY = CTASKS.CLAIM_TASK_SCD_KEY
AND MLR.CLAIM_TYPE_SCD_KEY = CTYPES.CLAIM_TYPE_SCD_KEY
AND MLR.GL_ACCOUNT_SCD_KEY= GLA.GL_ACCOUNT_SCD_KEY
AND MLR.EXPENSE_TYPE_SCD_KEY= ETS.EXPENSE_TYPE_SCD_KEY
AND MLR.PROD_CODE_SCD_KEY= PCS.PROD_CODE_SCD_KEY
AND MLR.CUST_ACCOUNT_SCD_KEY= CACCT.CUST_ACCOUNT_SCD_KEY
AND MLR.SUBMIT_OFFICE_SCD_KEY= SOS.SUBMIT_OFFICE_SCD_KEY
/* NATION CURRENCY */
/* AND GLA.COMPANY=ASX.PSGL(+) */
/* RESERVE PERCENT AND LAB/MAT CLASSIFICATION */
AND CTYPES.CLAIM_TYPE_DESCR = RES_PCT.CLAIM_TYPE 
AND ETS.EXPENSE_TYPE_DESCR=RES_PCT.EXPENSE_TYPE_DESCR
AND SOS.COMPANY_OWNED_IND=RES_PCT.COMPANY_OWNED_IND 
AND (CASE WHEN CACCT.CUST_CREDIT_CATG_CODE='Z1' THEN 'Y' ELSE 'N' END)=RES_PCT.CUST_CREDIT_CATG_CODE
/* FOR RESERVE GROUP */
AND GLA.R12_ENTITY /* -SS- COMPANY */ = PRODGRP.GL_LEDGER /* -SS- FIXME join won't work */
--AND CASE WHEN GLA.PROD_CODE IS NULL OR GLA.PROD_CODE = ' ' THEN PCS.PROD_CODE ELSE GLA.PROD_CODE END = PRODGRP.MANF_PROD_CODE 
AND PCS.PROD_CODE = PRODGRP.ORA_PRODUCT -- -SS- MANF_PROD_CODE, FIXME join won't work
AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL

AND PSA.TRANE_ACCOUNT_IND='X'
AND GLA.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
--AND MLR.CLAIM_NBR LIKE  '3469032%'

/* Warranty specific */
/* 6/27/07 msun only past 12 month needed */
--AND TD3.FULL_DATE>=TO_DATE('6/1/2006','MM/DD/YYYY') AND TD3.FULL_DATE<TO_DATE('7/1/2007','MM/DD/YYYY')
AND TD3.FULL_DATE>=TO_DATE('1/1/2000','MM/DD/YYYY') AND TD3.FULL_DATE<= TO_DATE('12/31/2008','MM/DD/YYYY')
--AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(td3.full_date))<=12
--AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(TD3.full_date))>=1
--AND (GLA.ACCOUNT like '8062%' or GLA.ACCOUNT like '0620%')
and GLA.R12_ACCOUNT /* -SS- ACCOUNT */ like '523500%' /* -SS- ???? */
GROUP BY 
MLR.CLAIM_NBR, 
MLR.STEP_NBR, 
GLA.R12_ENTITY /* -SS- COMPANY */ , 
PRODGRP.PRODUCT_CATEGORY,
CTYPES.CLAIM_TYPE_DESCR , 
RES_PCT.EXPENSE_TYPE_CATG,
GLA.R12_ACCOUNT /* -SS- ACCOUNT */ ,
ETS.EXPENSE_TYPE_DESCR, 
SOS.SUBMIT_OFFICE_NAME , 
GLA.R12_PRODUCT /* -SS- PROD_CODE */ , 
PCS.PROD_CODE , 
SOS.COMPANY_OWNED_IND, 
CACCT.ACCOUNT_NUMBER , 
CACCT.CUST_ACCT_NAME , 
(CASE WHEN CACCT.CUST_CREDIT_CATG_CODE='Z1' THEN 'Y' ELSE 'N' END) , 
TD3.FULL_DATE ,  
TO_CHAR(TD3.YEAR),
TO_CHAR(TD3.MONTH), 
CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1))))+1 ,
CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1))))+1 ,
TD2.FULL_DATE , 
( TD2.YEAR * 100 + TD2.MONTH ) , 
CEIL( ( (TD3.TIME_KEY - TD2.TIME_KEY) / 30.42 ) ) + 1 , 
TD.FULL_DATE , 
( (TD3.TIME_KEY - TD.TIME_KEY) / 30.42 ) , 
TD1.FULL_DATE , 
( (TD3.TIME_KEY - TD1.TIME_KEY) / 30.42 ) , 
(CASE WHEN TD1.FULL_DATE=TO_DATE('1/1/1900','MM/DD/YYYY') OR TD1.FULL_DATE IS NULL THEN 'NO'  ELSE  FCW.WA_POLICY_TYPE  END), 
(case when FCW.WA_RANGE='1'  then '1st Year Standard Warranty'
    when FCW.WA_RANGE= '2' then '2nd-5th Year Standard Warranty'
    when FCW.WA_RANGE='5' then '> 5th Year Standard Warranty'
    else 'Out of Standard Warranty' 
 end) ,
MLR.TRX_CURRENCY 
,(
	CASE
	WHEN GLA.R12_ENTITY IN ('5773', '5588') /* -SS- ASX.NATION_CURR='USD' */ THEN 'USA'
	ELSE 'CAN'
	/* -SS-
	WHEN ASX.NATION_CURR='CAD' THEN 'CAN' 
	ELSE 'CURRENCY: ' || ASX.NATION_CURR 
	*/
	END
)
/* NEW FIELDS ADDED 5/21/07 */
,MLR.RETRO_ID 
,GLA.R12_COST_CENTER /* -SS- COST_CENTER */
/* 2-5Year Specific */ 
,10000*(
CASE WHEN (PCS.PROD_CODE='0061' and CTYPES.CLAIM_TYPE_DESCR='MATERIAL') /* BR6 */
or (PCS.PROD_CODE in ('0054','0197')) /* BR4 */
or (NVL(FCW.WA_RANGE,'0') NOT IN ( '2' , '5') )/* BR3 */  
OR (ROUND((TD3.FULL_DATE - TD2.FULL_DATE)/30.42)>91) /* BR5 */ 
OR (ROUND((TD.FULL_DATE - TD2.FULL_DATE)/30.42)>24)
THEN 0 ELSE RES_PCT.RESERVE_PCT  END)
, ROUND((TD3.FULL_DATE - TD2.FULL_DATE)/30.42) 
, ROUND((TD.FULL_DATE - TD2.FULL_DATE)/30.42)
, 100*TD3.YEAR+TD3.MONTH 
,TD2.MONTH 
,TD2.YEAR  
,PSA.descr 
