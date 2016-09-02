SELECT
CASE WHEN DIST.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
DIST.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU,
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
dist.R12_LOCATION /* -SS- deptid */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
dist.R12_PRODUCT /* -SS- product */ AS GL_PRODUCT_ID,
DIST.JOURNAL_DATE AS JOURNAL_DATE ,
dist.journal_id AS JOURNAL_ID ,
Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end  AS DOLLAR_AMOUNT,
(100*(dist.debit_amt  -TRUNC(dist.debit_amt))) AS DOLLAR_AMOUNT_DEC

FROM dbo.R12_trnco_cm_dist_psb /* -SS- OTR */ dist
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- /* -SS- ,DBO.ACTUATE_SEC_XREF ASX */ */
WHERE
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- /* -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL */ */
AND DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004','MM/DD/YYYY') AND TO_DATE('12/31/2009','MM/DD/YYYY')
AND DIST.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '52%' /* -SS- ???? */
and DIST.R12_ENTITY <> '5773' /* -SS- ASX.NATION_CURR = 'USD' */
and ( dist.R12_LOCATION /* -SS- deptid */ IS NULL OR (dist.R12_LOCATION /* -SS- deptid */ = 'SL00' /* -SS- ???? */ ))

Union all

SELECT
CASE WHEN DIST.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
DIST.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU,
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
dist.R12_LOCATION /* -SS- deptid */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
dist.R12_PRODUCT /* -SS- product */ AS GL_PRODUCT_ID,
DIST.JOURNAL_DATE AS JOURNAL_DATE ,
dist.journal_id AS JOURNAL_ID ,
Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end  AS DOLLAR_AMOUNT,
(100*(dist.debit_amt  -TRUNC(dist.debit_amt))) AS DOLLAR_AMOUNT_DEC

FROM dbo.R12_trnco_cm_dist_psb /* -SS- OTR */ dist
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- /* -SS- ,DBO.ACTUATE_SEC_XREF ASX */ */
WHERE
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- /* -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL */ */
AND DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004','MM/DD/YYYY') AND TO_DATE('12/31/2009','MM/DD/YYYY')
AND DIST.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '53%' /* -SS- ???? */
and DIST.R12_ENTITY <> '5773' /* -SS- ASX.NATION_CURR = 'USD' */
and ( dist.R12_LOCATION /* -SS- deptid */ IS NULL OR (dist.R12_LOCATION /* -SS- deptid */ = 'SL00' /* -SS- ???? */ ))

Union all

SELECT
CASE WHEN DIST.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
DIST.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU,
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
DIST.R12_LOCATION /* -SS- DEPTID */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
DIST.R12_PRODUCT /* -SS- PRODUCT */ AS GL_PRODUCT_ID,
DIST.JOURNAL_DATE AS JOURNAL_DATE ,
dist.journal_id AS JOURNAL_ID ,
Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end  AS DOLLAR_AMOUNT,
(100*(dist.debit_amt  -TRUNC(dist.debit_amt))) AS DOLLAR_AMOUNT_DEC

FROM DBO.R12_TRNCO_CM_DIST_PSB /* -SS- OTR */ DIST
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,DBO.ACTUATE_SEC_XREF ASX */
WHERE
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL */
AND DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004','MM/DD/YYYY') AND TO_DATE('12/31/2009','MM/DD/YYYY')
AND DIST.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '54%' /* -SS- ???? */
AND DIST.R12_ENTITY <> '5773' /* -SS- ASX.NATION_CURR = 'USD' */
and ( DIST.R12_LOCATION /* -SS- DEPTID */ IS NULL OR (DIST.R12_LOCATION /* -SS- DEPTID */ = 'SL00' /* -SS- ???? */ ))

UNION ALL

SELECT
CASE WHEN DIST.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
DIST.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU,
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
DIST.R12_LOCATION /* -SS- DEPTID */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
DIST.R12_PRODUCT /* -SS- PRODUCT */ AS GL_PRODUCT_ID,
DIST.JOURNAL_DATE AS JOURNAL_DATE ,
dist.journal_id AS JOURNAL_ID ,
Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end  AS DOLLAR_AMOUNT,
(100*(dist.debit_amt  -TRUNC(dist.debit_amt))) AS DOLLAR_AMOUNT_DEC

FROM DBO.R12_TRNCO_CM_DIST_PSB /* -SS- OTR */ DIST
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,DBO.ACTUATE_SEC_XREF ASX */
WHERE
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL */
AND DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004','MM/DD/YYYY') AND TO_DATE('12/31/2009','MM/DD/YYYY')
AND DIST.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '52%' /* -SS- ???? */
AND DIST.R12_ENTITY = '5773' /* -SS- ASX.NATION_CURR = 'CAD' */
and ( DIST.R12_LOCATION /* -SS- DEPTID */ IS NULL OR ( DIST.R12_LOCATION /* -SS- DEPTID */ = 'TCA0' /* -SS- ???? */ ) OR ( DIST.R12_LOCATION /* -SS- DEPTID */ = 'SL00' /* -SS- ???? */ ))

