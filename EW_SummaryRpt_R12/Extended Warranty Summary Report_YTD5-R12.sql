/* EXTENDED WARRANTY YTD QUERY FOR GENERAL LEDGER LONG TERM BALANCE   YTD 5*/
-- 425.689 sec USA/JAN-16 (0 rows)
-- 20.386 sec CAN/JAN-16 (0 rows)
SELECT
	/*+ NO_CPU_COSTING */
	TRUNC(TO_DATE(TO_DATE('1-' ||:RunDate, 'dd-mon-yy')), 'YEAR') - 1 AS gl_BeginDate,
	LAST_DAY(to_date('1-' ||:RunDate, 'dd-mon-yy')) gl_End_Date,
	begbalances.COUNTRY_INDICATOR AS COUNTRY_INDICATOR,
	CAST(begbalances.ACCOUNT AS NUMBER) ACCOUNT,
	NVL(begbalances.begbal_base, 0)          AS Begning_Balance,
	NVL(endingbalances.EndBal_base, 0) * - 1 AS END_Blance
FROM
	(
	/* Begning Balance */
	SELECT
		/*+ NO_CPU_COSTING */
		/*TAY:       Cross_Ref.PeopleSoft_ac AS ACCOUNT,*/
		PSA.R12_Account         AS ACCOUNT,
		gl_ledgers.ledger_id    AS ledger,
		gl_balances.period_name AS fiscal_year,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END                                                                                                            AS COUNTRY_INDICATOR,
		SUM(DECODE(gl_balances.period_name, :RunDate, gl_balances.BEGIN_BALANCE_DR - gl_balances.BEGIN_BALANCE_CR, 0)) AS begbal_base,
		psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'                    AS DESCR
		/*TAY:      FROM SY_120_GL_LEDGERS_EW gl_ledgers, SY_120_GL_BALANCES_EW gl_balances, SY_120_GL_CODE_COMBO_EW gl_code_combinations,*/
		/*TAY:           OTR_TRANE_ACCOUNTS_PS psa,*/
	FROM SY_120_GL_LEDGERS_EW gl_ledgers
	INNER JOIN SY_120_GL_BALANCES_EW gl_balances
	ON gl_balances.ledger_id = gl_ledgers.ledger_id
	INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
	ON gl_code_combinations.code_combination_id = gl_balances.code_combination_id
	RIGHT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
	ON gl_code_combinations.Segment4 = PSA.R12_Account
		/*TAY:           (SELECT a.BUSINESS_UNIT PS_BU, A.ORACLE_XREF_VALUE Oracle_BU
		FROM dbo.ps_trane_R12_xref a
		WHERE Recname_xref IN ('ENTITY')
		AND a.BUSINESS_UNIT in ('GS001','GS165')
		AND a.ps_attribute1 = ' '
		AND a.ps_attribute2 = ' '
		AND a.ps_attribute3 = ' '
		AND a.ps_attribute4 = ' '
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
		FROM dbo.ps_trane_R12_xref a
		WHERE Recname_xref IN ('ACCOUNT')
		AND a.ps_attribute1 in ('521000','521100')
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
		)Cross_Ref,
		(SELECT a.BUSINESS_UNIT PS_BU, A.PS_ATTRIBUTE2 PS_DEPT, A.ORACLE_XREF_VALUE Oracle_DEPT
		from ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a
		where Recname_xref in ('LOCATION')
		and ps_attribute2 like 'GL00%'
		AND a.BUSINESS_UNIT IN ('GS001','GS165')
		and a.effdt = (SELECT MAX(b.EFFDT)
		from ps_trane_r12_xref b --@DR_INTFC_DR.LAX.TRANE.COM b
		where b.recname_xref  = a.recname_xref
		and b.business_unit = a.business_unit
		and b.ps_attribute1 = a.ps_attribute1
		and b.ps_attribute2 = a.ps_attribute2
		and b.ps_attribute3 = a.ps_attribute3
		and b.ps_attribute4 = a.ps_attribute4)
		) DEPT*/
	WHERE gl_balances.period_name = :RunDate
	AND
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			ELSE 'CAN'
		END                      = UPPER(:COUNTRY)
	AND gl_ledgers.ledger_id IN(2022, 2041)
		/*TAY:        AND gl_balances.ledger_id = gl_ledgers.ledger_id
		AND gl_balances.code_combination_id=gl_code_combinations.code_combination_id
		AND Cross_Ref.Oracle_Acc = gl_code_combinations.segment4
		AND Cross_ref_BU.ORACLE_BU = gl_code_combinations.segment1
		and Cross_ref_BU.PS_BU = dept.PS_BU
		and dept.Oracle_DEPT = gl_code_combinations.segment2*/
		/*TAY:        AND Cross_Ref.PeopleSoft_ac (+)    = PSA.ACCOUNT WIP*/
		/*TAY: Need R12 filter WIP*/
		-- -SS- NEW
	AND GL_CODE_COMBINATIONS.SEGMENT1 IN('119007', '129004')
		-- -SS- /NEW
		-- -SS- AND GL_CODE_COMBINATIONS.Segment1 IN ('GS001','GS165')
		/*TAY: Need R12 filter WIP*/
	AND GL_CODE_COMBINATIONS.Segment2 LIKE 'GL00%'
	AND gl_code_combinations.Segment4 IN('281951', '296551')
		/*      GROUP BY Cross_Ref.PeopleSoft_ac, gl_ledgers.ledger_id, gl_balances.period_name,*/
	GROUP BY PSA.R12_Account,
		gl_ledgers.ledger_id,
		gl_balances.period_name,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END,
		psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
	) begbalances --,
