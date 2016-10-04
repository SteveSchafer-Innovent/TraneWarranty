/*VARIABLE COUNTRY CHAR;
VARIABLE RunDate CHAR;
EXEC :COUNTRY := 'CAN';
EXEC :RunDate := 'JUN-16';*/
-- 917.049 sec USA/JUN-16 (R12: 33.708)
-- 81.769 sec CAN/JAN-16 (R12: 34.376)
/* EXTENDED WARRANTY DEFERRED REVENUE SUMMARY-MTD QUERY MTD1*/
SELECT
  /*+ NO_CPU_COSTING */
  ADD_MONTHS(((LAST_DAY(to_date('1-' ||:RunDate, 'dd-mon-yy')))), - 1) AS gl_BeginDate, (LAST_DAY(to_date('1-' ||:RunDate, 'dd-mon-yy'))) gl_End_Date,
  CASE
    WHEN sales.COUNTRY_INDICATOR IS NULL
    THEN begbalances.COUNTRY_INDICATOR
    ELSE sales.COUNTRY_INDICATOR
  END AS COUNTRY_INDICATOR, CAST(begbalances.ACCOUNT AS NUMBER) ACCOUNT,
  CASE
    WHEN sales.DESCR IS NULL
    THEN begbalances.DESCR
    ELSE sales.DESCR
  END AS GL_ACC_DESCR, SUM(NVL(begbalances.begbal_base, 0)) * - 1 AS Begning_Balance, SUM(NVL(perioddata.EndBal_base, 0)) * - 1 AS END_Blance,
  CASE
    WHEN sales.REVENUE_AMOUNT IS NULL
    THEN 0
    ELSE sales.REVENUE_AMOUNT
  END AS REVENUE_AMOUNT, NVL(deff.DEFERRED_REVENUE, 0) AS DEFERRED_REVENUE, NVL(rev.SHORT_TERM_BALA, 0) AS SHORT_TERM_BALA, NVL(rev.LONG_TERM_BALA, 0) AS LONG_TERM_BALA