Union all

SELECT
CASE WHEN DIST.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
DIST.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU,
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
DIST.R12_LOCATION /* -SS- DEPTID */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
DIST.R12_PRODUCT /* -SS- PRODUCT */ AS GL_PRODUCT_ID,
DIST.JOURNAL_DATE AS JOURNAL_DATE ,
dist.journal_id AS JOURNAL_ID ,
Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end  AS DOLLAR_AMOUNT,
(100*(dist.debit_amt  -TRUNC(dist.debit_amt))) AS DOLLAR_AMOUNT_DEC

FROM DBO.R12_TRNCO_CM_DIST_PSB /* -SS- OTR */ DIST
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,DBO.ACTUATE_SEC_XREF ASX */
WHERE
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL */
AND DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004','MM/DD/YYYY') AND TO_DATE('12/31/2009','MM/DD/YYYY')
AND DIST.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '53%' /* -SS- ???? */
AND DIST.R12_ENTITY = '5773' /* -SS- ASX.NATION_CURR = 'CAD' */
and ( DIST.R12_LOCATION /* -SS- DEPTID */ IS NULL OR ( DIST.R12_LOCATION /* -SS- DEPTID */ = 'TCA0' /* -SS- ???? */ ) OR ( DIST.R12_LOCATION /* -SS- DEPTID */ = 'SL00' /* -SS- ???? */ ))

Union all

SELECT
CASE WHEN DIST.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
DIST.R12_ENTITY /* -SS- BUSINESS_UNIT_GL */ AS BU,
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ AS GL_ACCOUNT,
DIST.R12_LOCATION /* -SS- DEPTID */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
DIST.R12_PRODUCT /* -SS- PRODUCT */ AS GL_PRODUCT_ID,
DIST.JOURNAL_DATE AS JOURNAL_DATE ,
dist.journal_id AS JOURNAL_ID ,
Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end  AS DOLLAR_AMOUNT,
(100*(dist.debit_amt  -TRUNC(dist.debit_amt))) AS DOLLAR_AMOUNT_DEC

FROM DBO.R12_TRNCO_CM_DIST_PSB /* -SS- OTR */ DIST
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,DBO.ACTUATE_SEC_XREF ASX */
WHERE
DIST.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL */
AND DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004','MM/DD/YYYY') AND TO_DATE('12/31/2009','MM/DD/YYYY')
AND DIST.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '54%' /* -SS- ???? */
AND DIST.R12_ENTITY = '5773' /* -SS- ASX.NATION_CURR = 'CAD' */
and ( DIST.R12_LOCATION /* -SS- DEPTID */ IS NULL OR ( DIST.R12_LOCATION /* -SS- DEPTID */ = 'TCA0' /* -SS- ???? */ ) OR ( DIST.R12_LOCATION /* -SS- DEPTID */ = 'SL00' /* -SS- ???? */ ))

Union all

