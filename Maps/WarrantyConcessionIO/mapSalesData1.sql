SELECT  /*+ NO_CPU_COSTING */
'RCPO' AS QUERY_SOURCE,
 NVL(PS.GL_BU_ID,
(CASE WHEN PS.CURRENCY_CODE='USD' THEN 'GS303'
      WHEN PS.CURRENCY_CODE='CAD' THEN 'GS315'
      ELSE 'INVALID CURRENCY-'||PS.CURRENCY_CODE END) )  AS BU
,SUM(PS.ORDER_AMOUNT) AS REVENUE_AMOUNT
,SUM(100*(PS.ORDER_AMOUNT-TRUNC(PS.ORDER_AMOUNT))) AS REVENUE_AMOUNT_DEC
-- PER PAT'S REQUEST 5/24/07
--,PS.PLNT_GL_ACCT AS GL_ACCOUNT
--,(CASE WHEN PS.PLNT_GL_ACCT2 = '750000' THEN PS.PLNT_GL_ACCT2 ELSE PS.PLNT_GL_ACCT END) AS GL_ACCOUNT
-- PER PAT'S REQUEST 5/30/07
,PS.R12_ACCOUNT /* -SS- PLNT_GL_ACCT2 */ AS GL_ACCOUNT
,NVL(PS.GL_DPT_ID, (CASE WHEN PS.CURRENCY_CODE='USD' THEN 97001
WHEN PS.CURRENCY_CODE='CAD' THEN 97011
ELSE -10 END)) AS DEPT_ID
,NVL(AOL.OFFICE_NAME, (CASE WHEN PS.CURRENCY_CODE='USD' THEN 'OTHER EQUIPMENT GROUP'
WHEN PS.CURRENCY_CODE='CAD' THEN 'CAN OTHER EQUIPMENT GROUP'
ELSE 'INVALID CURRENCY-'||PS.CURRENCY_CODE END) )AS DEPT_DESCR
,PS.PLNT_GL_PROD AS MANF_PROD_ID
,PX.MANF_PROD_CODE_DESCR AS MANF_PROD_DESCR
/* CHANGING MSUN 5/18/2007 */
--,(CASE WHEN PS.PLNT_GL_ACCT= '750000' THEN '804900' ELSE  PS.GL_PROD END ) AS DIST_GL_PRODUCT
-- PER PAT'S REQUEST 5/24/07
-- ,(CASE WHEN PS.PLNT_GL_ACCT= '750000' OR PS.PLNT_GL_ACCT2 = '750000' THEN '804900' ELSE  PS.GL_PROD END ) AS DIST_GL_PRODUCT
-- PER PAT'S REQUEST 5/30/07
 ,(CASE WHEN PS.PART_TYPE = 'Y' AND PS.PARTS_PROD_CODE_IND = 'PCR' THEN '804900' ELSE PS.R12_PRODUCT /* -SS- GL_PROD */ END) AS DIST_GL_PRODUCT
/* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
,NVL(PX.PRODUCT_CATEGORY,(CASE WHEN PS.PLNT_GL_PROD = 'ELIM' OR PS.PLNT_GL_PROD = 'TNA0' THEN 'LARGE' ELSE 'INVALID PROD CODE - '|| PS.PLNT_GL_PROD END)) AS RESERVE_GROUP
,PS.JRNL_DATE AS JRNL_DATE
,CAST(TO_CHAR(JRNL_DATE,'YYYY') AS INTEGER) AS JRNL_YEAR
,CAST(TO_CHAR(JRNL_DATE,'MM') AS INTEGER) AS JRNL_MONTH
,CAST(TO_CHAR(JRNL_DATE,'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE,'MM') AS INTEGER) AS JRNL_YEAR_MONTH
,PS.ORGN_JRNL_ID AS JRNL_ID
,PS.CURRENCY_CODE AS CURRENCY
,NVL(AOL.NATION_CURR, PS.CURRENCY_CODE) AS COUNTRY_INDICATOR
FROM OTR_ORACLE_PS_REV_RCPO PS
,OTR_PROD_CODE_XREF_RCPO PX
,ACTUATE_OFFICE_LOCATION AOL
WHERE PS.JRNL_DATE BETWEEN TO_DATE ('01/01/2005','MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE,-1))
--PS.JRNL_DATE BETWEEN CAST('2005-01-01 00:00:00.000' AS TIMESTAMP) AND CAST(LAST_DAY(ADD_MONTHS(SYSDATE,-1)) AS TIMESTAMP)
--AND PS.PRODUCT_CODE = '0331'
AND PS.PLNT_GL_BU = PX.GL_LEDGER(+)
AND PS.PLNT_GL_PROD = PX.MANF_PROD_CODE(+)
AND PS.GL_DPT_ID /* -SS- FIXME */ = AOL.ORA_LOCATION /* -SS- DEPT_ID */ (+)
AND PS.GL_BU_ID /* -SS- FIXME */ = AOL.ORA_ENTITY /* -SS- BU_UNIT */ (+)
GROUP BY  PS.GL_BU_ID
-- PER PAT'S REQUEST, 5/30/07
--,(CASE WHEN PS.PLNT_GL_ACCT2 = '750000' THEN PS.PLNT_GL_ACCT2 ELSE PS.PLNT_GL_ACCT END)
,PS.R12_ACCOUNT /* -SS- PLNT_GL_ACCT2 */
,PS.GL_DPT_ID
,AOL.OFFICE_NAME
,PS.PLNT_GL_PROD
,PX.MANF_PROD_CODE_DESCR
-- PER PAT'S REQUEST, 5/30/07
--,(CASE WHEN PS.PLNT_GL_ACCT= '750000' OR PS.PLNT_GL_ACCT2 = '750000' THEN '804900' ELSE  PS.GL_PROD END )
,(CASE WHEN PS.PART_TYPE = 'Y' AND PS.PARTS_PROD_CODE_IND = 'PCR' THEN '804900' ELSE PS.R12_PRODUCT /* -SS- GL_PROD */ END)
,PS.R12_PRODUCT /* -SS- GL_PROD */
,PX.PRODUCT_CATEGORY
,PS.JRNL_DATE
,CAST(TO_CHAR(PS.JRNL_DATE,'YYYY') AS INTEGER)
,CAST(TO_CHAR(PS.JRNL_DATE,'MM') AS INTEGER)
,CAST(TO_CHAR(PS.JRNL_DATE,'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(PS.JRNL_DATE,'MM') AS INTEGER)
,PS.ORGN_JRNL_ID
,PS.CURRENCY_CODE
,AOL.NATION_CURR
UNION ALL

/* 2ND*/
SELECT  /*+ NO_CPU_COSTING */
'P/S GL' AS QUERY_SOURCE,
 GA.BUSINESS_UNIT AS BU
,SUM(L.MONETARY_AMOUNT ) AS REVENUE_AMOUNT
,SUM(100*(L.MONETARY_AMOUNT-TRUNC(L.MONETARY_AMOUNT))) AS REVENUE_AMOUNT_DEC
, L.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT
, L.R12_LOCATION /* -SS- DEPTID */ AS DEPT_ID
, DP.DESCR AS DEPT_DESCR
, L.R12_PRODUCT /* -SS- PRODUCT */ AS MANF_PROD_ID
, PR.DESCR AS MANF_PROD_DESCR
-- PER PAT'S REQUEST 5/24/07
--, NULL AS DIST_GL_PRODUCT
, L.R12_PRODUCT /* -SS- PRODUCT */ AS DIST_GL_PRODUCT
/* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
,NVL(PX.PRODUCT_CATEGORY,(CASE WHEN L.R12_PRODUCT /* -SS- PRODUCT */ = 'ELIM' OR L.R12_PRODUCT /* -SS- PRODUCT */ = 'TNA0' THEN 'LARGE' ELSE 'INVALID PROD CODE - '|| L.R12_PRODUCT /* -SS- PRODUCT */ END)) AS RESERVE_GROUP
--, PX.PRODUCT_CATEGORY AS RESERVE_GROUP
, GA.JOURNAL_DATE AS JRNL_DATE
,TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE,'YYYY')) AS JRNL_YEAR
,TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE,'MM') ) AS JRNL_MONTH
,TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE,'YYYY')) * 100 + TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE,'MM') )  AS JRNL_YEAR_MONTH
, GA.JOURNAL_ID AS JRNL_ID
, L.CURRENCY_CD AS CURRENCY
,ASX.NATION_CURR AS COUNTRY_INDICATOR
FROM R12_JRNL_LN_PS /* -SS- OTR */ L
, R12_JRNL_HEADER_PS /* -SS- OTR */ GA
, R12_TRANE_PRODUCTS_PS /* -SS- OTR */ PR
, OTR_TRANE_DEPTS_PS DP
, OTR_PROD_CODE_XREF_RCPO PX
, ACTUATE_SEC_XREF ASX
WHERE GA.JRNL_HDR_STATUS IN ('P','U')
AND GA.FISCAL_YEAR  IN ('2003','2004')
AND L.LEDGER = 'ACTUALS'
AND L.R12_ACCOUNT /* -SS- ACCOUNT */ = '700000' /* -SS- ???? */
AND GA.BUSINESS_UNIT IN ('CAN','CSD')
AND GA.BUSINESS_UNIT = L.BUSINESS_UNIT
AND GA.JOURNAL_ID = L.JOURNAL_ID
AND GA.JOURNAL_DATE = L.JOURNAL_DATE
AND GA.UNPOST_SEQ = L.UNPOST_SEQ
AND L.R12_PRODUCT /* -SS- PRODUCT */ = PR.R12_PRODUCT /* -SS- PRODUCT */ (+)
AND L.R12_LOCATION /* -SS- DEPTID */ = DP.DEPTID(+)
AND L.BUSINESS_UNIT = PX.GL_LEDGER(+)
AND L.R12_PRODUCT /* -SS- PRODUCT */ = PX.MANF_PROD_CODE(+)
AND GA.BUSINESS_UNIT= ASX.PSGL(+)
GROUP BY GA.BUSINESS_UNIT
, L.R12_ACCOUNT /* -SS- ACCOUNT */
, L.R12_LOCATION /* -SS- DEPTID */
, DP.DESCR
, L.R12_PRODUCT /* -SS- PRODUCT */
, PR.DESCR
, PX.PRODUCT_CATEGORY
, GA.JOURNAL_DATE
,TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE,'YYYY'))
,TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE,'MM') )
,TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE,'YYYY')) * 100 + TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE,'MM') )
, GA.JOURNAL_ID
, L.CURRENCY_CD
, ASX.NATION_CURR