RIGHT OUTER JOIN
	(
	/* ENDING BALANCE*/
	SELECT
		/*+ NO_CPU_COSTING */
		/*TAY:       Cross_Ref.PeopleSoft_ac AS ACCOUNT,*/
		PSA.R12_Account         AS ACCOUNT,
		gl_ledgers.ledger_id    AS ledger,
		gl_balances.period_name AS fiscal_year,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END                                                                                                                              AS COUNTRY_INDICATOR,
		NVL(SUM(gl_balances.begin_balance_dr + gl_balances.period_net_dr - gl_balances.begin_balance_cr - gl_balances.period_net_cr), 0) AS EndBal_base,
		psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'                                      AS DESCR
		/*TAY:      FROM SY_120_GL_LEDGERS_EW gl_ledgers, SY_120_GL_BALANCES_EW gl_balances, SY_120_GL_CODE_COMBO_EW gl_code_combinations,*/
		/*TAY:           OTR_TRANE_ACCOUNTS_PS psa,*/
	FROM SY_120_GL_LEDGERS_EW gl_ledgers
	INNER JOIN SY_120_GL_BALANCES_EW gl_balances
	ON gl_balances.ledger_id = gl_ledgers.ledger_id
	INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
	ON gl_code_combinations.code_combination_id = gl_balances.code_combination_id
	RIGHT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
	ON gl_code_combinations.Segment4 = PSA.R12_Account
		/*TAY:         (SELECT a.BUSINESS_UNIT PS_BU,
		A.ORACLE_XREF_VALUE Oracle_BU
		FROM dbo.ps_trane_R12_xref   a
		WHERE Recname_xref IN ('ENTITY')
		AND a.BUSINESS_UNIT in ('GS001','GS165')
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
		(SELECT A.ORACLE_XREF_VALUE Oracle_Acc,
		a.PS_ATTRIBUTE1 PeopleSoft_ac
		FROM dbo.ps_trane_R12_xref   a
		WHERE Recname_xref IN ('ACCOUNT')
		AND a.ps_attribute1 in ('521000','521100')
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
		(SELECT a.BUSINESS_UNIT PS_BU,
		A.PS_ATTRIBUTE2 PS_DEPT,
		A.ORACLE_XREF_VALUE Oracle_DEPT
		from ps_trane_r12_xref a --@DR_INTFC_DR.LAX.TRANE.COM a
		where Recname_xref in ('LOCATION')
		and ps_attribute2 like 'GL00%'
		AND a.BUSINESS_UNIT IN ('GS001','GS165')
		and a.effdt = (SELECT MAX(b.EFFDT)
		from ps_trane_r12_xref b--@DR_INTFC_DR.LAX.TRANE.COM b
		where b.recname_xref  = a.recname_xref
		and b.business_unit = a.business_unit
		and b.ps_attribute1 = a.ps_attribute1
		and b.ps_attribute2 = a.ps_attribute2
		and b.ps_attribute3 = a.ps_attribute3
		and b.ps_attribute4 = a.ps_attribute4
		)
		) DEPT */
	WHERE gl_balances.period_name = 'Jan' || SUBSTR(:RunDate, 4, 3)
	AND
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			ELSE 'CAN'
		END                        = UPPER(:COUNTRY)
	AND gl_ledgers.ledger_id   IN(2022, 2041)
	AND gl_balances.ACTUAL_FLAG = 'A'
		/*TAY:        AND gl_balances.ledger_id          = gl_ledgers.ledger_id
		AND gl_balances.code_combination_id= gl_code_combinations.code_combination_id
		AND Cross_Ref.Oracle_Acc           = gl_code_combinations.segment4
		AND Cross_ref_BU.ORACLE_BU     = gl_code_combinations.segment1
		and Cross_ref_BU.PS_BU  =  dept.PS_BU
		and dept.Oracle_DEPT = gl_code_combinations.segment2*/
		/*TAY:        AND Cross_Ref.PeopleSoft_ac(+) = PSA.ACCOUNT WIP*/
		/*TAY: Need R12 filter WIP*/
		-- -SS- NEW
	AND GL_CODE_COMBINATIONS.SEGMENT1 IN('119007', '129004')
		-- -SS- /NEW
		-- -SS- AND GL_CODE_COMBINATIONS.Segment1 IN ('GS001','GS165')
		/*TAY: Need R12 filter WIP*/
	AND GL_CODE_COMBINATIONS.Segment2 LIKE 'GL00%'
	AND gl_code_combinations.Segment4 IN('281951', '296551')
		/*TAY:      GROUP BY Cross_Ref.PeopleSoft_ac, gl_ledgers.ledger_id, gl_balances.period_name,*/
	GROUP BY PSA.R12_Account,
		gl_ledgers.ledger_id,
		gl_balances.period_name,
		CASE
			WHEN gl_ledgers.ledger_id = 2022 THEN 'USA'
			WHEN gl_ledgers.ledger_id = 2041 THEN 'CAN'
		END,
		psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
	) endingbalances ON begbalances.Account = endingbalances.Account
AND begbalances.Fiscal_year              = endingbalances.Fiscal_year
AND begbalances.ledger                   = endingbalances.Ledger
	/*TAY: WHERE begbalances.ACCOUNT   = endingbalances.ACCOUNT(+)
	AND begbalances.ledger      = endingbalances.ledger(+)*/
ORDER BY account