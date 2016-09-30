SELECT
		/*+ NO_CPU_COSTING */
		'RCPO' AS QUERY_SOURCE,
		NVL(PS.GL_BU_ID,(
		CASE          WHEN PS.CURRENCY_CODE = 'USD'
			THEN 'GS303' WHEN PS.CURRENCY_CODE = 'CAD'
			THEN 'GS315'
			ELSE 'INVALID CURRENCY-'||PS.CURRENCY_CODE
		END)) AS BU,
		SUM(PS.ORDER_AMOUNT) AS REVENUE_AMOUNT,
		SUM(100 *(PS.ORDER_AMOUNT - TRUNC(PS.ORDER_AMOUNT))) AS REVENUE_AMOUNT_DEC
		-- PER PAT'S REQUEST 5/24/07
		--,PS.PLNT_GL_ACCT AS GL_ACCOUNT
		--,(CASE WHEN PS.PLNT_GL_ACCT2 = '750000' THEN PS.PLNT_GL_ACCT2 ELSE PS.PLNT_GL_ACCT END) AS GL_ACCOUNT
		-- PER PAT'S REQUEST 5/30/07
		,
		PS.R12_ACCOUNT AS GL_ACCOUNT, --  -SS- PLNT_GL_ACCT2
		NVL(PS.R12_LOCATION,(         -- -SS- GL_DPT_ID
		CASE        WHEN PS.CURRENCY_CODE = 'USD'
			THEN 97001 WHEN PS.CURRENCY_CODE = 'CAD'
			THEN 97011
			ELSE - 10
		END)) AS DEPT_ID,
		COALESCE(AOL_R12.OFFICE_NAME, COALESCE(AOL_PS.OFFICE_NAME,
		CASE                          WHEN PS.CURRENCY_CODE = 'USD'
			THEN 'OTHER EQUIPMENT GROUP' WHEN PS.CURRENCY_CODE = 'CAD'
			THEN 'CAN OTHER EQUIPMENT GROUP'
			ELSE 'INVALID CURRENCY-'||PS.CURRENCY_CODE
		END)) AS DEPT_DESCR,
		-- -SS- NVL(AOL.OFFICE_NAME,(
		-- -SS- CASE
		-- -SS-  WHEN PS.CURRENCY_CODE = 'USD' THEN 'OTHER EQUIPMENT GROUP'
		-- -SS-  WHEN PS.CURRENCY_CODE = 'CAD' THEN 'CAN OTHER EQUIPMENT GROUP'
		-- -SS-  ELSE 'INVALID CURRENCY-'||PS.CURRENCY_CODE
		-- -SS- END))                   AS DEPT_DESCR,
		PS.PLNT_GL_PROD AS MANF_PROD_ID,
		PX.MANF_PROD_CODE_DESCR AS MANF_PROD_DESCR
		/* CHANGING MSUN 5/18/2007 */
		--,(CASE WHEN PS.PLNT_GL_ACCT= '750000' THEN '804900' ELSE  PS.GL_PROD END ) AS DIST_GL_PRODUCT
		-- PER PAT'S REQUEST 5/24/07
		-- ,(CASE WHEN PS.PLNT_GL_ACCT= '750000' OR PS.PLNT_GL_ACCT2 = '750000' THEN '804900' ELSE  PS.GL_PROD END ) AS DIST_GL_PRODUCT
		-- PER PAT'S REQUEST 5/30/07
		,
		(
		CASE WHEN PS.PART_TYPE = 'Y' AND PS.PARTS_PROD_CODE_IND = 'PCR'
			THEN '804900'       -- -SS- ????
			ELSE PS.R12_PRODUCT -- -SS- GL_PROD
		END) AS DIST_GL_PRODUCT,
		/* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
		NVL(PX.PRODUCT_CATEGORY, 'INVALID PROD CODE - '|| PS.R12_PRODUCT) AS RESERVE_GROUP, -- -SS- PRODUCT
		PS.JRNL_DATE AS JRNL_DATE,
		CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) AS JRNL_YEAR,
		CAST(TO_CHAR(JRNL_DATE, 'MM') AS   INTEGER) AS JRNL_MONTH,
		CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER) AS JRNL_YEAR_MONTH,
		PS.ORGN_JRNL_ID AS JRNL_ID,
		PS.CURRENCY_CODE AS CURRENCY,
		COALESCE(AOL_R12.NATION_CURR, COALESCE(AOL_PS.NATION_CURR, PS.CURRENCY_CODE)) AS COUNTRY_INDICATOR
		-- -SS- NVL(AOL.NATION_CURR, PS.CURRENCY_CODE) AS COUNTRY_INDICATOR
	FROM
		R12_ORACLE_PS_REV_RCPO PS                                                                                              -- -SS- OTR
	LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO PX      ON PS.PLNT_GL_BU = PX.GL_LEDGER AND PS.PLNT_GL_PROD = PX.MANF_PROD_CODE  -- -SS- ???? missing PLNT_GL_PROD on R12_ORACLE_PS_REV_RCPO, issue 55
	LEFT OUTER JOIN ACTUATE_OFFICE_LOCATION AOL_PS  ON PS.PS_GL_DPT_ID = AOL_PS.DEPT_ID AND null /* -SS- issue 45 - PS.PS_GL_BU_ID */ = AOL_PS.BU_UNIT
	LEFT OUTER JOIN ACTUATE_OFFICE_LOCATION AOL_R12 ON PS.R12_LOCATION = AOL_R12.ORA_LOCATION AND PS.R12_ENTITY = AOL_R12.ORA_ENTITY -- -SS- ???? issue 45
		-- R12_2_R12 
		-- -SS- ACTUATE_OFFICE_LOCATION AOL
		-- -SS- AND PS.GL_DPT_ID = AOL.DEPT_ID (+)
		-- -SS- AND PS.GL_BU_ID=AOL.BU_UNIT  (+)
		-- -SS- issues 63, 73
	WHERE
		PS.JRNL_DATE BETWEEN TO_DATE('01/01/2005', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
		AND PS.PS_GL_DPT_ID != 'NA'
		AND null /* -SS- issue 45 - PS.PS_GL_BU_ID */ != 'NA' 
		AND AOL_R12.ORA_LOCATION IS NOT NULL
		AND AOL_R12.ORA_ENTITY IS NOT NULL
		--PS.JRNL_DATE BETWEEN CAST('2005-01-01 00:00:00.000' AS TIMESTAMP) AND CAST(LAST_DAY(ADD_MONTHS(SYSDATE,-1)) AS TIMESTAMP)
		--AND PS.PRODUCT_CODE = '0331'
		/* 2-5 year Warranty Project Rule */
		AND PX.TWO_FIVE = 'Y'
		/* 2-5 year Warranty Project Rule */
	GROUP BY
		PS.GL_BU_ID,
		-- PER PAT'S REQUEST, 5/30/07
		--,(CASE WHEN PS.PLNT_GL_ACCT2 = '750000' THEN PS.PLNT_GL_ACCT2 ELSE PS.PLNT_GL_ACCT END)
		PS.R12_ACCOUNT,  -- -SS- PLNT_GL_ACCT2
		PS.R12_LOCATION, -- -SS- GL_DPT_ID
		AOL_R12.OFFICE_NAME,
		AOL_PS.OFFICE_NAME,
		PS.PLNT_GL_PROD,
		PX.MANF_PROD_CODE_DESCR,
		-- PER PAT'S REQUEST, 5/30/07
		--,(CASE WHEN PS.PLNT_GL_ACCT= '750000' OR PS.PLNT_GL_ACCT2 = '750000' THEN '804900' ELSE  PS.GL_PROD END )
		(
		CASE WHEN PS.PART_TYPE = 'Y' AND PS.PARTS_PROD_CODE_IND = 'PCR' -- -SS- ???? missing columns issue 55
			THEN '804900'                                                  -- -SS- ????
			ELSE PS.R12_PRODUCT                                            -- -SS- GL_PROD
		END),
		PS.R12_PRODUCT, -- -SS- GL_PROD
		PX.PRODUCT_CATEGORY,
		PS.JRNL_DATE,
		CAST(TO_CHAR(PS.JRNL_DATE, 'YYYY') AS INTEGER),
		CAST(TO_CHAR(PS.JRNL_DATE, 'MM') AS   INTEGER),
		CAST(TO_CHAR(PS.JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(PS.JRNL_DATE, 'MM') AS INTEGER),
		PS.ORGN_JRNL_ID,
		PS.CURRENCY_CODE,
		AOL_R12.NATION_CURR,
		AOL_PS.NATION_CURR
UNION ALL

/* 2ND*/
SELECT
		/*+ NO_CPU_COSTING */
		'P/S GL' AS QUERY_SOURCE,
		GA.BUSINESS_UNIT AS BU,
		SUM(L.MONETARY_AMOUNT) AS REVENUE_AMOUNT,
		SUM(100 *(L.MONETARY_AMOUNT - TRUNC(L.MONETARY_AMOUNT))) AS REVENUE_AMOUNT_DEC,
		L.R12_ACCOUNT AS GL_ACCOUNT, -- -SS- ACCOUNT
		L.R12_LOCATION AS DEPT_ID,   --  -SS- DEPTID
		DP.DESCR AS DEPT_DESCR,
		L.R12_PRODUCT AS MANF_PROD_ID, -- -SS- PRODUCT
		PR.DESCR AS MANF_PROD_DESCR
		-- PER PAT'S REQUEST 5/24/07
		--, NULL AS DIST_GL_PRODUCT
		,
		L.R12_PRODUCT AS DIST_GL_PRODUCT, --  -SS- PRODUCT
		/* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
		NVL(PX.PRODUCT_CATEGORY, 'INVALID PROD CODE - '|| L.R12_PRODUCT) AS RESERVE_GROUP, -- -SS- PRODUCT, remove ELIM or TNA0
		--, PX.PRODUCT_CATEGORY AS RESERVE_GROUP
		GA.JOURNAL_DATE AS JRNL_DATE,
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'YYYY')) AS JRNL_YEAR,
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'MM')) AS JRNL_MONTH,
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'MM')) AS JRNL_YEAR_MONTH,
		GA.JOURNAL_ID AS JRNL_ID,
		L.CURRENCY_CD AS CURRENCY,
		ASX.NATION_CURR AS COUNTRY_INDICATOR
	FROM
		R12_JRNL_LN_PS L                                                                                                                                                             -- -SS- OTR
	INNER JOIN R12_JRNL_HEADER_PS GA ON GA.BUSINESS_UNIT = L.BUSINESS_UNIT AND GA.JOURNAL_ID = L.JOURNAL_ID AND GA.JOURNAL_DATE = L.JOURNAL_DATE AND GA.UNPOST_SEQ = L.UNPOST_SEQ -- -SS- OTR
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = L.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_PRODUCTS_PS PR   ON L.R12_PRODUCT = PR.R12_PRODUCT  -- R12_2_R12 -- -SS- OTR, PRODUCT, PRODUCT
	LEFT OUTER JOIN R12_TRANE_DEPTS_PS DP      ON L.R12_LOCATION = DP.PS_DEPTID   -- R12_2_R12  -- -SS- DEPTID -> R12_LOCATION 
	LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO PX ON L.BUSINESS_UNIT = PX.GL_LEDGER AND L.PS_PRODUCT = PX.MANF_PROD_CODE
	LEFT OUTER JOIN ACTUATE_SEC_XREF ASX       ON GA.BUSINESS_UNIT = ASX.PSGL
	WHERE
		GA.JRNL_HDR_STATUS IN('P', 'U')
		AND GA.FISCAL_YEAR IN('2003', '2004')
		AND L.LEDGER = 'ACTUALS'
		-- -SS- NEW
		AND((L.PS_ACCOUNT = 'NA'
		AND AFU.EQUAL_700000 = 'Y')
		OR(L.PS_ACCOUNT <> 'NA'
		AND L.PS_ACCOUNT = '700000'))
		-- -SS- /NEW
		-- -SS- L.ACCOUNT = '700000'
		AND GA.BUSINESS_UNIT IN('CAN', 'CSD')
		/* 2-5 year Warranty Project Rule */
		AND PX.TWO_FIVE = 'Y'
		/* 2-5 year Warranty Project Rule */
	GROUP BY
		GA.BUSINESS_UNIT,
		L.R12_ACCOUNT,  -- -SS- ACCOUNT
		L.R12_LOCATION, -- -SS- DEPTID
		DP.DESCR,
		L.R12_PRODUCT, -- -SS- PRODUCT
		PR.DESCR,
		PX.PRODUCT_CATEGORY,
		GA.JOURNAL_DATE,
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'YYYY')),
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'MM')),
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'MM')),
		GA.JOURNAL_ID,
		L.CURRENCY_CD,
		ASX.NATION_CURR