UNION
/* 3RD */
SELECT   /*+ NO_CPU_COSTING */
'P/S LEDGER' AS QUERY_SOURCE,
PS.BUSINESS_UNIT AS BU
,SUM(PS.POSTED_TOTAL_AMT ) AS REVENUE_AMOUNT
,SUM(100*(PS.POSTED_TOTAL_AMT-TRUNC(PS.POSTED_TOTAL_AMT))) AS REVENUE_AMOUNT_DEC
,PS.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT
,PS.R12_LOCATION /* -SS- DEPTID */ AS DEPT_ID
,DP.DESCR AS DEPT_DESCR
,PS.R12_PRODUCT /* -SS- PRODUCT */ AS MANF_PROD_ID
,PR.DESCR AS MANF_PROD_DESCR
-- PER PAT'S REQUEST 5/24/07
--,NULL AS DIST_GL_PRODUCT
,PS.R12_PRODUCT /* -SS- PRODUCT */ AS DIST_GL_PRODUCT
/* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
,NVL(PX.PRODUCT_CATEGORY,(CASE WHEN PS.R12_PRODUCT /* -SS- PRODUCT */ = 'ELIM' /* -SS- ???? */ OR PS.R12_PRODUCT /* -SS- PRODUCT */ = 'TNA0' /* -SS- ???? */ THEN 'LARGE' ELSE 'INVALID PROD CODE - '|| PS.R12_PRODUCT /* -SS- PRODUCT */ END)) AS RESERVE_GROUP
--,PX.PRODUCT_CATEGORY AS RESERVE_GROUP
,TO_DATE('15-' || PS.ACCOUNTING_PERIOD || '-' || PS.FISCAL_YEAR,'DD-MM-YYYY') AS JRNL_DATE
,PS.FISCAL_YEAR AS JRNL_YEAR
,PS.ACCOUNTING_PERIOD AS JRNL_MONTH
,PS.FISCAL_YEAR  * 100 + PS.ACCOUNTING_PERIOD AS JRNL_YEAR_MONTH
,'ZZZZZZ' AS JRNL_ID
,PS.CURRENCY_CD AS CURRENCY
,ASX.NATION_CURR AS COUNTRY_INDICATOR
FROM R12_LEDGER2_PS /* -SS- OTR */ PS
, R12_TRANE_PRODUCTS_PS /* -SS- OTR */ PR
, OTR_TRANE_DEPTS_PS DP
, OTR_PROD_CODE_XREF_RCPO PX
, ACTUATE_SEC_XREF ASX
WHERE PS.FISCAL_YEAR IN ('2001','2002')
AND PS.ACCOUNTING_PERIOD <= '12'
AND PS.R12_ACCOUNT /* -SS- ACCOUNT */ = '700000' /* -SS- ???? */
--ADD BY ALEX
AND PS.LEDGER ='ACTUALS'
--ADD BY ALEX
--AND PR.PRODUCT = '0331'
AND PS.R12_PRODUCT /* -SS- PRODUCT */ = PR.R12_PRODUCT /* -SS- PRODUCT */ (+)
AND PS.R12_LOCATION /* -SS- DEPTID */ = DP.DEPTID(+)
AND PS.R12_PRODUCT /* -SS- PRODUCT */ = PX.MANF_PROD_CODE(+)
AND PS.BUSINESS_UNIT = PX.GL_LEDGER(+)
AND PS.BUSINESS_UNIT= ASX.PSGL(+)
GROUP BY PS.BUSINESS_UNIT
,PS.R12_ACCOUNT /* -SS- ACCOUNT */
,PS.R12_LOCATION /* -SS- DEPTID */
,DP.DESCR
,PS.R12_PRODUCT /* -SS- PRODUCT */
,PR.DESCR
,PX.PRODUCT_CATEGORY
,TO_DATE('15-' || PS.ACCOUNTING_PERIOD || '-' || PS.FISCAL_YEAR,'DD-MM-YYYY')
,PS.FISCAL_YEAR
,PS.ACCOUNTING_PERIOD
,PS.FISCAL_YEAR  * 100 + PS.ACCOUNTING_PERIOD
,PS.CURRENCY_CD
, ASX.NATION_CURR

