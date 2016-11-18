/*
CREATE TABLE "DBO"."MAP_WARRANTY_EXPENSE_DATA"
( "CLAIM_NUMBER" NUMBER(8,0),
"STEP_NUMBER" NUMBER(9,0),
"BUSINESS_UNIT" VARCHAR2(6 BYTE),
"RESERVE_GROUP" VARCHAR2(5 BYTE),
"CLAIM_TYPE" CHAR(10 BYTE),
"EXPENSE_AMOUNT" NUMBER,
"EXPENSE_AMOUNT_DEC" NUMBER,
"MATERIAL_LABOR" VARCHAR2(8 BYTE),
"GL_ACCOUNT" VARCHAR2(10 BYTE),
"EXPENSE_TYPE_DESCR" VARCHAR2(15 BYTE),
"OFFICE_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE,
"GL_PROD_CODE" VARCHAR2(6 BYTE),
"MANF_PROD_CODE" VARCHAR2(6 BYTE) NOT NULL ENABLE,
"COMPANY_OWNED" VARCHAR2(1 BYTE) NOT NULL ENABLE,
"CUSTOMER_NUMBER" VARCHAR2(7 BYTE) NOT NULL ENABLE,
"CUSTOMER_NAME" VARCHAR2(34 BYTE) NOT NULL ENABLE,
"INTERNAL_EXTERNAL" CHAR(1 BYTE),
"TRX_DATE" DATE,
"TRX_YEAR" VARCHAR2(40 BYTE),
"TRX_MONTH" VARCHAR2(40 BYTE),
"INTMONTHS_TRX_TO_BASE" NUMBER,
"INTMONTHS_SHIP_TO_BASE" NUMBER,
"SHIP_DATE" DATE,
"SHIP_YEAR_MONTH" NUMBER,
"INTMONTHS_SHIP_TO_TRX" NUMBER,
"START_DATE" DATE,
"INTMONTHS_START_TO_TRX" NUMBER,
"FAIL_DATE" DATE,
"INTMONTHS_FAIL_TO_TRX" NUMBER,
"WARRANTY_TYPE" VARCHAR2(3 BYTE),
"WARRANTY_DURATION" VARCHAR2(30 BYTE),
"CURRENCY" VARCHAR2(3 BYTE),
"COUNTRY_INDICATOR" CHAR(3 BYTE),
"RETROFIT_ID" VARCHAR2(20 BYTE),
"GL_DEPT" VARCHAR2(10 BYTE),
"IN_RESERVE_PERCENT" NUMBER,
"TRX_LAG" NUMBER,
"TRXYEARMONTH" NUMBER,
"EXPENSE_AMT_IN_RES" NUMBER,
"EXPENSE_AMT_NOT_IN_RES" NUMBER
) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
TABLESPACE "D1_AA" ;
*/
ALTER TABLE MAP_WARRANTY_EXPENSE_DATA NOLOGGING;
TRUNCATE TABLE MAP_WARRANTY_EXPENSE_DATA
DROP STORAGE;
COMMIT;
INSERT /*+ APPEND */
	INTO MAP_WARRANTY_EXPENSE_DATA
