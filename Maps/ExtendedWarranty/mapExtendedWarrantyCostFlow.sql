SELECT 
GLA.COMPANY AS BUSINESS_UNIT, 
SUM(MLR.EXP_TYPE_AMOUNT*-1) AS EXPENSE_AMOUNT, 
SUM(100*(MLR.EXP_TYPE_AMOUNT*-1-TRUNC(MLR.EXP_TYPE_AMOUNT*-1))) AS EXPENSE_AMOUNT_DEC,
GLA.ACCOUNT AS GL_ACCOUNT,
TD2.YEAR  as Ship_year,
(case when FCW.WA_RANGE='1'  then '1st Year Standard Warranty'
    when FCW.WA_RANGE= '2' then '2nd-5th Year Standard Warranty'
    when FCW.WA_RANGE='5' then '> 5th Year Standard Warranty'
    else 'Out of Standard Warranty' 
 end) AS WARRANTY_DURATION, 
MLR.TRX_CURRENCY AS CURRENCY
,(CASE WHEN ASX.NATION_CURR='USD' THEN 'USA'WHEN ASX.NATION_CURR='CAD' THEN 'CAN' ELSE 'CURRENCY: ' ||ASX.NATION_CURR END)  AS COUNTRY_INDICATOR
, ROUND((TD3.FULL_DATE - TD2.FULL_DATE)/30.42) AS TRX_LAG
,CEIL( ( (TD3.TIME_KEY - TD2.TIME_KEY) / 30.42 ) ) + 1 AS INTMONTHS_SHIP_TO_TRX
, ROUND((TD.FULL_DATE - TD2.FULL_DATE)/30.42) AS Start_Lag
,( TD2.YEAR * 100 + TD2.MONTH ) AS SHIP_YEAR_MONTH
,TD2.MONTH AS Ship_month
,TD2.FULL_DATE AS SHIP_DATE
,TD3.FULL_DATE  AS TRX_DATE
,TO_CHAR(TD3.YEAR) AS TRX_YEAR
,TO_CHAR(TD3.MONTH) AS TRX_MONTH
,CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1))))+1 AS INTMONTHS_TRX_TO_BASE
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
,GL_ACCOUNT_SCD GLA
,EXPENSE_TYPE_SCD ETS
,PROD_CODE_SCD PCS
,CUST_ACCOUNT_SCD CACCT
,SUBMIT_OFFICE_SCD SOS
,OTR_PROD_CODE_XREF_RCPO@DR_INTFC_DW.LAX.TRANE.COM PRODGRP
,ACTUATE_SEC_XREF ASX
, DM_WAR_CSN_RSV_PCT_REF RES_PCT
, R12_TRANE_ACCOUNTS_PS /* -SS- OTR @DR_INTFC_DW.LAX.TRANE.COM */ PSA
WHERE 
MLR.CLAIM_TYPE_SCD_KEY <> 11
AND MLR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY 
AND MLR.CLAIM_NBR=FCW.CLAIM_NBR (+)
AND MLR.DETAIL_NBR=FCW.DETAIL_NBR (+)
AND MLR.STEP_NBR=FCW.STEP_NBR(+)
AND MLR.CCN_TRX_DATE_KEY=TD3.TIME_KEY
AND MLR.ORIGINAL_SHIP_DATE_KEY= TD2.TIME_KEY
AND MLR.FAIL_DATE_KEY=TD1.TIME_KEY 
AND MLR.START_DATE_KEY= TD.TIME_KEY
AND MLR.CLAIM_TASK_SCD_KEY = CTASKS.CLAIM_TASK_SCD_KEY
AND MLR.CLAIM_TYPE_SCD_KEY = CTYPES.CLAIM_TYPE_SCD_KEY
AND MLR.GL_ACCOUNT_SCD_KEY= GLA.GL_ACCOUNT_SCD_KEY
AND MLR.EXPENSE_TYPE_SCD_KEY= ETS.EXPENSE_TYPE_SCD_KEY
AND MLR.PROD_CODE_SCD_KEY= PCS.PROD_CODE_SCD_KEY
AND MLR.CUST_ACCOUNT_SCD_KEY= CACCT.CUST_ACCOUNT_SCD_KEY
AND MLR.SUBMIT_OFFICE_SCD_KEY= SOS.SUBMIT_OFFICE_SCD_KEY
AND GLA.COMPANY=ASX.PSGL(+)
AND CTYPES.CLAIM_TYPE_DESCR = RES_PCT.CLAIM_TYPE 
AND ETS.EXPENSE_TYPE_DESCR=RES_PCT.EXPENSE_TYPE_DESCR
AND SOS.COMPANY_OWNED_IND=RES_PCT.COMPANY_OWNED_IND 
AND (CASE WHEN CACCT.CUST_CREDIT_CATG_CODE='Z1' THEN 'Y' ELSE 'N' END)=RES_PCT.CUST_CREDIT_CATG_CODE
AND GLA.COMPANY=PRODGRP.GL_LEDGER 
AND PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE 
AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
AND PSA.TRANE_ACCOUNT_IND='X'
AND GLA.ACCOUNT = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND TD3.FULL_DATE>=TO_DATE('1/1/2000','MM/DD/YYYY') AND TD3.FULL_DATE<= TO_DATE('12/31/2008','MM/DD/YYYY')
and GLA.ACCOUNT  in ('523500','526892','526893','528100','528200','528300','532100')
GROUP BY 
GLA.COMPANY , 
GLA.ACCOUNT ,
TD2.YEAR,
(case when FCW.WA_RANGE='1'  then '1st Year Standard Warranty'
    when FCW.WA_RANGE= '2' then '2nd-5th Year Standard Warranty'
    when FCW.WA_RANGE='5' then '> 5th Year Standard Warranty'
    else 'Out of Standard Warranty' 
 end) ,
MLR.TRX_CURRENCY 
,(CASE WHEN ASX.NATION_CURR='USD' THEN 'USA'WHEN ASX.NATION_CURR='CAD' THEN 'CAN' ELSE 'CURRENCY: ' ||ASX.NATION_CURR END)  
, ROUND((TD3.FULL_DATE - TD2.FULL_DATE)/30.42) 
, ROUND((TD.FULL_DATE - TD2.FULL_DATE)/30.42)
,( TD2.YEAR * 100 + TD2.MONTH )
,TD2.MONTH
,TD2.FULL_DATE 
,TD3.FULL_DATE
,CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1))))+1
,PSA.descr
,CEIL( ( (TD3.TIME_KEY - TD2.TIME_KEY) / 30.42 ) ) + 1 
,TO_CHAR(TD3.YEAR)  
,TO_CHAR(TD3.MONTH)
order by 
GLA.ACCOUNT,
TD2.YEAR,
TD2.MONTH,
ROUND((TD3.FULL_DATE - TD2.FULL_DATE)/30.42)