UNION ALL

/*- 4TH QUERY 5/1
AND .BUSINESS_UNIT= ASX.PSGL
ADDING AOL.NAITON_CURR
CHANGING ALIAS NAME FOR MULTIPLE FIELDS
*/
--SELECT CASE WHEN BUSINESS_UNIT IN ('CAN','CSD') THEN BUSINESS_UNIT
--WHEN CURRENCY = 'CAN' THEN 'CAN' ELSE 'CSD' END AS BU
SELECT  /*+ NO_CPU_COSTING */
'PBS' AS QUERY_SOURCE,
 BUSINESS_UNIT AS BU
,SUM(P7_TOTAL ) AS REVENUE_AMOUNT
,SUM(100*(P7_TOTAL-TRUNC(P7_TOTAL))) AS REVENUE_AMOUNT_DEC
,GL_ACCOUNT AS GL_ACCOUNT
,DEPTID AS DEPT_ID
,DEPT_DESCR AS DEPT_DESCR
,PRODCODE AS MANF_PROD_ID
,PROD_DESCR AS MANF_PROD_DESCR
/* CHANGING 5/18/2007 MSUN*/
, GL_PRODCODE  AS DIST_GL_PRODUCT
,NVL(RESERVE_GROUP,'LARGE') AS RESERVE_GROUP
,JRNL_DATE AS JRNL_DATE
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY')) AS JRNL_YEAR
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM')) AS JRNL_MONTH
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM')) AS JRNL_YEAR_MONTH
,JRNL_ID AS JRNL_ID
,CURRENCY AS CURRENCY
,NATION_CURR AS COUNTRY_INDICATOR
FROM (
SELECT  /*+ NO_CPU_COSTING */ D.BUSINESS_UNIT_GL AS BUSINESS_UNIT,
       D.INVOICE AS INVOICE,
       D.LINE_SEQ_NUM AS SEQ_NUM,
       D.ACCT_ENTRY_TYPE AS ENTRY_TYPE,
       D.JOURNAL_ID AS JRNL_ID,
       D.JOURNAL_DATE AS JRNL_DATE,
       D.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
       D.MONETARY_AMOUNT AS P7_TOTAL,
       D.R12_LOCATION /* -SS- DEPTID */ AS DEPTID,
       AOL.OFFICE_NAME AS DEPT_DESCR,
       PR.DESCR AS PROD_DESCR,
       X.PRODUCT_CATEGORY AS RESERVE_GROUP,
       A.R12_PRODUCT /* -SS- IDENTIFIER */ AS PRODCODE,
       CASE WHEN D.R12_PRODUCT /* -SS- PRODUCT */ = '0064' THEN '804155' /* -SS- ???? */
            ELSE D.R12_PRODUCT /* -SS- PRODUCT */ END AS GL_PRODCODE,
       D.CURRENCY_CD AS CURRENCY,
       AOL.NATION_CURR
  FROM R12_BI_LINE_PSB /* -SS- OTR */ A,
       R12_BI_ACCT_ENTRY_PSB /* -SS- OTR */ D,
       OTR_PROD_CODE_XREF_RCPO X,
       R12_TRANE_PRODUCTS_PS /* -SS- OTR */ PR,
       ACTUATE_OFFICE_LOCATION AOL
 WHERE D.JOURNAL_DATE BETWEEN TO_DATE('03/01/2006', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
   AND '411101' /* -SS- '700000' */ = D.R12_ACCOUNT /* -SS- ACCOUNT */
   AND 'ACTUALS' = D.LEDGER
   AND '41206' <> D.R12_PRODUCT
   AND '41201' <> D.R12_PRODUCT
   AND '41299' <> D.R12_PRODUCT
   /* -SS-
   AND '804180' <> D.PRODUCT
   AND '804120' <> D.PRODUCT
   AND '804190' <> D.PRODUCT
   */
   AND D.LINE_SEQ_NUM = A.LINE_SEQ_NUM
   AND D.INVOICE = A.INVOICE
   AND D.BUSINESS_UNIT = A.BUSINESS_UNIT
   AND D.BUSINESS_UNIT = X.GL_LEDGER (+)
   AND D.R12_PRODUCT /* -SS- PRODUCT */ = X.MANF_PROD_CODE (+)
   AND D.R12_PRODUCT /* -SS- PRODUCT */ = PR.R12_PRODUCT /* -SS- PRODUCT */ (+)
   AND D.R12_LOCATION /* -SS- DEPTID */ = AOL.ORA_LOCATION /* -SS- DEPT_ID */ (+)
   AND D.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ = AOL.ORA_ENTITY /* -SS- BU_UNIT */ (+)
   AND EXISTS (SELECT /* index(b XPKOTR_BI_HDR_PSB) */ 'X'
                 FROM OTR_BI_HDR_PSB B
                WHERE B.BILL_SOURCE_ID = 'PBS'
                  AND D.INVOICE = B.INVOICE
                  AND D.BUSINESS_UNIT = B.BUSINESS_UNIT)
   AND EXISTS (SELECT /* index(c XPKOTR_TRNBI_BI_HDR_PSB) */  'X'
                 FROM OTR_TRNBI_BI_HDR_PSB C
                WHERE '7' = C.TRNBI_PROJECT_TYPE
                  AND D.INVOICE = C.INVOICE
                  AND D.BUSINESS_UNIT = C.BUSINESS_UNIT)
)

GROUP BY
BUSINESS_UNIT
,GL_ACCOUNT
,DEPTID
,DEPT_DESCR
,PROD_DESCR
,PRODCODE
--ADD BY ALEX
,GL_PRODCODE
--ADD BY ALEX
,NVL(RESERVE_GROUP,'LARGE')
,JRNL_DATE
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY'))
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM'))
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM'))
,JRNL_ID
,CURRENCY
,NATION_CURR

Union all
SELECT  /*+ NO_CPU_COSTING */
'P21' AS QUERY_SOURCE,
 BUSINESS_UNIT AS BU
,SUM(P7_TOTAL ) AS REVENUE_AMOUNT
,SUM(100*(P7_TOTAL-TRUNC(P7_TOTAL))) AS REVENUE_AMOUNT_DEC
,GL_ACCOUNT AS GL_ACCOUNT
,DEPTID AS DEPT_ID
,DEPT_DESCR AS DEPT_DESCR
,PRODCODE AS MANF_PROD_ID
,PROD_DESCR AS MANF_PROD_DESCR
/* CHANGING 5/18/2007 MSUN*/
, GL_PRODCODE  AS DIST_GL_PRODUCT
,NVL(RESERVE_GROUP,'LARGE') AS RESERVE_GROUP
,JRNL_DATE AS JRNL_DATE
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY')) AS JRNL_YEAR
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM')) AS JRNL_MONTH
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM')) AS JRNL_YEAR_MONTH
,JRNL_ID AS JRNL_ID
,CURRENCY AS CURRENCY
,NATION_CURR AS COUNTRY_INDICATOR
FROM (
SELECT  /*+ NO_CPU_COSTING */ D.BUSINESS_UNIT_GL AS BUSINESS_UNIT,
       D.INVOICE AS INVOICE,
       D.LINE_SEQ_NUM AS SEQ_NUM,
       D.ACCT_ENTRY_TYPE AS ENTRY_TYPE,
       D.JOURNAL_ID AS JRNL_ID,
       D.JOURNAL_DATE AS JRNL_DATE,
       D.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
       D.MONETARY_AMOUNT AS P7_TOTAL,
       D.R12_LOCATION /* -SS- DEPTID */ AS DEPTID,
       AOL.OFFICE_NAME AS DEPT_DESCR,
       PR.DESCR AS PROD_DESCR,
       X.PRODUCT_CATEGORY AS RESERVE_GROUP,
       A.R12_PRODUCT /* -SS- IDENTIFIER */ AS PRODCODE,
       CASE WHEN D.R12_PRODUCT /* -SS- PRODUCT */ = '0064' THEN '804155' /* -SS- ???? */
            ELSE D.R12_PRODUCT /* -SS- PRODUCT */ END AS GL_PRODCODE,
       D.CURRENCY_CD AS CURRENCY,
       AOL.NATION_CURR
  FROM R12_BI_LINE_PSB /* -SS- OTR */ A,
       R12_BI_ACCT_ENTRY_PSB D, /* -SS- OTR */
       OTR_PROD_CODE_XREF_RCPO X,
       R12_TRANE_PRODUCTS_PS /* -SS- OTR */ PR,
       ACTUATE_OFFICE_LOCATION AOL
 WHERE D.JOURNAL_DATE BETWEEN TO_DATE('01/11/2014', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
   AND '411101' /* -SS- '700000' */ = D.R12_ACCOUNT /* -SS- ACCOUNT */
   AND 'ACTUALS' = D.LEDGER
/* -SS-
805100 -> 41208
802921 -> 41399
801270 -> 41132
803270 -> 41499
804140 -> 41205
804140 -> 41299
*/
   AND '41208' <> D.R12_PRODUCT
   AND '41399' <> D.R12_PRODUCT
   AND '41132' <> D.R12_PRODUCT
   AND '41499' <> D.R12_PRODUCT
   AND '41205' <> D.R12_PRODUCT
   AND '41299' <> D.R12_PRODUCT
   /* -SS-
   AND '805100' <> D.PRODUCT
   AND '802921' <> D.PRODUCT
   AND '801270' <> D.PRODUCT
   AND '803270' <> D.PRODUCT
   AND '804140' <> D.PRODUCT
   */
   AND D.LINE_SEQ_NUM = A.LINE_SEQ_NUM
   AND D.INVOICE = A.INVOICE
   AND D.BUSINESS_UNIT = A.BUSINESS_UNIT
   AND D.BUSINESS_UNIT = X.GL_LEDGER (+)
   AND D.R12_PRODUCT /* -SS- PRODUCT */ = X.MANF_PROD_CODE (+)
   AND D.R12_PRODUCT /* -SS- PRODUCT */ = PR.R12_PRODUCT /* -SS- PRODUCT */ (+)
   AND D.R12_LOCATION /* -SS- DEPTID */ = AOL.ORA_LOCATION /* -SS- DEPT_ID */ (+)
   AND D.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ = AOL.ORA_ENTITY /* -SS- BU_UNIT */ (+)
   AND EXISTS (SELECT /* index(b XPKOTR_BI_HDR_PSB) */ 'X'
                 FROM OTR_BI_HDR_PSB B
                WHERE B.BILL_SOURCE_ID = 'P21'
                  AND D.INVOICE = B.INVOICE
                  AND D.BUSINESS_UNIT = B.BUSINESS_UNIT)
   AND EXISTS (SELECT /* index(c XPKOTR_TRNBI_BI_HDR_PSB) */  'X'
                 FROM OTR_TRNBI_BI_HDR_PSB C
                WHERE '7' = C.TRNBI_PROJECT_TYPE
                  AND D.INVOICE = C.INVOICE
                  AND D.BUSINESS_UNIT = C.BUSINESS_UNIT)
)

GROUP BY
BUSINESS_UNIT
,GL_ACCOUNT
,DEPTID
,DEPT_DESCR
,PROD_DESCR
,PRODCODE
--ADD BY ALEX
,GL_PRODCODE
--ADD BY ALEX
,NVL(RESERVE_GROUP,'LARGE')
,JRNL_DATE
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY'))
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM'))
,TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE),'MM'))
,JRNL_ID
,CURRENCY
,NATION_CURR

