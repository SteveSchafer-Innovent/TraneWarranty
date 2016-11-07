SELECT
  
  TRUNC(TO_DATE(TO_DATE('1-' ||:RunDate, 'dd-mon-yy')), 'YEAR') - 1 AS gl_BeginDate, 
  LAST_DAY(to_date('1-' ||:RunDate, 'dd-mon-yy')) gl_End_Date,
  CASE
    WHEN sales.COUNTRY_INDICATOR IS NULL
    THEN begbalances.COUNTRY_INDICATOR
    ELSE sales.COUNTRY_INDICATOR
  END AS COUNTRY_INDICATOR, 
  CAST(begbalances.ACCOUNT AS NUMBER) ACCOUNT,
  CASE
    WHEN sales.DESCR IS NULL
    THEN begbalances.DESCR
    ELSE sales.DESCR
  END AS GL_ACC_DESCR, 
  (NVL(begbalances.begbal_base, 0)) * - 1 AS Begning_Balance, 
  (NVL(perioddata.EndBal_base, 0)) * - 1 AS END_Blance,
  CASE
    WHEN sales.REVENUE_AMOUNT IS NULL
    THEN 0
    ELSE sales.REVENUE_AMOUNT
  END AS REVENUE_AMOUNT, 
  NVL(rev.DEFERRED_REVENUE, 0) AS DEFERRED_REVENUE, 
  NVL(rev.SHORT_TERM_BALA, 0) AS SHORT_TERM_BALA, 
  NVL(rev.LONG_TERM_BALA, 0) AS LONG_TERM_BALA
FROM
  (SELECT
    AFU.R12_ACCOUNT AS ACCOUNT,
    gl_ledgers.ledger_id AS ledger, gl_balances.period_name AS fiscal_year,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END AS COUNTRY_INDICATOR, SUM(DECODE(gl_balances.period_name, 'Jan' || SUBSTR(:RunDate, 4, 3), gl_balances.BEGIN_BALANCE_DR - gl_balances.BEGIN_BALANCE_CR, 0)) AS begbal_base,
    AFU.DESCR 
     || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')' AS DESCR
    
    
  FROM SY_120_GL_LEDGERS_EW gl_ledgers
  INNER JOIN SY_120_GL_BALANCES_EW gl_balances
  ON gl_ledgers.ledger_id = gl_balances.ledger_id
  INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
  ON gl_code_combinations.code_combination_id = gl_balances.code_combination_id
  
  RIGHT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU
  ON AFU.R12_ACCOUNT = GL_CODE_COMBINATIONS.SEGMENT4
    
  WHERE gl_balances.period_name = 'Jan' || SUBSTR(:RunDate, 4, 3)
  AND
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      ELSE 'CAN'
    END = UPPER(:COUNTRY)
  AND gl_ledgers.ledger_id IN(2022, 2041)
  AND GL_BALANCES.ACTUAL_FLAG = 'A'
    
    
  AND AFU.LIKE_52_53_54 = 'Y' 
    
  GROUP BY
    AFU.R12_ACCOUNT, 
    gl_ledgers.ledger_id, gl_balances.period_name,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END,
    AFU.DESCR 
    || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
    
  ) begbalances
LEFT OUTER JOIN
  (SELECT
    
    
    AFU.R12_ACCOUNT AS ACCOUNT, 
    gl_ledgers.ledger_id AS ledger, gl_balances.period_name AS fiscal_year,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END AS COUNTRY_INDICATOR, NVL(SUM(gl_balances.begin_balance_dr + gl_balances.period_net_dr - gl_balances.begin_balance_cr - gl_balances.period_net_cr), 0) AS EndBal_base,
    AFU.DESCR 
    ||' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')' AS DESCR
    
    
  FROM SY_120_GL_LEDGERS_EW gl_ledgers
  INNER JOIN SY_120_GL_BALANCES_EW gl_balances
  ON gl_balances.ledger_id = gl_ledgers.ledger_id
  INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
  ON gl_balances.code_combination_id = gl_code_combinations.code_combination_id
  
  RIGHT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU
  ON AFU.R12_ACCOUNT = GL_CODE_COMBINATIONS.SEGMENT4
    
    
  WHERE gl_balances.period_name = :RunDate
  AND
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      ELSE 'CAN'
    END = UPPER(:COUNTRY)
  AND gl_ledgers.ledger_id IN(2022, 2041)
  AND GL_BALANCES.ACTUAL_FLAG = 'A'
    
    
  AND AFU.LIKE_52_53_54 = 'Y' 
    
  GROUP BY 
  AFU.R12_ACCOUNT, 
  gl_ledgers.ledger_id, gl_balances.period_name,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END, 
    AFU.DESCR 
     || ' - (R12 A/C : ' ||gl_code_combinations.segment4 ||'-' ||gl_ledgers.name ||')'
    
  ) perioddata ON begbalances.ACCOUNT = perioddata.ACCOUNT