FROM
  (
  /* Begning Balance DRTRNP */
  SELECT
    /*+ NO_CPU_COSTING */
    PSA.R12_ACCOUNT AS ACCOUNT,                                             -- -SS- Cross_Ref.PeopleSoft_ac AS ACCOUNT,
    gl_ledgers.ledger_id AS ledger, gl_balances.period_name AS fiscal_year, --    gl_je_headers.period_name    AS fiscal_year,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END AS COUNTRY_INDICATOR, SUM(DECODE(gl_balances.period_name, :RunDate, gl_balances.BEGIN_BALANCE_DR - gl_balances.BEGIN_BALANCE_CR, 0)) AS begbal_base, psa.DESCR || ' - (R12 A/C : ' || gl_code_combinations.segment4 || '-' ||gl_ledgers.name || ')' AS DESCR
    -- -SS- convert to ANSI joins
  FROM SY_120_GL_LEDGERS_EW gl_ledgers
  INNER JOIN SY_120_GL_BALANCES_EW gl_balances
  ON gl_ledgers.ledger_id = gl_balances.ledger_id
  INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
  ON gl_code_combinations.code_combination_id = gl_balances.code_combination_id
    /*TAY:   OTR_TRANE_ACCOUNTS_PS psa,*/
  RIGHT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
  ON GL_CODE_COMBINATIONS.SEGMENT4 = PSA.R12_ACCOUNT -- (+) -SS- R12_2_R12
    /* -SS- ,
    (SELECT a.BUSINESS_UNIT PS_BU,
    A.ORACLE_XREF_VALUE Oracle_BU
    FROM dbo.ps_trane_R12_xref a
    WHERE Recname_xref  IN('ENTITY')
    AND a.BUSINESS_UNIT IN('CAN', 'CSD')
    AND a.effdt          =
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
    (SELECT A.ORACLE_XREF_VALUE Oracle_Acc,
    a.PS_ATTRIBUTE1 PeopleSoft_ac
    FROM dbo.ps_trane_R12_xref a
    WHERE Recname_xref IN('ACCOUNT')
    AND a.ps_attribute1 LIKE '5%'
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
    ) Cross_Ref,
    (SELECT a.BUSINESS_UNIT PS_BU,
    A.PS_ATTRIBUTE2 PS_DEPT,
    A.ORACLE_XREF_VALUE Oracle_DEPT
    FROM ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a
    WHERE Recname_xref IN('LOCATION')
    AND ps_attribute2 LIKE 'SL00%'
    AND a.BUSINESS_UNIT IN('CAN', 'CSD')
    AND a.effdt          =
    (SELECT MAX(b.EFFDT)
    FROM ps_trane_r12_xref b--@DR_INTFC_DR.LAX.TRANE.COM b
    WHERE b.recname_xref = a.recname_xref
    AND b.business_unit  = a.business_unit
    AND b.ps_attribute1  = a.ps_attribute1
    AND b.ps_attribute2  = a.ps_attribute2
    AND b.ps_attribute3  = a.ps_attribute3
    AND b.ps_attribute4  = a.ps_attribute4
    )
    ) DEPT */
  WHERE gl_balances.period_name = :RunDate
  AND
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      ELSE 'CAN'
    END = UPPER(:COUNTRY)
  AND gl_ledgers.ledger_id IN(2022, 2041)
  AND GL_BALANCES.ACTUAL_FLAG = 'A'
    -- -SS- NEW
  AND GL_CODE_COMBINATIONS.SEGMENT2 IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')
    -- -SS- /NEW
    -- -SS- AND GL_CODE_COMBINATIONS.SEGMENT2 LIKE 'SL00%'
  AND GL_CODE_COMBINATIONS.SEGMENT1 IN('5773', '5588') -- -SS- SEGMENT1 = R12 ENTITY
    -- -SS- AND Cross_Ref.Oracle_Acc            = gl_code_combinations.segment4
    -- -SS- Cross_ref_BU and DEPT joins exist in order to filter by BU in ('CAN','CSD') and DEPT like 'SL00%'
    -- -SS- AND Cross_ref_BU.ORACLE_BU          = gl_code_combinations.segment1
    -- -SS- AND Cross_ref_BU.PS_BU              = dept.PS_BU
    -- -SS- AND dept.Oracle_DEPT                = gl_code_combinations.segment2
    -- AND Cross_Ref.PeopleSoft_ac (+) = PSA.PS_ACCOUNT
  AND PSA.TRANE_ACCOUNT_IND = 'X'
  GROUP BY PSA.R12_ACCOUNT, -- -SS- Cross_Ref.PeopleSoft_ac,
    gl_ledgers.ledger_id, gl_balances.period_name,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END, psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
  ) begbalances
