DROP PUBLIC SYNONYM DM_030_EXT_SALES_MVW;
CREATE OR REPLACE PUBLIC SYNONYM DM_030_EXT_SALES_MVW FOR DBO.DM_030_EXT_SALES_MVW;
	DROP MATERIALIZED VIEW DBO.DM_030_EXT_SALES_MVW;
CREATE MATERIALIZED VIEW DBO.DM_030_EXT_SALES_MVW(JRNL_YEAR_MONTH, GL_ACCOUNT, JOURNAL_DATE, REVENUE_AMOUNT, COUNTRY_INDICATOR) TABLESPACE D1_AA NOCACHE LOGGING NOCOMPRESS NOPARALLEL BUILD DEFERRED REFRESH COMPLETE ON DEMAND
WITH PRIMARY KEY AS
/* Formatted on 8/9/2016 5:40:43 PM (QP5 v5.163.1008.3004) */
SELECT JRNL_YEAR_MONTH,
	GL_ACCOUNT,
	JOURNAL_DATE,
	NVL(REVENUE_AMOUNT, 0) AS REVENUE_AMOUNT,
	COUNTRY_INDICATOR
FROM
	(SELECT
		/*+ FIRST_ROWS */
		TO_CHAR(A.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		A.R12_ACCOUNT                       AS GL_ACCOUNT,
		CASE
			WHEN A.R12_ENTITY IN('5773', '5588') THEN 'CDN'
			ELSE 'USD'
		END
		/* ASX.NATION_CURR */
		                              AS COUNTRY_INDICATOR,
		TRUNC(A.GL_POSTED_DATE, 'MM') AS JOURNAL_DATE,
		SUM(A.AMOUNT * - 1)           AS REVENUE_AMOUNT
	FROM R12_AP_030_ARC_BILL A
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR
	ON A.R12_ACCOUNT          = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		/* -SS- , DBO.ACTUATE_SEC_XREF ASX */
	WHERE
		-- -SS- A.COMPANY = ASX.PSGL(+) AND
		-- -SS- A.ACCOUNT = PSA.ACCOUNT (+) AND
		A.GL_POSTED_DATE BETWEEN TO_DATE('01/01/2000', 'MM/DD/YYYY') AND TO_DATE('12/31/2004', 'MM/DD/YYYY')
	AND A.CATEGORY = 'Sales Invoices'
		-- -SS- NEW
	AND((A.PS_ACCOUNT              = 'NA'
	AND AFU.LIKE_52_53_54_NOT_5268 = 'Y')
	OR(A.PS_ACCOUNT               <> 'NA'
	AND((A.PS_ACCOUNT LIKE '52%'
	OR A.PS_ACCOUNT LIKE '53%'
	OR A.PS_ACCOUNT LIKE '54%')
	AND A.PS_ACCOUNT NOT LIKE '5268%')))
		-- -SS- /NEW
		-- -SS- AND(A.ACCOUNT LIKE '52%' OR A.ACCOUNT LIKE '53%' OR A.ACCOUNT LIKE '54%')
		-- -SS- AND A.ACCOUNT NOT LIKE '5268%'
	GROUP BY TO_CHAR(A.GL_POSTED_DATE, 'YYYYMM'),
		A.R12_ACCOUNT,
		CASE
			WHEN A.R12_ENTITY IN('5773', '5588') THEN 'CDN'
			ELSE 'USD'
		END,
		-- -SS- ASX.NATION_CURR
		TRUNC(A.GL_POSTED_DATE, 'MM')
	UNION ALL
	SELECT
		/*+ FIRST_ROWS */
		TO_CHAR(A.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		A.R12_ACCOUNT                       AS GL_ACCOUNT,
		CASE
			WHEN A.R12_ENTITY IN('5773', '5588') THEN 'CDN'
			ELSE 'USD'
		END
		-- -SS- ASX.NATION_CURR
		                              AS COUNTRY_INDICATOR,
		TRUNC(A.GL_POSTED_DATE, 'MM') AS JOURNAL_DATE,
		SUM(A.AMOUNT * - 1)           AS REVENUE_AMOUNT
	FROM R12_AP_030_ARC_BILL A
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
		-- -SS- OTR
	ON A.R12_ACCOUNT          = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		/* -SS- ,
		DBO.ACTUATE_SEC_XREF ASX */
	WHERE
		-- -SS- A.COMPANY = ASX.PSGL(+) AND
		-- -SS- A.ACCOUNT = PSA.ACCOUNT (+)
		A.GL_POSTED_DATE BETWEEN TO_DATE('01/01/2004', 'MM/DD/YYYY') AND TO_DATE('12/31/2004', 'MM/DD/YYYY')
	AND A.CATEGORY = 'Sales Invoices'
		-- -SS- NEW
	AND((A.PS_ACCOUNT = 'NA'
	AND AFU.LIKE_5268 = 'Y')
	OR(A.PS_ACCOUNT  <> 'NA'
	AND A.PS_ACCOUNT LIKE '5268%'))
		-- -SS- /NEW
		-- -SS- AND A.ACCOUNT LIKE '5268%'
	GROUP BY TO_CHAR(A.GL_POSTED_DATE, 'YYYYMM'),
		A.R12_ACCOUNT,
		CASE
			WHEN A.R12_ENTITY IN('5773', '5588') THEN 'CDN'
			ELSE 'USD'
		END,
		-- -SS- ASX.NATION_CURR
		TRUNC(A.GL_POSTED_DATE, 'MM')
	UNION ALL
	SELECT
		/*+ FIRST_ROWS */
		TO_CHAR(A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		A.R12_ACCOUNT
		-- -SS- ACCOUNT
		AS GL_ACCOUNT,
		CASE
			WHEN A.R12_ENTITY IN('5773', '5588') THEN 'CDN'
			ELSE 'USD'
		END
		-- -SS- ASX.NATION_CURR
		                             AS COUNTRY_INDICATOR,
		TRUNC(A.JOURNAL_DATE, 'MM')  AS JOURNAL_DATE,
		SUM(A.MONETARY_AMOUNT * - 1) AS REVENUE_AMOUNT
	FROM R12_BI_ACCT_ENTRY_PSB A
		-- -SS- OTR
	INNER JOIN R12_TRNBI_BI_HDR_PSB B -- -SS- OTR
	ON A.BUSINESS_UNIT = B.BUSINESS_UNIT
	AND A.INVOICE      = B.INVOICE
	INNER JOIN R12_BI_HDR_PSB C
	ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
	AND B.INVOICE      = C.INVOICE
	AND C.ENTRY_TYPE   = 'IN'
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
		-- -SS- OTR
	ON A.R12_ACCOUNT          = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		/* -SS- ,
		DBO.ACTUATE_SEC_XREF ASX */
	WHERE A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2003', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
	AND A.R12_ENTITY                                                                                 IN('5773', '5588')
		-- -SS- AND A.BUSINESS_UNIT_GL IN ('CAN', 'CSD')
		-- -SS- AND A.BUSINESS_UNIT_GL = ASX.PSGL(+)
		-- -SS- AND A.ACCOUNT = PSA.ACCOUNT (+)
		-- -SS- AND A.BUSINESS_UNIT = B.BUSINESS_UNIT
		-- -SS- AND A.INVOICE = B.INVOICE
		-- -SS- AND B.BUSINESS_UNIT = C.BUSINESS_UNIT
		-- -SS- AND B.INVOICE = C.INVOICE
		-- -SS- AND C.ENTRY_TYPE = 'IN'
		-- -SS- NEW
	AND((A.PS_ACCOUNT              = 'NA'
	AND AFU.LIKE_52_53_54_NOT_5268 = 'Y')
	OR(A.PS_ACCOUNT               <> 'NA'
	AND(A.PS_ACCOUNT LIKE '52%'
	OR A.PS_ACCOUNT LIKE '53%'
	OR A.PS_ACCOUNT LIKE '54%')
	AND A.PS_ACCOUNT NOT LIKE '5268%'))
		-- -SS- /NEW
		-- -SS- AND(A.ACCOUNT LIKE '52%' OR A.ACCOUNT LIKE '53%' OR A.ACCOUNT LIKE '54%')
		-- -SS- AND A.ACCOUNT NOT LIKE '5268%'
	GROUP BY TO_CHAR(A.JOURNAL_DATE, 'YYYYMM'),
		A.R12_ACCOUNT,
		CASE
			WHEN A.R12_ENTITY IN('5773', '5588') THEN 'CDN'
			ELSE 'USD'
		END,
		-- -SS- ASX.NATION_CURR
		TRUNC(A.JOURNAL_DATE, 'MM')
	UNION ALL
	SELECT
		/*+ FIRST_ROWS */
		TO_CHAR(A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		A.R12_ACCOUNT
		/* ACCOUNT */
		AS GL_ACCOUNT,
		CASE
			WHEN A.R12_ENTITY IN('5773', '5588') THEN 'CDN'
			ELSE 'USD'
		END
		/* ASX.NATION_CURR */
		                             AS COUNTRY_INDICATOR,
		TRUNC(A.JOURNAL_DATE, 'MM')  AS JOURNAL_DATE,
		SUM(A.MONETARY_AMOUNT * - 1) AS REVENUE_AMOUNT
	FROM R12_BI_ACCT_ENTRY_PSB A
		-- -SS- OTR
	INNER JOIN R12_TRNBI_BI_HDR_PSB B
	ON A.BUSINESS_UNIT = B.BUSINESS_UNIT
	AND A.INVOICE      = B.INVOICE
	INNER JOIN R12_BI_HDR_PSB C
	ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
	AND B.INVOICE      = C.INVOICE
	AND C.ENTRY_TYPE   = 'IN'
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
	ON A.R12_ACCOUNT          = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- OTR
		/* -SS- ,
		DBO.ACTUATE_SEC_XREF ASX */
	WHERE A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2004', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
		-- -SS- separate conditions for PS and R12
	AND A.R12_ENTITY IN ('5773', '5588') -- -SS- CAN, CSD
		-- -SS- AND A.BUSINESS_UNIT_GL IN('CAN', 'CSD')
		-- -SS- AND A.BUSINESS_UNIT_GL = ASX.PSGL(+)
		-- -SS- AND A.ACCOUNT = PSA.ACCOUNT (+)
		-- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- AND A.BUSINESS_UNIT = B.BUSINESS_UNIT
		-- -SS- AND A.INVOICE = B.INVOICE
		-- -SS- AND B.BUSINESS_UNIT = C.BUSINESS_UNIT
		-- -SS- AND B.INVOICE = C.INVOICE
		-- -SS- AND C.ENTRY_TYPE = 'IN'
	AND(A.PS_ACCOUNT IS NULL
	OR A.PS_ACCOUNT LIKE '5268%')
		-- -SS- AND(A.ACCOUNT LIKE '5268%')
	GROUP BY TO_CHAR(A.JOURNAL_DATE, 'YYYYMM'),
		A.R12_ACCOUNT,
		CASE
			WHEN A.R12_ENTITY IN('5773', '5588') THEN 'CDN'
			ELSE 'USD'
		END
		-- -SS- ASX.NATION_CURR
		,
		TRUNC(A.JOURNAL_DATE, 'MM')
	UNION ALL
	SELECT TO_CHAR(UPD.JRNL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		UPD.GL_ACCOUNT                         AS GL_ACCOUNT,
		UPD.COUNTRY_INDICATOR                  AS COUNTRY_INDICATOR, --'SALES DATA BACK
		-- FROM 1998' AS QUERY_SOURCE,
		TRUNC(UPD.JRNL_DATE, 'MM') AS JOURNAL_DATE,
		SUM(UPD.REVENUE_AMOUNT)    AS REVENUE_AMOUNT
	FROM MD_030_SALES_DTL_UPD UPD
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
	ON UPD.GL_ACCOUNT         = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- OTR
		-- -SS- WHERE
		-- -SS- UPD.GL_ACCOUNT = PSA.ACCOUNT (+)
		-- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
	GROUP BY TO_CHAR(UPD.JRNL_DATE, 'YYYYMM'),
		UPD.GL_ACCOUNT,
		UPD.COUNTRY_INDICATOR,
		TRUNC(UPD.JRNL_DATE, 'MM')
	UNION ALL
	SELECT DISTINCT TO_CHAR(UPD.JRNL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		UPD.GL_ACCOUNT                                  AS GL_ACCOUNT,
		UPD.COUNTRY_INDICATOR                           AS COUNTRY_INDICATOR, --'ZERO' AS
		-- QUERY_SOURCE,
		TRUNC(ADD_MONTHS(UPD.JRNL_DATE, - 24), 'MM') AS JOURNAL_DATE,
		0                                            AS REVENUE_AMOUNT
	FROM MD_030_SALES_DTL_UPD UPD
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
	ON UPD.GL_ACCOUNT         = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- OTR
		-- -SS- WHERE
		-- -SS- UPD.GL_ACCOUNT = PSA.ACCOUNT (+)
		-- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
	)
WHERE JOURNAL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE, - 144), 'MM') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1)) ;
COMMENT ON MATERIALIZED VIEW DBO.DM_030_EXT_SALES_MVW
IS
	'snapshot table for snapshot DBO.DM_030_EXT_SALES_MVW';
	CREATE INDEX DBO.XIE1DM_030_EXT_SALES_MVW
	ON DBO.DM_030_EXT_SALES_MVW
		(
			COUNTRY_INDICATOR,
			GL_ACCOUNT
		)
		LOGGING TABLESPACE I1_AA PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE
		(
			INITIAL 80K NEXT 1M MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0 BUFFER_POOL DEFAULT
		)
		NOPARALLEL;
	GRANT
	SELECT ON DBO.DM_030_EXT_SALES_MVW TO ACTUATE_SECURITY;
	GRANT
	SELECT ON DBO.DM_030_EXT_SALES_MVW TO READ_DBO;
