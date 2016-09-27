SELECT
	CASE
		WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END AS COUNTRY_INDICATOR,
	-- -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR,
	TO_CHAR(DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	DIST.R12_ENTITY                      AS BU,         -- -SS- BUSINESS_UNIT_GL
	DIST.R12_ACCOUNT                     AS GL_ACCOUNT, -- -SS- ACCOUNT
	DIST.R12_LOCATION                    AS GL_DEP_ID,  -- -SS- deptid
	'P/S LEDGER'                         AS QUERY_SOURCE,
	DIST.R12_PRODUCT                     AS GL_PRODUCT_ID, -- -SS- product
	DIST.JOURNAL_DATE                    AS JOURNAL_DATE,
	DIST.JOURNAL_ID                      AS JOURNAL_ID,
	CASE
		WHEN DIST.DEBIT_AMT = 0 OR DIST.DEBIT_AMT IS NULL OR DIST.CREDIT_AMOUNT <> '' THEN DIST.CREDIT_AMOUNT * - 1
		ELSE DIST.DEBIT_AMT
	END                                             AS DOLLAR_AMOUNT,
	(100 *(DIST.DEBIT_AMT - TRUNC(DIST.DEBIT_AMT))) AS DOLLAR_AMOUNT_DEC
FROM DBO.R12_TRNCO_CM_DIST_PSB DIST -- -SS- OTR
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
	-- -SS- /NEW
INNER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR
ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- DBO.ACTUATE_SEC_XREF ASX */
WHERE
	-- -SS- DIST.ACCOUNT = PSA.ACCOUNT
	-- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL
	DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004', 'MM/DD/YYYY') AND TO_DATE('12/31/2009', 'MM/DD/YYYY')
	-- -SS- NEW
AND((DIST.PS_ACCOUNT = 'NA'
AND AFU.LIKE_52      = 'Y')
OR(DIST.PS_ACCOUNT  <> 'NA'
AND DIST.PS_ACCOUNT LIKE '52%'))
	-- -SS- /NEW
	-- -SS- AND DIST.ACCOUNT LIKE '52%'
AND DIST.R12_ENTITY NOT IN('5773', '5588') -- -SS- ASX.NATION_CURR = 'USD'
	-- -SS- NEW
AND((DIST.PS_DEPTID    = 'NA'
AND(DIST.R12_LOCATION IS NULL
OR DIST.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(DIST.PS_DEPTID     <> 'NA'
AND (DIST.PS_DEPTID IS NULL OR DIST.PS_DEPTID = 'SL00')))
-- -SS- /NEW
-- -SS- AND (DIST.deptid IS NULL OR (DIST.deptid = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END AS COUNTRY_INDICATOR,
	-- -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR,
	TO_CHAR(DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	DIST.R12_ENTITY                      AS BU,         -- -SS- BUSINESS_UNIT_GL
	DIST.R12_ACCOUNT                     AS GL_ACCOUNT, -- -SS- ACCOUNT
	DIST.R12_LOCATION                    AS GL_DEP_ID,  -- -SS- deptid
	'P/S LEDGER'                         AS QUERY_SOURCE,
	DIST.R12_PRODUCT                     AS GL_PRODUCT_ID, -- -SS- product
	DIST.JOURNAL_DATE                    AS JOURNAL_DATE,
	DIST.JOURNAL_ID                      AS JOURNAL_ID,
	CASE
		WHEN DIST.DEBIT_AMT = 0 OR DIST.DEBIT_AMT IS NULL OR DIST.CREDIT_AMOUNT <> '' THEN DIST.CREDIT_AMOUNT * - 1
		ELSE DIST.DEBIT_AMT
	END                                             AS DOLLAR_AMOUNT,
	(100 *(DIST.DEBIT_AMT - TRUNC(DIST.DEBIT_AMT))) AS DOLLAR_AMOUNT_DEC
FROM DBO.R12_TRNCO_CM_DIST_PSB DIST -- -SS- OTR
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
	-- -SS- /NEW
INNER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR
ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- ,DBO.ACTUATE_SEC_XREF ASX
WHERE
	-- -SS- DIST.ACCOUNT = PSA.ACCOUNT
	-- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL
	DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004', 'MM/DD/YYYY') AND TO_DATE('12/31/2009', 'MM/DD/YYYY')
	-- -SS- NEW
AND((DIST.PS_ACCOUNT = 'NA'
AND AFU.LIKE_53      = 'Y')
OR(DIST.PS_ACCOUNT  <> 'NA'
AND DIST.PS_ACCOUNT LIKE '53%'))
	-- -SS- /NEW
	-- -SS- AND DIST.ACCOUNT LIKE '53%'
AND DIST.R12_ENTITY NOT IN('5773', '5588')
	-- -SS- ASX.NATION_CURR = 'USD'
	-- -SS- NEW
AND((DIST.PS_DEPTID    = 'NA'
AND(DIST.R12_LOCATION IS NULL
OR DIST.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(DIST.PS_DEPTID     <> 'NA'
AND (DIST.PS_DEPTID IS NULL OR DIST.PS_DEPTID = 'SL00')))
-- -SS- /NEW
-- -SS- AND (DIST.deptid IS NULL OR (DIST.deptid = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END AS COUNTRY_INDICATOR,
	-- -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR,
	TO_CHAR(DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	DIST.R12_ENTITY                      AS BU,         -- -SS- BUSINESS_UNIT_GL
	DIST.R12_ACCOUNT                     AS GL_ACCOUNT, -- -SS- ACCOUNT
	DIST.R12_LOCATION                    AS GL_DEP_ID,  -- -SS- DEPTID
	'P/S LEDGER'                         AS QUERY_SOURCE,
	DIST.R12_PRODUCT                     AS GL_PRODUCT_ID, -- -SS- PRODUCT
	DIST.JOURNAL_DATE                    AS JOURNAL_DATE,
	DIST.JOURNAL_ID                      AS JOURNAL_ID,
	CASE
		WHEN DIST.DEBIT_AMT = 0 OR DIST.DEBIT_AMT IS NULL OR DIST.CREDIT_AMOUNT <> '' THEN DIST.CREDIT_AMOUNT * - 1
		ELSE DIST.DEBIT_AMT
	END                                             AS DOLLAR_AMOUNT,
	(100 *(DIST.DEBIT_AMT - TRUNC(DIST.DEBIT_AMT))) AS DOLLAR_AMOUNT_DEC
FROM DBO.R12_TRNCO_CM_DIST_PSB DIST -- -SS- OTR
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
	-- -SS- /NEW
INNER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- ,DBO.ACTUATE_SEC_XREF ASX
WHERE
	-- -SS- DIST.ACCOUNT = PSA.ACCOUNT
	-- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL
	DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004', 'MM/DD/YYYY') AND TO_DATE('12/31/2009', 'MM/DD/YYYY')
	-- -SS- NEW
AND((DIST.PS_ACCOUNT = 'NA'
AND AFU.LIKE_54      = 'Y')
OR(DIST.PS_ACCOUNT  <> 'NA'
AND DIST.PS_ACCOUNT LIKE '54%'))
	-- -SS- /NEW
	-- -SS- AND DIST.ACCOUNT LIKE '54%'
AND DIST.R12_ENTITY NOT IN('5773', '5588')
	-- -SS- ASX.NATION_CURR = 'USD'
	-- -SS- NEW
AND((DIST.PS_DEPTID    = 'NA'
AND(DIST.R12_LOCATION IS NULL
OR DIST.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(DIST.PS_DEPTID     <> 'NA'
AND (DIST.PS_DEPTID IS NULL OR DIST.PS_DEPTID = 'SL00')))
-- -SS- /NEW
-- -SS- AND (DIST.deptid IS NULL OR (DIST.deptid = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END AS COUNTRY_INDICATOR,
	-- -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR,
	TO_CHAR(DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	DIST.R12_ENTITY                      AS BU,         -- -SS- BUSINESS_UNIT_GL
	DIST.R12_ACCOUNT                     AS GL_ACCOUNT, -- -SS- ACCOUNT
	DIST.R12_LOCATION                    AS GL_DEP_ID,  -- -SS- DEPTID
	'P/S LEDGER'                         AS QUERY_SOURCE,
	DIST.R12_PRODUCT                     AS GL_PRODUCT_ID, -- -SS- PRODUCT
	DIST.JOURNAL_DATE                    AS JOURNAL_DATE,
	DIST.JOURNAL_ID                      AS JOURNAL_ID,
	CASE
		WHEN DIST.DEBIT_AMT = 0 OR DIST.DEBIT_AMT IS NULL OR DIST.CREDIT_AMOUNT <> '' THEN DIST.CREDIT_AMOUNT * - 1
		ELSE DIST.DEBIT_AMT
	END                                             AS DOLLAR_AMOUNT,
	(100 *(DIST.DEBIT_AMT - TRUNC(DIST.DEBIT_AMT))) AS DOLLAR_AMOUNT_DEC
FROM DBO.R12_TRNCO_CM_DIST_PSB DIST -- -SS- OTR
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
	-- -SS- /NEW
INNER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- ,DBO.ACTUATE_SEC_XREF ASX
WHERE
	-- -SS- DIST.ACCOUNT = PSA.ACCOUNT
	-- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL
	DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004', 'MM/DD/YYYY') AND TO_DATE('12/31/2009', 'MM/DD/YYYY')
	-- -SS- NEW
AND((DIST.PS_ACCOUNT = 'NA'
AND AFU.LIKE_52      = 'Y')
OR(DIST.PS_ACCOUNT  <> 'NA'
AND DIST.PS_ACCOUNT LIKE '52%'))
	-- -SS- /NEW
	-- -SS- AND DIST.ACCOUNT LIKE '52%'
AND DIST.R12_ENTITY IN('5773', '5588')
	-- -SS- ASX.NATION_CURR = 'CAD'
	-- -SS- NEW
AND((DIST.PS_DEPTID    = 'NA'
AND(DIST.R12_LOCATION IS NULL
OR DIST.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(DIST.PS_DEPTID     <> 'NA'
AND (DIST.PS_DEPTID IS NULL OR DIST.PS_DEPTID IN('TCA0', 'SL00'))))
-- -SS- /NEW
-- -SS- AND(DIST.DEPTID IS NULL OR(DIST.DEPTID = 'TCA0') OR(DIST.DEPTID = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END AS COUNTRY_INDICATOR,
	-- -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR,
	TO_CHAR(DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	DIST.R12_ENTITY                      AS BU,         -- -SS- BUSINESS_UNIT_GL
	DIST.R12_ACCOUNT                     AS GL_ACCOUNT, -- -SS- ACCOUNT
	DIST.R12_LOCATION                    AS GL_DEP_ID,  -- -SS- DEPTID
	'P/S LEDGER'                         AS QUERY_SOURCE,
	DIST.R12_PRODUCT                     AS GL_PRODUCT_ID, -- -SS- PRODUCT
	DIST.JOURNAL_DATE                    AS JOURNAL_DATE,
	DIST.JOURNAL_ID                      AS JOURNAL_ID,
	CASE
		WHEN DIST.DEBIT_AMT = 0 OR DIST.DEBIT_AMT IS NULL OR DIST.CREDIT_AMOUNT <> '' THEN DIST.CREDIT_AMOUNT * - 1
		ELSE DIST.DEBIT_AMT
	END                                             AS DOLLAR_AMOUNT,
	(100 *(DIST.DEBIT_AMT - TRUNC(DIST.DEBIT_AMT))) AS DOLLAR_AMOUNT_DEC
FROM DBO.R12_TRNCO_CM_DIST_PSB DIST -- -SS- OTR
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
	-- -SS- /NEW
INNER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- ,DBO.ACTUATE_SEC_XREF ASX
WHERE
	-- -SS- DIST.ACCOUNT = PSA.ACCOUNT
	-- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL
	DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004', 'MM/DD/YYYY') AND TO_DATE('12/31/2009', 'MM/DD/YYYY')
	-- -SS- NEW
AND((DIST.PS_ACCOUNT = 'NA'
AND AFU.LIKE_53      = 'Y')
OR(DIST.PS_ACCOUNT  <> 'NA'
AND DIST.PS_ACCOUNT LIKE '53%'))
	-- -SS- /NEW
	-- -SS- AND DIST.ACCOUNT LIKE '53%'
AND DIST.R12_ENTITY IN('5773', '5588')
	-- -SS- ASX.NATION_CURR = 'CAD'
	-- -SS- NEW
AND((DIST.PS_DEPTID    = 'NA'
AND(DIST.R12_LOCATION IS NULL
OR DIST.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(DIST.PS_DEPTID     <> 'NA'
AND DISP.PS_DEPTID IS NULL OR DIST.PS_DEPTID IN('TCA0', 'SL00')))
-- -SS- /NEW
-- -SS- AND(DIST.DEPTID IS NULL OR(DIST.DEPTID = 'TCA0') OR(DIST.DEPTID = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END AS COUNTRY_INDICATOR,
	-- -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR,
	TO_CHAR(DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	DIST.R12_ENTITY                      AS BU,         -- -SS- BUSINESS_UNIT_GL
	DIST.R12_ACCOUNT                     AS GL_ACCOUNT, -- -SS- ACCOUNT
	DIST.R12_LOCATION                    AS GL_DEP_ID,  -- -SS- DEPTID
	'P/S LEDGER'                         AS QUERY_SOURCE,
	DIST.R12_PRODUCT                     AS GL_PRODUCT_ID, -- -SS- PRODUCT
	DIST.JOURNAL_DATE                    AS JOURNAL_DATE,
	DIST.JOURNAL_ID                      AS JOURNAL_ID,
	CASE
		WHEN DIST.DEBIT_AMT = 0 OR DIST.DEBIT_AMT IS NULL OR DIST.CREDIT_AMOUNT <> '' THEN DIST.CREDIT_AMOUNT * - 1
		ELSE DIST.DEBIT_AMT
	END                                             AS DOLLAR_AMOUNT,
	(100 *(DIST.DEBIT_AMT - TRUNC(DIST.DEBIT_AMT))) AS DOLLAR_AMOUNT_DEC
FROM DBO.R12_TRNCO_CM_DIST_PSB DIST -- -SS- OTR
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
	-- -SS- /NEW
INNER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- ,DBO.ACTUATE_SEC_XREF ASX
WHERE
	-- -SS- DIST.ACCOUNT = PSA.ACCOUNT
	-- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
	-- -SS- AND DIST.BUSINESS_UNIT_GL = ASX.PSGL
	DIST.JOURNAL_DATE BETWEEN TO_DATE('11/01/2004', 'MM/DD/YYYY') AND TO_DATE('12/31/2009', 'MM/DD/YYYY')
	-- -SS- NEW
AND((DIST.PS_ACCOUNT = 'NA'
AND AFU.LIKE_54      = 'Y')
OR(DIST.PS_ACCOUNT  <> 'NA'
AND DIST.PS_ACCOUNT LIKE '54%'))
	-- -SS- /NEW
	-- -SS- AND DIST.ACCOUNT LIKE '54%'
AND DIST.R12_ENTITY IN('5773', '5588')
	-- -SS- ASX.NATION_CURR = 'CAD'
	-- -SS- NEW
AND((DIST.PS_DEPTID    = 'NA'
AND(DIST.R12_LOCATION IS NULL
OR DIST.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(DIST.PS_DEPTID     <> 'NA'
AND DIST.PS_DEPTID IS NULL OR DIST.PS_DEPTID IN('TCA0', 'SL00')))
-- -SS- /NEW
-- -SS- AND(DIST.DEPTID IS NULL OR(DIST.DEPTID = 'TCA0') OR(DIST.DEPTID = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN GL_CODE.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END
	/* ASX.NATION_CURR */
	AS COUNTRY_INDICATOR,
	/* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
	TO_CHAR(COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	GL_CODE.R12_ENTITY
	/* -SS- SEGMENT1 */
	AS BU,
	GL_CODE.R12_ACCOUNT
	/* -SS- SEGMENT2 */
	AS GL_ACCOUNT,
	GL_CODE.R12_LOCATION
	/* -SS- SEGMENT3 */
	             AS GL_DEP_ID,
	'P/S LEDGER' AS QUERY_SOURCE,
	GL_CODE.R12_PRODUCT
	/* -SS- SEGMENT4 */
	                                               AS GL_PRODUCT_ID,
	COMM.GL_POSTED_DATE                            AS JOURNAL_DATE,
	CAST(COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE)) AS JOURNAL_ID,
	CASE
		WHEN COMM.DEBIT_AMOUNT = 0 OR COMM.DEBIT_AMOUNT IS NULL OR COMM.CREDIT_AMOUNT <> '' THEN COMM.CREDIT_AMOUNT * - 1
		ELSE COMM.DEBIT_AMOUNT
	END                                                   AS DOLLAR_AMOUNT,
	(100 *(COMM.DEBIT_AMOUNT - TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC
FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID -- -SS-
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
	-- -SS- /NEW
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON GL_CODE.R12_ACCOUNT = PSA.R12_ACCOUNT -- /* -SS- ACCOUNT */ /* -SS- SEGMENT2 */ (+) --/* -SS- OTR */
	/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE 1                   = 2
AND PSA.TRANE_ACCOUNT_IND = 'X'
	/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000', 'MM/DD/YYYY') AND TO_DATE('10/31/2004', 'MM/DD/YYYY')
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT2 = 'NA'
AND AFU.LIKE_52          = 'Y')
OR(GL_CODE.PS_SEGMENT2  <> 'NA'
AND GL_CODE.PS_SEGMENT2 LIKE '52%'))
	-- -SS- /NEW
	-- -SS- AND GL_CODE.SEGMENT2 LIKE '52%'
AND GL_CODE.R12_ENTITY NOT IN('5773', '5588')
	/* -SS- AND ASX.NATION_CURR = 'USD' */
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT3    = 'NA'
AND(GL_CODE.R12_LOCATION IS NULL
OR GL_CODE.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(GL_CODE.PS_SEGMENT3     <> 'NA'
AND GL_CODE.PS_SEGMENT3 IS NULL OR GL_CODE.PS_SEGMENT3 = 'SL00'))
-- -SS- /NEW
-- -SS- AND(GL_CODE.SEGMENT3 IS NULL OR(GL_CODE.SEGMENT3 = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN GL_CODE.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END
	/* ASX.NATION_CURR */
	AS COUNTRY_INDICATOR,
	/* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
	TO_CHAR(COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	GL_CODE.R12_ENTITY
	/* -SS- SEGMENT1 */
	AS BU,
	GL_CODE.R12_ACCOUNT
	/* -SS- SEGMENT2 */
	AS GL_ACCOUNT,
	GL_CODE.R12_LOCATION
	/* -SS- SEGMENT3 */
	             AS GL_DEP_ID,
	'P/S LEDGER' AS QUERY_SOURCE,
	GL_CODE.R12_PRODUCT
	/* -SS- SEGMENT4 */
	                                               AS GL_PRODUCT_ID,
	COMM.GL_POSTED_DATE                            AS JOURNAL_DATE,
	CAST(COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE)) AS JOURNAL_ID,
	CASE
		WHEN COMM.DEBIT_AMOUNT = 0 OR COMM.DEBIT_AMOUNT IS NULL OR COMM.CREDIT_AMOUNT <> '' THEN COMM.CREDIT_AMOUNT * - 1
		ELSE COMM.DEBIT_AMOUNT
	END                                                   AS DOLLAR_AMOUNT,
	(100 *(COMM.DEBIT_AMOUNT - TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC
FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID --/* -SS- */
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
	-- -SS- /NEW
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON GL_CODE.R12_ACCOUNT = PSA.R12_ACCOUNT -- /* -SS- ACCOUNT */ /* -SS- SEGMENT2 */ (+) --/* -SS- OTR */
	/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE 1                   = 2
AND PSA.TRANE_ACCOUNT_IND = 'X'
	/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000', 'MM/DD/YYYY') AND TO_DATE('10/31/2004', 'MM/DD/YYYY')
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT2 = 'NA'
AND AFU.LIKE_53          = 'Y')
OR(GL_CODE.PS_SEGMENT2  <> 'NA'
AND GL_CODE.PS_SEGMENT2 LIKE '53%'))
	-- -SS- /NEW
	-- -SS- AND GL_CODE.SEGMENT2 LIKE '53%'
AND GL_CODE.R12_ENTITY NOT IN('5773', '5588')
	/* -SS- AND ASX.NATION_CURR = 'USD' */
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT3 = 'NA'
AND(GL_CODE.R12_LOCATION IS NULL
OR GL_CODE.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(GL_CODE.PS_SEGMENT3 <> 'NA'
AND GL_CODE.PS_SEGMENT3 IS NULL OR GL_CODE.PS_SEGMENT3 = 'SL00'))
-- -SS- /NEW
-- -SS- AND(GL_CODE.SEGMENT3 IS NULL OR(GL_CODE.SEGMENT3 = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN GL_CODE.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END
	/* ASX.NATION_CURR */
	AS COUNTRY_INDICATOR,
	/* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
	TO_CHAR(COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	GL_CODE.R12_ENTITY
	/* -SS- SEGMENT1 */
	AS BU,
	GL_CODE.R12_ACCOUNT
	/* -SS- SEGMENT2 */
	AS GL_ACCOUNT,
	GL_CODE.R12_LOCATION
	/* -SS- SEGMENT3 */
	             AS GL_DEP_ID,
	'P/S LEDGER' AS QUERY_SOURCE,
	GL_CODE.R12_PRODUCT
	/* -SS- SEGMENT4 */
	                                               AS GL_PRODUCT_ID,
	COMM.GL_POSTED_DATE                            AS JOURNAL_DATE,
	CAST(COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE)) AS JOURNAL_ID,
	CASE
		WHEN COMM.DEBIT_AMOUNT = 0 OR COMM.DEBIT_AMOUNT IS NULL OR COMM.CREDIT_AMOUNT <> '' THEN COMM.CREDIT_AMOUNT * - 1
		ELSE COMM.DEBIT_AMOUNT
	END                                                   AS DOLLAR_AMOUNT,
	(100 *(COMM.DEBIT_AMOUNT - TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC
FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID --/* -SS- */
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
	-- -SS- /NEW
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON GL_CODE.R12_ACCOUNT = PSA.R12_ACCOUNT -- /* -SS- ACCOUNT */ /* -SS- SEGMENT2 */ (+) --/* -SS- OTR */
	/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE 1                   = 2
AND PSA.TRANE_ACCOUNT_IND = 'X'
	/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000', 'MM/DD/YYYY') AND TO_DATE('10/31/2004', 'MM/DD/YYYY')
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT2 = 'NA'
AND AFU.LIKE_54          = 'Y')
OR(GL_CODE.PS_SEGMENT2  <> 'NA'
AND GL_CODE.PS_SEGMENT2 LIKE '54%'))
	-- -SS- /NEW
	-- -SS- AND GL_CODE.SEGMENT2 LIKE '54%'
AND GL_CODE.R12_ENTITY NOT IN('5773', '5588') -- /* -SS- AND ASX.NATION_CURR = 'USD' */
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT3    = 'NA'
AND(GL_CODE.R12_LOCATION IS NULL
OR GL_CODE.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(GL_CODE.PS_SEGMENT3     <> 'NA'
AND GL_CODE.PS_SEGMENT3 IS NULL OR GL_CODE.PS_SEGMENT3 = 'SL00'))
-- -SS- /NEW
-- -SS- AND(GL_CODE.SEGMENT3 IS NULL OR(GL_CODE.SEGMENT3 = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN GL_CODE.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END
	/* ASX.NATION_CURR */
	AS COUNTRY_INDICATOR,
	/* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
	TO_CHAR(COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	GL_CODE.R12_ENTITY
	/* -SS- SEGMENT1 */
	AS BU,
	GL_CODE.R12_ACCOUNT
	/* -SS- SEGMENT2 */
	AS GL_ACCOUNT,
	GL_CODE.R12_LOCATION
	/* -SS- SEGMENT3 */
	             AS GL_DEP_ID,
	'P/S LEDGER' AS QUERY_SOURCE,
	GL_CODE.R12_PRODUCT
	/* -SS- SEGMENT4 */
	                                               AS GL_PRODUCT_ID,
	COMM.GL_POSTED_DATE                            AS JOURNAL_DATE,
	CAST(COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE)) AS JOURNAL_ID,
	CASE
		WHEN COMM.DEBIT_AMOUNT = 0 OR COMM.DEBIT_AMOUNT IS NULL OR COMM.CREDIT_AMOUNT <> '' THEN COMM.CREDIT_AMOUNT * - 1
		ELSE COMM.DEBIT_AMOUNT
	END                                                   AS DOLLAR_AMOUNT,
	(100 *(COMM.DEBIT_AMOUNT - TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC
FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID -- /* -SS- */
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
	-- -SS- /NEW
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON GL_CODE.R12_ACCOUNT = PSA.R12_ACCOUNT -- /* -SS- SEGMENT2 */ /* -SS- ACCOUNT */ (+)-- /* -SS- OTR */
	/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE 1                   = 2
AND PSA.TRANE_ACCOUNT_IND = 'X'
	/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000', 'MM/DD/YYYY') AND TO_DATE('10/31/2004', 'MM/DD/YYYY')
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT2 = 'NA'
AND AFU.LIKE_52          = 'Y')
OR(GL_CODE.PS_SEGMENT2  <> 'NA'
AND GL_CODE.PS_SEGMENT2 LIKE '52%'))
	-- -SS- /NEW
	-- -SS- AND GL_CODE.SEGMENT2 LIKE '52%'
AND GL_CODE.R12_ENTITY IN('5773', '5588')
	/* -SS- AND ASX.NATION_CURR = 'CAD' */
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT3    = 'NA'
AND(GL_CODE.R12_LOCATION IS NULL
OR GL_CODE.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(GL_CODE.PS_SEGMENT3     <> 'NA'
AND GL_CODE.PS_SEGMENT3 IS NULL OR GL_CODE.PS_SEGMENT3 IN ('SL00', 'TCA0')))
-- -SS- /NEW
-- -SS- AND(GL_CODE.SEGMENT3 IS NULL OR(GL_CODE.SEGMENT3 = 'TCA0') OR(GL_CODE.SEGMENT3 = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN GL_CODE.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END
	/* ASX.NATION_CURR */
	AS COUNTRY_INDICATOR,
	/* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
	TO_CHAR(COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	GL_CODE.R12_ENTITY
	/* -SS- SEGMENT1 */
	AS BU,
	GL_CODE.R12_ACCOUNT
	/* -SS- SEGMENT2 */
	AS GL_ACCOUNT,
	GL_CODE.R12_LOCATION
	/* -SS- SEGMENT3 */
	             AS GL_DEP_ID,
	'P/S LEDGER' AS QUERY_SOURCE,
	GL_CODE.R12_PRODUCT
	/* -SS- SEGMENT4 */
	                                               AS GL_PRODUCT_ID,
	COMM.GL_POSTED_DATE                            AS JOURNAL_DATE,
	CAST(COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE)) AS JOURNAL_ID,
	CASE
		WHEN COMM.DEBIT_AMOUNT = 0 OR COMM.DEBIT_AMOUNT IS NULL OR COMM.CREDIT_AMOUNT <> '' THEN COMM.CREDIT_AMOUNT * - 1
		ELSE COMM.DEBIT_AMOUNT
	END                                                   AS DOLLAR_AMOUNT,
	(100 *(COMM.DEBIT_AMOUNT - TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC
FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID --  /* -SS- */
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
	-- -SS- /NEW
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON GL_CODE.R12_ACCOUNT = PSA.R12_ACCOUNT -- /* -SS- SEGMENT2 */   /* -SS- ACCOUNT */ (+) -- /* -SS- OTR */
	/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE 1                   = 2
AND PSA.TRANE_ACCOUNT_IND = 'X'
	/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000', 'MM/DD/YYYY') AND TO_DATE('10/31/2004', 'MM/DD/YYYY')
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT2 = 'NA'
AND AFU.LIKE_53          = 'Y')
OR(GL_CODE.PS_SEGMENT2  <> 'NA'
AND GL_CODE.PS_SEGMENT2 LIKE '53%'))
	-- -SS- /NEW
	-- -SS- AND GL_CODE.SEGMENT2 LIKE '53%'
AND GL_CODE.R12_ENTITY IN('5773', '5588')
	/* -SS- AND ASX.NATION_CURR = 'CAD' */
-- -SS- NEW
AND((GL_CODE.PS_SEGMENT3    = 'NA'
AND(GL_CODE.R12_LOCATION IS NULL
OR GL_CODE.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(GL_CODE.PS_SEGMENT3     <> 'NA'
AND GL_CODE.PS_SEGMENT3 IS NULL OR GL_CODE.PS_SEGMENT3 IN ('SL00', 'TCA0')))
-- -SS- /NEW
-- -SS- AND(GL_CODE.SEGMENT3 IS NULL OR(GL_CODE.SEGMENT3 = 'TCA0') OR(GL_CODE.SEGMENT3 = 'SL00'))
UNION ALL
SELECT
	CASE
		WHEN GL_CODE.R12_ENTITY IN('5773', '5588') THEN 'CDN'
		ELSE 'USD'
	END
	/* ASX.NATION_CURR */
	AS COUNTRY_INDICATOR,
	/* -SS- ASX.NATION_CURR AS COUNTRY_INDICATOR, */
	TO_CHAR(COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
	GL_CODE.R12_ENTITY
	/* -SS- SEGMENT1 */
	AS BU,
	GL_CODE.R12_ACCOUNT
	/* -SS- SEGMENT2 */
	AS GL_ACCOUNT,
	GL_CODE.R12_LOCATION
	/* -SS- SEGMENT3 */
	             AS GL_DEP_ID,
	'P/S LEDGER' AS QUERY_SOURCE,
	GL_CODE.R12_PRODUCT
	/* -SS- SEGMENT4 */
	                                               AS GL_PRODUCT_ID,
	COMM.GL_POSTED_DATE                            AS JOURNAL_DATE,
	CAST(COMM.CMS_POSTING_ID AS VARCHAR2(10 BYTE)) AS JOURNAL_ID,
	CASE
		WHEN COMM.DEBIT_AMOUNT = 0 OR COMM.DEBIT_AMOUNT IS NULL OR COMM.CREDIT_AMOUNT <> '' THEN COMM.CREDIT_AMOUNT * - 1
		ELSE COMM.DEBIT_AMOUNT
	END                                                   AS DOLLAR_AMOUNT,
	(100 *(COMM.DEBIT_AMOUNT - TRUNC(COMM.DEBIT_AMOUNT))) AS REVENUE_AMOUNT_DEC
FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID-- /* -SS- */
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
	-- -SS- /NEW
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON GL_CODE.R12_ACCOUNT = PSA.R12_ACCOUNT -- /* -SS- SEGMENT2 */  /* -SS- ACCOUNT */ (+) --  /* -SS- OTR */
	/* -SS- ,ACTUATE_SEC_XREF ASX */
WHERE 1                   = 2
AND PSA.TRANE_ACCOUNT_IND = 'X'
	/* -SS- AND GL_CODE.SEGMENT1 = ASX.PSGL(+) */
AND COMM.GL_POSTED_DATE BETWEEN TO_DATE('1/01/2000', 'MM/DD/YYYY') AND TO_DATE('10/31/2004', 'MM/DD/YYYY')
	-- -SS- NEW
AND((GL_CODE.PS_SEGMENT2 = 'NA'
AND AFU.LIKE_54          = 'Y')
OR(GL_CODE.PS_SEGMENT2  <> 'NA'
AND GL_CODE.PS_SEGMENT2 LIKE '54%'))
	-- -SS- /NEW
	-- -SS- AND GL_CODE.SEGMENT2 LIKE '54%'
AND GL_CODE.R12_ENTITY IN('5773', '5588')
	/* -SS- AND ASX.NATION_CURR = 'CAD' */
-- -SS- NEW
AND((GL_CODE.PS_SEGMENT3    = 'NA'
AND(GL_CODE.R12_LOCATION IS NULL
OR GL_CODE.R12_LOCATION  IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')))
OR(GL_CODE.PS_SEGMENT3     <> 'NA'
AND GL_CODE.PS_SEGMENT3 IS NULL OR GL_CODE.PS_SEGMENT3 IN ('SL00', 'TCA0')))
-- -SS- /NEW
-- -SS- AND(GL_CODE.SEGMENT3 IS NULL OR(GL_CODE.SEGMENT3 = 'TCA0') OR(GL_CODE.SEGMENT3 = 'SL00'))
UNION ALL

/* COMMISSION DATA BACK FROM 1998 TO 1999*/
SELECT
	CASE
		WHEN UPD.COUNTRY_INDICATOR = 'CAN' THEN 'CAD'
		ELSE 'USD'
	END                                                     AS COUNTRY_INDICATOR,
	TO_CHAR(UPD.JRNL_DATE, 'YYYYMM')                        AS JRNL_YEAR_MONTH,
	''                                                      AS BU,
	UPD.GL_ACCOUNT                                          AS GL_ACCOUNT,
	''                                                      AS GL_DEP_ID,
	'COMM 1998'                                             AS QUERY_SOURCE,
	''                                                      AS GL_PRODUCT_ID,
	UPD.JRNL_DATE                                           AS JOURNAL_DATE,
	''                                                      AS JOURNAL_ID,
	UPD.REVENUE_AMOUNT                                      AS REVENUE_AMOUNT,
	(100 *(UPD.REVENUE_AMOUNT - TRUNC(UPD.REVENUE_AMOUNT))) AS REVENUE_AMOUNT_DEC
FROM MD_030_COMMISSION_DTL_UPD UPD
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON UPD.GL_ACCOUNT         = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND = 'X'
WHERE
	-- -SS- UPD.GL_ACCOUNT = PSA.ACCOUNT (+)
	-- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
	UPD.JRNL_DATE BETWEEN TO_DATE('01/01/1998', 'MM/DD/YYYY') AND TO_DATE('12/31/1999', 'MM/DD/YYYY')