LEFT OUTER JOIN
  (
  /* Ending Balance DRTRNP */
  SELECT
    /*+ NO_CPU_COSTING */
    PSA.R12_ACCOUNT AS ACCOUNT, -- -SS- Cross_Ref.PeopleSoft_ac AS ACCOUNT,
    gl_ledgers.ledger_id AS ledger, gl_balances.period_name AS fiscal_year,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END AS COUNTRY_INDICATOR, NVL(SUM(gl_balances.begin_balance_dr + gl_balances.period_net_dr - gl_balances.begin_balance_cr - gl_balances.period_net_cr), 0) AS EndBal_base, psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')' AS DESCR
  FROM SY_120_GL_LEDGERS_EW gl_ledgers
  INNER JOIN SY_120_GL_BALANCES_EW gl_balances
  ON gl_balances.ledger_id = gl_ledgers.ledger_id
  INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
  ON gl_balances.code_combination_id = gl_code_combinations.code_combination_id
    /*TAY:   OTR_TRANE_ACCOUNTS_PS psa,*/
  RIGHT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
  ON GL_CODE_COMBINATIONS.SEGMENT4 = PSA.R12_ACCOUNT -- (+) -SS- R12_2_R12
    /* -SS-
    (SELECT a.BUSINESS_UNIT PS_BU,
    A.ORACLE_XREF_VALUE Oracle_BU
    FROM dbo.ps_trane_R12_xref a
    WHERE Recname_xref  IN('ENTITY')
    AND a.BUSINESS_UNIT IN('CAN', 'CSD')
    AND a.ps_attribute1  = ' '
    AND a.ps_attribute2  = ' '
    AND a.ps_attribute3  = ' '
    AND a.ps_attribute4  = ' '
    AND a.effdt          =
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
    (SELECT A.ORACLE_XREF_VALUE Oracle_Acc,
    a.PS_ATTRIBUTE1 PeopleSoft_ac
    FROM dbo.ps_trane_R12_xref a
    WHERE Recname_xref IN('ACCOUNT')
    AND a.ps_attribute1 LIKE '5%'
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
    ) Cross_Ref,
    (SELECT a.BUSINESS_UNIT PS_BU,
    A.PS_ATTRIBUTE2 PS_DEPT,
    A.ORACLE_XREF_VALUE Oracle_DEPT
    FROM ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a
    WHERE Recname_xref IN('LOCATION')
    AND ps_attribute2 LIKE 'SL00%'
    AND a.BUSINESS_UNIT IN('CAN', 'CSD')
    AND a.effdt          =
    (SELECT MAX(b.EFFDT)
    FROM ps_trane_r12_xref b --@DR_INTFC_DR.LAX.TRANE.COM b
    WHERE b.recname_xref = a.recname_xref
    AND b.business_unit  = a.business_unit
    AND b.ps_attribute1  = a.ps_attribute1
    AND b.ps_attribute2  = a.ps_attribute2
    AND b.ps_attribute3  = a.ps_attribute3
    AND b.ps_attribute4  = a.ps_attribute4
    )
    ) DEPT
    */
  WHERE gl_balances.period_name = :RunDate
  AND
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      ELSE 'CAN'
    END = UPPER(:COUNTRY)
  AND gl_ledgers.ledger_id IN(2022, 2041)
  AND GL_BALANCES.ACTUAL_FLAG = 'A'
    -- -SS- NEW
  AND GL_CODE_COMBINATIONS.SEGMENT2 IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')
    -- -SS- /NEW
    -- -SS- AND GL_CODE_COMBINATIONS.SEGMENT2 LIKE 'SL00%'
  AND GL_CODE_COMBINATIONS.SEGMENT1 IN('5773', '5588') -- -SS- SEGMENT1 = R12 ENTITY = CANADA
    -- -SS- AND Cross_Ref.Oracle_Acc            = gl_code_combinations.segment4
    -- -SS- Cross_ref_BU and DEPT joins exist in order to filter by BU in ('CAN','CSD') and DEPT like 'SL00%'
    -- -SS- AND Cross_ref_BU.ORACLE_BU          = gl_code_combinations.segment1
    -- -SS- AND Cross_ref_BU.PS_BU              = dept.PS_BU
    -- -SS- AND dept.Oracle_DEPT                = gl_code_combinations.segment2
    -- AND Cross_Ref.PeopleSoft_ac (+) = PSA.PS_ACCOUNT
  AND PSA.TRANE_ACCOUNT_IND = 'X'
  GROUP BY PSA.R12_ACCOUNT, -- -SS- Cross_Ref.PeopleSoft_ac,
    gl_ledgers.ledger_id, gl_balances.period_name, gl_balances.period_name,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END, psa.DESCR || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
  ) perioddata ON begbalances.ACCOUNT = perioddata.ACCOUNT -- -SS- (+)
