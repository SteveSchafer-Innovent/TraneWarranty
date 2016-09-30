/* EXTENDED WARRANTY DEFERRED REVENUE SUMMARY-YTD QUERY YTD1*/
-- 1392.464 sec USA/JAN-16
-- 1961.811 sec USA/JUN-16
-- 87.839 sec USA/JUN-16 (R12: 236.972)
-- 40.009 sec CAN/JAN-16
SELECT
	/*+ NO_CPU_COSTING */
	TRUNC(TO_DATE(TO_DATE('1-' ||:RunDate, 'dd-mon-yy')), 'YEAR') - 1 AS gl_BeginDate,
	LAST_DAY(to_date('1-' ||:RunDate, 'dd-mon-yy')) gl_End_Date,
	CASE
		WHEN sales.COUNTRY_INDICATOR IS NULL THEN begbalances.COUNTRY_INDICATOR
		ELSE sales.COUNTRY_INDICATOR
	END AS COUNTRY_INDICATOR,
	CAST(begbalances.ACCOUNT AS NUMBER) ACCOUNT,
	CASE
		WHEN sales.DESCR IS NULL THEN begbalances.DESCR
		ELSE sales.DESCR
	END                                     AS GL_ACC_DESCR,
	(NVL(begbalances.begbal_base, 0)) * - 1 AS Begning_Balance,
	(NVL(perioddata.EndBal_base, 0))  * - 1 AS END_Blance,
	CASE
		WHEN sales.REVENUE_AMOUNT IS NULL THEN 0
		ELSE sales.REVENUE_AMOUNT
	END                          AS REVENUE_AMOUNT,
	NVL(rev.DEFERRED_REVENUE, 0) AS DEFERRED_REVENUE,
	NVL(rev.SHORT_TERM_BALA, 0)  AS SHORT_TERM_BALA,
	NVL(rev.LONG_TERM_BALA, 0)   AS LONG_TERM_BALA
