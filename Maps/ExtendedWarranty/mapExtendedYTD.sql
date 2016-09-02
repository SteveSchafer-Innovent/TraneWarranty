/* EXTENDED WARRANTY SCHEDULE-YTD REPORT QUERY */
Select /*+ FIRST_ROWS */  
sales.COUNTRY_INDICATOR,
begbalances.ACCOUNT,
sales.DESCR,
--begbalances.ledger,
---begbalances.fiscal_year,
begbalances.begbal_base as Begning_Balance,
100*(begbalances.begbal_base -trunc (begbalances.begbal_base)) as Begning_Balance_Dec,
begbalances.begbal_base + perioddata.prdmonetaryamt_base AS END_Blance,
100*( begbalances.begbal_base + perioddata.prdmonetaryamt_base - trunc (begbalances.begbal_base + perioddata.prdmonetaryamt_base))AS END_Blance_Dec,
sales.REVENUE_AMOUNT,
100*(SALES.REVENUE_AMOUNT- trunc( sales.REVENUE_AMOUNT) ) as REVENUE_AMOUNT_DEC,
rev.DEFERRED_REVENUE as DEFERRED_REVENUE,
100*(rev.DEFERRED_REVENUE -Trunc(rev.DEFERRED_REVENUE) )as DEFERRED_REVENUE_DEC,
rev.SHORT_TERM_BALA as SHORT_TERM_BALA,
100*(rev.SHORT_TERM_BALA -Trunc (rev.SHORT_TERM_BALA)) as SHORT_TERM_BALA_dec,
rev.LONG_TERM_BALA as LONG_TERM_BALA,
100*(rev.LONG_TERM_BALA - trunc (rev.LONG_TERM_BALA ))as LONG_TERM_BALA_Dec

from 
(/* Begning Balance DRTRNP */
SELECT    
L.R12_ACCOUNT /* -SS- ACCOUNT */, 
l.ledger,    
L.fiscal_year,               
SUM(DECODE (l.accounting_period, 0, l.posted_base_amt, 0))   AS begbal_base
--100*(SUM(DECODE (l.accounting_period, 0, l.posted_base_amt, 0))  - TRUNC( SUM(DECODE (l.accounting_period, 0, l.posted_base_amt, 0))) )   AS begbal_base_DEC
          
FROM R12_LEDGER2_PS /* -SS- OTR */ l,            
actuate_sec_xref asx
WHERE l.fiscal_year = TO_CHAR(TO_DATE('1-'||:RunDate,'dd-mon-yy'),'YYYY')
AND l.ledger = 'ACTUALS'
AND l.business_unit in  ('CAN' ,'CSD')
AND L.R12_ACCOUNT /* -SS- ACCOUNT */  between '523000' AND '546900' /* -SS- ???? */
AND L.R12_LOCATION /* -SS- DEPTID */ LIKE 'SL00%' /* -SS- ???? */
AND CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END =UPPER(:COUNTRY)         
AND l.business_unit = asx.psgl(+)
group by L.R12_ACCOUNT /* -SS- ACCOUNT */, L.fiscal_year, l.ledger 
)begbalances,
                


( /* Ending Balance DRTRNP */

SELECT   /*+ index (ga XPKOTR_JRNL_HEADER_PS) */
l.ACCOUNT, ga.fiscal_year, l.ledger,    
SUM ( NVL(DECODE  (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),  -1, l.monetary_amount ) ,0) 
+
DECODE (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),   -1, 0,
DECODE (SIGN (  TO_CHAR (ga.journal_date, 'MM')  - TO_CHAR(TO_DATE('1-'||:RunDate,'dd-mon-yy'),'mm')   ), 1, 0,  l.monetary_amount  ) )) AS prdmonetaryamt_base 

--100*(SUM ( NVL(DECODE  (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),  -1, l.monetary_amount ) ,0) 
-- +
-- DECODE (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),   -1, 0,
--DECODE (SIGN (  TO_CHAR (ga.journal_date, 'MM')  - TO_CHAR(TO_DATE('1-'||:RunDate,'dd-mon-yy'),'mm')   ), 1, 0,  l.monetary_amount  ) )) -TRUNC (SUM ( NVL(DECODE  (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),  -1, l.monetary_amount ) ,0) 
-- +
-- DECODE (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),   -1, 0,
--DECODE (SIGN (  TO_CHAR (ga.journal_date, 'MM')  - TO_CHAR(TO_DATE('1-'||:RunDate,'dd-mon-yy'),'mm')   ), 1, 0,  l.monetary_amount  ) )))) AS  prdmonetaryamt_base_Dec

               
FROM R12_JRNL_LN_PS /* -SS- OTR */ l, OTR_JRNL_HEADER_PS ga, actuate_sec_xref asx
WHERE ga.jrnl_hdr_status IN ('P', 'U')
AND ga.fiscal_year = TO_CHAR(TO_DATE('1-'||:RunDate,'dd-mon-yy'),'YYYY')
AND ga.journal_date <=LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) 
AND l.ledger ='ACTUALS'
AND l.business_unit in  ('CAN' ,'CSD')
AND CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END =UPPER(:COUNTRY)  
AND l.ACCOUNT  between '523000' AND '546900'
AND l.deptid = 'SL00'
AND ga.business_unit = l.business_unit
AND l.business_unit = asx.psgl(+)
AND ga.journal_id = l.journal_id
AND ga.journal_date = l.journal_date
AND ga.unpost_seq = l.unpost_seq 