AND begbalances.fiscal_year = perioddata.fiscal_year       -- -SS- (+)
AND begbalances.ledger = perioddata.ledger                 -- -SS- (+)
LEFT OUTER JOIN
  (
  /* Sales Data DRTRNP */
  SELECT
    /*+ NO_CPU_COSTING */
    /*TAY:   CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR,*/
    CASE
      WHEN A.r12_entity IN(5773, 5588)
      THEN 'CAN'
      ELSE 'USA'
    END AS COUNTRY_INDICATOR, A.R12_ACCOUNT AS Account, -- -SS- A.PS_ACCOUNT
    PSA.DESCR, SUM(A.MONETARY_AMOUNT * - 1) AS REVENUE_AMOUNT
    /*TAY:  FROM OTR_BI_ACCT_ENTRY_PSB A, OTR_TRNBI_BI_HDR_PSB B, OTR_BI_HDR_PSB C, OTR_TRANE_ACCOUNTS_PS psa, ACTUATE_SEC_XREF ASX*/
  FROM R12_BI_ACCT_ENTRY_PSB A
  INNER JOIN R12_TRNBI_BI_HDR_PSB B
  ON A.BUSINESS_UNIT = B.BUSINESS_UNIT
  AND A.INVOICE = B.INVOICE
  INNER JOIN R12_BI_HDR_PSB C
  ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
  AND B.INVOICE = C.INVOICE
  INNER JOIN R12_TRANE_ACCOUNTS_PS psa
  ON A.R12_ACCOUNT = PSA.R12_ACCOUNT --, ACTUATE_SEC_XREF ASX R12_2_R12
    -- -SS- NEW
  INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
  ON AFU.R12_ACCOUNT = A.R12_ACCOUNT -- R12_2_R12
    -- -SS- /NEW
  WHERE A.JOURNAL_DATE >=(to_date('1-' ||:RunDate, 'dd-mon-yy'))
  AND A.JOURNAL_DATE <=(LAST_DAY(to_date('1-' ||:RunDate, 'dd-mon-yy')))
    /*TAY:    AND A.BUSINESS_UNIT_GL IN ('CAN', 'CSD')*/
  AND A.R12_ENTITY IN ('5773', '5588')
    -- -SS- AND A.PS_BUSINESS_UNIT_GL IN('CAN', 'CSD')
    /*TAY:       AND CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)*/
  AND
    CASE
      WHEN A.r12_entity IN(5773, 5588)
      THEN 'CAN'
      ELSE 'USA'
    END = UPPER(:COUNTRY)
    /*TAY:    AND A.BUSINESS_UNIT_GL   = ASX.PSGL(+)*/
    --AND A.BUSINESS_UNIT_GL   = ASX.PSGL(+)
    /*TAY:    AND a.ACCOUNT            = PSA.ACCOUNT (+)*/
    -- -SS- AND A.PS_ACCOUNT          = PSA.PS_ACCOUNT (+)
  AND PSA.TRANE_ACCOUNT_IND = 'X'
    -- -SS- AND A.BUSINESS_UNIT       = B.BUSINESS_UNIT
    -- -SS- AND A.INVOICE             = B.INVOICE
    /*TAY:    AND B.BUSINESS_UNIT      = C.BUSINESS_UNIT*/
    -- -SS- AND B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
    -- -SS- AND B.INVOICE       = C.INVOICE
  AND C.ENTRY_TYPE = 'IN'
    -- -SS- NEW
  AND((A.PS_ACCOUNT = 'NA'
  AND AFU.LIKE_5 = 'Y')
  OR(A.PS_ACCOUNT <> 'NA'
  AND A.PS_ACCOUNT LIKE '5%'))
    -- -SS- /NEW
    -- -SS- AND A.ACCOUNT LIKE '5%'
    /*TAY:  GROUP BY ASX.NATION_CURR, A.ACCOUNT, PSA.DESCR*/
  GROUP BY A.r12_entity, A.R12_ACCOUNT, -- -SS- A.PS_ACCOUNT,
    PSA.DESCR
  ) sales ON begbalances.ACCOUNT = sales.ACCOUNT -- -SS- (+)
