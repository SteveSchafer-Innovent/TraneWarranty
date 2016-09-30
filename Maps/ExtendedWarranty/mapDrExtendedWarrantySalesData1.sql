SELECT
		/*+ NO_CPU_COSTING */
		CASE WHEN A.R12_ENTITY IN('5773', '5588')
			THEN 'CDN'
			ELSE 'USD'
		END
		/* ASX.NATION_CURR */
		AS COUNTRY_INDICATOR,
		TO_CHAR(A.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		A.R12_ENTITY AS BU, -- -SS- COMPANY
		A.R12_ACCOUNT AS GL_ACCOUNT,
		A.COST_CENTER AS GL_DEP_ID, -- -SS- ???? COST_CENTER missing, issue 72
		'Oracle Ledger' AS QUERY_SOURCE,
		A.PRODUCT_CODE AS GL_PRODUCT_ID,
		A.GL_POSTED_DATE AS JOURNAL_DATE,
		CAST(A.POSTING_CONTROL_ID AS VARCHAR2(10)) AS JOURNAL_ID, -- -SS- ???? issue 68
		--A.posting_control_id AS JOURNAL_ID,
		A.AMOUNT * - 1 AS REVENUE_AMOUNT,
		(100 *(A.AMOUNT * - 1 - TRUNC(A.AMOUNT * - 1))) AS REVENUE_AMOUNT_DEC
	FROM
		R12_AP_030_ARC_BILL A -- not used any more per Pam DBO.AP_030_ARC_BILL_MVW A
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU     ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT  -- R12_2_R12 -- -SS- issues 23, 35
		
		-- -SS- ,dbo.ACTUATE_SEC_XREF ASX
	WHERE
		PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- A.ACCOUNT = PSA.ACCOUNT
		-- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- A.COMPANY= ASX.PSGL(+) and
		-- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
		AND A.GL_POSTED_DATE BETWEEN TO_DATE('01/01/2000', 'MM/DD/YYYY') AND TO_DATE('12/31/2004', 'MM/DD/YYYY')
		AND A.CATEGORY = 'Sales Invoices'
		AND((A.PS_ACCOUNT = 'NA'
		AND AFU.LIKE_52_53_54 = 'Y')
		OR(A.PS_ACCOUNT <> 'NA'
		AND(A.PS_ACCOUNT LIKE '52%'
		OR A.PS_ACCOUNT LIKE '53%'
		OR A.PS_ACCOUNT LIKE '54%')))
-- -SS- /NEW
-- -SS- and ( A.ACCOUNT like '52%' or A.ACCOUNT like '53%' or A.ACCOUNT like '54%')
UNION ALL
SELECT
		/*+ NO_CPU_COSTING */
		CASE WHEN A.R12_ENTITY IN('5773', '5588')
			THEN 'CDN'
			ELSE 'USD'
		END
		/* ASX.NATION_CURR */
		AS COUNTRY_INDICATOR,
		TO_CHAR(A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		A.R12_ENTITY AS BU,          -- -SS- BUSINESS_UNIT_GL
		A.R12_ACCOUNT AS GL_ACCOUNT, -- -SS- ACCOUNT
		A.R12_LOCATION AS GL_DEP_ID, -- -SS- DEPTID
		'P/S Ledger' AS QUERY_SOURCE,
		A.R12_PRODUCT AS GL_PRODUCT_ID, -- -SS- PRODUCT
		A.JOURNAL_DATE AS JOURNAL_DATE,
		(A.JOURNAL_ID) AS JOURNAL_ID,
		A.MONETARY_AMOUNT * - 1 AS REVENUE_AMOUNT,
		(100 *(A.MONETARY_AMOUNT * - 1 - TRUNC(A.MONETARY_AMOUNT * - 1))) AS REVENUE_AMOUNT_DEC
	FROM
		DBO.R12_BI_ACCT_ENTRY_PSB A -- /* OTR */
	INNER JOIN DBO.R12_TRNBI_BI_HDR_PSB B ON A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE
	INNER JOIN DBO.R12_BI_HDR_PSB C       ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT AND B.INVOICE = C.INVOICE
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT  -- R12_2_R12 -- /* -SS- ACCOUNT */ /* -SS- ACCOUNT */ (+) -- /* -SS- OTR */
		/* --SS- ,dbo.ACTUATE_SEC_XREF ASX */
	WHERE
		A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2003', 'MM/DD/YYYY') AND TO_DATE('12/31/2050', 'MM/DD/YYYY')
		AND A.R12_ENTITY IN('5773', '5588')
		-- -SS- AND A.BUSINESS_UNIT_GL IN('CAN', 'CSD')
		-- -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+)
		AND PSA.TRANE_ACCOUNT_IND = 'X'
		AND C.ENTRY_TYPE = 'IN'
		-- -SS- NEW
		AND((A.PS_ACCOUNT = 'NA'
		AND AFU.LIKE_52 = 'Y')
		OR(A.PS_ACCOUNT <> 'NA'
		AND A.PS_ACCOUNT LIKE '52%'))
-- -SS- /NEW
-- -SS- AND A.ACCOUNT LIKE '52%'
UNION ALL
SELECT
		/*+ NO_CPU_COSTING */
		CASE WHEN A.R12_ENTITY IN('5773', '5588')
			THEN 'CDN'
			ELSE 'USD'
		END
		/* ASX.NATION_CURR */
		AS COUNTRY_INDICATOR,
		TO_CHAR(A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		A.R12_ENTITY AS BU,          -- -SS- BUSINESS_UNIT_GL
		A.R12_ACCOUNT AS GL_ACCOUNT, -- -SS- ACCOUNT
		A.R12_LOCATION AS GL_DEP_ID, -- -SS- DEPTID
		'P/S Ledger' AS QUERY_SOURCE,
		A.R12_PRODUCT AS GL_PRODUCT_ID, -- -SS- PRODUCT
		A.JOURNAL_DATE AS JOURNAL_DATE,
		(A.JOURNAL_ID) AS JOURNAL_ID,
		A.MONETARY_AMOUNT * - 1 AS REVENUE_AMOUNT,
		(100 *(A.MONETARY_AMOUNT * - 1 - TRUNC(A.MONETARY_AMOUNT * - 1))) AS REVENUE_AMOUNT_DEC
	FROM
		DBO.R12_BI_ACCT_ENTRY_PSB A -- /* -SS- OTR */
	INNER JOIN DBO.R12_TRNBI_BI_HDR_PSB B ON A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE
	INNER JOIN DBO.R12_BI_HDR_PSB C       ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT AND B.INVOICE = C.INVOICE
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT  -- R12_2_R12 --  /* -SS- ACCOUNT *//* -SS- ACCOUNT */ (+) -- /* -SS- OTR */
		-- -SS- ,dbo.ACTUATE_SEC_XREF ASX
	WHERE
		A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2003', 'MM/DD/YYYY') AND TO_DATE('12/31/2050', 'MM/DD/YYYY')
		AND A.R12_ENTITY IN('5773', '5588')
		-- -SS- AND A.BUSINESS_UNIT_GL IN('CAN', 'CSD')
		-- -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+)
		AND PSA.TRANE_ACCOUNT_IND = 'X'
		AND C.ENTRY_TYPE = 'IN'
		-- -SS- NEW
		AND((A.PS_ACCOUNT = 'NA'
		AND AFU.LIKE_53 = 'Y')
		OR(A.PS_ACCOUNT <> 'NA'
		AND A.PS_ACCOUNT LIKE '53%'))
-- -SS- /NEW
-- -SS- AND A.ACCOUNT LIKE '53%'
UNION ALL
SELECT
		/*+ NO_CPU_COSTING */
		CASE WHEN A.R12_ENTITY IN('5773', '5588')
			THEN 'CDN'
			ELSE 'USD'
		END
		/* ASX.NATION_CURR */
		AS COUNTRY_INDICATOR,
		TO_CHAR(A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		A.R12_ENTITY AS BU,          -- -SS- BUSINESS_UNIT_GL
		A.R12_ACCOUNT AS GL_ACCOUNT, -- -SS- ACCOUNT
		A.R12_LOCATION AS GL_DEP_ID, -- -SS- DEPTID
		'P/S Ledger' AS QUERY_SOURCE,
		A.R12_PRODUCT AS GL_PRODUCT_ID, -- -SS- PRODUCT
		A.JOURNAL_DATE AS JOURNAL_DATE,
		(A.JOURNAL_ID) AS JOURNAL_ID,
		A.MONETARY_AMOUNT * - 1 AS REVENUE_AMOUNT,
		(100 *(A.MONETARY_AMOUNT * - 1 - TRUNC(A.MONETARY_AMOUNT * - 1))) AS REVENUE_AMOUNT_DEC
	FROM
		DBO.R12_BI_ACCT_ENTRY_PSB A -- -SS- OTR
	INNER JOIN DBO.R12_TRNBI_BI_HDR_PSB B ON A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE
	INNER JOIN DBO.R12_BI_HDR_PSB C       ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT AND B.INVOICE = C.INVOICE AND C.ENTRY_TYPE = 'IN'
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT -- R12_2_R12  -- -SS- OTR
	
		-- -SS- ,dbo.ACTUATE_SEC_XREF ASX
	WHERE
		A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2003', 'MM/DD/YYYY') AND TO_DATE('12/31/2050', 'MM/DD/YYYY')
		AND A.R12_ENTITY IN('5773', '5588')
		AND PSA.TRANE_ACCOUNT_IND = 'X' 
		-- -SS- AND A.BUSINESS_UNIT_GL IN('CAN', 'CSD')
		-- -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+)
		-- -SS- AND A.ACCOUNT = PSA.ACCOUNT (+)
		-- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- AND A.BUSINESS_UNIT       = B.BUSINESS_UNIT
		-- -SS- AND A.INVOICE             = B.INVOICE
		-- -SS- AND B.BUSINESS_UNIT       = C.BUSINESS_UNIT
		-- -SS- AND B.INVOICE             = C.INVOICE
		-- -SS- AND C.ENTRY_TYPE          = 'IN'
		-- -SS- NEW
		AND((A.PS_ACCOUNT = 'NA'
		AND AFU.LIKE_54 = 'Y')
		OR(A.PS_ACCOUNT <> 'NA'
		AND A.PS_ACCOUNT LIKE '54%'))
-- -SS- /NEW
-- -SS- AND A.ACCOUNT LIKE '54%'
UNION ALL

/* SALES DATA BACK FROM 1998 TO 1999*/
SELECT
		/*+ NO_CPU_COSTING */
		UPD.COUNTRY_INDICATOR AS COUNTRY_INDICATOR,
		TO_CHAR(UPD.JRNL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		'' AS BU,
		UPD.GL_ACCOUNT AS GL_ACCOUNT,
		'' AS GL_DEP_ID,
		'SALES 1998' AS QUERY_SOURCE,
		'' AS GL_PRODUCT_ID,
		UPD.JRNL_DATE AS JOURNAL_DATE,
		'' AS JOURNAL_ID,
		UPD.REVENUE_AMOUNT AS REVENUE_AMOUNT,
		(100 *(UPD.REVENUE_AMOUNT - TRUNC(UPD.REVENUE_AMOUNT))) AS REVENUE_AMOUNT_DEC
	FROM
		MD_030_SALES_DTL_UPD UPD
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA ON UPD.GL_ACCOUNT = PSA.R12_ACCOUNT  -- R12_2_R12 
	WHERE
		UPD.JRNL_DATE BETWEEN TO_DATE('01/01/1998', 'MM/DD/YYYY') AND TO_DATE('12/31/2003', 'MM/DD/YYYY')
		-- -SS- AND UPD.ACCOUNT = PSA.ACCOUNT (+)
		AND PSA.TRANE_ACCOUNT_IND = 'X'
		;