/* Comm detail Dollar Amt*/
-- 154.738 sec USA/JAN-16 (R12: 221.017)
-- 164.743 sec CAN/JAN-16 (R12: 234.327)
SELECT
	/*+ NO_CPU_COSTING */
	to_date('1-'||:RunDate, 'dd-mon-yy') AS gl_BeginDate,
	LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
	CASE
		WHEN a.COUNTRY_INDICATOR IS NULL THEN b.COUNTRY_INDICATOR
		ELSE a.COUNTRY_INDICATOR
	END AS COUNTRY_INDICATOR,
	CASE
		WHEN a.GL_ACCOUNT IS NULL THEN b.account
		ELSE a.GL_ACCOUNT
	END AS GL_ACCOUNT,
	NVL(a.DOLLAR_AMOUNT, 0) DOLLAR_AMOUNT,
	CASE
		WHEN B.GL_ACC_DESCR IS NULL THEN a.GL_ACC_DESCR
		ELSE B.GL_ACC_DESCR
	END                                   AS GL_ACC_DESCR,
	NVL(B.Amort_Comm_and_prepaid_comm, 0) AS Amort_Comm_and_prepaid_comm,
	NVL(C.SHORT_TERM_COMM, 0)             AS SHORT_TERM_COMM,
	NVL(C.LONG_TERM_COMM, 0)              AS LONG_TERM_COMM
