SELECT GLA.R12_ENTITY                                                                     AS BUSINESS_UNIT, -- -SS- COMPANY
	SUM(MLR.EXP_TYPE_AMOUNT * - 1)                                                           AS EXPENSE_AMOUNT,
	SUM(100                 *(MLR.EXP_TYPE_AMOUNT * - 1 - TRUNC(MLR.EXP_TYPE_AMOUNT * - 1))) AS EXPENSE_AMOUNT_DEC,
	GLA.R12_ACCOUNT                                                                          AS GL_ACCOUNT, -- -SS- ACCOUNT
	TD2.YEAR                                                                                 AS SHIP_YEAR,
	(
	CASE
		WHEN FCW.WA_RANGE = '1' THEN '1st Year Standard Warranty'
		WHEN FCW.WA_RANGE = '2' THEN '2nd-5th Year Standard Warranty'
		WHEN FCW.WA_RANGE = '5' THEN '> 5th Year Standard Warranty'
		ELSE 'Out of Standard Warranty'
	END)             AS WARRANTY_DURATION,
	MLR.TRX_CURRENCY AS CURRENCY,
	(
	CASE
		WHEN GLA.R12_ENTITY NOT IN('5773', '5588') THEN 'USA' -- /* -SS- ASX.NATION_CURR='USD' */
		ELSE 'CAN'
			/* -SS-
			WHEN ASX.NATION_CURR='CAD' THEN 'CAN'
			ELSE 'CURRENCY: ' || ASX.NATION_CURR
			*/
	END)                                                                                AS COUNTRY_INDICATOR,
	ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42)                                      AS TRX_LAG,
	CEIL(((TD3.TIME_KEY  - TD2.TIME_KEY) / 30.42)) + 1                                  AS INTMONTHS_SHIP_TO_TRX,
	ROUND((TD.FULL_DATE  - TD2.FULL_DATE) / 30.42)                                      AS START_LAG,
	(TD2.YEAR            * 100 + TD2.MONTH)                                             AS SHIP_YEAR_MONTH,
	TD2.MONTH                                                                           AS SHIP_MONTH,
	TD2.FULL_DATE                                                                       AS SHIP_DATE,
	TD3.FULL_DATE                                                                       AS TRX_DATE,
	TO_CHAR(TD3.YEAR)                                                                   AS TRX_YEAR,
	TO_CHAR(TD3.MONTH)                                                                  AS TRX_MONTH,
	CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_TRX_TO_BASE,
	PSA.DESCR                                                                           AS DESCRIPTION
FROM WC_MAT_LBR_ROLLUP MLR
INNER JOIN EXPENSE_TYPE_SCD ET
ON MLR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY
INNER JOIN TIME_DAY TD3
ON MLR.CCN_TRX_DATE_KEY = TD3.TIME_KEY
INNER JOIN TIME_DAY TD2
ON MLR.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
INNER JOIN TIME_DAY TD1
ON MLR.FAIL_DATE_KEY = TD1.TIME_KEY
INNER JOIN TIME_DAY TD
ON MLR.START_DATE_KEY = TD.TIME_KEY
INNER JOIN CLAIM_TASK_SCD CTASKS
ON MLR.CLAIM_TASK_SCD_KEY = CTASKS.CLAIM_TASK_SCD_KEY
INNER JOIN CLAIM_TYPE_SCD CTYPES
ON MLR.CLAIM_TYPE_SCD_KEY = CTYPES.CLAIM_TYPE_SCD_KEY
INNER JOIN R12_GL_ACCOUNT_SCD GLA
ON MLR.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY -- /* -SS- */
INNER JOIN EXPENSE_TYPE_SCD ETS
ON MLR.EXPENSE_TYPE_SCD_KEY = ETS.EXPENSE_TYPE_SCD_KEY
INNER JOIN PROD_CODE_SCD PCS
ON MLR.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
INNER JOIN CUST_ACCOUNT_SCD CACCT
ON MLR.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
INNER JOIN SUBMIT_OFFICE_SCD SOS
ON MLR.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
INNER JOIN OTR_PROD_CODE_XREF_RCPO PRODGRP
ON GLA.PS_COMPANY = PRODGRP.GL_LEDGER -- -SS- ???? issue 22 -- -SS- @DR_INTFC_DW.LAX.TRANE.COM
AND PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE -- -SS- issues 55, 56
	-- -SS- ,ACTUATE_SEC_XREF ASX