UNION

/* 3RD */
SELECT
		/*+ NO_CPU_COSTING */
		'P/S LEDGER' AS QUERY_SOURCE,
		PS.BUSINESS_UNIT AS BU,
		SUM(PS.POSTED_TOTAL_AMT) AS REVENUE_AMOUNT,
		SUM(100 *(PS.POSTED_TOTAL_AMT - TRUNC(PS.POSTED_TOTAL_AMT))) AS REVENUE_AMOUNT_DEC,
		PS.R12_ACCOUNT
		-- -SS- ACCOUNT
		AS GL_ACCOUNT,
		PS.R12_LOCATION
		-- -SS- DEPTID
		AS DEPT_ID,
		DP.DESCR AS DEPT_DESCR,
		PS.R12_PRODUCT
		-- -SS- PRODUCT
		AS MANF_PROD_ID,
		PR.DESCR AS MANF_PROD_DESCR
		-- PER PAT'S REQUEST 5/24/07
		--,NULL AS DIST_GL_PRODUCT
		,
		PS.R12_PRODUCT AS DIST_GL_PRODUCT, -- -SS- PRODUCT
		--  /* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
		NVL(PX.PRODUCT_CATEGORY, 'INVALID PROD CODE - '|| PS.R12_PRODUCT) AS RESERVE_GROUP, -- -SS- PRODUCT
		--,PX.PRODUCT_CATEGORY AS RESERVE_GROUP
		TO_DATE('15-' || PS.ACCOUNTING_PERIOD || '-' || PS.FISCAL_YEAR, 'DD-MM-YYYY') AS JRNL_DATE,
		PS.FISCAL_YEAR AS JRNL_YEAR,
		PS.ACCOUNTING_PERIOD AS JRNL_MONTH,
		PS.FISCAL_YEAR * 100 + PS.ACCOUNTING_PERIOD AS JRNL_YEAR_MONTH,
		'ZZZZZZ' AS JRNL_ID,
		PS.CURRENCY_CD AS CURRENCY,
		ASX.NATION_CURR AS COUNTRY_INDICATOR
	FROM
		R12_LEDGER2_PS PS -- -SS- OTR
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = PS.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_PRODUCTS_PS PR ON PS.R12_PRODUCT = PR.R12_PRODUCT -- R12_2_R12 
		-- -SS- PRODUCT
		-- -SS- PRODUCT
		-- -SS- OTR
	LEFT OUTER JOIN R12_TRANE_DEPTS_PS DP      ON PS.R12_LOCATION = DP.PS_DEPTID -- R12_2_R12 -- -SS- DEPTID, ???? issue 69
	LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO PX ON PS.PS_PRODUCT = PX.MANF_PROD_CODE AND PS.BUSINESS_UNIT = PX.GL_LEDGER
	LEFT OUTER JOIN ACTUATE_SEC_XREF ASX       ON PS.BUSINESS_UNIT = ASX.PSGL
	WHERE
		PS.FISCAL_YEAR IN('2000', '2001', '2002')
		AND PS.ACCOUNTING_PERIOD <= '12'
		-- -SS- NEW
		AND((PS.PS_ACCOUNT = 'NA'
		AND AFU.EQUAL_700000 = 'Y')
		OR(PS.PS_ACCOUNT <> 'NA'
		AND PS.PS_ACCOUNT = '700000'))
		-- -SS- /NEW
		-- -SS- PS.ACCOUNT = '700000'
		--ADD BY ALEX
		AND PS.LEDGER = 'ACTUALS'
		--ADD BY ALEX
		--AND PR.PRODUCT = '0331'
		/* 2-5 year Warranty Project Rule */
		AND PX.TWO_FIVE = 'Y'
		/* 2-5 year Warranty Project Rule */
	GROUP BY
		PS.BUSINESS_UNIT,
		PS.R12_ACCOUNT,  -- -SS- ACCOUNT
		PS.R12_LOCATION, -- -SS- DEPTID
		DP.DESCR,
		PS.R12_PRODUCT, -- -SS- PRODUCT
		PR.DESCR,
		PX.PRODUCT_CATEGORY,
		TO_DATE('15-' || PS.ACCOUNTING_PERIOD || '-' || PS.FISCAL_YEAR, 'DD-MM-YYYY'),
		PS.FISCAL_YEAR,
		PS.ACCOUNTING_PERIOD,
		PS.FISCAL_YEAR * 100 + PS.ACCOUNTING_PERIOD,
		PS.CURRENCY_CD,
		ASX.NATION_CURR