FROM
	(SELECT
		/*+ NO_CPU_COSTING */
		TO_DATE('1-'||:RunDate, 'dd-mon-yy')           AS gl_BeginDate,
		LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) AS gl_End_Date,
		/*TAY:       CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR,*/
		CASE
			WHEN DIST.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END AS COUNTRY_INDICATOR,
		--TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
		/*TAY:       DIST.ACCOUNT AS GL_ACCOUNT, WIP*/
		DIST.PS_ACCOUNT AS GL_ACCOUNT,
		--DIST.JOURNAL_DATE AS JOURNAL_DATE ,
		SUM(
		CASE
			WHEN dist.debit_amt = 0 OR dist.debit_amt IS NULL OR dist.credit_amount <> '' THEN dist.credit_amount * - 1
			ELSE dist.debit_amt
		END)      AS DOLLAR_AMOUNT,
		psa.DESCR AS GL_ACC_DESCR,
		0         AS Amort_Comm_and_prepaid_comm,
		0         AS SHORT_TERM_COMM,
		0         AS LONG_TERM_COMM
		/*TAY:      FROM dbo.otr_trnco_cm_dist_psb dist, dbo.otr_TRANE_ACCOUNTS_ps psa, dbo.ACTUATE_SEC_XREF ASX*/
	FROM dbo.R12_TRNCO_CM_DIST_PSB Dist
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT /* R12_2_R12 */
		-- -SS- /NEW
	INNER JOIN dbo.R12_TRANE_ACCOUNTS_PS psa
	ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT /* R12_2_R12 */
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		--, dbo.ACTUATE_SEC_XREF ASX
		/*TAY:      WHERE DIST.ACCOUNT = PSA.ACCOUNT*/
	WHERE
		-- -SS- DIST.R12_ACCOUNT = PSA.R12_ACCOUNT
		-- -SS-  AND PSA.TRANE_ACCOUNT_IND = 'X'
		/*TAY:        AND DIST.BUSINESS_UNIT_GL = ASX.PSGL*/
		--AND DIST.BUSINESS_UNIT_GL = ASX.PSGL
		-- -SS- AND
		DIST.JOURNAL_DATE BETWEEN TO_DATE('1-'||:RunDate, 'dd-mon-yy')
	AND LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
		/*TAY:        AND DIST.ACCOUNT LIKE '5%' WIP*/
		-- -SS- NEW
	AND((DIST.PS_ACCOUNT = 'NA'
	AND AFU.LIKE_5       = 'Y')
	OR(DIST.PS_ACCOUNT  <> 'NA'
	AND DIST.PS_ACCOUNT LIKE '5%'))
		-- -SS- /NEW
		-- -SS- AND DIST.ACCOUNT LIKE '5%'
		/*TAY:        and CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)*/
	AND
		CASE
			WHEN DIST.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END = UPPER(:COUNTRY)
		/*TAY:        and ASX.NATION_CURR = 'USD' WIP*/
		-- Not sure this is correct way to implement
	AND DIST.r12_entity NOT IN(5773, 5588)
		/*TAY:        and (dist.deptid IS NULL OR (dist.deptid = 'SL00')) WIP*/
		-- -SS- NEW
	AND((DIST.PS_DEPTID    = 'NA'
	AND DIST.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
	OR(DIST.PS_DEPTID     <> 'NA'
	AND DIST.PS_DEPTID     = 'SL00'))
		-- -SS- /NEW
		-- -SS- and (dist.PS_deptid IS NULL OR (dist.PS_deptid = 'SL00'))
		/*TAY:      GROUP BY CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END, DIST.ACCOUNT, psa.DESCR*/
	GROUP BY
		CASE
			WHEN DIST.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END,
		DIST.PS_ACCOUNT,
		psa.DESCR
	UNION ALL
	SELECT
		/*+ NO_CPU_COSTING */
		TO_DATE('1-'||:RunDate, 'dd-mon-yy') AS gl_BeginDate,
		LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
		/*TAY:       CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR,*/
		CASE
			WHEN DIST.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END AS COUNTRY_INDICATOR,
		--TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
		/*TAY:       DIST.ACCOUNT AS GL_ACCOUNT, WIP*/
		DIST.PS_ACCOUNT AS GL_ACCOUNT,
		SUM(
		CASE
			WHEN dist.debit_amt = 0 OR dist.debit_amt IS NULL OR dist.credit_amount <> '' THEN dist.credit_amount * - 1
			ELSE dist.debit_amt
		END)      AS DOLLAR_AMOUNT,
		psa.DESCR AS GL_ACC_DESCR,
		0         AS Amort_Comm_and_prepaid_comm,
		0         AS SHORT_TERM_COMM,
		0         AS LONG_TERM_COMM
		/*TAY:      FROM dbo.otr_trnco_cm_dist_psb dist, dbo.otr_TRANE_ACCOUNTS_ps psa, dbo.ACTUATE_SEC_XREF ASX*/
	FROM dbo.R12_TRNCO_CM_DIST_PSB dist
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT /* R12_2_R12 */
		-- -SS- /NEW
	INNER JOIN dbo.R12_TRANE_ACCOUNTS_PS psa
	ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT /* R12_2_R12 */
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		--, dbo.ACTUATE_SEC_XREF ASX
		/*TAY:      WHERE DIST.ACCOUNT = PSA.ACCOUNT*/
	WHERE -- -SS- DIST.R12_ACCOUNT = PSA.R12_ACCOUNT
		-- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
		/*TAY:        AND DIST.BUSINESS_UNIT_GL= ASX.PSGL*/
		--AND DIST.BUSINESS_UNIT_GL= ASX.PSGL
		-- -SS- AND
		DIST.JOURNAL_DATE BETWEEN TO_DATE('1-'||:RunDate, 'dd-mon-yy')
	AND LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
		/*TAY:        AND DIST.ACCOUNT LIKE '5%' WIP*/
		-- -SS- NEW
	AND((DIST.PS_ACCOUNT = 'NA'
	AND AFU.LIKE_5       = 'Y')
	OR(DIST.PS_ACCOUNT  <> 'NA'
	AND DIST.PS_ACCOUNT LIKE '5%'))
		-- -SS- /NEW
		-- -SS- AND DIST.ACCOUNT LIKE '5%'
		/*TAY:        and  CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)*/
	AND
		CASE
			WHEN DIST.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END = UPPER(:COUNTRY)
		/*TAY:        and ASX.NATION_CURR = 'CAD' WIP*/
		-- Not sure that this is the right way to get the same effect
	AND DIST.r12_entity IN(5773, 5588)
		/*TAY:        and ( dist.deptid IS NULL OR (dist.deptid = 'TCA0') OR (dist.deptid = 'SL00') ) WIP*/
		-- -SS- NEW
	AND((DIST.PS_DEPTID    = 'NA'
	AND DIST.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
	OR(DIST.PS_DEPTID     <> 'NA'
	AND DIST.PS_DEPTID     = 'SL00'))
		-- -SS- /NEW
		-- -SS- and ( dist.PS_deptid IS NULL OR (dist.PS_deptid = 'TCA0') OR (dist.PS_deptid = 'SL00') )
		/*TAY:       GROUP BY CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END, DIST.ACCOUNT, psa.DESCR*/
	GROUP BY
		CASE
			WHEN DIST.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END,
		DIST.PS_ACCOUNT,
		psa.DESCR
	) a,
	(
	/* Amort_Comm_and_prepaid_comm (Month to date data)*/
	SELECT
		/*+ NO_CPU_COSTING */
		TO_DATE('1-'||:RunDate, 'dd-mon-yy') AS gl_BeginDate,
		LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
		B.country_indicator,
		B.gl_account                       AS account,
		0                                  AS DOLLAR_AMOUNT,
		B.GL_ACCOUNT_DESCR                 AS GL_ACC_DESCR,
		SUM(B.Amort_Comm_and_prepaid_comm) AS Amort_Comm_and_prepaid_comm
	FROM
		(SELECT a.country_indicator,
			a.gl_account,
			A.GL_ACCOUNT_DESCR,
			to_date('1-'||:RunDate, 'dd-mon-yy'),
			(MAX(a.Comm_amort_mnthly) +
			CASE
				WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate, 'dd-mon-yy') THEN MAX(a.PREPAID_COMMISSION)
				ELSE 0
			END) AS Amort_Comm_and_prepaid_comm,
			A.forecast_period
			/*TAY:             from DM_030_COMM_AMORTIZATION@DW_INTFC_DR.LAX.TRANE.COM a,OTR_TRANE_ACCOUNTS_PS psa*/
		FROM DW_DM_030_COMM_AMORTIZATION a
			-- -SS- NEW
		INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
		ON AFU.R12_ACCOUNT = A.GL_ACCOUNT -- -SS- GL_ACCOUNT is R12 /* R12_2_R12 */
			-- -SS- /NEW
		LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
		ON a.gl_account           = PSA.PS_ACCOUNT /* R12_2_R12 */ /*TAY: "a.gl_account" is linked to "R12_COLUMN" above*/
		AND PSA.TRANE_ACCOUNT_IND = 'X'
			/*TAY:            WHERE a.gl_account = PSA.ACCOUNT (+) WIP*/
		WHERE -- -SS- a.gl_account = PSA.PS_ACCOUNT (+)
			-- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
			-- -SS- and
			a.country_indicator = UPPER(:COUNTRY)
		AND a.RUN_PERIOD    >= TO_DATE('1-'||UPPER(:RunDate), 'dd-mon-yy')
		AND a.RUN_PERIOD     < LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
			/*TAY:               AND a.gl_account like '5%' WIP*/
			-- -SS- NEW
		AND AFU.LIKE_5 = 'Y' -- -SS- ???? issue 67
			-- -SS- /NEW
			-- -SS- AND a.gl_account like '5%'
		AND A.FORECAST_PERIOD >= TO_DATE('1-'||UPPER(:RunDate), 'dd-mon-yy')
		AND A.FORECAST_PERIOD  <(LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')))
		GROUP BY a.country_indicator,
			a.gl_account,
			A.GL_ACCOUNT_DESCR,
			A.forecast_period
		) B
	GROUP BY B.country_indicator,
		gL_ACCOUNT,
		B.GL_ACCOUNT_DESCR
	) B,
	(
	/* long_and_short_term (Year to date data)*/
	SELECT
		/*+ NO_CPU_COSTING */
		TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') - 1 AS gl_BeginDate,
		LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
		B.country_indicator,
		B.gl_account           AS account,
		0                      AS DOLLAR_AMOUNT,
		B.GL_ACCOUNT_DESCR     AS GL_ACC_DESCR,
		SUM(b.SHORT_TERM_COMM) AS SHORT_TERM_COMM,
		SUM(B.LONG_TERM_COMM)  AS LONG_TERM_COMM
	FROM
		(SELECT a.country_indicator,
			a.gl_account,
			A.GL_ACCOUNT_DESCR,
			to_date('1-'||:RunDate, 'dd-mon-yy'),
			MAX(a.short_term_pp_comm) AS SHORT_TERM_COMM,
			MAX(a.long_term_pp_comm)  AS LONG_TERM_COMM,
			A.forecast_period
			/*TAY:            from DM_030_COMM_AMORTIZATION@DW_INTFC_DR.LAX.TRANE.COM a,OTR_TRANE_ACCOUNTS_PS psa*/
		FROM DW_DM_030_COMM_AMORTIZATION a
			-- -SS- NEW
		INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
		ON AFU.R12_ACCOUNT = A.GL_ACCOUNT -- -SS- GL_ACCOUNT is R12 /* R12_2_R12 */
			-- -SS- /NEW
		LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
		ON a.gl_account           = PSA.PS_ACCOUNT /* R12_2_R12 */ /*TAY: "a.gl_account" is linked to "R12_ACCOUNT" above*/
		AND PSA.TRANE_ACCOUNT_IND = 'X'
			/*TAY:            where a.gl_account = PSA.ACCOUNT (+) WIP*/
		WHERE -- -SS- a.gl_account = PSA.PS_ACCOUNT (+)
			-- -SS- AND PSA.TRANE_ACCOUNT_IND='X'
			-- -SS- and
			a.country_indicator = UPPER(:COUNTRY)
		AND a.RUN_PERIOD    >= TO_DATE('1-'||UPPER(:RunDate), 'dd-mon-yy')
		AND a.RUN_PERIOD     < add_months(to_date('1-'||:RunDate, 'dd-mon-yy'), 1)
			/*TAY:              AND  a.gl_account like '5%' WIP*/
			-- -SS- NEW
		AND AFU.LIKE_5 = 'Y' -- -SS- ???? issue 67
			-- -SS- /NEW
			-- -SS- AND A.GL_ACCOUNT LIKE '5%'
		AND A.SHIP_PERIOD >=
			CASE
				WHEN to_date('1-'||:RunDate, 'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') THEN TRUNC(TRUNC(to_date('1-'||:RunDate, 'dd-mon-yy'), 'YEAR') - 1) - 30
				ELSE TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
			END
		AND A.SHIP_PERIOD <(TO_DATE('1-'||:RunDate, 'dd-mon-yy'))
		GROUP BY a.country_indicator,
			a.gl_account,
			A.GL_ACCOUNT_DESCR,
			A.forecast_period
		) B
	GROUP BY B.country_indicator,
		gL_ACCOUNT,
		B.GL_ACCOUNT_DESCR
	) C
WHERE a.GL_ACCOUNT (+)      = B.ACCOUNT
AND a.COUNTRY_INDICATOR (+) = B.COUNTRY_INDICATOR
AND B.ACCOUNT               = C.ACCOUNT (+)
AND B.COUNTRY_INDICATOR     = C.COUNTRY_INDICATOR (+)
UNION

/* Qry to fetch accounts wich does not exist in dbo.otr_trnco_cm_dist_psb dist table */
SELECT
	/*+ NO_CPU_COSTING */
	TO_DATE('1-'||:RunDate, 'dd-mon-yy') AS gl_BeginDate,
	LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
	'' AS COUNTRY_INDICATOR,
	/*TAY: PSA.ACCOUNT AS GL_ACCOUNT,*/
	PSA.PS_ACCOUNT AS GL_ACCOUNT,
	--DIST.JOURNAL_DATE AS JOURNAL_DATE ,
	0         AS DOLLAR_AMOUNT,
	psa.descr AS GL_ACC_DESCR,
	0         AS Amort_Comm_and_prepaid_comm,
	0         AS SHORT_TERM_COMM,
	0         AS LONG_TERM_COMM
	/*TAY:FROM dbo.otr_TRANE_ACCOUNTS_ps psa*/
FROM dbo.R12_TRANE_ACCOUNTS_PS psa
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = PSA.R12_ACCOUNT /* R12_2_R12 */
	-- -SS- /NEW
WHERE PSA.TRANE_ACCOUNT_IND = 'X'
	/*TAY:  AND PSA.ACCOUNT LIKE '5%' WIP*/
	-- -SS- NEW
AND((PSA.PS_ACCOUNT = 'NA'
AND AFU.LIKE_5      = 'Y')
OR(PSA.PS_ACCOUNT  <> 'NA'
AND PSA.PS_ACCOUNT LIKE '5%'))
	-- -SS- /NEW
	-- -SS- AND PSA.ACCOUNT LIKE '5%'
AND NOT EXISTS
	(SELECT 'X'
		/*TAY:                  FROM dbo.otr_trnco_cm_dist_psb dist, dbo.ACTUATE_SEC_XREF ASX*/
	FROM dbo.R12_TRNCO_CM_DIST_PSB dist --, dbo.ACTUATE_SEC_XREF ASX
		/*TAY:                  WHERE DIST.ACCOUNT = PSA.ACCOUNT WIP*/
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT /* R12_2_R12 */
		-- -SS- /NEW
	WHERE DIST.R12_ACCOUNT = PSA.R12_ACCOUNT /* R12_2_R12 */
		/*TAY:                    AND DIST.BUSINESS_UNIT_GL= ASX.PSGL*/
		--AND DIST.BUSINESS_UNIT_GL= ASX.PSGL
	AND DIST.JOURNAL_DATE BETWEEN TO_DATE('1-'||:RunDate, 'dd-mon-yy')
	AND LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
		/*TAY:                    AND DIST.ACCOUNT LIKE '5%' WIP*/
		-- -SS- NEW
	AND((DIST.PS_ACCOUNT = 'NA'
	AND AFU.LIKE_5       = 'Y')
	OR(DIST.PS_ACCOUNT  <> 'NA'
	AND DIST.PS_ACCOUNT LIKE '5%'))
		-- -SS- /NEW
		-- -SS- AND DIST.ACCOUNT LIKE '5%'
		/*TAY                    and CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY))*/
	AND
		CASE
			WHEN DIST.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END = UPPER(:COUNTRY)
	)
AND NOT EXISTS
	(SELECT 'x'
		/*TAY:                  FROM DM_030_COMM_AMORTIZATION@DW_INTFC_DR.LAX.TRANE.COM a*/
	FROM DW_DM_030_COMM_AMORTIZATION a
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = A.GL_ACCOUNT -- -SS- GL_ACCOUNT is R12 /* R12_2_R12 */
		-- -SS- /NEW
	WHERE a.RUN_PERIOD >= TO_DATE('1-'||UPPER(:RunDate), 'dd-mon-yy')
	AND a.RUN_PERIOD    < add_months(to_date('1-'||:RunDate, 'dd-mon-yy'), 1)
		/*TAY:             AND  a.gl_account= PSA.ACCOUNT WIP*/
	AND a.gl_account   = PSA.PS_ACCOUNT /* R12_2_R12 */ /*TAY: "a.gl_account" is linked to "R12_ACCOUNT" column above*/
	AND A.SHIP_PERIOD >=
		CASE
			WHEN TO_DATE('1-'||:RunDate, 'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') THEN TRUNC(TRUNC(TO_DATE('1-'||:RunDate, 'dd-mon-yy'), 'YEAR') - 1) - 30
			ELSE TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
		END
	AND A.SHIP_PERIOD       <(to_date('1-'||:RunDate, 'dd-mon-yy'))
	AND a.country_indicator = UPPER(:COUNTRY)
		/*TAY:             AND  a.gl_account like '5%' WIP*/
		-- -SS- NEW
	AND AFU.LIKE_5 = 'Y' -- -SS- ???? issue 67
		-- -SS- /NEW
		-- -SS- AND A.GL_ACCOUNT LIKE '5%'
	) ;