FROM
	(SELECT
		/*+ NO_CPU_COSTING */
		/*TAY:       Cross_Ref.PeopleSoft_ac AS ACCOUNT,*/
		PSA.R12_ACCOUNT         AS ACCOUNT,
		gl_ledgers.ledger_id    AS ledger,
		gl_balances.period_name AS fiscal_year,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END                                                                                                                                   AS COUNTRY_INDICATOR,
		SUM(DECODE(gl_balances.period_name, 'Jan' || SUBSTR(:RunDate, 4, 3), gl_balances.BEGIN_BALANCE_DR - gl_balances.BEGIN_BALANCE_CR, 0)) AS begbal_base,
		psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'                                           AS DESCR
		/*TAY:      FROM SY_120_GL_LEDGERS_EW gl_ledgers, SY_120_GL_BALANCES_EW gl_balances, SY_120_GL_CODE_COMBO_EW gl_code_combinations,*/
		/*TAY:           OTR_TRANE_ACCOUNTS_PS psa,*/
	FROM SY_120_GL_LEDGERS_EW gl_ledgers
	INNER JOIN SY_120_GL_BALANCES_EW gl_balances
	ON gl_ledgers.ledger_id = gl_balances.ledger_id
	INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
	ON gl_code_combinations.code_combination_id = gl_balances.code_combination_id
	RIGHT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
	ON gl_code_combinations.segment4 = psa.r12_account /* R12_2_R12 */
		/*TAY:           (SELECT a.BUSINESS_UNIT PS_BU, A.ORACLE_XREF_VALUE Oracle_BU
		FROM dbo.ps_trane_R12_xref  a
		WHERE Recname_xref IN ('ENTITY')
		AND a.BUSINESS_UNIT IN ('CAN','CSD')
		AND a.effdt =
		(SELECT MAX(b.EFFDT)
		FROM dbo.ps_trane_R12_xref b
		WHERE b.recname_xref = a.recname_xref
		AND b.business_unit  = a.business_unit
		AND b.ps_attribute1  = a.ps_attribute1
		AND b.ps_attribute2  = a.ps_attribute2
		AND b.ps_attribute3  = a.ps_attribute3
		AND b.ps_attribute4  = a.ps_attribute4
		)
		) Cross_ref_BU,
		(SELECT A.ORACLE_XREF_VALUE Oracle_Acc, a.PS_ATTRIBUTE1 PeopleSoft_ac
		FROM dbo.ps_trane_R12_xref   a
		WHERE Recname_xref IN ('ACCOUNT')
		AND a.ps_attribute1 like '5%'
		AND a.effdt =
		(SELECT MAX(b.EFFDT)
		FROM dbo.ps_trane_R12_xref b
		WHERE b.recname_xref = a.recname_xref
		AND b.business_unit  = a.business_unit
		AND b.ps_attribute1  = a.ps_attribute1
		AND b.ps_attribute2  = a.ps_attribute2
		AND b.ps_attribute3  = a.ps_attribute3
		AND b.ps_attribute4  = a.ps_attribute4
		)
		) Cross_Ref ,
		(SELECT a.BUSINESS_UNIT PS_BU, A.PS_ATTRIBUTE2 PS_DEPT, A.ORACLE_XREF_VALUE Oracle_DEPT
		from ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a
		where Recname_xref in ('LOCATION')
		and ps_attribute2 like 'SL00%'
		and a.effdt =
		(SELECT MAX(b.EFFDT)
		from ps_trane_r12_xref b--@DR_INTFC_DR.LAX.TRANE.COM b
		where b.recname_xref  = a.recname_xref
		and b.business_unit = a.business_unit
		and b.ps_attribute1 = a.ps_attribute1
		and b.ps_attribute2 = a.ps_attribute2
		and b.ps_attribute3 = a.ps_attribute3
		and b.ps_attribute4 = a.ps_attribute4
		) --Dept
		) DEPT */
	WHERE gl_balances.period_name = 'Jan' || SUBSTR(:RunDate, 4, 3)
	AND
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			ELSE 'CAN'
		END                        = UPPER(:COUNTRY)
	AND gl_ledgers.ledger_id   IN(2022, 2041)
	AND GL_BALANCES.ACTUAL_FLAG = 'A'
		/*TAY:        AND gl_balances.ledger_id          = gl_ledgers.ledger_id
		AND gl_balances.code_combination_id=gl_code_combinations.code_combination_id
		AND Cross_Ref.Oracle_Acc    = gl_code_combinations.segment4
		AND Cross_ref_BU.ORACLE_BU         = gl_code_combinations.segment1
		and Cross_ref_BU.PS_BU  =  dept.PS_BU
		and dept.Oracle_DEPT = gl_code_combinations.segment2*/
		/*TAY:        AND Cross_Ref.PeopleSoft_ac (+)    = PSA.ACCOUNT*/
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		/*TAY:      GROUP BY Cross_Ref.PeopleSoft_ac, gl_ledgers.ledger_id, gl_balances.period_name ,*/
	GROUP BY PSA.R12_ACCOUNT,
		gl_ledgers.ledger_id,
		gl_balances.period_name,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END,
		psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
		/*TAY:     ) begbalances,*/
	) begbalances
