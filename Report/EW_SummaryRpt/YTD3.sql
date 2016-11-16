/* Comm detail Dollar Amt YTD3 */
SELECT
  TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') AS gl_BeginDate, LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
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
    ELSE b.GL_ACC_DESCR
    END AS GL_ACC_DESCR,
  NVL(B.Amort_Comm_and_prepaid_comm, 0) AS Amort_Comm_and_prepaid_comm,
  NVL(B.SHORT_TERM_COMM, 0) AS SHORT_TERM_COMM,
  NVL(B.LONG_TERM_COMM, 0) AS LONG_TERM_COMM

FROM
-- a
(
  SELECT
    /*+ NO_CPU_COSTING */
    TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') AS gl_BeginDate, LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
    CASE
      WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
      ELSE 'USA'
      END AS COUNTRY_INDICATOR,
    DIST.R12_ACCOUNT AS GL_ACCOUNT,
    SUM( CASE
      WHEN dist.debit_amt = 0 OR dist.debit_amt IS NULL OR dist.credit_amount <> ''
        THEN dist.credit_amount * - 1
      ELSE dist.debit_amt
      END) AS DOLLAR_AMOUNT, 
    AFU.DESCR AS GL_ACC_DESCR, 
    0 AS Amort_Comm_and_prepaid_comm,
    0 AS SHORT_TERM_COMM,
    0 AS LONG_TERM_COMM
    
  FROM dbo.R12_TRNCO_CM_DIST_PSB Dist
  INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
    ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT

  WHERE 
    DIST.JOURNAL_DATE BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
  AND LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
  AND AFU.LIKE_5 = 'Y'
  AND CASE
    WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
    ELSE 'USA'
    END = UPPER(:COUNTRY)
  AND DIST.r12_entity IN('5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
  AND(
    (DIST.PS_DEPTID = 'NA'
      AND DIST.R12_LOCATION IN('113602', '129003'))
    OR(DIST.PS_DEPTID <> 'NA'
      AND(DIST.PS_DEPTID IS NULL
        OR DIST.PS_DEPTID = 'SL00')))

  GROUP BY
    CASE
      WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
      ELSE 'USA'
      END,
    DIST.R12_ACCOUNT, 
    AFU.DESCR 

  UNION ALL

  SELECT
    /*+ NO_CPU_COSTING */
    TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') AS gl_BeginDate, LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) gl_End_Date,
    CASE
      WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
      ELSE 'USA'
      END AS COUNTRY_INDICATOR,
    DIST.R12_ACCOUNT AS GL_ACCOUNT,
    SUM( CASE
      WHEN dist.debit_amt = 0 OR dist.debit_amt IS NULL OR dist.credit_amount <> ''
        THEN dist.credit_amount * - 1
      ELSE dist.debit_amt
      END) AS DOLLAR_AMOUNT, 
    AFU.DESCR AS GL_ACC_DESCR, 
    0 AS Amort_Comm_and_prepaid_comm,
    0 AS SHORT_TERM_COMM,
    0 AS LONG_TERM_COMM

  FROM dbo.R12_TRNCO_CM_DIST_PSB dist
  INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
    ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT

  WHERE 
    DIST.JOURNAL_DATE BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
  AND LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
  AND AFU.LIKE_5 = 'Y'
  AND CASE
    WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
    ELSE 'USA'
    END = UPPER(:COUNTRY)
  AND DIST.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
  AND((DIST.PS_DEPTID = 'NA'
    AND DIST.R12_LOCATION IN('113602', '129003'))
    OR(DIST.PS_DEPTID <> 'NA'
      AND(DIST.PS_DEPTID IS NULL
        OR DIST.PS_DEPTID IN('SL00', 'TCA0'))))

  GROUP BY
    CASE
      WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
      ELSE 'USA'
      END,
    DIST.R12_ACCOUNT, 
    AFU.DESCR 

) a,
-- B
(
  SELECT
    /*+ NO_CPU_COSTING */
    TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') AS GL_BEGINDATE,
    LAST_DAY(TO_DATE('1-'||:RunDate, 'dd-mon-yy')) GL_END_DATE,
    B.COUNTRY_INDICATOR,
    B.GL_ACCOUNT AS ACCOUNT,
    0 AS DOLLAR_AMOUNT,
    B.GL_ACCOUNT_DESCR AS GL_ACC_DESCR,
    SUM(B.AMORT_COMM_AND_PREPAID_COMM) AS AMORT_COMM_AND_PREPAID_COMM,
    SUM(B.SHORT_TERM_COMM) AS SHORT_TERM_COMM,
    SUM(B.LONG_TERM_COMM) AS LONG_TERM_COMM

  FROM
  -- B
  (
    SELECT a.country_indicator, a.gl_account, A.GL_ACCOUNT_DESCR AS GL_ACCOUNT_DESCR, to_date('1-'||:RunDate, 'dd-mon-yy'),
      CASE
        WHEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR') = To_date('1-'||:RunDate, 'dd-mon-yy')
        THEN CASE
          WHEN A.FORECAST_PERIOD = TO_DATE('1-'||:RunDate, 'dd-mon-yy') THEN MAX(a.PREPAID_COMMISSION)
          ELSE 0
          END
        ELSE (MAX(A.COMM_AMORT_MNTHLY) + CASE
          WHEN A.FORECAST_PERIOD = TO_DATE('1-'||:RunDate, 'dd-mon-yy') THEN MAX(a.PREPAID_COMMISSION)
          ELSE 0
          END)
        END AS AMORT_COMM_AND_PREPAID_COMM,
      MAX(A.SHORT_TERM_PP_COMM) AS SHORT_TERM_COMM,
      MAX(A.LONG_TERM_PP_COMM) AS LONG_TERM_COMM,
      A.FORECAST_PERIOD
      
    FROM DW_DM_030_COMM_AMORTIZATION a
    INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
      ON AFU.R12_ACCOUNT = A.GL_ACCOUNT 

    WHERE 
      A.COUNTRY_INDICATOR = UPPER(:COUNTRY)
    AND A.RUN_PERIOD >= TO_DATE('1-'||UPPER(:RunDate), 'dd-mon-yy')
    AND A.RUN_PERIOD < ADD_MONTHS(TO_DATE('1-'||:RunDate, 'dd-mon-yy'), 1)
    AND AFU.LIKE_5 = 'Y' 
    AND A.SHIP_PERIOD >= CASE
      WHEN to_date('1-'||:RunDate, 'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
        THEN TRUNC(TRUNC(to_date('1-'||:RunDate, 'dd-mon-yy'), 'YEAR') - 1) - 30
      ELSE TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
      END
    AND A.SHIP_PERIOD < (TO_DATE('1-'||:RunDate, 'dd-mon-yy'))

    GROUP BY
    A.COUNTRY_INDICATOR,
    A.GL_ACCOUNT,
    A.GL_ACCOUNT_DESCR,
    A.FORECAST_PERIOD

  ) B

  GROUP BY
  B.COUNTRY_INDICATOR,
  GL_ACCOUNT, B.GL_ACCOUNT_DESCR

) B

WHERE a.GL_ACCOUNT (+) = B.ACCOUNT
AND a.COUNTRY_INDICATOR (+) = B.COUNTRY_INDICATOR

UNION

SELECT
  /*+ NO_CPU_COSTING */
  ADD_MONTHS(((LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')))), - 1) AS GL_BEGINDATE,
  LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy')) GL_END_DATE,
  '' AS COUNTRY_INDICATOR,
  AFU.R12_ACCOUNT AS GL_ACCOUNT, 
  0 AS DOLLAR_AMOUNT, 
  AFU.DESCR AS GL_ACC_DESCR, 
  0 AS Amort_Comm_and_prepaid_comm,
  0 AS SHORT_TERM_COMM,
  0 AS LONG_TERM_COMM
  
FROM
R12_ACCOUNT_FILTER_UPD AFU
  
WHERE 1=1
AND AFU.LIKE_5 = 'Y'
AND NOT EXISTS (
  SELECT 'X'
    
  FROM DBO.R12_TRNCO_CM_DIST_PSB DIST 
    
  WHERE 1=1
  AND DIST.R12_ACCOUNT = AFU.R12_ACCOUNT 
  AND DIST.JOURNAL_DATE 
    BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
    AND LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
  AND CASE
    WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
    ELSE 'USA'
    END = UPPER(:COUNTRY)
  AND DIST.R12_ENTITY IN ('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
)
AND NOT EXISTS (
  SELECT 'X'
    
  FROM DW_DM_030_COMM_AMORTIZATION A

  WHERE A.RUN_PERIOD >= TO_DATE('1-'||UPPER(:RunDate), 'dd-mon-yy')
  AND A.RUN_PERIOD < ADD_MONTHS(TO_DATE('1-'||:RunDate, 'dd-mon-yy'), 1)
  AND A.GL_ACCOUNT = AFU.R12_ACCOUNT 
  AND A.SHIP_PERIOD >= CASE
    WHEN to_date('1-'||:RunDate, 'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
      THEN TRUNC(TRUNC(to_date('1-'||:RunDate, 'dd-mon-yy'), 'YEAR') - 1) - 30
    ELSE TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
    END
  AND A.SHIP_PERIOD <(to_date('1-'||:RunDate, 'dd-mon-yy'))
  AND a.country_indicator = UPPER(:COUNTRY)

)