UNION ALL

/* 4th -New Query to get the Residential data for Year 2000 and 2001, on 10/01/07  */
SELECT
		/*+ NO_CPU_COSTING */
		DISTINCT 'CS_LD' AS QUERY_SOURCE,
		RS_LEDGER.BUSINESS_UNIT AS BU,
		SUM(RS_LEDGER.SALES_TOTAL) AS REVENUE_AMOUNT,
		SUM(100 *(RS_LEDGER.SALES_TOTAL - TRUNC(RS_LEDGER.SALES_TOTAL))) AS REVENUE_AMOUNT_DEC,
		RS_LEDGER.R12_ACCOUNT
		-- -SS- ACCOUNT
		AS GL_ACCOUNT,
		RS_LEDGER.R12_LOCATION
		-- -SS- DEPT_ID
		AS DEPT_ID,
		DP.DESCR AS DEPT_DESCR,
		RS_LEDGER.R12_PRODUCT
		-- -SS- PRODUCT_ID
		AS MANF_PROD_ID,
		PR.DESCR AS MANF_PROD_DESCR,
		RS_LEDGER.R12_PRODUCT
		-- -SS- PRODUCT_ID
		AS DIST_GL_PRODUCT
		/* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
		,
		NVL(PX.PRODUCT_CATEGORY, 'INVALID PROD CODE - ' || RS_LEDGER.R12_PRODUCT) AS RESERVE_GROUP, -- -SS- PRODUCT_ID
		--,PX.PRODUCT_CATEGORY AS RESERVE_GROUP
		TO_DATE('15-' || RS_LEDGER.ACCOUNTING_PERIOD || '-' || RS_LEDGER.ACCOUNTING_YEAR, 'DD-MM-YYYY') AS JRNL_DATE,
		RS_LEDGER.ACCOUNTING_YEAR AS JRNL_YEAR,
		RS_LEDGER.ACCOUNTING_PERIOD AS JRNL_MONTH,
		RS_LEDGER.ACCOUNTING_YEAR * 100 + RS_LEDGER.ACCOUNTING_PERIOD AS JRNL_YEAR_MONTH,
		'ZZZZZZ' AS JRNL_ID,
		SUBSTR('', 3) AS CURRENCY,
		ASX.NATION_CURR AS COUNTRY_INDICATOR
	FROM
		R12_COM_SALES_RS_LEDGER RS_LEDGER -- -SS- OTR
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = RS_LEDGER.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_PRODUCTS_PS PR   ON RS_LEDGER.R12_PRODUCT = PR.R12_PRODUCT  -- R12_2_R12 -- -SS- PRODUCT_ID, PRODUCT, OTR
	LEFT OUTER JOIN R12_TRANE_DEPTS_PS DP      ON RS_LEDGER.R12_LOCATION = DP.PS_DEPTID   -- R12_2_R12  -- -SS- DEPT_ID, (+)
	LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO PX ON RS_LEDGER.PS_PRODUCT_ID = PX.MANF_PROD_CODE AND RS_LEDGER.BUSINESS_UNIT = PX.GL_LEDGER
	LEFT OUTER JOIN ACTUATE_SEC_XREF ASX       ON RS_LEDGER.BUSINESS_UNIT = ASX.PSGL
	WHERE
		PX.TWO_FIVE = 'Y'
		-- -SS- NEW
		AND((RS_LEDGER.PS_ACCOUNT = 'NA'
		AND AFU.EQUAL_700000 = 'Y')
		OR(RS_LEDGER.PS_ACCOUNT <> 'NA'
		AND RS_LEDGER.PS_ACCOUNT = '700000'))
		-- -SS- /NEW
		-- -SS- RS_LEDGER.ACCOUNT = '700000'
		AND RS_LEDGER.LEDGER = 'ACTUALS'
		AND RS_LEDGER.ACCOUNTING_PERIOD <= '12'
		AND RS_LEDGER.ACCOUNTING_YEAR IN('2000', '2001')
		--AND  RS_LEDGER.BUSINESS_UNIT = 'GLUPG'
	GROUP BY
		RS_LEDGER.BUSINESS_UNIT,
		RS_LEDGER.R12_ACCOUNT,  -- -SS- ACCOUNT
		RS_LEDGER.R12_LOCATION, -- -SS- DEPT_ID
		DP.DESCR,
		RS_LEDGER.R12_PRODUCT, -- -SS- PRODUCT_ID
		PR.DESCR,
		RS_LEDGER.R12_PRODUCT, -- -SS- PRODUCT_ID
		PX.PRODUCT_CATEGORY,
		TO_DATE('15-' || RS_LEDGER.ACCOUNTING_PERIOD || '-' || RS_LEDGER.ACCOUNTING_YEAR, 'DD-MM-YYYY'),
		RS_LEDGER.ACCOUNTING_YEAR,
		RS_LEDGER.ACCOUNTING_PERIOD,
		RS_LEDGER.ACCOUNTING_YEAR * 100 + RS_LEDGER.ACCOUNTING_PERIOD,
		ASX.NATION_CURR
UNION ALL

/*- 5TH QUERY 5/1
AND .BUSINESS_UNIT= ASX.PSGL
ADDING AOL.NAITON_CURR
CHANGING ALIAS NAME FOR MULTIPLE FIELDS
*/
--SELECT CASE WHEN BUSINESS_UNIT IN ('CAN','CSD') THEN BUSINESS_UNIT
--WHEN CURRENCY = 'CAN' THEN 'CAN' ELSE 'CSD' END AS BU
SELECT
		/*+ NO_CPU_COSTING */
		'PBS' AS QUERY_SOURCE,
		BUSINESS_UNIT AS BU,
		SUM(P7_TOTAL) AS REVENUE_AMOUNT,
		SUM(100 *(P7_TOTAL - TRUNC(P7_TOTAL))) AS REVENUE_AMOUNT_DEC,
		GL_ACCOUNT AS GL_ACCOUNT,
		DEPTID AS DEPT_ID,
		DEPT_DESCR AS DEPT_DESCR,
		PRODCODE AS MANF_PROD_ID,
		PROD_DESCR AS MANF_PROD_DESCR
		/* CHANGING 5/18/2007 MSUN*/
		,
		GL_PRODCODE AS DIST_GL_PRODUCT,
		NVL(RESERVE_GROUP, 'LARGE') AS RESERVE_GROUP,
		JRNL_DATE AS JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) AS JRNL_YEAR,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_MONTH,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_YEAR_MONTH,
		JRNL_ID AS JRNL_ID,
		CURRENCY AS CURRENCY,
		NATION_CURR AS COUNTRY_INDICATOR
	FROM
		(
			SELECT
					/*+ NO_CPU_COSTING */
					D.R12_ENTITY AS BUSINESS_UNIT, -- -SS- BUSINESS_UNIT_GL
					D.INVOICE AS INVOICE,
					D.LINE_SEQ_NUM AS SEQ_NUM,
					D.ACCT_ENTRY_TYPE AS ENTRY_TYPE,
					D.JOURNAL_ID AS JRNL_ID,
					D.JOURNAL_DATE AS JRNL_DATE,
					D.R12_ACCOUNT AS GL_ACCOUNT, -- -SS- ACCOUNT
					D.MONETARY_AMOUNT AS P7_TOTAL,
					D.R12_LOCATION AS DEPTID, -- -SS- DEPTID
					COALESCE(AOL_R12.OFFICE_NAME, AOL_PS.OFFICE_NAME) AS DEPT_DESCR,
					-- -SS- AOL.OFFICE_NAME    AS DEPT_DESCR,
					PR.DESCR AS PROD_DESCR,
					X.PRODUCT_CATEGORY AS RESERVE_GROUP,
					A.R12_PRODUCT AS PRODCODE, -- -SS- IDENTIFIER
					CASE WHEN D.R12_PRODUCT IN('41204', '41198')
						THEN '41204'
						ELSE D.R12_PRODUCT
					END AS GL_PRODCODE,
					-- -SS- WHEN D.PRODUCT = '0064' THEN '804155' ELSE D.PRODUCT END AS GL_PRODCODE,
					D.CURRENCY_CD AS CURRENCY,
					COALESCE(AOL_R12.NATION_CURR, AOL_PS.NATION_CURR) AS NATION_CURR
					-- -SS- AOL.NATION_CURR
				FROM
					R12_BI_LINE_PSB A                                                                                                                    -- -SS- OTR
				INNER JOIN R12_BI_ACCT_ENTRY_PSB D ON D.LINE_SEQ_NUM = A.LINE_SEQ_NUM AND D.INVOICE = A.INVOICE AND D.BUSINESS_UNIT = A.BUSINESS_UNIT -- -SS- OTR
					-- -SS- NEW
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = D.R12_ACCOUNT
					-- -SS- /NEW
				LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO X       ON A.PS_IDENTIFIER = X.MANF_PROD_CODE
				LEFT OUTER JOIN R12_TRANE_PRODUCTS_PS PR        ON D.R12_PRODUCT = PR.R12_PRODUCT  -- R12_2_R12 -- -SS- PRODUCT, PRODUCT, OTR
				LEFT OUTER JOIN ACTUATE_OFFICE_LOCATION AOL_PS  ON D.PS_DEPTID = AOL_PS.DEPT_ID
				LEFT OUTER JOIN ACTUATE_OFFICE_LOCATION AOL_R12 ON AOL_R12.ORA_LOCATION IS NOT NULL AND D.R12_LOCATION = AOL_R12.ORA_LOCATION
					-- -SS- ACTUATE_OFFICE_LOCATION AOL
					-- -SS- D.DEPTID = AOL.DEPT_ID (+), issues 63, 73
				WHERE
					D.JOURNAL_DATE BETWEEN TO_DATE('03/01/2006', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
					-- -SS- NEW
					AND((D.PS_ACCOUNT = 'NA'
					AND AFU.EQUAL_700000 = 'Y')
					OR(D.PS_ACCOUNT <> 'NA'
					AND D.PS_ACCOUNT = '700000'))
					-- -SS- /NEW
					-- -SS- D.ACCOUNT = '700000'
					AND 'ACTUALS' = D.LEDGER
					AND '41206' <> D.R12_PRODUCT -- -SS-
					AND '41201' <> D.R12_PRODUCT -- -SS-
					AND '41299' <> D.R12_PRODUCT -- -SS-
					/* -SS-
					AND '804180' <> D.PRODUCT
					AND '804120' <> D.PRODUCT
					AND '804190' <> D.PRODUCT
					*/
					/* 2-5 year Warranty Project Rule */
					AND X.TWO_FIVE = 'Y'
					/*New Logic Adedd as of Oct27-2010 as  Jackie Req */
					--AND D.BUSINESS_UNIT = X.GL_LEDGER (+)
					-- AND D.PRODUCT = X.MANF_PROD_CODE (+)
					AND X.GL_LEDGER = 'CSD'
					/* New Logic Adedd as of Oct27-2010 as  Jackie Req  */
					AND EXISTS
					(
						SELECT
								'X'
							FROM
								R12_BI_HDR_PSB B
							WHERE
								B.BILL_SOURCE_ID = 'PBS'
								AND D.INVOICE = B.INVOICE
								AND D.BUSINESS_UNIT = B.PS_BUSINESS_UNIT
					)
					AND EXISTS
					(
						SELECT
								'X'
							FROM
								R12_TRNBI_BI_HDR_PSB C
							WHERE
								'7' = C.TRNBI_PROJECT_TYPE
								AND D.INVOICE = C.INVOICE
								AND D.BUSINESS_UNIT = C.BUSINESS_UNIT
					)
		)
	GROUP BY
		BUSINESS_UNIT,
		GL_ACCOUNT,
		DEPTID,
		DEPT_DESCR,
		PROD_DESCR,
		PRODCODE
		--ADD BY ALEX
		,
		GL_PRODCODE
		--ADD BY ALEX
		,
		NVL(RESERVE_GROUP, 'LARGE'),
		JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		JRNL_ID,
		CURRENCY,
		NATION_CURR
UNION ALL
SELECT
		/*+ NO_CPU_COSTING */
		'P21' AS QUERY_SOURCE,
		BUSINESS_UNIT AS BU,
		SUM(P7_TOTAL) AS REVENUE_AMOUNT,
		SUM(100 *(P7_TOTAL - TRUNC(P7_TOTAL))) AS REVENUE_AMOUNT_DEC,
		GL_ACCOUNT AS GL_ACCOUNT,
		DEPTID AS DEPT_ID,
		DEPT_DESCR AS DEPT_DESCR,
		PRODCODE AS MANF_PROD_ID,
		PROD_DESCR AS MANF_PROD_DESCR
		/* CHANGING 5/18/2007 MSUN*/
		,
		GL_PRODCODE AS DIST_GL_PRODUCT,
		NVL(RESERVE_GROUP, 'LARGE') AS RESERVE_GROUP,
		JRNL_DATE AS JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) AS JRNL_YEAR,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_MONTH,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_YEAR_MONTH,
		JRNL_ID AS JRNL_ID,
		CURRENCY AS CURRENCY,
		NATION_CURR AS COUNTRY_INDICATOR
	FROM
		(
			SELECT
					/*+ NO_CPU_COSTING */
					D.R12_ENTITY AS BUSINESS_UNIT, -- -SS- BUSINESS_UNIT_GL
					D.INVOICE AS INVOICE,
					D.LINE_SEQ_NUM AS SEQ_NUM,
					D.ACCT_ENTRY_TYPE AS ENTRY_TYPE,
					D.JOURNAL_ID AS JRNL_ID,
					D.JOURNAL_DATE AS JRNL_DATE,
					D.R12_ACCOUNT AS GL_ACCOUNT, -- -SS- ACCOUNT
					D.MONETARY_AMOUNT AS P7_TOTAL,
					D.R12_LOCATION AS DEPTID, -- -SS- DEPTID
					COALESCE(AOL_R12.OFFICE_NAME, AOL_PS.OFFICE_NAME) AS DEPT_DESCR,
					-- -SS- AOL.OFFICE_NAME AS DEPT_DESCR,
					PR.DESCR AS PROD_DESCR,
					X.PRODUCT_CATEGORY AS RESERVE_GROUP,
					A.R12_PRODUCT AS PRODCODE, -- -SS- IDENTIFIER
					CASE WHEN D.R12_PRODUCT IN('41204', '41198')
						THEN '41204'
						ELSE D.R12_PRODUCT
					END AS GL_PRODCODE,
					-- -SS- WHEN D.PRODUCT = '0064' THEN '804155' ELSE D.PRODUCT END AS GL_PRODCODE,
					D.CURRENCY_CD AS CURRENCY,
					COALESCE(AOL_R12.NATION_CURR, AOL_PS.NATION_CURR) AS NATION_CURR
					-- -SS- AOL.NATION_CURR
				FROM
					R12_BI_LINE_PSB A                                                    -- -SS- OTR
				INNER JOIN R12_BI_ACCT_ENTRY_PSB D ON D.LINE_SEQ_NUM = A.LINE_SEQ_NUM -- -SS- OTR
					AND D.INVOICE = A.INVOICE AND D.BUSINESS_UNIT = A.BUSINESS_UNIT
					-- -SS- NEW
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = D.R12_ACCOUNT
					-- -SS- /NEW
				LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO X       ON A.PS_IDENTIFIER = X.MANF_PROD_CODE
				LEFT OUTER JOIN R12_TRANE_PRODUCTS_PS PR        ON D.R12_PRODUCT = PR.R12_PRODUCT  -- R12_2_R12 -- -SS- OTR, PRODUCT
				LEFT OUTER JOIN ACTUATE_OFFICE_LOCATION AOL_PS  ON D.PS_DEPTID = AOL_PS.DEPT_ID
				LEFT OUTER JOIN ACTUATE_OFFICE_LOCATION AOL_R12 ON AOL_R12.ORA_LOCATION IS NOT NULL AND D.R12_LOCATION = AOL_R12.ORA_LOCATION
					-- -SS- ACTUATE_OFFICE_LOCATION AOL
					-- -SS- D.DEPTID = AOL.DEPT_ID (+), issues 63, 73
				WHERE
					D.JOURNAL_DATE BETWEEN TO_DATE('03/01/2006', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
					AND D.PS_DEPTID != 'NA'
					-- -SS- NEW
					AND((D.PS_ACCOUNT = 'NA'
					AND AFU.EQUAL_700000 = 'Y')
					OR(D.PS_ACCOUNT <> 'NA'
					AND D.PS_ACCOUNT = '700000'))
					-- -SS- /NEW
					-- -SS- D.ACCOUNT = '700000'
					AND 'ACTUALS' = D.LEDGER
					AND '41208' <> D.R12_PRODUCT -- -SS-
					AND '41399' <> D.R12_PRODUCT -- -SS-
					AND '41132' <> D.R12_PRODUCT -- -SS-
					AND '41499' <> D.R12_PRODUCT -- -SS-
					AND '41205' <> D.R12_PRODUCT -- -SS-
					/* -SS-
					AND '805100' <> D.PRODUCT
					AND '802921' <> D.PRODUCT
					AND '801270' <> D.PRODUCT
					AND '803270' <> D.PRODUCT
					AND '804140' <> D.PRODUCT
					*/
					/* 2-5 year Warranty Project Rule */
					AND X.TWO_FIVE = 'Y'
					/* 2-5 year Warranty Project Rule */
					/* New Logic Adedd as of Oct27-2010 as  Jackie Req */
					-- AND D.BUSINESS_UNIT = X.GL_LEDGER (+)
					-- AND D.PRODUCT = X.MANF_PROD_CODE (+)
					AND X.GL_LEDGER = 'CSD'
					/* New Logic Adedd as of Oct27-2010 as  Jackie Req  */
					-- -SS- PRODUCT
					AND EXISTS
					(
						SELECT
								'X'
							FROM
								R12_BI_HDR_PSB B
							WHERE
								B.BILL_SOURCE_ID = 'P21'
								AND D.INVOICE = B.INVOICE
								AND D.BUSINESS_UNIT = B.PS_BUSINESS_UNIT
					)
					AND EXISTS
					(
						SELECT
								'X'
							FROM
								R12_TRNBI_BI_HDR_PSB C
							WHERE
								'7' = C.TRNBI_PROJECT_TYPE
								AND D.INVOICE = C.INVOICE
								AND D.BUSINESS_UNIT = C.BUSINESS_UNIT
					)
		)
	GROUP BY
		BUSINESS_UNIT,
		GL_ACCOUNT,
		DEPTID,
		DEPT_DESCR,
		PROD_DESCR,
		PRODCODE
		--ADD BY ALEX
		,
		GL_PRODCODE
		--ADD BY ALEX
		,
		NVL(RESERVE_GROUP, 'LARGE'),
		JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		JRNL_ID,
		CURRENCY,
		NATION_CURR;