SELECT
		/*+ NO_CPU_COSTING */
		CCN_DATA.CLAIM_NBR AS CLAIM_NUMBER,
		CCN_DATA.STEP_NBR AS STEP_NUMBER,
		CCN_DATA.R12_ENTITY  --SR MOVE TO CCN
		-- -SS- COMPANY
		AS BUSINESS_UNIT,
		PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
		CCN_DATA.CLAIM_TYPE AS CLAIM_TYPE,
		CCN_DATA.DOLLAR_AMOUNT AS EXPENSE_AMOUNT,
		100 *(CCN_DATA.DOLLAR_AMOUNT - TRUNC(CCN_DATA.DOLLAR_AMOUNT)) AS EXPENSE_AMOUNT_DEC,
		CCN_DATA.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
		CCN_DATA.R12_ACCOUNT
		-- -SS- ACCOUNT
		AS GL_ACCOUNT,
		CCN_DATA.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
		SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
		CASE WHEN CCN_DATA.R12_PRODUCT
				-- -SS- PROD_CODE
				IS NULL OR CCN_DATA.R12_PRODUCT
				-- -SS- PROD_CODE
				= ''
			THEN PCS.PROD_CODE
			ELSE CCN_DATA.R12_PRODUCT
				-- -SS- PROD_CODE
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
		/* PER JACKIE'S REQUEST ON 5/24/07 IF FAIL DATE = 1/1/1900 OR NULL THEN SET WARRANTY TYPE TO NO. */
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
				-- -SS- ASX.NATION_CURR='USD'
			THEN 'USA'
			ELSE 'CAN'
				/* -SS-
				WHEN ASX.NATION_CURR='CAD' THEN 'CAN'
				ELSE 'CURRENCY: ' || ASX.NATION_CURR
				*/
		END) AS COUNTRY_INDICATOR
		/* NEW FIELDS ADDED 5/21/07 */
		,
		CCN_DATA.RETRO_ID AS RETROFIT_ID,
		CCN_DATA.R12_COST_CENTER
		-- -SS- COST_CENTER
		AS GL_DEPT
		--, case when  a.CLAIM_NUMBER is null   then 10000*(CASE WHEN PCS.PROD_CODE='0061' or FCW.WA_RANGE<>'1' THEN 0 ELSE RES_PCT.RESERVE_PCT  END)  else  res_PCT1.RESERVE_PCT end  AS IN_RESERVE_PERCENT
		,
		CASE WHEN A.CLAIM_NUMBER IS NULL
			THEN 10000 *(RES_PCT.RESERVE_PCT)
			ELSE RES_PCT1.RESERVE_PCT
		END AS IN_RESERVE_PERCENT,
		ROUND((CCN_DATA.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
		100 * CCN_DATA.YEAR + CCN_DATA.MONTH AS TRXYEARMONTH
		--,CCN_DATA.DOLLAR_AMOUNT*(CASE WHEN PCS.PROD_CODE='0061' THEN 0 ELSE RES_PCT.RESERVE_PCT  END)  AS EXPENSE_AMT_IN_RES
		,
		0 AS EXPENSE_AMT_IN_RES
		--,CCN_DATA.DOLLAR_AMOUNT*(1-(CASE WHEN PCS.PROD_CODE='0061' THEN 0 ELSE RES_PCT.RESERVE_PCT  END))  AS EXPENSE_AMT_NOT_IN_RES
		,
		0 AS EXPENSE_AMT_NOT_IN_RES
	FROM
		(
			/* THIS IS THE CORE PORTION FOR SPD CLAIM TYPE TO RETRIEVE EXPENSE RELATED INFORMATION */
			SELECT
					/*+  no_cpu_costing */
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
				INNER JOIN TIME_DAY TD            ON TD.TIME_KEY = LR.CCN_TRX_DATE_KEY --, EXPENSE_TYPE_SCD ET
				INNER JOIN CLAIM_TYPE_SCD CT      ON LR.CLAIM_TYPE_SCD_KEY = CT.CLAIM_TYPE_SCD_KEY
				INNER JOIN R12_GL_ACCOUNT_SCD GLA ON GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
					/* -SS- */
					-- -SS- NEW
				LEFT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
					-- -SS- /NEW
				WHERE
					1 = 1
					/* for 'SPD','RETROFIT LABOR','EXTD PURCHASED LABOR' only */
					AND LR.CLAIM_TYPE_SCD_KEY IN(1, 2, 9)
					AND TD.FULL_DATE BETWEEN add_months(trunc(sysdate,'YEAR'),'-72') and last_day(add_months(trunc(sysdate,'mm'),-1)) 
					-- -SS- NEW
					AND((GLA.PS_ACCOUNT = 'NA'
					AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y')
					OR GLA.PS_ACCOUNT LIKE '0620%'
					OR GLA.PS_ACCOUNT LIKE '8062%')
					-- -SS- /NEW
					-- -SS- AND(GLA.ACCOUNT LIKE '0620%' OR GLA.ACCOUNT LIKE '8062%')
					-- AND LR.CLAIM_NBR = 8543136
		)
		CCN_DATA
	LEFT OUTER JOIN
		(SELECT
					/*+  no_cpu_costing */
					DISTINCT CLAIM_NBR, STEP_NBR, WA_POLICY_TYPE, WA_RANGE FROM DM_FAL_CLAIMS_WARRANTY_XRF
		) FCW                  ON CCN_DATA.CLAIM_NBR = FCW.CLAIM_NBR AND CCN_DATA.STEP_NBR = FCW.STEP_NBR
-- SR USE FROM INLINE VIEW	INNER JOIN TIME_DAY TD3 ON CCN_DATA.CCN_TRX_DATE_KEY = TD3.TIME_KEY
	INNER JOIN TIME_DAY TD2 ON CCN_DATA.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
	INNER JOIN TIME_DAY TD1 ON CCN_DATA.FAIL_DATE_KEY = TD1.TIME_KEY
	INNER JOIN TIME_DAY TD ON CCN_DATA.START_DATE_KEY = TD.TIME_KEY
-- SR USE FROM IN LINE VIEW -	INNER JOIN R12_GL_ACCOUNT_SCD GLA ON CCN_DATA.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
		/* -SS- */
		--,EXPENSE_TYPE_SCD ETS
	INNER JOIN PROD_CODE_SCD PCS              ON CCN_DATA.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
	INNER JOIN CUST_ACCOUNT_SCD CACCT         ON CCN_DATA.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
	INNER JOIN SUBMIT_OFFICE_SCD SOS          ON CCN_DATA.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
	INNER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP ON -- -SS- issue 22
		PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE      -- -SS- issues 55, 56
		AND CCN_DATA.PS_COMPANY = PRODGRP.GL_LEDGER      -- SR-r12???
		-- -SS- ,ACTUATE_SEC_XREF ASX
	INNER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT   ON CCN_DATA.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR AND CCN_DATA.EXPENSE_TYPE_CATG = UPPER(RES_PCT.EXPENSE_TYPE_CATG) AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
	LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ A ON CCN_DATA.CLAIM_NBR = A.CLAIM_NUMBER
		/* FOR RESERVE GROUP */
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
		-- AND CCN_DATA.CLAIM_NBR = 8543136
		;
		
