SELECT  /*+ NO_CPU_COSTING */ 
CASE WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(A.GL_POSTED_DATE,'YYYYMM')AS JRNL_YEAR_MONTH, 
A.COMPANY AS BU, 
A.ACCOUNT AS GL_ACCOUNT, 
A.cost_center AS GL_DEP_ID, 
'Oracle Ledger' as QUERY_SOURCE,
A.PRODUCT_code AS GL_PRODUCT_ID, 
A.GL_POSTED_DATE AS JOURNAL_DATE ,
cast (A.posting_control_id as varchar2(10))AS JOURNAL_ID , 
--A.posting_control_id AS JOURNAL_ID,
A.AMOUNT *-1  AS REVENUE_AMOUNT,
(100*(A.AMOUNT*-1 -TRUNC(A.AMOUNT*-1))) AS REVENUE_AMOUNT_DEC
 

FROM DBO.ap_030_arc_bill_mvw /* ???? translate to what? */ A
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,dbo.ACTUATE_SEC_XREF ASX */
WHERE 
/* -SS- A.COMPANY= ASX.PSGL(+)
and */ A.ACCOUNT   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
AND A.GL_POSTED_DATE BETWEEN TO_DATE('01/01/2000','MM/DD/YYYY') AND TO_DATE('12/31/2004','MM/DD/YYYY')
and a.category ='Sales Invoices'
and ( A.ACCOUNT like '52%' or A.ACCOUNT like '53%' or A.ACCOUNT like '54%')

union all
SELECT /*+ NO_CPU_COSTING */ 
CASE WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(A.JOURNAL_DATE,'YYYYMM')AS JRNL_YEAR_MONTH, 
A.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU, 
A.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT, 
A.R12_LOCATION /* -SS- DEPTID */ AS GL_DEP_ID, 
'P/S Ledger' as QUERY_SOURCE,
A.R12_PRODUCT /* -SS- PRODUCT */ AS GL_PRODUCT_ID, 
A.JOURNAL_DATE AS JOURNAL_DATE ,
(A.JOURNAL_ID ) AS JOURNAL_ID , 
A.MONETARY_AMOUNT *-1  AS REVENUE_AMOUNT,
(100*(A.MONETARY_AMOUNT*-1 -TRUNC(A.MONETARY_AMOUNT*-1))) AS REVENUE_AMOUNT_DEC


FROM 
dbo.R12_BI_ACCT_ENTRY_PSB /* OTR */ A
,dbo.OTR_TRNBI_BI_HDR_PSB B
,dbo.OTR_BI_HDR_PSB C
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* --SS- ,dbo.ACTUATE_SEC_XREF ASX */

WHERE A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2003','MM/DD/YYYY') AND TO_DATE('12/31/2050','MM/DD/YYYY')
AND   A.BUSINESS_UNIT_GL IN ('CAN' ,'CSD') /* -SS- ???? */
/* -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+) */
AND a.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
AND A.BUSINESS_UNIT = B.BUSINESS_UNIT 
AND A.INVOICE = B.INVOICE 
AND B.BUSINESS_UNIT = C.BUSINESS_UNIT 
AND B.INVOICE = C.INVOICE 
AND C.ENTRY_TYPE = 'IN'
and A.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '52%' /* -SS- ???? */

union all
SELECT /*+ NO_CPU_COSTING */  
CASE WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(A.JOURNAL_DATE,'YYYYMM')AS JRNL_YEAR_MONTH, 
A.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU, 
A.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT, 
A.R12_LOCATION /* -SS- DEPTID */ AS GL_DEP_ID, 
'P/S Ledger' as QUERY_SOURCE,
A.R12_PRODUCT /* -SS- PRODUCT */ AS GL_PRODUCT_ID, 
A.JOURNAL_DATE AS JOURNAL_DATE ,
(A.JOURNAL_ID ) AS JOURNAL_ID , 
A.MONETARY_AMOUNT *-1  AS REVENUE_AMOUNT,
(100*(A.MONETARY_AMOUNT*-1 -TRUNC(A.MONETARY_AMOUNT*-1))) AS REVENUE_AMOUNT_DEC