INNER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT
ON CTYPES.CLAIM_TYPE_DESCR = RES_PCT.CLAIM_TYPE
AND ETS.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR
AND SOS.COMPANY_OWNED_IND  = RES_PCT.COMPANY_OWNED_IND
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
	-- -SS- /NEW
LEFT OUTER JOIN DM_FAL_CLAIMS_WARRANTY_XRF FCW
ON MLR.CLAIM_NBR   = FCW.CLAIM_NBR
AND MLR.DETAIL_NBR = FCW.DETAIL_NBR
AND MLR.STEP_NBR   = FCW.STEP_NBR
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR @DR_INTFC_DW.LAX.TRANE.COM
ON GLA.R12_ACCOUNT            = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND     = 'X'
WHERE MLR.CLAIM_TYPE_SCD_KEY <> 11
	-- -SS- AND GLA.COMPANY=ASX.PSGL(+)
AND(
	CASE
		WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1' THEN 'Y'
		ELSE 'N'
	END)                         = RES_PCT.CUST_CREDIT_CATG_CODE
AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
	-- -SS- AND GLA.ACCOUNT = PSA.ACCOUNT (+)
	-- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
AND TD3.FULL_DATE >= TO_DATE('1/1/2000', 'MM/DD/YYYY')
AND TD3.FULL_DATE <= TO_DATE('12/31/2008', 'MM/DD/YYYY')
	-- -SS- NEW
AND((GLA.PS_ACCOUNT = 'NA'
AND(AFU.LIKE_523500 = 'Y'
OR AFU.LIKE_526892  = 'Y'
OR AFU.LIKE_526893  = 'Y'
OR AFU.LIKE_528100  = 'Y'
OR AFU.LIKE_528200  = 'Y'
OR AFU.LIKE_528300  = 'Y'
OR AFU.LIKE_532100  = 'Y'))
OR(GLA.PS_ACCOUNT  <> 'NA'
AND GLA.PS_ACCOUNT IN('523500', '526892', '526893', '528100', '528200', '528300', '532100')))
	-- -SS- /NEW
	-- -SS- OLD: AND GLA.ACCOUNT IN( '523500', '526892', '526893', '528100', '528200', '528300', '532100')
GROUP BY GLA.R12_ENTITY, -- -SS- COMPANY
	GLA.R12_ACCOUNT,        -- -SS- ACCOUNT
	TD2.YEAR,
	(
	CASE
		WHEN FCW.WA_RANGE = '1' THEN '1st Year Standard Warranty'
		WHEN FCW.WA_RANGE = '2' THEN '2nd-5th Year Standard Warranty'
		WHEN FCW.WA_RANGE = '5' THEN '> 5th Year Standard Warranty'
		ELSE 'Out of Standard Warranty'
	END),
	MLR.TRX_CURRENCY,
	(
	CASE
		WHEN GLA.R12_ENTITY NOT IN('5773', '5588')
			-- -SS- ASX.NATION_CURR='USD'
		THEN 'USA'
		ELSE 'CAN'
			/* -SS-
			WHEN ASX.NATION_CURR='CAD' THEN 'CAN'
			ELSE 'CURRENCY: ' || ASX.NATION_CURR
			*/
	END),
	ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42),
	ROUND((TD.FULL_DATE  - TD2.FULL_DATE) / 30.42),
	(TD2.YEAR            * 100 + TD2.MONTH),
	TD2.MONTH,
	TD2.FULL_DATE,
	TD3.FULL_DATE,
	CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1,
	PSA.DESCR,
	CEIL(((TD3.TIME_KEY - TD2.TIME_KEY) / 30.42)) + 1,
	TO_CHAR(TD3.YEAR),
	TO_CHAR(TD3.MONTH)
ORDER BY GLA.R12_ACCOUNT, -- -SS- ACCOUNT
	TD2.YEAR,
	TD2.MONTH,
	ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) ;