LEFT OUTER JOIN
	(SELECT
		/*+ NO_CPU_COSTING */
		/*TAY:       Cross_Ref.PeopleSoft_ac AS ACCOUNT,*/
		PSA.R12_ACCOUNT         AS ACCOUNT,
		gl_ledgers.ledger_id    AS ledger,
		gl_balances.period_name AS fiscal_year,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END                                                                                                                              AS COUNTRY_INDICATOR,
		NVL(SUM(gl_balances.begin_balance_dr + gl_balances.period_net_dr - gl_balances.begin_balance_cr - gl_balances.period_net_cr), 0) AS EndBal_base,
		psa.DESCR ||' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'                                       AS DESCR
		/*TAY:      FROM SY_120_GL_LEDGERS_EW gl_ledgers, SY_120_GL_BALANCES_EW gl_balances, SY_120_GL_CODE_COMBO_EW gl_code_combinations,*/
		/*TAY:           OTR_TRANE_ACCOUNTS_PS psa,*/
	FROM SY_120_GL_LEDGERS_EW gl_ledgers
	INNER JOIN SY_120_GL_BALANCES_EW gl_balances
	ON gl_balances.ledger_id = gl_ledgers.ledger_id
	INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
	ON gl_balances.code_combination_id = gl_code_combinations.code_combination_id
	RIGHT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
	ON gl_code_combinations.segment4 = psa.r12_account /* R12_2_R12 */
		/*TAY:           (SELECT a.BUSINESS_UNIT PS_BU, A.ORACLE_XREF_VALUE Oracle_BU
		FROM dbo.ps_trane_R12_xref   a
		WHERE Recname_xref IN ('ENTITY')
		AND a.BUSINESS_UNIT IN ('CAN','CSD')
		AND a.ps_attribute1 = ' '
		AND a.ps_attribute2 = ' '
		AND a.ps_attribute3 = ' '
		AND a.ps_attribute4 = ' '
		AND a.effdt =
		(SELECT MAX(b.EFFDT)
		FROM dbo.ps_trane_R12_xref   b
		WHERE b.recname_xref = a.recname_xref
		AND b.business_unit  = a.business_unit
		AND b.ps_attribute1  = a.ps_attribute1
		AND b.ps_attribute2  = a.ps_attribute2
		AND b.ps_attribute3  = a.ps_attribute3
		AND b.ps_attribute4  = a.ps_attribute4
		)
		) Cross_ref_BU,
		(SELECT   A.ORACLE_XREF_VALUE Oracle_Acc, a.PS_ATTRIBUTE1 PeopleSoft_ac
		FROM dbo.ps_trane_R12_xref   a
		WHERE Recname_xref IN ('ACCOUNT')
		AND a.ps_attribute1 like '5%'
		AND a.effdt =
		(SELECT MAX(b.EFFDT)
		FROM dbo.ps_trane_R12_xref   b
		WHERE b.recname_xref = a.recname_xref
		AND b.business_unit  = a.business_unit
		AND b.ps_attribute1  = a.ps_attribute1
		AND b.ps_attribute2  = a.ps_attribute2
		AND b.ps_attribute3  = a.ps_attribute3
		AND b.ps_attribute4  = a.ps_attribute4
		)
		) Cross_Ref ,
		(SELECT a.BUSINESS_UNIT PS_BU, A.PS_ATTRIBUTE2 PS_DEPT, A.ORACLE_XREF_VALUE Oracle_DEPT
		from ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a
		where Recname_xref in ('LOCATION')
		and ps_attribute2 like 'SL00%'
		AND a.BUSINESS_UNIT IN ('CAN','CSD')
		and a.effdt = (SELECT MAX(b.EFFDT)
		from ps_trane_r12_xref b --@DR_INTFC_DR.LAX.TRANE.COM b
		where b.recname_xref  = a.recname_xref
		and b.business_unit = a.business_unit
		and b.ps_attribute1 = a.ps_attribute1
		and b.ps_attribute2 = a.ps_attribute2
		and b.ps_attribute3 = a.ps_attribute3
		and b.ps_attribute4 = a.ps_attribute4)
		) DEPT */
	WHERE gl_balances.period_name = :RunDate
	AND
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			ELSE 'CAN'
		END                        = UPPER(:COUNTRY)
	AND gl_ledgers.ledger_id   IN(2022, 2041)
	AND GL_BALANCES.ACTUAL_FLAG = 'A'
		/*TAY:        AND gl_balances.ledger_id          = gl_ledgers.ledger_id
		AND gl_balances.code_combination_id=gl_code_combinations.code_combination_id
		AND Cross_Ref.Oracle_Acc    = gl_code_combinations.segment4
		AND Cross_ref_BU.ORACLE_BU         = gl_code_combinations.segment1
		and Cross_ref_BU.PS_BU  =  dept.PS_BU
		and dept.Oracle_DEPT = gl_code_combinations.segment2*/
		/*TAY:        AND Cross_Ref.PeopleSoft_ac(+)     = PSA.ACCOUNT WIP*/
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		/*TAY:      GROUP BY Cross_Ref.PeopleSoft_ac, gl_ledgers.ledger_id, gl_balances.period_name,*/
	GROUP BY PSA.R12_ACCOUNT,
		gl_ledgers.ledger_id,
		gl_balances.period_name,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END,
		psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
		/*TAY:     ) perioddata,*/
	) perioddata ON begbalances.ACCOUNT = perioddata.ACCOUNT