SELECT
		/*+  no_cpu_costing */
		CCN_DATA.CLAIM_NBR AS CLAIM_NUMBER,
		CCN_DATA.STEP_NBR AS STEP_NUMBER,
		CCN_DATA.R12_ENTITY AS BUSINESS_UNIT,
		PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
		CCN_DATA.CLAIM_TYPE AS CLAIM_TYPE,
		CCN_DATA.DOLLAR_AMOUNT AS EXPENSE_AMOUNT,
		100 *(CCN_DATA.DOLLAR_AMOUNT - TRUNC(CCN_DATA.DOLLAR_AMOUNT)) AS EXPENSE_AMOUNT_DEC,
		CCN_DATA.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
		CCN_DATA.R12_ACCOUNT AS GL_ACCOUNT,
		CCN_DATA.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
		SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
		CASE WHEN CCN_DATA.R12_PRODUCT IS NULL OR CCN_DATA.R12_PRODUCT = ''
			THEN PCS.PROD_CODE
			ELSE CCN_DATA.R12_PRODUCT
		END AS GL_PROD_CODE,
		PCS.PROD_CODE AS MANF_PROD_CODE,
		SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
		CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
		CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
		(
		CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
			THEN 'Y'
			ELSE 'N'
		END) AS INTERNAL_EXTERNAL,
		CCN_DATA.FULL_DATE AS TRX_DATE,
		TO_CHAR(CCN_DATA.YEAR) AS TRX_YEAR,
		TO_CHAR(CCN_DATA.MONTH) AS TRX_MONTH,
		CEIL(ABS(MONTHS_BETWEEN(CCN_DATA.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_TRX_TO_BASE,
		CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_SHIP_TO_BASE,
		TD2.FULL_DATE AS SHIP_DATE,
		(TD2.YEAR * 100 + TD2.MONTH) AS SHIP_YEAR_MONTH,
		CEIL(((CCN_DATA.TIME_KEY - TD2.TIME_KEY) / 30.42)) + 1 AS INTMONTHS_SHIP_TO_TRX,
		TD.FULL_DATE AS START_DATE,
		((CCN_DATA.TIME_KEY - TD.TIME_KEY) / 30.42) AS INTMONTHS_START_TO_TRX,
		TD1.FULL_DATE AS FAIL_DATE,
		((CCN_DATA.TIME_KEY - TD1.TIME_KEY) / 30.42) AS INTMONTHS_FAIL_TO_TRX,
		(
		CASE WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY') OR TD1.FULL_DATE IS NULL
			THEN 'NO'
			ELSE FCW.WA_POLICY_TYPE
		END) AS WARRANTY_TYPE,
		(
		CASE WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR'
			THEN 'Out of Standard Warranty'
			ELSE(
				CASE                                   WHEN FCW.WA_RANGE = '1'
					THEN '1st Year Standard Warranty'     WHEN FCW.WA_RANGE = '2'
					THEN '2nd-5th Year Standard Warranty' WHEN FCW.WA_RANGE = '5'
					THEN '> 5th Year Standard Warranty'
					ELSE 'Out of Standard Warranty'
				END)
		END) AS WARRANTY_DURATION,
		CCN_DATA.TRX_CURRENCY AS CURRENCY,
		(
		CASE WHEN CCN_DATA.R12_ENTITY <> 5773
			THEN 'USA'
			ELSE 'CAN'
		END) AS COUNTRY_INDICATOR,
		CCN_DATA.RETRO_ID AS RETROFIT_ID,
		CCN_DATA.R12_COST_CENTER
		-- -SS- COST_CENTER
		AS GL_DEPT,
		CASE WHEN A.CLAIM_NUMBER IS NULL
			THEN 10000 *(RES_PCT.RESERVE_PCT)
			ELSE RES_PCT1.RESERVE_PCT
		END AS IN_RESERVE_PERCENT,
		ROUND((CCN_DATA.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
		100 * CCN_DATA.YEAR + CCN_DATA.MONTH AS TRXYEARMONTH,
		0 AS EXPENSE_AMT_IN_RES,
		0 AS EXPENSE_AMT_NOT_IN_RES
	FROM
		(
			/* THIS IS THE CORE PORTION FOR CONCESSION CLAIM TYPE TO RETRIEVE EXPENSE RELATED INFORMATION */
			SELECT
					/*+  no_cpu_costing */
					'TRANE_MATERIAL' AS TYPE,
					MLR.CLAIM_NBR,
					MLR.RETRO_ID,
					'CONCESSION' AS CLAIM_TYPE,
					'TRANE COMPANY' AS EXPENSE_TYPE_DESCR,
					'MATERIAL' AS EXPENSE_TYPE_CATG,
					LR.CHARGE_COMM_PCT,
					LR.CHARGE_COMPANY_PCT,
					MAX(((LR.APPR_SUBLET_MAT_AMT + LR.APPR_SUBLET_REF_AMT + LR.APPR_SUBLET_SERV_AMT) /
					(
						SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
					)
					* LR.CHARGE_COMPANY_PCT)) AS DOLLAR_AMOUNT,
					MLR.STEP_NBR,
					MLR.CCN_TRX_DATE_KEY,
					MLR.ORIGINAL_SHIP_DATE_KEY,
					MLR.FAIL_DATE_KEY,
					MLR.START_DATE_KEY,
					MLR.GL_ACCOUNT_SCD_KEY,
					MLR.PROD_CODE_SCD_KEY,
					MLR.CUST_ACCOUNT_SCD_KEY,
					MLR.SUBMIT_OFFICE_SCD_KEY,
					MLR.TRX_CURRENCY,
					GLA.R12_ENTITY,
					GLA.R12_ACCOUNT,
					GLA.R12_COST_CENTER,
					GLA.PS_COMPANY,
					GLA.R12_PRODUCT,
					TD.FULL_DATE,
					TD.YEAR,
					TD.MONTH,
					TD.TIME_KEY
				FROM
					WC_MAT_LBR_ROLLUP MLR
				INNER JOIN WC_LABOR_ROLLUP LR              ON MLR.CCN_TRX_DATE_KEY = LR.CCN_TRX_DATE_KEY AND MLR.DETAIL_NBR = LR.DETAIL_NBR AND MLR.CLAIM_NBR = LR.CLAIM_NBR
				INNER JOIN TIME_DAY TD                     ON TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY AND TD.TIME_KEY = LR.CCN_TRX_DATE_KEY
				INNER JOIN R12_GL_ACCOUNT_SCD GLA          ON GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY
				LEFT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
				WHERE
					/* CONCESSION CLAIM TYPE ONLY */
					MLR.CLAIM_TYPE_SCD_KEY = 11
					AND TD.FULL_DATE BETWEEN ADD_MONTHS(TRUNC(SYSDATE, 'YEAR'), '-72') AND LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE, 'mm'), - 1))
					AND((GLA.PS_ACCOUNT = 'NA'
					AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y')
					OR GLA.PS_ACCOUNT LIKE '0620%'
					OR GLA.PS_ACCOUNT LIKE '8062%')
					-- AND MLR.CLAIM_NBR = 8543136
				GROUP BY
					MLR.CLAIM_NBR,
					LR.CHARGE_COMM_PCT,
					LR.CHARGE_COMPANY_PCT,
					MLR.CCN_TRX_DATE_KEY,
					MLR.ORIGINAL_SHIP_DATE_KEY,
					MLR.FAIL_DATE_KEY,
					MLR.START_DATE_KEY,
					MLR.STEP_NBR,
					MLR.GL_ACCOUNT_SCD_KEY,
					MLR.PROD_CODE_SCD_KEY,
					MLR.CUST_ACCOUNT_SCD_KEY,
					MLR.SUBMIT_OFFICE_SCD_KEY,
					MLR.TRX_CURRENCY,
					MLR.RETRO_ID
			UNION ALL
			SELECT
					/*+  no_cpu_costing */
					'TRANE_LABOR' AS TYPE,
					MLR.CLAIM_NBR,
					MLR.RETRO_ID,
					'CONCESSION' AS CLAIM_TYPE,
					'TRANE COMPANY' AS EXPENSE_TYPE_DESCR,
					'LABOR' AS EXPENSE_TYPE_CATG,
					LR.CHARGE_COMM_PCT,
					LR.CHARGE_COMPANY_PCT,
					((SUM((LR2.APPR_AMT)) + MAX((LR.APPR_DIAGNOSTIC_AMT + LR.APPR_TRAVEL_AMT) /
					(
						SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
					)
					)) * LR.CHARGE_COMPANY_PCT) AS DOLLAR_AMOUNT,
					MLR.STEP_NBR,
					MLR.CCN_TRX_DATE_KEY,
					MLR.ORIGINAL_SHIP_DATE_KEY,
					MLR.FAIL_DATE_KEY,
					MLR.START_DATE_KEY,
					MLR.GL_ACCOUNT_SCD_KEY,
					MLR.PROD_CODE_SCD_KEY,
					MLR.CUST_ACCOUNT_SCD_KEY,
					MLR.SUBMIT_OFFICE_SCD_KEY,
					MLR.TRX_CURRENCY,
					GLA.R12_ENTITY,
					GLA.R12_ACCOUNT,
					GLA.R12_COST_CENTER,
					GLA.PS_COMPANY,
					GLA.R12_PRODUCT,
					TD.FULL_DATE,
					TD.YEAR,
					TD.MONTH,
					TD.TIME_KEY
				FROM
					WC_MAT_LBR_ROLLUP MLR
				INNER JOIN WC_LABOR_ROLLUP LR     ON MLR.CCN_TRX_DATE_KEY = LR.CCN_TRX_DATE_KEY AND MLR.DETAIL_NBR = LR.DETAIL_NBR AND MLR.CLAIM_NBR = LR.CLAIM_NBR AND MLR.STEP_NBR = LR.STEP_NBR
				INNER JOIN TIME_DAY TD            ON TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY AND TD.TIME_KEY = LR.CCN_TRX_DATE_KEY
				INNER JOIN R12_GL_ACCOUNT_SCD GLA ON GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY AND GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
				INNER JOIN
					(SELECT DISTINCT CLAIM_NBR, DETAIL_NBR, STEP_NBR, APPR_AMT, CCN_TRX_DATE_KEY FROM WC_LABOR_ROLLUP LR1 WHERE CLAIM_TYPE_SCD_KEY = 11 AND EXISTS
								(SELECT 'X' FROM R12_GL_ACCOUNT_SCD GLA -- -SS-
										LEFT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
										WHERE
											LR1.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
											AND((GLA.PS_ACCOUNT = 'NA'
											AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y')
											OR GLA.PS_ACCOUNT LIKE '0620%'
											OR GLA.PS_ACCOUNT LIKE '8062%')
								)
					)
					LR2 ON MLR.CCN_TRX_DATE_KEY = LR2.CCN_TRX_DATE_KEY
					AND TD.TIME_KEY = LR2.CCN_TRX_DATE_KEY
					AND MLR.STEP_NBR = LR2.STEP_NBR
					AND MLR.DETAIL_NBR = LR2.DETAIL_NBR
					AND MLR.CLAIM_NBR = LR2.CLAIM_NBR
				LEFT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
				WHERE
					1 = 1
					/* CONCESSION CLAIM TYPE ONLY */
					AND MLR.CLAIM_TYPE_SCD_KEY = 11
					AND TD.FULL_DATE BETWEEN ADD_MONTHS(TRUNC(SYSDATE, 'YEAR'), '-72') AND LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE, 'mm'), - 1))
					/* WARRANTY LIMITATION */
					AND((GLA.PS_ACCOUNT = 'NA'
					AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y')
					OR GLA.PS_ACCOUNT LIKE '0620%'
					OR GLA.PS_ACCOUNT LIKE '8062%')
				GROUP BY
					MLR.CLAIM_NBR,
					LR.CHARGE_COMM_PCT,
					LR.CHARGE_COMPANY_PCT,
					MLR.CCN_TRX_DATE_KEY,
					MLR.ORIGINAL_SHIP_DATE_KEY,
					MLR.FAIL_DATE_KEY,
					MLR.START_DATE_KEY,
					MLR.STEP_NBR,
					MLR.GL_ACCOUNT_SCD_KEY,
					MLR.PROD_CODE_SCD_KEY,
					MLR.CUST_ACCOUNT_SCD_KEY,
					MLR.SUBMIT_OFFICE_SCD_KEY,
					MLR.TRX_CURRENCY,
					MLR.RETRO_ID
		)
		CCN_DATA
	LEFT OUTER JOIN DM_FAL_CLAIMS_WARRANTY_XRF FCW ON CCN_DATA.CLAIM_NBR = FCW.CLAIM_NBR
		/* CONCESSION CLAIM TYPE */
		AND CCN_DATA.STEP_NBR = FCW.STEP_NBR
	INNER JOIN TIME_DAY TD2                         ON CCN_DATA.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
	INNER JOIN TIME_DAY TD1                         ON CCN_DATA.FAIL_DATE_KEY = TD1.TIME_KEY
	INNER JOIN TIME_DAY TD                          ON CCN_DATA.START_DATE_KEY = TD.TIME_KEY
	INNER JOIN PROD_CODE_SCD PCS                    ON CCN_DATA.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
	INNER JOIN CUST_ACCOUNT_SCD CACCT               ON CCN_DATA.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
	INNER JOIN SUBMIT_OFFICE_SCD SOS                ON CCN_DATA.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
	INNER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP       ON PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE AND CCN_DATA.PS_COMPANY = PRODGRP.GL_LEDGER -- SR-r12???-- -SS- issues 55, 56 -- -SS- issue 22
	INNER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT       ON CCN_DATA.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR AND CCN_DATA.EXPENSE_TYPE_CATG = UPPER(RES_PCT.EXPENSE_TYPE_CATG) AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
	LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ A     ON CCN_DATA.CLAIM_NBR = A.CLAIM_NUMBER
	LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT1 ON A.CLAIM_TYPE = RES_PCT1.CLAIM_TYPE
	WHERE
		1 = 1
		AND(
		CASE WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR'
			THEN 'EXTENDED PURCHASED LABOR'
			ELSE CCN_DATA.CLAIM_TYPE
		END) = RES_PCT.CLAIM_TYPE
		AND(
		CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
			THEN 'Y'
			ELSE 'N'
		END) = RES_PCT.CUST_CREDIT_CATG_CODE
		AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL ;
COMMIT;
-- ALTER SESSION SET SQL_TRACE=TRUE;
-- ALTER SESSION SET TRACEFILE_IDENTIFIER=warr_expense_section_2a;
-- MIDDLE SECTION
INSERT
		/*+ APPEND */
	INTO
		MAP_WARRANTY_EXPENSE_DATA
SELECT
		/*+  no_cpu_costing */
		MLR.CLAIM_NBR AS CLAIM_NUMBER,
		MLR.STEP_NBR AS STEP_NUMBER,
		GLA.R12_ENTITY AS BUSINESS_UNIT,
		PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
		CTYPES.CLAIM_TYPE_DESCR AS CLAIM_TYPE,
		SUM(MLR.EXP_TYPE_AMOUNT * - 1) AS EXPENSE_AMOUNT,
		SUM(100 *(MLR.EXP_TYPE_AMOUNT * - 1 - TRUNC(MLR.EXP_TYPE_AMOUNT * - 1))) AS EXPENSE_AMOUNT_DEC,
		RES_PCT.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
		GLA.R12_ACCOUNT AS GL_ACCOUNT,
		ETS.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
		SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
		CASE WHEN GLA.R12_PRODUCT IS NULL OR GLA.R12_PRODUCT = ''
			THEN PCS.PROD_CODE
			ELSE GLA.R12_PRODUCT
		END AS GL_PROD_CODE,
		PCS.PROD_CODE AS MANF_PROD_CODE,
		SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
		CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
		CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
		(
		CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
			THEN 'Y'
			ELSE 'N'
		END) AS INTERNAL_EXTERNAL,
		TD3.FULL_DATE AS TRX_DATE,
		TO_CHAR(TD3.YEAR) AS TRX_YEAR,
		TO_CHAR(TD3.MONTH) AS TRX_MONTH,
		CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_TRX_TO_BASE,
		CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_SHIP_TO_BASE,
		TD2.FULL_DATE AS SHIP_DATE,
		(TD2.YEAR * 100 + TD2.MONTH) AS SHIP_YEAR_MONTH,
		CEIL(((TD3.TIME_KEY - TD2.TIME_KEY) / 30.42)) + 1 AS INTMONTHS_SHIP_TO_TRX,
		TD.FULL_DATE AS START_DATE,
		((TD3.TIME_KEY - TD.TIME_KEY) / 30.42) AS INTMONTHS_START_TO_TRX,
		TD1.FULL_DATE AS FAIL_DATE,
		((TD3.TIME_KEY - TD1.TIME_KEY) / 30.42) AS INTMONTHS_FAIL_TO_TRX,
		(
		CASE WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY') OR TD1.FULL_DATE IS NULL
			THEN 'NO'
			ELSE FCW.WA_POLICY_TYPE
		END) AS WARRANTY_TYPE,
		(
		CASE                                   WHEN FCW.WA_RANGE = '1'
			THEN '1st Year Standard Warranty'     WHEN FCW.WA_RANGE = '2'
			THEN '2nd-5th Year Standard Warranty' WHEN FCW.WA_RANGE = '5'
			THEN '> 5th Year Standard Warranty'
			ELSE 'Out of Standard Warranty'
		END) AS WARRANTY_DURATION,
		MLR.TRX_CURRENCY AS CURRENCY,
		(
		CASE WHEN GLA.R12_ENTITY <> 5773
			THEN 'USA'
			ELSE 'CAN'
		END) AS COUNTRY_INDICATOR,
		MLR.RETRO_ID AS RETROFIT_ID,
		GLA.R12_COST_CENTER AS GL_DEPT,
		CASE WHEN A.CLAIM_NUMBER IS NULL
			THEN 10000 *(RES_PCT.RESERVE_PCT)
			ELSE RES_PCT1.RESERVE_PCT
		END AS IN_RESERVE_PERCENT,
		ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
		100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH,
		0 AS EXPENSE_AMT_IN_RES,
		0 AS EXPENSE_AMT_NOT_IN_RES
	FROM
		WC_MAT_LBR_ROLLUP MLR
	LEFT OUTER JOIN DM_FAL_CLAIMS_WARRANTY_XRF FCW  ON MLR.CLAIM_NBR = FCW.CLAIM_NBR AND MLR.DETAIL_NBR = FCW.DETAIL_NBR AND MLR.STEP_NBR = FCW.STEP_NBR
	INNER JOIN TIME_DAY TD3                         ON MLR.CCN_TRX_DATE_KEY = TD3.TIME_KEY
	INNER JOIN TIME_DAY TD2                         ON MLR.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
	INNER JOIN TIME_DAY TD1                         ON MLR.FAIL_DATE_KEY = TD1.TIME_KEY
	INNER JOIN TIME_DAY TD                          ON MLR.START_DATE_KEY = TD.TIME_KEY
	INNER JOIN CLAIM_TASK_SCD CTASKS                ON MLR.CLAIM_TASK_SCD_KEY = CTASKS.CLAIM_TASK_SCD_KEY
	INNER JOIN CLAIM_TYPE_SCD CTYPES                ON MLR.CLAIM_TYPE_SCD_KEY = CTYPES.CLAIM_TYPE_SCD_KEY
	INNER JOIN R12_GL_ACCOUNT_SCD GLA               ON MLR.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
	INNER JOIN EXPENSE_TYPE_SCD ETS                 ON MLR.EXPENSE_TYPE_SCD_KEY = ETS.EXPENSE_TYPE_SCD_KEY
	INNER JOIN PROD_CODE_SCD PCS                    ON MLR.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
	INNER JOIN CUST_ACCOUNT_SCD CACCT               ON MLR.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
	INNER JOIN SUBMIT_OFFICE_SCD SOS                ON MLR.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
	INNER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP       ON PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE AND GLA.PS_COMPANY = PRODGRP.GL_LEDGER -- SR-r12???     -- -SS- issues 55, 56 -- -SS- issue 22
	INNER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT       ON CTYPES.CLAIM_TYPE_DESCR = RES_PCT.CLAIM_TYPE AND ETS.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
	LEFT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU      ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
	LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ A     ON MLR.CLAIM_NBR = A.CLAIM_NUMBER
	LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT1 ON A.CLAIM_TYPE = RES_PCT1.CLAIM_TYPE
	WHERE
		1 = 1
		AND MLR.CLAIM_TYPE_SCD_KEY IN(3, 10)
		AND(
		CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
			THEN 'Y'
			ELSE 'N'
		END) = RES_PCT.CUST_CREDIT_CATG_CODE
		AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
		--   AND TD3.FULL_DATE >= TO_DATE('1/1/2001', 'MM/DD/YYYY')
		-- AND TD3.FULL_DATE BETWEEN ADD_MONTHS(TRUNC(SYSDATE, 'YEAR'), '-72') AND LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE, 'mm'), - 1))
		AND((GLA.PS_ACCOUNT = 'NA'
		AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y')
		OR GLA.PS_ACCOUNT LIKE '0620%'
		OR GLA.PS_ACCOUNT LIKE '8062%')
	GROUP BY
		MLR.CLAIM_NBR,
		MLR.STEP_NBR,
		GLA.R12_ENTITY,
		PRODGRP.PRODUCT_CATEGORY,
		CTYPES.CLAIM_TYPE_DESCR,
		RES_PCT.EXPENSE_TYPE_CATG,
		GLA.R12_ACCOUNT,
		ETS.EXPENSE_TYPE_DESCR,
		SOS.SUBMIT_OFFICE_NAME,
		GLA.R12_PRODUCT,
		PCS.PROD_CODE,
		SOS.COMPANY_OWNED_IND,
		CACCT.ACCOUNT_NUMBER,
		CACCT.CUST_ACCT_NAME,
		(
		CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
			THEN 'Y'
			ELSE 'N'
		END),
		TD3.FULL_DATE,
		TO_CHAR(TD3.YEAR),
		TO_CHAR(TD3.MONTH),
		CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1,
		CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1,
		TD2.FULL_DATE,
		(TD2.YEAR * 100 + TD2.MONTH),
		CEIL(((TD3.TIME_KEY - TD2.TIME_KEY) / 30.42)) + 1,
		TD.FULL_DATE,
		((TD3.TIME_KEY - TD.TIME_KEY) / 30.42),
		TD1.FULL_DATE,
		((TD3.TIME_KEY - TD1.TIME_KEY) / 30.42),
		(
		CASE WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY') OR TD1.FULL_DATE IS NULL
			THEN 'NO'
			ELSE FCW.WA_POLICY_TYPE
		END),
		(
		CASE                                   WHEN FCW.WA_RANGE = '1'
			THEN '1st Year Standard Warranty'     WHEN FCW.WA_RANGE = '2'
			THEN '2nd-5th Year Standard Warranty' WHEN FCW.WA_RANGE = '5'
			THEN '> 5th Year Standard Warranty'
			ELSE 'Out of Standard Warranty'
		END),
		MLR.TRX_CURRENCY,
		(
		CASE WHEN GLA.R12_ENTITY <> 5773
			THEN 'USA'
			ELSE 'CAN'
		END),
		MLR.RETRO_ID,
		GLA.R12_COST_CENTER,
		CASE WHEN A.CLAIM_NUMBER IS NULL
			THEN 10000 *(RES_PCT.RESERVE_PCT)
			ELSE RES_PCT1.RESERVE_PCT
		END,
		ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42),
		100 * TD3.YEAR + TD3.MONTH ;