SELECT
CASE WHEN GL_CODE.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
  /* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
TO_CHAR(COMM.GL_POSTED_DATE,'YYYYMM')AS JRNL_YEAR_MONTH,
GL_CODE.R12_ENTITY /* -SS- SEGMENT1 */ as BU,
GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ AS GL_ACCOUNT,
GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
GL_CODE.R12_PRODUCT /* -SS- SEGMENT4 */ AS GL_PRODUCT_ID,
COMM.GL_POSTED_DATE AS JOURNAL_DATE,
CAST (COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE) )AS JOURNAL_ID,
Case when COMM.DEBIT_AMOUNT =0  or COMM.DEBIT_AMOUNT is null or COMM.credit_AMOUNT <>'' then COMM.credit_AMOUNT*-1 else COMM.DEBIT_AMOUNT end  AS DOLLAR_AMOUNT,
(100*(COMM.DEBIT_AMOUNT -TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC

FROM CMS_COMMISSION_DISTRIBUTIONS COMM
,R12_GL_CODE_COMBINATIONS /* -SS- */ GL_CODE
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE
COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID
and GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000','MM/DD/YYYY') AND TO_DATE('10/31/2004','MM/DD/YYYY')
AND GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '52%' /* -SS- ???? */
AND GL_CODE.R12_ENTITY <> '5773' /* -SS- AND ASX.NATION_CURR = 'USD' */
and ( GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IS NULL OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'SL00' /* -SS- ???? */ ))

UNION ALL

SELECT
CASE WHEN GL_CODE.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
  /* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
TO_CHAR(COMM.GL_POSTED_DATE,'YYYYMM')AS JRNL_YEAR_MONTH,
GL_CODE.R12_ENTITY /* -SS- SEGMENT1 */ as BU,
GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ AS GL_ACCOUNT,
GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
GL_CODE.R12_PRODUCT /* -SS- SEGMENT4 */ AS GL_PRODUCT_ID,
COMM.GL_POSTED_DATE AS JOURNAL_DATE,
CAST (COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE) )AS JOURNAL_ID,
Case when COMM.DEBIT_AMOUNT =0  or COMM.DEBIT_AMOUNT is null or COMM.credit_AMOUNT <>'' then COMM.credit_AMOUNT*-1 else COMM.DEBIT_AMOUNT end  AS DOLLAR_AMOUNT,
(100*(COMM.DEBIT_AMOUNT -TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC

FROM CMS_COMMISSION_DISTRIBUTIONS COMM
,R12_GL_CODE_COMBINATIONS /* -SS- */ GL_CODE
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE
COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID
and GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000','MM/DD/YYYY') AND TO_DATE('10/31/2004','MM/DD/YYYY')
AND GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '53%' /* -SS- ???? */ 
AND GL_CODE.R12_ENTITY <> '5773' /* -SS- AND ASX.NATION_CURR = 'USD' */
and ( GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IS NULL OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'SL00' /* -SS- ???? */ ))

UNION ALL

SELECT
CASE WHEN GL_CODE.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
  /* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
TO_CHAR(COMM.GL_POSTED_DATE,'YYYYMM')AS JRNL_YEAR_MONTH,
GL_CODE.R12_ENTITY /* -SS- SEGMENT1 */ as BU,
GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ AS GL_ACCOUNT,
GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
GL_CODE.R12_PRODUCT /* -SS- SEGMENT4 */ AS GL_PRODUCT_ID,
COMM.GL_POSTED_DATE AS JOURNAL_DATE,
CAST (COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE) )AS JOURNAL_ID,
Case when COMM.DEBIT_AMOUNT =0  or COMM.DEBIT_AMOUNT is null or COMM.credit_AMOUNT <>'' then COMM.credit_AMOUNT*-1 else COMM.DEBIT_AMOUNT end  AS DOLLAR_AMOUNT,
(100*(COMM.DEBIT_AMOUNT -TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC

FROM CMS_COMMISSION_DISTRIBUTIONS COMM
,R12_GL_CODE_COMBINATIONS /* -SS- */ GL_CODE
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE
COMM.CODE_COMBINATION_ID=GL_CODE.CODE_COMBINATION_ID
and GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000','MM/DD/YYYY') AND TO_DATE('10/31/2004','MM/DD/YYYY')
AND GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '54%' /* -SS- ???? */ 
AND GL_CODE.R12_ENTITY <> '5773' /* -SS- AND ASX.NATION_CURR = 'USD' */
and ( GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IS NULL OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'SL00' /* -SS- ???? */ ))

UNION ALL

SELECT
CASE WHEN GL_CODE.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
  /* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
TO_CHAR(COMM.GL_POSTED_DATE,'YYYYMM')AS JRNL_YEAR_MONTH,
GL_CODE.R12_ENTITY /* -SS- SEGMENT1 */ as BU,
GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ AS GL_ACCOUNT,
GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
GL_CODE.R12_PRODUCT /* -SS- SEGMENT4 */ AS GL_PRODUCT_ID,
COMM.GL_POSTED_DATE AS JOURNAL_DATE,
CAST (COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE) )AS JOURNAL_ID,
Case when COMM.DEBIT_AMOUNT =0  or COMM.DEBIT_AMOUNT is null or COMM.credit_AMOUNT <>'' then COMM.credit_AMOUNT*-1 else COMM.DEBIT_AMOUNT end  AS DOLLAR_AMOUNT,
(100*(COMM.DEBIT_AMOUNT -TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC

FROM CMS_COMMISSION_DISTRIBUTIONS COMM
,R12_GL_CODE_COMBINATIONS /* -SS- */ GL_CODE
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE
COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID
and GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000','MM/DD/YYYY') AND TO_DATE('10/31/2004','MM/DD/YYYY')
AND GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '52%' /* -SS- ???? */ 
AND GL_CODE.R12_ENTITY = '5773' /* -SS- AND ASX.NATION_CURR = 'CAD' */
and ( GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IS NULL OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'TCA0' /* -SS- ???? */ ) OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'SL00' /* -SS- ???? */ ))

UNION ALL