AND begbalances.fiscal_year          = perioddata.fiscal_year
AND begbalances.ledger               = perioddata.ledger
LEFT OUTER JOIN
	(SELECT
		/*TAY:      CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR,*/
		CASE
			WHEN A.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END AS COUNTRY_INDICATOR,
		/*TAY:       A.ACCOUNT, PSA.DESCR, SUM(A.MONETARY_AMOUNT *-1 ) AS REVENUE_AMOUNT WIP*/
		A.R12_ACCOUNT Account,
		PSA.DESCR,
		SUM(A.MONETARY_AMOUNT * - 1) AS REVENUE_AMOUNT
		/*TAY:      FROM OTR_BI_ACCT_ENTRY_PSB A, OTR_TRNBI_BI_HDR_PSB B, OTR_BI_HDR_PSB C, OTR_TRANE_ACCOUNTS_PS psa, ACTUATE_SEC_XREF ASX*/
	FROM R12_BI_ACCT_ENTRY_PSB A
	INNER JOIN R12_TRNBI_BI_HDR_PSB B
	ON A.BUSINESS_UNIT = B.BUSINESS_UNIT
	AND A.INVOICE      = B.INVOICE
	INNER JOIN R12_BI_HDR_PSB C
	ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
	AND B.INVOICE      = C.INVOICE
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = A.R12_ACCOUNT /* R12_2_R12 */
		-- -SS- /NEW
	INNER JOIN R12_TRANE_ACCOUNTS_PS psa
	ON A.R12_ACCOUNT      = PSA.R12_ACCOUNT /* R12_2_R12 */
	WHERE A.JOURNAL_DATE >= TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
	AND A.JOURNAL_DATE   <= LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
		/*TAY:        AND A.BUSINESS_UNIT_GL IN ('CAN' ,'CSD') WIP*/
	AND A.R12_ENTITY IN ('5773', '5588')
	-- -SS- AND A.PS_BUSINESS_UNIT_GL IN('CAN', 'CSD')
		/*TAY:        AND CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)*/
	AND
		CASE
			WHEN A.r12_entity IN(5773, 5588) THEN 'CAN'
			ELSE 'USA'
		END = UPPER(:COUNTRY)
		/*TAY:        AND A.BUSINESS_UNIT_GL   = ASX.PSGL(+)*/
		--AND A.BUSINESS_UNIT_GL   = ASX.PSGL(+)
		/*TAY:        AND a.ACCOUNT            = PSA.ACCOUNT (+)*/
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		/*TAY:        AND A.BUSINESS_UNIT      = B.BUSINESS_UNIT
		AND A.INVOICE            = B.INVOICE
		AND B.BUSINESS_UNIT      = C.BUSINESS_UNIT
		AND B.INVOICE            = C.INVOICE*/
	AND C.ENTRY_TYPE = 'IN'
		/*TAY:        AND A.ACCOUNT LIKE '5%' WIP*/
		-- -SS- NEW
	AND((A.PS_ACCOUNT = 'NA'
	AND AFU.LIKE_5    = 'Y')
	OR(A.PS_ACCOUNT  <> 'NA'
	AND A.PS_ACCOUNT LIKE '5%'))
		-- -SS- /NEW
		-- -SS- AND A.ACCOUNT LIKE '5%'
		/*TAY:      GROUP BY ASX.NATION_CURR, A.ACCOUNT, PSA.DESCR*/
	GROUP BY A.R12_ACCOUNT,
		A.r12_entity,
		A.PS_ACCOUNT,
		PSA.DESCR
		/*TAY:     ) sales,*/
	) sales ON begbalances.ACCOUNT = sales.ACCOUNT