group by l.ACCOUNT, ga.fiscal_year, l.ledger)perioddata,

(/* Sales Data DRTRNP */

SELECT /*+ FIRST_ROWS */  
CASE WHEN A.R12_ENTITY <> '5773' /* -SS- ASX.NATION_CURR ='USD' */ THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR,
A.R12_ACCOUNT /* -SS- ACCOUNT */ AS ACCOUNT,
PSA.DESCR,
SUM(A.MONETARY_AMOUNT *-1 ) AS REVENUE_AMOUNT
--SUM (100*(A.MONETARY_AMOUNT*-1 -TRUNC(A.MONETARY_AMOUNT*-1))) AS REVENUE_AMOUNT_DEC
FROM 
R12_BI_ACCT_ENTRY_PSB /* -SS- OTR */ A
, OTR_TRNBI_BI_HDR_PSB B
, OTR_BI_HDR_PSB C
, R12_TRANE_ACCOUNTS_PS /* -SS- OTR was PS_TRANE_ACCOUNTS */ PSA
/* -SS- , ACTUATE_SEC_XREF ASX */
WHERE A.JOURNAL_DATE >= TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') 
AND  A.JOURNAL_DATE<= LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) 
--BETWEEN TO_DATE('01/01/2003','MM/DD/YYYY') AND TO_DATE('12/31/2050','MM/DD/YYYY')
AND A.BUSINESS_UNIT_GL IN ('CAN' ,'CSD')
AND CASE WHEN A.R12_ENTITY <> '5773' /* -SS- ASX.NATION_CURR ='USD' */ THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)
/* -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+) */
AND a.ACCOUNT = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
AND A.BUSINESS_UNIT = B.BUSINESS_UNIT 
AND A.INVOICE = B.INVOICE 
AND B.BUSINESS_UNIT = C.BUSINESS_UNIT 
AND B.INVOICE = C.INVOICE 
AND C.ENTRY_TYPE = 'IN'
and A.ACCOUNT   between '523000' AND '546900'

GROUP BY 
CASE WHEN A.R12_ENTITY <> '5773' THEN 'USA' ELSE 'CAN' END /* -SS- ASX.NATION_CURR */  ,
A.R12_ACCOUNT /* -SS- ACCOUNT */,
PSA.DESCR 
) sales,

( /* DEFERRED,SHORT_TERM,LONG_TERM DWTRNP */
SELECT 
B.gl_account AS account ,
B.GL_ACCOUNT_DESCR as DESCRIPTION ,
SUM(B.DEFERRED_REVENUE)as DEFERRED_REVENUE,
SUM(B.SHORT_TERM_REVENUE) AS SHORT_TERM_BALA,
SUM(LONG_TERM_REVENUE) AS LONG_TERM_BALA

FROM (
select 
a.gl_account,A.GL_ACCOUNT_DESCR ,
to_date('1-'||:RunDate,'dd-mon-yy'),
(MAX(a.rec_rev_mnthly)+ CASE WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate,'dd-mon-yy') THEN  MAX(A.DEFERRED_REVENUE) ELSE 0 END ) as DEFERRED_REVENUE,
MAX(a.SHORT_TERM_DR) as SHORT_TERM_REVENUE,
MAX(a.LONG_TERM_DR) as LONG_TERM_REVENUE,
A.FORECAST_PERIOD 
/* TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')   as ship_from
, (to_date('1-'||:RunDate,'dd-mon-yy') )as ship_to */    
from DM_030_REV_RELEASE@DW_INTFC_DR.LAX.TRANE.COM a
where a.country_indicator  = UPPER(:COUNTRY)
AND a.RUN_PERIOD >= TO_DATE('1-'||:RunDate,'dd-mon-yy')
and  a.RUN_PERIOD<add_months(to_date('1-'||:RunDate,'dd-mon-yy'),1) 
AND  a.gl_account  between '523000' AND '546900'
 
AND A.SHIP_PERIOD >= TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') 
AND A.SHIP_PERIOD <  (to_date('1-'||:RunDate,'dd-mon-yy') )
GROUP BY  a.gl_account,A.GL_ACCOUNT_DESCR , A.FORECAST_PERIOD ) B
GROUP BY gL_ACCOUNT,B.GL_ACCOUNT_DESCR )Rev

WHERE     begbalances.begbal_base <> 0   
AND  begbalances.ACCOUNT =sales.ACCOUNT    
and begbalances.ACCOUNT =Rev.account
and begbalances.ACCOUNT = perioddata.ACCOUNT(+)
AND begbalances.fiscal_year = perioddata.fiscal_year(+)
AND begbalances.ledger = perioddata.ledger(+)
     