union all
/*- 5H QUERY PUEBLO/1 */

SELECT  /*+   ORDERED NO_CPU_COSTING  INDEX(PR XAK1AP_135_PROJ_RESOURCE)*/
'PUEBLO' AS QUERY_SOURCE,
PR.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU,
(CD.RESOURCE_AMOUNT)AS REVENUE_AMOUNT,
(100*(CD.RESOURCE_AMOUNT -TRUNC(CD.RESOURCE_AMOUNT))) AS REVENUE_AMOUNT_DEC,
PR.R12_ACCOUNT /* -SS- ACCOUNT */ GL_ACCOUNT,
PR.R12_LOCATION /* -SS-- DEPTID */ AS DEPT_ID,
PR.DESCR AS DEPT_DESCR,
RES.TRNPC_MFG_PROD_CD AS MANF_PROD_ID,
MPC.PRODUCT_CODE_DESCRIPTION AS MANF_PROD_DESCR,
MPC.DIST_PROD_CODE AS DIST_GL_PRODUCT
,'Large'  AS RESERVE_GROUP
, PR.ACCOUNTING_DT AS JRNL_DATE
,TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT,'YYYY')) AS JRNL_YEAR
,TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT,'MM') ) AS JRNL_MONTH
,TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT,'YYYY')) * 100 + TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT,'MM') )  AS JRNL_YEAR_MONTH
, PR.JOURNAL_ID AS JRNL_ID
, PR.CURRENCY_CD AS CURRENCY
, CASE
  WHEN PR. R12_ENTITY IN ('5773', '5588')
  THEN 'CAN'
  ELSE 'USA'
  END AS COUNTRY_INDICATOR