LEFT OUTER JOIN
	(SELECT B.gl_account       AS account,
		B.GL_ACCOUNT_DESCR        AS DESCRIPTION,
		SUM(B.DEFERRED_REVENUE)   AS DEFERRED_REVENUE,
		SUM(B.SHORT_TERM_REVENUE) AS SHORT_TERM_BALA,
		SUM(LONG_TERM_REVENUE)    AS LONG_TERM_BALA
	FROM
		(SELECT a.gl_account,
			A.GL_ACCOUNT_DESCR,
			to_date('1-'||:RunDate, 'dd-mon-yy'),
			CASE
				WHEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') = To_date('1-'||:RunDate, 'dd-mon-yy') THEN
					CASE
						WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate, 'dd-mon-yy') THEN MAX(A.DEFERRED_REVENUE)
						ELSE 0
					END
				ELSE(MAX(a.rec_rev_mnthly) +
					CASE
						WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate, 'dd-mon-yy') THEN MAX(A.DEFERRED_REVENUE)
						ELSE 0
					END)
			END                  AS DEFERRED_REVENUE,
			MAX(a.SHORT_TERM_DR) AS SHORT_TERM_REVENUE,
			MAX(a.LONG_TERM_DR)  AS LONG_TERM_REVENUE,
			A.FORECAST_PERIOD
			/*TAY:            FROM DBO.DM_030_REV_RELEASE@DW_INTFC_DR.LAX.TRANE.COM a, OTR_TRANE_ACCOUNTS_PS psa*/
		FROM DW_DM_030_REV_RELEASE a
			-- -SS- NEW
		INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
		ON AFU.R12_ACCOUNT = A.GL_ACCOUNT -- -SS- GL_ACCOUNT is R12 /* R12_2_R12 */
			-- -SS- /NEW
		LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
		ON a.gl_account = PSA.R12_ACCOUNT /* R12_2_R12 */
			/*TAY:            WHERE a.gl_account       = PSA.ACCOUNT (+) WIP*/
			/*TAY:              AND PSA.TRANE_ACCOUNT_IND = 'X'*/
		WHERE PSA.TRANE_ACCOUNT_IND = 'X'
		AND a.country_indicator     = UPPER(:COUNTRY)
		AND a.RUN_PERIOD           >= TO_DATE('1-'||:RunDate, 'dd-mon-yy')
		AND a.RUN_PERIOD            < add_months(to_date('1-'||:RunDate, 'dd-mon-yy'), 1)
			/*TAY:              AND a.gl_account LIKE '5%'*/
			-- -SS- NEW
		AND((PSA.PS_ACCOUNT = 'NA'
		AND AFU.LIKE_5      = 'Y')
		OR(PSA.PS_ACCOUNT  <> 'NA'
		AND PSA.PS_ACCOUNT LIKE '5%'))
			-- -SS- /NEW
			-- -SS- AND PSA.ACCOUNT LIKE '5%'
		AND A.SHIP_PERIOD >=
			CASE
				WHEN to_date('1-'||:RunDate, 'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') THEN TRUNC(TRUNC(to_date('1-'||:RunDate, 'dd-mon-yy'), 'YEAR') - 1) - 30
				ELSE TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
			END
		AND A.SHIP_PERIOD <(to_date('1-'||:RunDate, 'dd-mon-yy'))
		GROUP BY a.gl_account,
			A.GL_ACCOUNT_DESCR,
			A.FORECAST_PERIOD
		) B
	GROUP BY B.GL_ACCOUNT,
		B.GL_ACCOUNT_DESCR
	) Rev ON begbalances.ACCOUNT = Rev.account
/*TAY: WHERE begbalances.ACCOUNT   =sales.ACCOUNT(+)
AND begbalances.ACCOUNT     =Rev.account(+)
AND begbalances.ACCOUNT     = perioddata.ACCOUNT(+)
AND begbalances.ledger      = perioddata.ledger(+)*/
UNION