COMMIT;
-- THIRD SECTION
INSERT /*+ APPEND */
	INTO MAP_WARRANTY_EXPENSE_DATA
SELECT
		/*+ NO_CPU_COSTING */
		CCN_DATA.CLAIM_NBR AS CLAIM_NUMBER,
		CCN_DATA.STEP_NBR AS STEP_NUMBER,
		CCN_DATA.R12_ENTITY AS BUSINESS_UNIT, --SR MOVE TO CCN  -- -SS- COMPANY
		PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
		CCN_DATA.CLAIM_TYPE AS CLAIM_TYPE,
		CCN_DATA.DOLLAR_AMOUNT AS EXPENSE_AMOUNT,
		100 *(CCN_DATA.DOLLAR_AMOUNT - TRUNC(CCN_DATA.DOLLAR_AMOUNT)) AS EXPENSE_AMOUNT_DEC,
		CCN_DATA.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
		CCN_DATA.R12_ACCOUNT AS GL_ACCOUNT, -- -SS- ACCOUNT
		CCN_DATA.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
		SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
		CASE WHEN CCN_DATA.R12_PRODUCT IS NULL OR CCN_DATA.R12_PRODUCT = ''
			THEN PCS.PROD_CODE
			ELSE CCN_DATA.R12_PRODUCT
		END AS GL_PROD_CODE,
		PCS.PROD_CODE AS MANF_PROD_CODE,
		SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
		CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
		CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
		(
		CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
			THEN 'Y'
			ELSE 'N'
		END) AS INTERNAL_EXTERNAL,
		TD3.FULL_DATE AS TRX_DATE,
		TO_CHAR(TD3.YEAR) AS TRX_YEAR,
		TO_CHAR(TD3.MONTH) AS TRX_MONTH,
		CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_TRX_TO_BASE,
		CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_SHIP_TO_BASE,
		TD2.FULL_DATE AS SHIP_DATE,
		(TD2.YEAR * 100 + TD2.MONTH) AS SHIP_YEAR_MONTH,
		CEIL(((TD3.TIME_KEY - TD2.TIME_KEY) / 30.42)) + 1 AS INTMONTHS_SHIP_TO_TRX,
		TD.FULL_DATE AS START_DATE,
		((TD3.TIME_KEY - TD.TIME_KEY) / 30.42) AS INTMONTHS_START_TO_TRX,
		TD1.FULL_DATE AS FAIL_DATE,
		((TD3.TIME_KEY - TD1.TIME_KEY) / 30.42) AS INTMONTHS_FAIL_TO_TRX,
		(
		CASE WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY') OR TD1.FULL_DATE IS NULL
			THEN 'NO'
			ELSE FCW.WA_POLICY_TYPE
		END) AS WARRANTY_TYPE,
		(
		CASE WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR'
			THEN 'Out of Standard Warranty'
			ELSE(
				CASE                                   WHEN FCW.WA_RANGE = '1'
					THEN '1st Year Standard Warranty'     WHEN FCW.WA_RANGE = '2'
					THEN '2nd-5th Year Standard Warranty' WHEN FCW.WA_RANGE = '5'
					THEN '> 5th Year Standard Warranty'
					ELSE 'Out of Standard Warranty'
				END)
		END) AS WARRANTY_DURATION,
		CCN_DATA.TRX_CURRENCY AS CURRENCY,
		(
		CASE WHEN CCN_DATA.R12_ENTITY <> 5773
			THEN 'USA'
			ELSE 'CAN'
		END) AS COUNTRY_INDICATOR,
		CCN_DATA.RETRO_ID AS RETROFIT_ID,
		CCN_DATA.R12_COST_CENTER AS GL_DEPT,
		CASE WHEN A.CLAIM_NUMBER IS NULL
			THEN 10000 *(RES_PCT.RESERVE_PCT)
			ELSE RES_PCT1.RESERVE_PCT
		END AS IN_RESERVE_PERCENT,
		ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
		100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH,
		0 AS EXPENSE_AMT_IN_RES,
		0 AS EXPENSE_AMT_NOT_IN_RES
	FROM
		(
			SELECT
					'SPD/Retrofit Labor/Extended Purchased Labor' AS TYPE,
					LR.CLAIM_NBR,
					LR.RETRO_ID,
					CT.CLAIM_TYPE_CODE AS CLAIM_TYPE,
					(
					CASE WHEN EXPENSE_TYPE_SCD_KEY IN(58, 60, 61)
						THEN 'MATERIAL'
						ELSE 'LABOR'
					END) AS EXPENSE_TYPE_DESCR,
					(
					CASE WHEN EXPENSE_TYPE_SCD_KEY IN(58, 60, 61)
						THEN 'MATERIAL'
						ELSE 'LABOR'
					END) AS EXPENSE_TYPE_CATG,
					LR.CHARGE_COMM_PCT,
					LR.CHARGE_COMPANY_PCT,
					LR.ALLOCATED_EXP_TYPE_AMOUNT * - 1 AS DOLLAR_AMOUNT,
					LR.STEP_NBR,
					LR.CCN_TRX_DATE_KEY,
					LR.ORIGINAL_SHIP_DATE_KEY,
					LR.FAIL_DATE_KEY,
					LR.START_DATE_KEY,
					LR.GL_ACCOUNT_SCD_KEY,
					LR.PROD_CODE_SCD_KEY,
					LR.CUST_ACCOUNT_SCD_KEY,
					LR.SUBMIT_OFFICE_SCD_KEY,
					LR.TRX_CURRENCY,
					GLA.R12_ENTITY,
					GLA.R12_ACCOUNT,
					GLA.R12_COST_CENTER,
					GLA.PS_COMPANY,
					GLA.R12_PRODUCT,
					TD.FULL_DATE,
					TD.YEAR,
					TD.MONTH,
					TD.TIME_KEY
				FROM
					WC_LABOR_ROLLUP LR
				INNER JOIN TIME_DAY TD                     ON TD.TIME_KEY = LR.CCN_TRX_DATE_KEY --, EXPENSE_TYPE_SCD ET
				INNER JOIN CLAIM_TYPE_SCD CT               ON LR.CLAIM_TYPE_SCD_KEY = CT.CLAIM_TYPE_SCD_KEY
				INNER JOIN R12_GL_ACCOUNT_SCD GLA          ON GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
				LEFT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
				WHERE
					1 = 1
					AND LR.CLAIM_TYPE_SCD_KEY IN(1, 2, 9)
					AND TD.FULL_DATE BETWEEN ADD_MONTHS(TRUNC(SYSDATE, 'YEAR'), '-72') AND LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE, 'mm'), - 1))
					AND((GLA.PS_ACCOUNT = 'NA'
					AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y')
					OR GLA.PS_ACCOUNT LIKE '0620%'
					OR GLA.PS_ACCOUNT LIKE '8062%')
		)
		CCN_DATA
	LEFT OUTER JOIN
		(SELECT
					/*+  no_cpu_costing */
					DISTINCT CLAIM_NBR, STEP_NBR, WA_POLICY_TYPE, WA_RANGE FROM DM_FAL_CLAIMS_WARRANTY_XRF
		) FCW                                          ON CCN_DATA.CLAIM_NBR = FCW.CLAIM_NBR AND CCN_DATA.STEP_NBR = FCW.STEP_NBR
	INNER JOIN TIME_DAY TD3                         ON CCN_DATA.CCN_TRX_DATE_KEY = TD3.TIME_KEY
	INNER JOIN TIME_DAY TD2                         ON CCN_DATA.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
	INNER JOIN TIME_DAY TD1                         ON CCN_DATA.FAIL_DATE_KEY = TD1.TIME_KEY
	INNER JOIN TIME_DAY TD                          ON CCN_DATA.START_DATE_KEY = TD.TIME_KEY
	INNER JOIN PROD_CODE_SCD PCS                    ON CCN_DATA.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
	INNER JOIN CUST_ACCOUNT_SCD CACCT               ON CCN_DATA.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
	INNER JOIN SUBMIT_OFFICE_SCD SOS                ON CCN_DATA.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
	INNER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP       ON PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE AND CCN_DATA.PS_COMPANY = PRODGRP.GL_LEDGER -- -SS- issues 55, 56 -- -SS- issue 22 -- SR-r12???
	INNER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT       ON CCN_DATA.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR AND CCN_DATA.EXPENSE_TYPE_CATG = UPPER(RES_PCT.EXPENSE_TYPE_CATG) AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
	LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ A     ON CCN_DATA.CLAIM_NBR = A.CLAIM_NUMBER
	LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT1 ON A.CLAIM_TYPE = RES_PCT1.CLAIM_TYPE
	WHERE
		1 = 1
		AND(
		CASE WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR'
			THEN 'EXTENDED PURCHASED LABOR'
			ELSE CCN_DATA.CLAIM_TYPE
		END) = RES_PCT.CLAIM_TYPE
		AND(
		CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
			THEN 'Y'
			ELSE 'N'
		END) = RES_PCT.CUST_CREDIT_CATG_CODE
		AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
		--  AND CCN_DATA.CLAIM_NBR = 8543136
		;
COMMIT;