FROM R12_PROJ_RESOURCE_PS /* -SS- OTR was AP_135_PROJ_RESOURCE */ PR, -- @ED_INTFC_DR.LAX.TRANE.COM PR,
AP_135_TRNPC_PROJ_RES  RES, --@ED_INTFC_DR.LAX.TRANE.COM  RES,
AP_400_SEL_CRED_JB_CLSS_CD   JBCLSCD,--@ED_INTFC_DR.LAX.TRANE.COM  JBCLSCD,
AP_400_JOB_CODE   JBCD,-- @ED_INTFC_DR.LAX.TRANE.COM  JBCD,
AP_135_TRNPC_COMM_DATA    CD,--@ED_INTFC_DR.LAX.TRANE.COM  CD,
AP_400_COMM_CODE  CC,--@ED_INTFC_DR.LAX.TRANE.COM  CC,
/* -SS- MD_SECURITY_ENTITY_DRV SEC, @ED_INTFC_DR.LAX.TRANE.COM  SEC, */
MD_PRODUCT_CODE MPC --  @ED_INTFC_DR.LAX.TRANE.COM  MPC

WHERE /* -SS- PR.BUSINESS_UNIT_GL = SEC.PS_GL
AND PR.DEPTID = SEC.PS_DEPT_ID
AND */ PR.BUSINESS_UNIT = RES.BUSINESS_UNIT
AND PR.PROJECT_ID = RES.PROJECT_ID
AND PR.RESOURCE_ID = RES.RESOURCE_ID
AND PR.ACTIVITY_ID = RES.ACTIVITY_ID
AND PR.PROJECT_ID = CAST (JBCLSCD.CREDIT_JOB_ID AS VARCHAR2 (15 Byte))
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
AND (PR.R12_ACCOUNT /* -SS- ACCOUNT */ = '700000' /* -SS- ???? */ OR PR.R12_ACCOUNT /* -SS- ACCOUNT */ = '700020' /* -SS- ???? */)
AND PR.GL_DISTRIB_STATUS = 'G'
AND JBCD.JOB_CLASS_ID = 38
AND TRUNC (PR.ACCOUNTING_DT) >= TO_DATE ('01/01/2007', 'MM/DD/YYYY')
AND TRUNC (PR.ACCOUNTING_DT) <= TO_DATE ('12/31/2050', 'MM/DD/YYYY')
--AND RES.TRNPC_LEG_ORD_NBR LIKE 'F2N483%'
--AND RES.TRNPC_CUST_ACCT LIKE '7635758%'

