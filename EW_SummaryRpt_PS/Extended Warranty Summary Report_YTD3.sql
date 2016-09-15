SELECT   /* Comm detail Dollar Amt*/ 
TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  as gl_BeginDate,
LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
case when a.COUNTRY_INDICATOR is null then b.COUNTRY_INDICATOR  else a.COUNTRY_INDICATOR end as COUNTRY_INDICATOR   , 
case when a.GL_ACCOUNT is null then b.account else a.GL_ACCOUNT end as GL_ACCOUNT ,
NVL(a.DOLLAR_AMOUNT,0)DOLLAR_AMOUNT,
case when B.GL_ACC_DESCR is null then a.GL_ACC_DESCR  else b.GL_ACC_DESCR  end  as GL_ACC_DESCR,
nvl(B.Amort_Comm_and_prepaid_comm,0) AS Amort_Comm_and_prepaid_comm,
nvl(B.SHORT_TERM_COMM,0) AS SHORT_TERM_COMM,
nvl(B.LONG_TERM_COMM,0)  AS LONG_TERM_COMM

from (
SELECT   /*+ NO_CPU_COSTING */
TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  as gl_BeginDate,
LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR, 
--TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH, 
DIST.ACCOUNT AS GL_ACCOUNT,
--DIST.JOURNAL_DATE AS JOURNAL_DATE ,
SUM(Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end ) AS DOLLAR_AMOUNT,
psa.DESCR as GL_ACC_DESCR,
0 AS Amort_Comm_and_prepaid_comm,
0 AS SHORT_TERM_COMM,
0  AS LONG_TERM_COMM
FROM dbo.otr_trnco_cm_dist_psb dist
,dbo.otr_TRANE_ACCOUNTS_ps psa
,dbo.ACTUATE_SEC_XREF ASX
WHERE  
DIST.ACCOUNT   = PSA.ACCOUNT    
AND PSA.TRANE_ACCOUNT_IND='X'
AND DIST.BUSINESS_UNIT_GL= ASX.PSGL   
AND DIST.JOURNAL_DATE BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') AND LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy'))
AND DIST.ACCOUNT LIKE '5%'
 
and CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)
and ASX.NATION_CURR = 'USD'
 and ( dist.deptid IS NULL OR (dist.deptid = 'SL00'))

GROUP BY
CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END ,
DIST.ACCOUNT,psa.DESCR

UNION ALL
 
SELECT /*+ NO_CPU_COSTING */
TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  as gl_BeginDate,
LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date, 
CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR, 
--TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH, 
DIST.ACCOUNT AS GL_ACCOUNT, 
sum(Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end  )AS DOLLAR_AMOUNT,
psa.DESCR as GL_ACC_DESCR,
0 AS Amort_Comm_and_prepaid_comm,
0 AS SHORT_TERM_COMM,
0  AS LONG_TERM_COMM
FROM dbo.otr_trnco_cm_dist_psb dist
,dbo.otr_TRANE_ACCOUNTS_ps psa
,dbo.ACTUATE_SEC_XREF ASX
WHERE  
DIST.ACCOUNT = PSA.ACCOUNT    
AND PSA.TRANE_ACCOUNT_IND='X'
AND DIST.BUSINESS_UNIT_GL= ASX.PSGL   
AND DIST.JOURNAL_DATE BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')   AND LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy'))
AND DIST.ACCOUNT LIKE '5%'
and  CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)
and ASX.NATION_CURR = 'CAD'
and ( dist.deptid IS NULL OR (dist.deptid = 'TCA0') OR (dist.deptid = 'SL00') )
GROUP BY
CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END ,
DIST.ACCOUNT,psa.DESCR)a,

