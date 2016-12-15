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
					DP.DESCR AS DEPT_DESCR,
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
					CASE WHEN D.R12_ENTITY IN('5773', '5588')
						THEN 'CAD'
						ELSE 'USD'
					END AS NATION_CURR
					-- -SS- AOL.NATION_CURR
				FROM
					R12_BI_LINE_PSB A                                                    -- -SS- OTR
				INNER JOIN R12_BI_ACCT_ENTRY_PSB D ON D.LINE_SEQ_NUM = A.LINE_SEQ_NUM -- -SS- OTR
					AND D.INVOICE = A.INVOICE AND D.BUSINESS_UNIT = A.BUSINESS_UNIT AND D.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
					-- -SS- NEW
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = D.R12_ACCOUNT
					-- -SS- /NEW
				LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO X ON D.PS_PRODUCT = X.MANF_PROD_CODE AND D.BUSINESS_UNIT = X.GL_LEDGER -- (+)
				LEFT OUTER JOIN R12_TRANE_PRODUCTS_PS PR        ON D.R12_PRODUCT = PR.R12_PRODUCT -- R12_2_R12_ok -- -SS- OTR, PRODUCT, PRODUCT, (+)
				LEFT OUTER JOIN R12_TRANE_LOCATIONS DP ON DP.R12_LOCATION = D.R12_LOCATION -- -SS- R12_2_R12, issue 47
					-- -SS- ACTUATE_OFFICE_LOCATION AOL
					-- -SS- D.DEPTID = AOL.DEPT_ID (+), issues 63, 73
					-- -SS- AND D.BUSINESS_UNIT_GL = AOL.BU_UNIT (+)
				WHERE
					D.JOURNAL_DATE BETWEEN TO_DATE('01/11/2014', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
					-- -SS- NEW
					AND((D.PS_ACCOUNT = 'NA'
					AND AFU.EQUAL_700000 = 'Y')
					OR(D.PS_ACCOUNT <> 'NA'
					AND D.PS_ACCOUNT = '700000'))
					-- -SS- /NEW
					-- -SS- D.ACCOUNT = '700000'
					AND 'ACTUALS' = D.LEDGER
					/* -SS-
					805100 -> 41208
					802921 -> 41399
					801270 -> 41132
					803270 -> 41499
					804140 -> 41205
					*/
					AND ((D.PS_PRODUCT <> 'NA' AND D.PS_PRODUCT <> '805100') OR (D.PS_PRODUCT = 'NA' AND D.R12_PRODUCT <> '41208')) -- -SS-
					AND ((D.PS_PRODUCT <> 'NA' AND D.PS_PRODUCT <> '802921') OR (D.PS_PRODUCT = 'NA' AND D.R12_PRODUCT <> '41399')) -- -SS-
					AND ((D.PS_PRODUCT <> 'NA' AND D.PS_PRODUCT <> '801270') OR (D.PS_PRODUCT = 'NA' AND D.R12_PRODUCT <> '41132')) -- -SS-
					AND ((D.PS_PRODUCT <> 'NA' AND D.PS_PRODUCT <> '803270') OR (D.PS_PRODUCT = 'NA' AND D.R12_PRODUCT <> '41499')) -- -SS-
					AND ((D.PS_PRODUCT <> 'NA' AND D.PS_PRODUCT <> '804140') OR (D.PS_PRODUCT = 'NA' AND D.R12_PRODUCT <> '41205')) -- -SS-
					/* -SS-
					AND '805100' <> D.PRODUCT
					AND '802921' <> D.PRODUCT
					AND '801270' <> D.PRODUCT
					AND '803270' <> D.PRODUCT
					AND '804140' <> D.PRODUCT
					*/
					AND EXISTS
					(
						SELECT
								/* index(b XPKOTR_BI_HDR_PSB) */
								'X'
							FROM
								R12_BI_HDR_PSB B
							WHERE
								B.BILL_SOURCE_ID = 'P21'
								AND D.INVOICE = B.INVOICE
								AND D.BUSINESS_UNIT = B.PS_BUSINESS_UNIT -- -SS- BUSINESS_UNIT
								AND D.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
					)
					AND EXISTS
					(
						SELECT
								/* index(c XPKOTR_TRNBI_BI_HDR_PSB) */
								'X'
							FROM
								R12_TRNBI_BI_HDR_PSB C
							WHERE
								'7' = C.TRNBI_PROJECT_TYPE
								AND D.INVOICE = C.INVOICE
								AND D.BUSINESS_UNIT = C.BUSINESS_UNIT
								AND D.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
					)
		)
	GROUP BY
		BUSINESS_UNIT,
		GL_ACCOUNT,
		DEPTID,
		DEPT_DESCR,
		PROD_DESCR,
		PRODCODE, --ADD BY ALEX
		GL_PRODCODE, --ADD BY ALEX
		NVL(RESERVE_GROUP, 'LARGE'),
		JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		JRNL_ID,
		CURRENCY,
		NATION_CURR