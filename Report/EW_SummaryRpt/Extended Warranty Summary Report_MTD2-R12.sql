/* EXTENDED WARRANTY MTD QUERY  MTD2*/
--  418.805 sec USA/JAN-16 (0 rows)
--  23.205 sec CAN/JAN-16 (0 rows)
SELECT
  /*+ FIRST_ROWS */
  ADD_MONTHS((LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))), - 1) AS gl_BeginDate, LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date, begbalances.COUNTRY_INDICATOR AS COUNTRY_INDICATOR, CAST(begbalances.ACCOUNT AS NUMBER) ACCOUNT, NVL(begbalances.begbal_base, 0) AS Begning_Balance, NVL(endingbalances.EndBal_base, 0) AS END_Blance
FROM
  (
  /* Begning Balance DRTRNP */
  SELECT
    /*+ NO_CPU_COSTING */
    /*TAY:       Cross_Ref.PeopleSoft_ac AS ACCOUNT,*/
    -- -SS- issue 88: PSA.R12_Account AS ACCOUNT, 
		AFU.R12_ACCOUNT AS ACCOUNT, -- -SS- issue 88
		gl_ledgers.ledger_id AS ledger, gl_balances.period_name AS fiscal_year,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END AS COUNTRY_INDICATOR, SUM(DECODE(gl_balances.period_name, :RunDate, gl_balances.BEGIN_BALANCE_DR - gl_balances.BEGIN_BALANCE_CR, 0)) AS begbal_base, 
		-- -SS- issue 88: psa.DESCR 
		AFU.DESCR -- -SS- issue 88
		|| ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')' AS DESCR
    /*TAY:      FROM SY_120_GL_LEDGERS_EW gl_ledgers, SY_120_GL_BALANCES_EW gl_balances, SY_120_GL_CODE_COMBO_EW gl_code_combinations,*/
  FROM SY_120_GL_LEDGERS_EW gl_ledgers
  INNER JOIN SY_120_GL_BALANCES_EW gl_balances
  ON gl_balances.ledger_id = gl_ledgers.ledger_id
  INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
  ON gl_code_combinations.code_combination_id = gl_balances.code_combination_id
    -- -SS- NEW
  RIGHT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU
  ON AFU.R12_ACCOUNT = GL_CODE_COMBINATIONS.SEGMENT4 -- -SS- GL_ACCOUNT will be R12
    -- -SS- /NEW
    /*TAY:           OTR_TRANE_ACCOUNTS_PS psa,*/
  -- -SS- issue 88: RIGHT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA ON gl_code_combinations.Segment4 = PSA.R12_Account -- R12_2_R12
    /*,
    (SELECT a.BUSINESS_UNIT PS_BU ,
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
    AND a.ps_attribute1 = '490650'
    AND a.effdt         =
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
    (SELECT a.BUSINESS_UNIT PS_BU,
    A.PS_ATTRIBUTE2 PS_DEPT,
    A.ORACLE_XREF_VALUE  Oracle_DEPT
    from ps_trane_r12_xref a --@DR_INTFC_DR.LAX.TRANE.COM a
    where Recname_xref in ('LOCATION')
    and ps_attribute2 like 'GL00%'
    AND a.BUSINESS_UNIT in ('GS001','GS165')
    and a.effdt = (SELECT MAX(b.EFFDT)
    from ps_trane_r12_xref b--@DR_INTFC_DR.LAX.TRANE.COM b
    where b.recname_xref  = a.recname_xref
    and b.business_unit = a.business_unit
    and b.ps_attribute1 = a.ps_attribute1
    and b.ps_attribute2 = a.ps_attribute2
    and b.ps_attribute3 = a.ps_attribute3
    and b.ps_attribute4 = a.ps_attribute4
    ) --Dept
    ) DEPT*/
  WHERE gl_balances.period_name = :RunDate
  AND gl_ledgers.ledger_id IN(2022, 2041)
  AND
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      ELSE 'CAN'
    END = UPPER(:COUNTRY)
  AND gl_balances.ACTUAL_FLAG = 'A'
    /*TAY:        AND gl_balances.ledger_id             = gl_ledgers.ledger_id
    AND gl_balances.code_combination_id   =gl_code_combinations.code_combination_id*/
    /*TAY:        AND Cross_Ref.Oracle_Acc              = gl_code_combinations.segment4
    AND Cross_ref_BU.ORACLE_BU            = gl_code_combinations.segment1
    and Cross_ref_BU.PS_BU                =  dept.PS_BU
    and dept.Oracle_DEPT                  = gl_code_combinations.segment2
    AND Cross_Ref.PeopleSoft_ac (+)       = PSA.ACCOUNT*/
  -- -SS- issue 88: AND PSA.TRANE_ACCOUNT_IND = 'X'
  AND AFU.EQUAL_490650 = 'Y' -- -SS- issue 88
    /*TAY: Need R12 filter WIP*/
    -- -SS- NEW
  AND GL_CODE_COMBINATIONS.SEGMENT1 IN('119007', '129004')
    -- -SS- /NEW
    -- -SS- AND GL_CODE_COMBINATIONS.Segment1 IN ('GS001','GS165')
    /*TAY: Need R12 filter WIP*/
  AND GL_CODE_COMBINATIONS.Segment2 LIKE 'GL00%' -- -SS- location
  AND gl_code_combinations.Segment4 = '195462' -- -SS- this is R12 (= 490650 PS)
    /*TAY:      GROUP BY Cross_Ref.PeopleSoft_ac, gl_ledgers.ledger_id, gl_balances.period_name, psa.DESCR,*/
  GROUP BY 
    -- -SS- issue 88: PSA.R12_Account,
    AFU.R12_ACCOUNT, -- -SS- issue 88 
    gl_ledgers.ledger_id, gl_balances.period_name, 
		-- -SS- issue 88: psa.DESCR,
		AFU.DESCR, -- -SS- issue 88
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END, 
		-- -SS- issue 88: psa.DESCR 
		AFU.DESCR -- -SS- issue 88
		|| ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
    /*TAY:  ) begbalances,*/
  ) begbalances