SELECT
CASE WHEN GL_CODE.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
  /* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
TO_CHAR(COMM.GL_POSTED_DATE,'YYYYMM')AS JRNL_YEAR_MONTH,
GL_CODE.R12_ENTITY /* -SS- SEGMENT1 */ as BU,
GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ AS GL_ACCOUNT,
GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
GL_CODE.R12_PRODUCT /* -SS- SEGMENT4 */ AS GL_PRODUCT_ID,
COMM.GL_POSTED_DATE AS JOURNAL_DATE,
CAST (COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE) )AS JOURNAL_ID,
Case when COMM.DEBIT_AMOUNT =0  or COMM.DEBIT_AMOUNT is null or COMM.credit_AMOUNT <>'' then COMM.credit_AMOUNT*-1 else COMM.DEBIT_AMOUNT end  AS DOLLAR_AMOUNT,
(100*(COMM.DEBIT_AMOUNT -TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC

FROM CMS_COMMISSION_DISTRIBUTIONS COMM
,R12_GL_CODE_COMBINATIONS /* -SS- */ GL_CODE
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE
COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID
and GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000','MM/DD/YYYY') AND TO_DATE('10/31/2004','MM/DD/YYYY')
AND GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '53%' /* -SS- ???? */ 
AND GL_CODE.R12_ENTITY = '5773' /* -SS- AND ASX.NATION_CURR = 'CAD' */
and ( GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IS NULL OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'TCA0' /* -SS- ???? */ ) OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'SL00' /* -SS- ???? */ ))

UNION ALL

SELECT
CASE WHEN GL_CODE.R12_ENTITY = '5773' THEN 'CDN' ELSE 'USD' END /* ASX.NATION_CURR */ AS COUNTRY_INDICATOR,
  /* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
TO_CHAR(COMM.GL_POSTED_DATE,'YYYYMM')AS JRNL_YEAR_MONTH,
GL_CODE.R12_ENTITY /* -SS- SEGMENT1 */ as BU,
GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ AS GL_ACCOUNT,
GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ AS GL_DEP_ID,
'P/S LEDGER' as QUERY_SOURCE,
GL_CODE.R12_PRODUCT /* -SS- SEGMENT4 */ AS GL_PRODUCT_ID,
COMM.GL_POSTED_DATE AS JOURNAL_DATE,
CAST (COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE) )AS JOURNAL_ID,
Case when COMM.DEBIT_AMOUNT =0  or COMM.DEBIT_AMOUNT is null or COMM.credit_AMOUNT <>'' then COMM.credit_AMOUNT*-1 else COMM.DEBIT_AMOUNT end  AS DOLLAR_AMOUNT,
(100*(COMM.DEBIT_AMOUNT -TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC

FROM CMS_COMMISSION_DISTRIBUTIONS COMM
,R12_GL_CODE_COMBINATIONS /* -SS- */ GL_CODE
,R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE
COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID
and GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000','MM/DD/YYYY') AND TO_DATE('10/31/2004','MM/DD/YYYY')
AND GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '54%' /* -SS- ???? */ 
AND GL_CODE.R12_ENTITY = '5773' /* -SS- AND ASX.NATION_CURR = 'CAD' */
and ( GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IS NULL OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'TCA0' /* -SS- ???? */ ) OR 
	(GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'SL00' /* -SS- ???? */ ))

UNION ALL

/* COMMISSION DATA BACK FROM 1998 TO 1999*/
SELECT
CASE WHEN UPD.COUNTRY_INDICATOR ='CAN' THEN 'CAD' ELSE 'USD' END  AS COUNTRY_INDICATOR,
TO_CHAR(UPD.JRNL_DATE,'YYYYMM')AS JRNL_YEAR_MONTH,
'' AS BU,
UPD.GL_ACCOUNT  AS GL_ACCOUNT,
'' AS GL_DEP_ID,
'COMM 1998' AS QUERY_SOURCE,
'' AS GL_PRODUCT_ID,
UPD.JRNL_DATE  AS JOURNAL_DATE ,
''AS JOURNAL_ID ,
UPD.REVENUE_AMOUNT  AS REVENUE_AMOUNT,
(100*(UPD.REVENUE_AMOUNT - TRUNC(UPD.REVENUE_AMOUNT))) AS REVENUE_AMOUNT_DEC

FROM MD_030_COMMISSION_DTL_UPD UPD ,
R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
WHERE
UPD.GL_ACCOUNT   = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
AND PSA.TRANE_ACCOUNT_IND='X'
AND UPD.JRNL_DATE BETWEEN TO_DATE('01/01/1998','MM/DD/YYYY') AND TO_DATE('12/31/1999','MM/DD/YYYY')