FROM 
dbo.R12_BI_ACCT_ENTRY_PSB /* -SS- OTR */ A
,dbo.OTR_TRNBI_BI_HDR_PSB B
,dbo.OTR_BI_HDR_PSB C
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,dbo.ACTUATE_SEC_XREF ASX */

WHERE A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2003','MM/DD/YYYY') AND TO_DATE('12/31/2050','MM/DD/YYYY')
AND   A.BUSINESS_UNIT_GL IN ('CAN' ,'CSD') /* -SS- ???? */
/* -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+) */
AND a.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
AND A.BUSINESS_UNIT = B.BUSINESS_UNIT 
AND A.INVOICE = B.INVOICE 
AND B.BUSINESS_UNIT = C.BUSINESS_UNIT 
AND B.INVOICE = C.INVOICE 
AND C.ENTRY_TYPE = 'IN'
and A.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '53%' /* -SS- ???? */


union all
SELECT /*+ NO_CPU_COSTING */ 
CASE WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(A.JOURNAL_DATE,'YYYYMM')AS JRNL_YEAR_MONTH, 
A.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU, 
A.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT, 
A.R12_LOCATION /* -SS- DEPTID */ AS GL_DEP_ID, 
'P/S Ledger' as QUERY_SOURCE,
A.R12_PRODUCT /* -SS- PRODUCT */ AS GL_PRODUCT_ID, 
A.JOURNAL_DATE AS JOURNAL_DATE ,
(A.JOURNAL_ID ) AS JOURNAL_ID , 
A.MONETARY_AMOUNT *-1  AS REVENUE_AMOUNT,
(100*(A.MONETARY_AMOUNT*-1 -TRUNC(A.MONETARY_AMOUNT*-1))) AS REVENUE_AMOUNT_DEC


FROM 
dbo.R12_BI_ACCT_ENTRY_PSB /* -SS- OTR */ A
, dbo.OTR_TRNBI_BI_HDR_PSB B
, dbo.OTR_BI_HDR_PSB C
, R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,dbo.ACTUATE_SEC_XREF ASX */

WHERE A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2003','MM/DD/YYYY') AND TO_DATE('12/31/2050','MM/DD/YYYY')
AND   A.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ IN ('CAN' ,'CSD') /* -SS- ???? */
/* -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+) */
AND a.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
AND A.BUSINESS_UNIT = B.BUSINESS_UNIT 
AND A.INVOICE = B.INVOICE 
AND B.BUSINESS_UNIT = C.BUSINESS_UNIT 
AND B.INVOICE = C.INVOICE 
AND C.ENTRY_TYPE = 'IN'
and A.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '54%' /* -SS- ???? */

UNION ALL

/* SALES DATA BACK FROM 1998 TO 1999*/ 
SELECT  /*+ NO_CPU_COSTING */ 
UPD.COUNTRY_INDICATOR AS COUNTRY_INDICATOR,
TO_CHAR(UPD.JRNL_DATE,'YYYYMM')AS JRNL_YEAR_MONTH, 
'' AS BU, 
UPD.GL_ACCOUNT  AS GL_ACCOUNT, 
'' AS GL_DEP_ID, 
'SALES 1998' AS QUERY_SOURCE,
'' AS GL_PRODUCT_ID, 
UPD.JRNL_DATE  AS JOURNAL_DATE ,
''AS JOURNAL_ID , 
UPD.REVENUE_AMOUNT  AS REVENUE_AMOUNT,
(100*(UPD.REVENUE_AMOUNT - TRUNC(UPD.REVENUE_AMOUNT))) AS REVENUE_AMOUNT_DEC

FROM MD_030_SALES_DTL_UPD UPD ,
R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
WHERE 
UPD.GL_ACCOUNT   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
AND UPD.JRNL_DATE BETWEEN TO_DATE('01/01/1998','MM/DD/YYYY') AND TO_DATE('12/31/2003','MM/DD/YYYY')