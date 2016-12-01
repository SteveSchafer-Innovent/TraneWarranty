CREATE OR REPLACE VIEW MAP_EXTWARRANTYEXPENSEDATA_VW
AS
	SELECT
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
			CASE WHEN GLA.R12_ENTITY IN('5773', '5588')
				THEN 'CAN'
				ELSE 'USA'
			END) AS COUNTRY_INDICATOR,
			MLR.RETRO_ID AS RETROFIT_ID,
			GLA.R12_COST_CENTER AS GL_DEPT,
			(
			CASE WHEN(PCS.PROD_CODE = '0061' AND CTYPES.CLAIM_TYPE_DESCR = 'MATERIAL') OR(PCS.PROD_CODE IN('0054', '0197')) OR(NVL(FCW.WA_RANGE, '0') NOT IN('2', '5')) OR(ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) > 91) OR(ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) > 24)
				THEN 0
				ELSE RES_PCT.RESERVE_PCT
			END) AS IN_RESERVE_PERCENT,
			ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
			ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) AS START_LAG,
			100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH,
			0 AS EXPENSE_AMT_IN_RES,
			0 AS EXPENSE_AMT_NOT_IN_RES
		FROM
			WC_MAT_LBR_ROLLUP MLR
		INNER JOIN EXPENSE_TYPE_SCD ET                 ON MLR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY
		LEFT OUTER JOIN DM_FAL_CLAIMS_WARRANTY_XRF FCW ON MLR.CLAIM_NBR = FCW.CLAIM_NBR AND MLR.DETAIL_NBR = FCW.DETAIL_NBR AND MLR.STEP_NBR = FCW.STEP_NBR
		INNER JOIN TIME_DAY TD3                        ON MLR.CCN_TRX_DATE_KEY = TD3.TIME_KEY
		INNER JOIN TIME_DAY TD2                        ON MLR.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
		INNER JOIN TIME_DAY TD1                        ON MLR.FAIL_DATE_KEY = TD1.TIME_KEY
		INNER JOIN TIME_DAY TD                         ON MLR.START_DATE_KEY = TD.TIME_KEY
		INNER JOIN CLAIM_TASK_SCD CTASKS               ON MLR.CLAIM_TASK_SCD_KEY = CTASKS.CLAIM_TASK_SCD_KEY
		INNER JOIN CLAIM_TYPE_SCD CTYPES               ON MLR.CLAIM_TYPE_SCD_KEY = CTYPES.CLAIM_TYPE_SCD_KEY
		INNER JOIN R12_GL_ACCOUNT_SCD GLA              ON MLR.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
		INNER JOIN EXPENSE_TYPE_SCD ETS                ON MLR.EXPENSE_TYPE_SCD_KEY = ETS.EXPENSE_TYPE_SCD_KEY
		INNER JOIN PROD_CODE_SCD PCS                   ON MLR.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
		INNER JOIN CUST_ACCOUNT_SCD CACCT              ON MLR.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
		INNER JOIN SUBMIT_OFFICE_SCD SOS               ON MLR.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
		INNER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP      ON PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE AND GLA.PS_COMPANY = PRODGRP.GL_LEDGER
		INNER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT      ON CTYPES.CLAIM_TYPE_DESCR = RES_PCT.CLAIM_TYPE AND ETS.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
		INNER JOIN R12_ACCOUNT_FILTER_UPD AFU          ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
		WHERE
			--and MLR.CLAIM_NBR =1617369
			/*  this portion for 'MATERIAL','RETROFIT MATERIAL'  */
			MLR.CLAIM_TYPE_SCD_KEY <> 11
			AND AFU.LIKE_52_53_54 = 'Y'
			AND(
			CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
				THEN 'Y'
				ELSE 'N'
			END) = RES_PCT.CUST_CREDIT_CATG_CODE
			AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
			AND TD3.FULL_DATE >= TO_DATE('1/01/2000', 'MM/DD/YYYY')
			AND TD3.FULL_DATE <= TO_DATE('12/31/2050', 'MM/DD/YYYY')
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
			CASE WHEN GLA.R12_ENTITY NOT IN('5773', '5588')
				THEN 'USA'
				ELSE 'CAN'
			END),
			MLR.RETRO_ID,
			GLA.R12_COST_CENTER,
			(
			CASE WHEN(PCS.PROD_CODE = '0061' AND CTYPES.CLAIM_TYPE_DESCR = 'MATERIAL') OR(PCS.PROD_CODE IN('0054', '0197')) OR(NVL(FCW.WA_RANGE, '0') NOT IN('2', '5')) OR(ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) > 91) OR(ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) > 24)
				THEN 0
				ELSE RES_PCT.RESERVE_PCT
			END),
			ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42),
			ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42),
			100 * TD3.YEAR + TD3.MONTH
		ORDER BY
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
			CASE WHEN GLA.R12_ENTITY NOT IN('5773', '5588')
				THEN 'USA'
				ELSE 'CAN'
			END),
			MLR.RETRO_ID,
			GLA.R12_COST_CENTER,
			(
			CASE WHEN(PCS.PROD_CODE = '0061' AND CTYPES.CLAIM_TYPE_DESCR = 'MATERIAL') OR(PCS.PROD_CODE IN('0054', '0197')) OR(NVL(FCW.WA_RANGE, '0') NOT IN('2', '5')) OR(ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) > 91) OR(ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) > 24)
				THEN 0
				ELSE RES_PCT.RESERVE_PCT
			END),
			ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42),
			ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42),
			100 * TD3.YEAR + TD3.MONTH ;