AND begbalances.fiscal_year = perioddata.fiscal_year
AND begbalances.ledger = perioddata.ledger
LEFT OUTER JOIN
  (SELECT
    
    CASE
      WHEN A.r12_entity IN(5773, 5588)
      THEN 'CAN'
      ELSE 'USA'
    END AS COUNTRY_INDICATOR,
    
    A.R12_ACCOUNT Account, 
    AFU.DESCR, 
    SUM(A.MONETARY_AMOUNT * - 1) AS REVENUE_AMOUNT
    
  FROM R12_BI_ACCT_ENTRY_PSB A
  INNER JOIN R12_TRNBI_BI_HDR_PSB B
  ON A.BUSINESS_UNIT = B.BUSINESS_UNIT
  AND A.INVOICE = B.INVOICE AND A.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
  INNER JOIN R12_BI_HDR_PSB C
  ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
  AND B.INVOICE = C.INVOICE AND B.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
  INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
  ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
  
  WHERE A.JOURNAL_DATE >= TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
  AND A.JOURNAL_DATE <= LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
    
  AND A.R12_ENTITY IN ('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
    
  AND
    CASE
      WHEN a.R12_ENTITY IN ('5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984') THEN 'USA'
      WHEN a.R12_ENTITY IN ('5773', '5588') THEN 'CAN' ELSE '???'
    END = UPPER(:COUNTRY)
    
    
    
  AND C.ENTRY_TYPE = 'IN'
    
  AND AFU.LIKE_5 = 'Y'
    
  GROUP BY A.R12_ACCOUNT, A.r12_entity, A.PS_ACCOUNT, 
  AFU.DESCR 
    
  ) sales ON begbalances.ACCOUNT = sales.ACCOUNT
LEFT OUTER JOIN
  (SELECT B.gl_account AS account, B.GL_ACCOUNT_DESCR AS DESCRIPTION, SUM(B.DEFERRED_REVENUE) AS DEFERRED_REVENUE, SUM(B.SHORT_TERM_REVENUE) AS SHORT_TERM_BALA, SUM(LONG_TERM_REVENUE) AS LONG_TERM_BALA
  FROM
    (SELECT a.gl_account, A.GL_ACCOUNT_DESCR, to_date('1-'||:RunDate, 'dd-mon-yy'),
      CASE
        WHEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') = To_date('1-'||:RunDate, 'dd-mon-yy')
        THEN
          CASE
            WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate, 'dd-mon-yy')
            THEN MAX(A.DEFERRED_REVENUE)
            ELSE 0
          END
        ELSE(MAX(a.rec_rev_mnthly) +
          CASE
            WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate, 'dd-mon-yy')
            THEN MAX(A.DEFERRED_REVENUE)
            ELSE 0
          END)
      END AS DEFERRED_REVENUE, MAX(a.SHORT_TERM_DR) AS SHORT_TERM_REVENUE, MAX(a.LONG_TERM_DR) AS LONG_TERM_REVENUE, A.FORECAST_PERIOD
      
    FROM DW_DM_030_REV_RELEASE a
    INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
    ON AFU.R12_ACCOUNT = A.GL_ACCOUNT 
    
      
      
    WHERE 1=1
    AND a.country_indicator = UPPER(:COUNTRY)
    AND a.RUN_PERIOD >= TO_DATE('1-'||:RunDate, 'dd-mon-yy')
    AND a.RUN_PERIOD < add_months(to_date('1-'||:RunDate, 'dd-mon-yy'), 1)
      
    AND AFU.LIKE_5 = 'Y'
    AND A.SHIP_PERIOD >=
      CASE
        WHEN to_date('1-'||:RunDate, 'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
        THEN TRUNC(TRUNC(to_date('1-'||:RunDate, 'dd-mon-yy'), 'YEAR') - 1) - 30
        ELSE TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
      END
    AND A.SHIP_PERIOD <(to_date('1-'||:RunDate, 'dd-mon-yy'))
    GROUP BY a.gl_account, A.GL_ACCOUNT_DESCR, A.FORECAST_PERIOD
    ) B
  GROUP BY B.GL_ACCOUNT, B.GL_ACCOUNT_DESCR
  ) Rev ON begbalances.ACCOUNT = Rev.account

UNION


SELECT
  
  ADD_MONTHS(((LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')))), - 1) AS gl_BeginDate, LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date, '' AS COUNTRY_INDICATOR,
  
  CAST(AFU.R12_ACCOUNT AS NUMBER) AS ACCOUNT, 
  AFU.DESCR AS GL_ACCOUNT_DESCR, 
  0 AS Begning_Balance, 0 AS END_Blance, 0 AS REVENUE_AMOUNT, 0 AS DEFERRED_REVENUE, 0 AS SHORT_TERM_BALA, 0 AS LONG_TERM_BALA
  
FROM
R12_ACCOUNT_FILTER_UPD AFU
WHERE 1=1
  
AND AFU.LIKE_5 = 'Y'
AND NOT EXISTS
  (SELECT 'x'
    
  FROM SY_120_GL_LEDGERS_EW gl_ledgers
  INNER JOIN SY_120_GL_BALANCES_EW gl_balances
  ON gl_balances.ledger_id = gl_ledgers.ledger_id
  INNER JOIN SY_120_GL_CODE_COMBO_EW gl_code_combinations
  ON gl_balances.code_combination_id = gl_code_combinations.code_combination_id
    
  WHERE gl_balances.period_name = :RunDate
  AND
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      ELSE 'CAN'
    END = UPPER(:COUNTRY)
  AND gl_ledgers.ledger_id IN(2022, 2041)
  AND GL_BALANCES.ACTUAL_FLAG = 'A'
    
  AND GL_CODE_COMBINATIONS.SEGMENT2 IN('113602', '115615', '119001', '119007', '129001', '129003', '129004')
  AND GL_CODE_COMBINATIONS.SEGMENT1 IN('5773', '5588')
  AND GL_CODE_COMBINATIONS.SEGMENT4 = AFU.R12_ACCOUNT 
    
  GROUP BY
  AFU.R12_ACCOUNT, 
  AFU.DESCR, 
  gl_balances.period_name, gl_ledgers.ledger_id,
    CASE
      WHEN gl_ledgers.ledger_id = 2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id = 2041
      THEN 'CAN'
    END
  )