(/* Amort_Comm_and_prepaid_comm_and_long_and_short_term*/ 
SELECT /*+ NO_CPU_COSTING */
TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  as gl_BeginDate,
LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
B.country_indicator,
B.gl_account AS account ,
0 as DOLLAR_AMOUNT,
B.GL_ACCOUNT_DESCR as GL_ACC_DESCR ,
sum(B.Amort_Comm_and_prepaid_comm) AS Amort_Comm_and_prepaid_comm,
sum(b.SHORT_TERM_COMM) AS SHORT_TERM_COMM,
SUM(B.LONG_TERM_COMM) AS LONG_TERM_COMM
FROM (
select  a.country_indicator,
 a.gl_account, 
 A.GL_ACCOUNT_DESCR  AS GL_ACCOUNT_DESCR  ,
to_date('1-'||:RunDate,'dd-mon-yy'),
CASE WHEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') = To_date('1-'||:RunDate,'dd-mon-yy') 
THEN CASE WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate,'dd-mon-yy') THEN  MAX(a.PREPAID_COMMISSION) ELSE 0 END
ELSE  (MAX(a.Comm_amort_mnthly)+ CASE WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate,'dd-mon-yy') THEN  MAX(a.PREPAID_COMMISSION) ELSE 0 END )  END as Amort_Comm_and_prepaid_comm, 
MAX(a.short_term_pp_comm) as SHORT_TERM_COMM,
MAX(a.long_term_pp_comm) as LONG_TERM_COMM,
 A.forecast_period 
from DM_030_COMM_AMORTIZATION@DW_INTFC_DR.LAX.TRANE.COM a,OTR_TRANE_ACCOUNTS_PS psa
where 
a.gl_account = PSA.ACCOUNT (+)
AND PSA.TRANE_ACCOUNT_IND='X'
and a.country_indicator  = UPPER(:COUNTRY)
AND a.RUN_PERIOD >= TO_DATE('1-'||UPPER(:RunDate),'dd-mon-yy')
and  a.RUN_PERIOD<add_months(to_date('1-'||:RunDate,'dd-mon-yy'),1) 
AND  a.gl_account like '5%'
AND A.SHIP_PERIOD >= case when to_date('1-'||:RunDate,'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  then  trunc(trunc(to_date('1-'||:RunDate,'dd-mon-yy'),'YEAR') -1 )-30 else   TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  end
AND A.SHIP_PERIOD <  (to_date('1-'||:RunDate,'dd-mon-yy') )
GROUP BY   a.country_indicator,a.gl_account,A.GL_ACCOUNT_DESCR  ,  A.forecast_period  ) B
GROUP BY B.country_indicator,gL_ACCOUNT,B.GL_ACCOUNT_DESCR  )B


WHERE a.GL_ACCOUNT  (+)  = B.ACCOUNT
AND a.COUNTRY_INDICATOR   (+) = B.COUNTRY_INDICATOR 

union
/* Qry to fetch accounts wich does not exist in dbo.otr_trnco_cm_dist_psb dist table */
SELECT  /*+ NO_CPU_COSTING */
ADD_MONTHS(((LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')))), -1)  as gl_BeginDate,
LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
''AS COUNTRY_INDICATOR, 
PSA.ACCOUNT AS GL_ACCOUNT,
--DIST.JOURNAL_DATE AS JOURNAL_DATE ,
0 AS DOLLAR_AMOUNT,
PSA.DESCR as GL_ACC_DESCR,
0 AS Amort_Comm_and_prepaid_comm,
0 AS SHORT_TERM_COMM,
0  AS LONG_TERM_COMM
 FROM dbo.otr_TRANE_ACCOUNTS_ps psa
WHERE  PSA.TRANE_ACCOUNT_IND='X'
AND PSA.ACCOUNT LIKE '5%' 
and not exists( select 'X'
FROM dbo.otr_trnco_cm_dist_psb dist,dbo.ACTUATE_SEC_XREF ASX
WHERE
DIST.ACCOUNT   = PSA.ACCOUNT      
AND DIST.BUSINESS_UNIT_GL= ASX.PSGL  
AND DIST.JOURNAL_DATE BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  AND LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy'))
AND DIST.ACCOUNT LIKE '5%'
and CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY) )

and not exists( 
 select 'x' from DM_030_COMM_AMORTIZATION@DW_INTFC_DR.LAX.TRANE.COM a
where  
a.RUN_PERIOD >= TO_DATE('1-'||UPPER(:RunDate),'dd-mon-yy')
and  a.RUN_PERIOD<add_months(to_date('1-'||:RunDate,'dd-mon-yy'),1) 
AND  a.gl_account= PSA.ACCOUNT     
AND A.SHIP_PERIOD >= case when to_date('1-'||:RunDate,'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  then  trunc(trunc(to_date('1-'||:RunDate,'dd-mon-yy'),'YEAR') -1 )-30 else   TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  end
AND A.SHIP_PERIOD <  (to_date('1-'||:RunDate,'dd-mon-yy') )  
and a.country_indicator  = UPPER(:COUNTRY)
AND  a.gl_account like '5%'  )