LEFT OUTER JOIN
  (
  /*SHORT_TERM,LONG_TERM DWTRNP */
  SELECT
    /*+ NO_CPU_COSTING */
    B.gl_account AS account, B.GL_ACCOUNT_DESCR AS DESCRIPTION, SUM(B.SHORT_TERM_REVENUE) AS SHORT_TERM_BALA, SUM(LONG_TERM_REVENUE) AS LONG_TERM_BALA
  FROM
    (SELECT a.gl_account, A.GL_ACCOUNT_DESCR, to_date('1-' ||:RunDate, 'dd-mon-yy'), MAX(a.SHORT_TERM_DR) AS SHORT_TERM_REVENUE, MAX(a.LONG_TERM_DR) AS LONG_TERM_REVENUE, A.FORECAST_PERIOD
      /*TAY:        FROM DBO.DM_030_REV_RELEASE@DW_INTFC_DR.LAX.TRANE.COM a, OTR_TRANE_ACCOUNTS_PS psa*/
    FROM DW_DM_030_REV_RELEASE a
      -- -SS- NEW
    INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
    ON AFU.R12_ACCOUNT = A.GL_ACCOUNT -- -SS- GL_ACCOUNT will be R12
      -- -SS- /NEW
    LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
    ON a.gl_account = PSA.R12_ACCOUNT -- -SS- GL_ACCOUNT will be R12, R12_2_R12
    WHERE
      -- -SS- a.gl_account        = PSA.PS_ACCOUNT (+) AND
      PSA.TRANE_ACCOUNT_IND = 'X'
    AND a.country_indicator = UPPER(:COUNTRY)
    AND a.RUN_PERIOD >= TO_DATE('1-'||:RunDate, 'dd-mon-yy')
    AND a.RUN_PERIOD < add_months(to_date('1-'||:RunDate, 'dd-mon-yy'), 1)
      -- -SS- NEW
    AND AFU.LIKE_5 = 'Y' -- -SS- ???? issue 67
      -- -SS- /NEW
      -- -SS- AND A.ACCOUNT LIKE '5%'
    AND A.FORECAST_PERIOD >=
      CASE
        WHEN to_date('1-' ||:RunDate, 'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
        THEN TRUNC(TRUNC(to_date('1-'||:RunDate, 'dd-mon-yy'), 'YEAR') - 1) - 30
        ELSE TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
      END
    AND A.FORECAST_PERIOD <(to_date('1-'||:RunDate, 'dd-mon-yy'))
    GROUP BY a.gl_account, A.GL_ACCOUNT_DESCR, A.FORECAST_PERIOD
    ) B
  GROUP BY B.GL_ACCOUNT, B.GL_ACCOUNT_DESCR
  ) Rev ON begbalances.ACCOUNT = Rev.account -- -SS- (+)
LEFT OUTER JOIN
  (
  /* DEFERRED*/
  SELECT
    /*+ NO_CPU_COSTING */
    B.gl_account AS account, B.GL_ACCOUNT_DESCR AS DESCRIPTION, SUM(B.DEFERRED_REVENUE) AS DEFERRED_REVENUE
  FROM
    (SELECT a.gl_account, A.GL_ACCOUNT_DESCR, to_date('1-'||:RunDate, 'dd-mon-yy'), (MAX(a.rec_rev_mnthly) +
      CASE
        WHEN A.FORECAST_PERIOD = to_date('1-' ||:RunDate, 'dd-mon-yy')
        THEN MAX(A.DEFERRED_REVENUE)
        ELSE 0
      END) AS DEFERRED_REVENUE, A.FORECAST_PERIOD
      /*TAY:        FROM DBO.DM_030_REV_RELEASE@DW_INTFC_DR.LAX.TRANE.COM a, OTR_TRANE_ACCOUNTS_PS psa*/
    FROM DW_DM_030_REV_RELEASE a
      -- -SS- NEW
    INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
    ON AFU.R12_ACCOUNT = A.GL_ACCOUNT -- -SS- GL_ACCOUNT will be R12
      -- -SS- /NEW
    LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS psa
    ON a.gl_account = PSA.R12_ACCOUNT -- -SS- GL_ACCOUNT will be R12, R12_2_R12
    WHERE
      -- -SS- a.gl_account        = PSA.PS_ACCOUNT (+) AND
      PSA.TRANE_ACCOUNT_IND = 'X'
    AND a.country_indicator = UPPER(:COUNTRY)
    AND a.RUN_PERIOD >= TO_DATE('1-'||:RunDate, 'dd-mon-yy')
    AND a.RUN_PERIOD < LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
      -- -SS- NEW
    AND AFU.LIKE_5 = 'Y' -- -SS- issue 67
      -- -SS- /NEW
      -- -SS- AND a.gl_account LIKE '5%'
    AND A.FORECAST_PERIOD >= TO_DATE('1-'||UPPER(:RunDate), 'dd-mon-yy')
    AND A.FORECAST_PERIOD < LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
    GROUP BY a.gl_account, A.GL_ACCOUNT_DESCR, A.FORECAST_PERIOD
    ) B
  GROUP BY B.gL_ACCOUNT, B.GL_ACCOUNT_DESCR
  ) deff ON rev.ACCOUNT = deff.ACCOUNT -- (+)
AND rev.DESCRIPTION = deff.DESCRIPTION -- (+)
GROUP BY CAST(begbalances.ACCOUNT AS NUMBER),
  CASE
    WHEN sales.COUNTRY_INDICATOR IS NULL
    THEN begbalances.COUNTRY_INDICATOR
    ELSE sales.COUNTRY_INDICATOR
  END,
  CASE
    WHEN sales.DESCR IS NULL
    THEN begbalances.DESCR
    ELSE sales.DESCR
  END, begbalances.begbal_base,
  CASE
    WHEN sales.REVENUE_AMOUNT IS NULL
    THEN 0
    ELSE sales.REVENUE_AMOUNT
  END, deff.DEFERRED_REVENUE, Rev.SHORT_TERM_BALA, Rev.LONG_TERM_BALA
UNION

/* Qry to fetch accounts which does not exist in the main query */
SELECT
  /*+ NO_CPU_COSTING */
  ADD_MONTHS(((LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')))), - 1) AS gl_BeginDate, LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date, '' AS COUNTRY_INDICATOR, CAST(PSA.R12_ACCOUNT AS NUMBER) AS ACCOUNT, psa.DESCR AS GL_ACC_DESCR, 0 AS Begning_Balance, 0 AS END_Blance, 0 AS REVENUE_AMOUNT, 0 AS DEFERRED_REVENUE, 0 AS SHORT_TERM_BALA, 0 AS LONG_TERM_BALA
  /*TAY:FROM dbo.otr_TRANE_ACCOUNTS_ps psa*/
FROM dbo.R12_TRANE_ACCOUNTS_PS psa
  -- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = PSA.R12_ACCOUNT -- R12_2_R12
  -- -SS- /NEW
WHERE PSA.TRANE_ACCOUNT_IND = 'X'
  -- -SS- NEW
AND((PSA.PS_ACCOUNT = 'NA'
AND AFU.LIKE_5 = 'Y')
OR(PSA.PS_ACCOUNT <> 'NA'
AND PSA.PS_ACCOUNT LIKE '5%'))
  -- -SS- /NEW
  -- -SS- AND PSA.ACCOUNT LIKE '5%'
AND NOT EXISTS
  (SELECT 'x'
  FROM SY_120_GL_LEDGERS_EW gl_ledgers
  INNER JOIN SY_120_GL_BALANCES_EW gl_balances
  ON gl_balances.ledger_id = gl_ledgers.ledger_id
  INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
  ON gl_balances.code_combination_id = gl_code_combinations.code_combination_id
    /* -SS- ,
    (SELECT a.BUSINESS_UNIT PS_BU,
    A.ORACLE_XREF_VALUE Oracle_BU
    FROM dbo.ps_trane_R12_xref a
    WHERE Recname_xref  IN('ENTITY')
    AND a.BUSINESS_UNIT IN('CAN', 'CSD')
    AND a.ps_attribute1  = ' '
    AND a.ps_attribute2  = ' '
    AND a.ps_attribute3  = ' '
    AND a.ps_attribute4  = ' '
    AND a.effdt          =
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
    (SELECT A.ORACLE_XREF_VALUE Oracle_Acc,
    a.PS_ATTRIBUTE1 PeopleSoft_ac
    FROM dbo.ps_trane_R12_xref a
    WHERE Recname_xref IN('ACCOUNT')
    AND a.ps_attribute1 LIKE '5%'
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
    ) Cross_Ref,
    (SELECT a.BUSINESS_UNIT PS_BU,
    A.PS_ATTRIBUTE2 PS_DEPT,
    A.ORACLE_XREF_VALUE Oracle_DEPT
    FROM ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a
    WHERE Recname_xref IN('LOCATION')
    AND ps_attribute2 LIKE 'SL00%'
    AND a.BUSINESS_UNIT IN('CAN', 'CSD')
    AND a.effdt          =
    (SELECT MAX(b.EFFDT)
    FROM ps_trane_r12_xref b--@DR_INTFC_DR.LAX.TRANE.COM b
    WHERE b.recname_xref = a.recname_xref
    AND b.business_unit  = a.business_unit
    AND b.ps_attribute1  = a.ps_attribute1
    AND b.ps_attribute2  = a.ps_attribute2
    AND b.ps_attribute3  = a.ps_attribute3
    AND b.ps_attribute4  = a.ps_attribute4
    )
    ) DEPT
    */
  WHERE gl_balances.period_name = :RunDate
  AND
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      ELSE 'CAN'
    END = UPPER(:COUNTRY)
  AND gl_ledgers.ledger_id IN(2022, 2041)
  AND GL_BALANCES.ACTUAL_FLAG = 'A'
    -- -SS- NEW
  AND GL_CODE_COMBINATIONS.SEGMENT2 IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')
    -- -SS- /NEW
    -- -SS- AND GL_CODE_COMBINATIONS.SEGMENT2 LIKE 'SL00%'
  AND GL_CODE_COMBINATIONS.SEGMENT1 IN('5773', '5588') -- -SS- SEGMENT1 = R12 ENTITY = CANADA
    -- -SS- AND Cross_Ref.Oracle_Acc            = gl_code_combinations.segment4
    -- -SS- Cross_ref_BU and DEPT joins exist in order to filter by BU in ('CAN','CSD') and DEPT like 'SL00%'
    -- -SS- AND Cross_ref_BU.ORACLE_BU          = gl_code_combinations.segment1
    -- -SS- AND Cross_ref_BU.PS_BU              = dept.PS_BU
    -- -SS- AND dept.Oracle_DEPT                = gl_code_combinations.segment2
    -- AND Cross_Ref.PeopleSoft_ac (+) = PSA.PS_ACCOUNT
  AND PSA.TRANE_ACCOUNT_IND = 'X'
  AND GL_CODE_COMBINATIONS.SEGMENT4 = PSA.R12_ACCOUNT -- R12_2_R12
  GROUP BY PSA.R12_ACCOUNT, -- -SS- Cross_Ref.PeopleSoft_ac,
    psa.DESCR, gl_balances.period_name, gl_ledgers.ledger_id,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END
  ) ;