RIGHT OUTER JOIN
  (
  /* Ending Balance DRTRNP */
  SELECT
    /*+ NO_CPU_COSTING */
    /*TAY:    Cross_Ref.PeopleSoft_ac AS ACCOUNT,*/
    -- -SS- issue 88: PSA.R12_Account AS ACCOUNT, 
    AFU.R12_ACCOUNT AS ACCOUNT,
    gl_ledgers.ledger_id AS ledger, gl_balances.period_name AS fiscal_year,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END AS COUNTRY_INDICATOR, NVL(SUM(gl_balances.begin_balance_dr + gl_balances.period_net_dr - gl_balances.begin_balance_cr - gl_balances.period_net_cr), 0) AS EndBal_base, 
    -- -SS- issue 88: psa.DESCR
    AFU.DESCR -- -SS- issue 88 
    || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')' AS DESCR
    /*TAY:   FROM SY_120_GL_LEDGERS_EW gl_ledgers, SY_120_GL_BALANCES_EW gl_balances, SY_120_GL_CODE_COMBO_EW gl_code_combinations,*/
  FROM SY_120_GL_LEDGERS_EW gl_ledgers
  INNER JOIN SY_120_GL_BALANCES_EW gl_balances
  ON gl_balances.ledger_id = gl_ledgers.ledger_id
  INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
  ON gl_code_combinations.code_combination_id = gl_balances.code_combination_id
  -- -SS- issue 88: RIGHT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA ON gl_code_combinations.Segment4 = PSA.R12_Account -- R12_2_R12
    -- -SS- NEW issue 88
  RIGHT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU
  ON AFU.R12_ACCOUNT = GL_CODE_COMBINATIONS.SEGMENT4 -- -SS- GL_ACCOUNT will be R12
    -- -SS- /NEW
    /*TAY:           OTR_TRANE_ACCOUNTS_PS psa,*/
    /*TAY:        (SELECT a.BUSINESS_UNIT PS_BU ,
    A.ORACLE_XREF_VALUE Oracle_BU
    FROM dbo.ps_trane_R12_xref   a
    WHERE Recname_xref IN ('ENTITY')
    AND a.BUSINESS_UNIT in ('GS001','GS165')
    AND a.ps_attribute1 = ' '
    AND a.ps_attribute2 = ' '
    AND a.ps_attribute3 = ' '
    AND a.ps_attribute4 = ' '
    AND a.effdt         =
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
    (SELECT   A.ORACLE_XREF_VALUE Oracle_Acc,
    a.PS_ATTRIBUTE1 PeopleSoft_ac
    FROM dbo.ps_trane_R12_xref   a
    WHERE Recname_xref IN ('ACCOUNT')
    AND a.ps_attribute1 = '490650'
    AND a.effdt         =
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
    (SELECT a.BUSINESS_UNIT  PS_BU    , A.PS_ATTRIBUTE2 PS_DEPT,A.ORACLE_XREF_VALUE  Oracle_DEPT
    from ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a
    where Recname_xref in ('LOCATION')
    and ps_attribute2 like 'GL00%'
    AND a.BUSINESS_UNIT in ('GS001','GS165')
    and a.effdt = (SELECT MAX(b.EFFDT)
    from ps_trane_r12_xref b--@DR_INTFC_DR.LAX.TRANE.COM b
    where b.recname_xref  = a.recname_xref
    and b.business_unit = a.business_unit
    and b.ps_attribute1 = a.ps_attribute1
    and b.ps_attribute2 = a.ps_attribute2
    and b.ps_attribute3 = a.ps_attribute3
    and b.ps_attribute4 = a.ps_attribute4
    ) --Dept
    ) DEPT*/
  WHERE gl_balances.period_name = :RunDate
  AND
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      ELSE 'CAN'
    END = UPPER(:COUNTRY)
  AND gl_ledgers.ledger_id IN(2022, 2041)
  AND gl_balances.ACTUAL_FLAG = 'A'
    /*TAY:    AND gl_balances.ledger_id          = gl_ledgers.ledger_id
    AND gl_balances.code_combination_id=gl_code_combinations.code_combination_id
    AND Cross_Ref.Oracle_Acc    = gl_code_combinations.segment4
    AND Cross_ref_BU.ORACLE_BU     = gl_code_combinations.segment1
    and Cross_ref_BU.PS_BU  =  dept.PS_BU
    and dept.Oracle_DEPT = gl_code_combinations.segment2*/
    /*TAY:     AND Cross_Ref.PeopleSoft_ac(+) = PSA.ACCOUNT WIP*/
    /*TAY:     AND Cross_Ref.PeopleSoft_ac(+) = PSA.PS_ACCOUNT*/
  -- -SS- issue 88: AND PSA.TRANE_ACCOUNT_IND = 'X'
    -- -SS- NEW issue 88
  AND AFU.EQUAL_490650 = 'Y'
    -- -SS- /NEW
    /*TAY: Need R12 filter WIP*/
    -- -SS- NEW
  AND GL_CODE_COMBINATIONS.SEGMENT1 IN('119007', '129004')
    -- -SS- /NEW
    -- -SS- AND gl_code_combinations.Segment1 IN ('GS001', 'GS165')
    /*TAY: Need R12 filter WIP*/
  AND gl_code_combinations.Segment2 LIKE('GL00%') -- -SS- ????
  AND gl_code_combinations.Segment4 = '195462' -- -SS- this is R12 (= 490650 PS)
    /*TAY:   GROUP BY Cross_Ref.PeopleSoft_ac, gl_ledgers.ledger_id, gl_balances.period_name,*/
  GROUP BY 
  -- -SS- issue 88: PSA.R12_Account,
  AFU.R12_ACCOUNT, 
  gl_ledgers.ledger_id, gl_balances.period_name,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END, 
    -- -SS- issue 88: psa.DESCR
    AFU.DESCR -- -SS- issue 88 
    || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
  ) endingbalances ON begbalances.Account = endingbalances.Account
AND begbalances.Fiscal_year = endingbalances.Fiscal_year
AND begbalances.ledger = endingbalances.Ledger
  /*WHERE begbalances.ACCOUNT   = endingbalances.ACCOUNT(+)
  AND begbalances.fiscal_year = endingbalances.fiscal_year(+)
  AND begbalances.ledger      = endingbalances.ledger(+)*/
GROUP BY CAST(begbalances.ACCOUNT AS NUMBER), begbalances.COUNTRY_INDICATOR, begbalances.begbal_base, endingbalances.EndBal_base