/* Qry to fetch accounts which does not exist in the main query */
SELECT
	/*+ NO_CPU_COSTING */
	ADD_MONTHS(((LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')))), - 1) AS gl_BeginDate,
	LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
	'' AS COUNTRY_INDICATOR,
	/*TAY: CAST (PSA.ACCOUNT AS NUMBER )AS ACCOUNT,*/
	CAST(PSA.PS_ACCOUNT AS NUMBER) AS ACCOUNT,
	psa.DESCR                      AS GL_ACC_DESCR,
	0                              AS Begning_Balance,
	0                              AS END_Blance,
	0                              AS REVENUE_AMOUNT,
	0                              AS DEFERRED_REVENUE,
	0                              AS SHORT_TERM_BALA,
	0                              AS LONG_TERM_BALA
	/*TAY:FROM dbo.otr_TRANE_ACCOUNTS_ps psa*/
FROM dbo.R12_TRANE_ACCOUNTS_PS psa
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = PSA.R12_ACCOUNT /* R12_2_R12 */
	-- -SS- /NEW
WHERE PSA.TRANE_ACCOUNT_IND = 'X'
	/*TAY:  AND PSA.ACCOUNT LIKE '5%'*/
	-- -SS- NEW
AND((PSA.PS_ACCOUNT = 'NA'
AND AFU.LIKE_5      = 'Y')
OR(PSA.PS_ACCOUNT  <> 'NA'
AND PSA.PS_ACCOUNT LIKE '5%'))
	-- -SS- /NEW
	-- -SS- AND PSA.ACCOUNT LIKE '5%'
AND NOT EXISTS
	(SELECT 'x'
		/*TAY:                  FROM SY_120_GL_LEDGERS_EW gl_ledgers, SY_120_GL_BALANCES_EW gl_balances, SY_120_GL_CODE_COMBO_EW gl_code_combinations,*/
	FROM SY_120_GL_LEDGERS_EW gl_ledgers
	INNER JOIN SY_120_GL_BALANCES_EW gl_balances
	ON gl_balances.ledger_id = gl_ledgers.ledger_id
	INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
	ON gl_balances.code_combination_id = gl_code_combinations.code_combination_id
		/*TAY:                       (SELECT a.BUSINESS_UNIT PS_BU, A.ORACLE_XREF_VALUE Oracle_BU
		FROM dbo.ps_trane_R12_xref   a
		WHERE Recname_xref IN ('ENTITY')
		AND a.BUSINESS_UNIT IN ('CAN','CSD')
		AND a.effdt =
		(SELECT MAX(b.EFFDT)
		FROM dbo.ps_trane_R12_xref   b
		WHERE b.recname_xref = a.recname_xref
		AND b.business_unit  = a.business_unit
		AND b.ps_attribute1  = a.ps_attribute1
		AND b.ps_attribute2  = a.ps_attribute2
		AND b.ps_attribute3  = a.ps_attribute3
		AND b.ps_attribute4  = a.ps_attribute4
		)
		) Cross_ref_BU,
		(SELECT A.ORACLE_XREF_VALUE Oracle_Acc, a.PS_ATTRIBUTE1 PeopleSoft_ac
		FROM dbo.ps_trane_R12_xref   a
		WHERE Recname_xref IN ('ACCOUNT')
		AND a.ps_attribute1 like '5%'
		AND a.effdt =
		(SELECT MAX(b.EFFDT)
		FROM dbo.ps_trane_R12_xref   b
		WHERE b.recname_xref = a.recname_xref
		AND b.business_unit  = a.business_unit
		AND b.ps_attribute1  = a.ps_attribute1
		AND b.ps_attribute2  = a.ps_attribute2
		AND b.ps_attribute3  = a.ps_attribute3
		AND b.ps_attribute4  = a.ps_attribute4
		)
		) Cross_Ref,
		(SELECT a.BUSINESS_UNIT PS_BU, A.PS_ATTRIBUTE2 PS_DEPT, A.ORACLE_XREF_VALUE Oracle_DEPT
		from ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a
		where Recname_xref in ('LOCATION')
		and ps_attribute2 like 'SL00%'
		AND a.BUSINESS_UNIT IN ('CAN','CSD')
		and a.effdt = (SELECT MAX(b.EFFDT)
		from ps_trane_r12_xref b --@DR_INTFC_DR.LAX.TRANE.COM b
		where b.recname_xref  = a.recname_xref
		and b.business_unit = a.business_unit
		and b.ps_attribute1 = a.ps_attribute1
		and b.ps_attribute2 = a.ps_attribute2
		and b.ps_attribute3 = a.ps_attribute3
		and b.ps_attribute4 = a.ps_attribute4) --Dept
		) DEPT */
	WHERE gl_balances.period_name = :RunDate
	AND
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			ELSE 'CAN'
		END                        = UPPER(:COUNTRY)
	AND gl_ledgers.ledger_id   IN(2022, 2041)
	AND GL_BALANCES.ACTUAL_FLAG = 'A'
		/*TAY:                    and gl_balances.ledger_id= gl_ledgers.ledger_id
		and gl_balances.code_combination_id=gl_code_combinations.code_combination_id
		and Cross_Ref.Oracle_Acc= gl_code_combinations.segment4
		and Cross_ref_BU.ORACLE_BU = gl_code_combinations.segment1
		and Cross_ref_BU.PS_BU  =  dept.PS_BU
		and dept.Oracle_DEPT = gl_code_combinations.segment2
		AND Cross_Ref.PeopleSoft_ac  = PSA.ACCOUNT*/
	AND PSA.TRANE_ACCOUNT_IND = 'X'
	AND GL_CODE_COMBINATIONS.SEGMENT2 LIKE 'SL00%'
	AND GL_CODE_COMBINATIONS.SEGMENT1 IN('5773', '5588')
	AND GL_CODE_COMBINATIONS.SEGMENT4  = PSA.R12_ACCOUNT -- join with outer query /* R12_2_R12 */
		/*TAY:                  GROUP BY Cross_Ref.PeopleSoft_ac, psa.DESCR, gl_balances.period_name, gl_ledgers.ledger_id ,*/
	GROUP BY PSA.R12_ACCOUNT,
		psa.DESCR,
		gl_balances.period_name,
		gl_ledgers.ledger_id,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END
	) ;