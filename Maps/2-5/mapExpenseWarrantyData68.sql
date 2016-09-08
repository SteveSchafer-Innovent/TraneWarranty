/* 2-5Year Specific */
SELECT
  /* + NO_CPU_COSTING  */
  CCN_DATA.CLAIM_NBR AS CLAIM_NUMBER,
  CCN_DATA.STEP_NBR AS STEP_NUMBER,
  GLA.R12_ENTITY
  /* -SS- COMPANY */
  AS BUSINESS_UNIT,
  PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
  CCN_DATA.CLAIM_TYPE AS CLAIM_TYPE,
  CCN_DATA.DOLLAR_AMOUNT AS EXPENSE_AMOUNT,
  100 *(CCN_DATA.DOLLAR_AMOUNT - TRUNC(CCN_DATA.DOLLAR_AMOUNT)) AS EXPENSE_AMOUNT_DEC,
  CCN_DATA.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
  GLA.R12_ACCOUNT
  /* -SS- ACCOUNT */
  AS GL_ACCOUNT,
  CCN_DATA.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
  SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
  CASE
    WHEN GLA.R12_PRODUCT
      /* -SS- PROD_CODE */
      IS NULL
    OR GLA.R12_PRODUCT
      /* -SS- PROD_CODE */
      = ''
    THEN PCS.PROD_CODE
    ELSE GLA.R12_PRODUCT
      /* -SS- PROD_CODE */
  END AS GL_PROD_CODE,
  PCS.PROD_CODE AS MANF_PROD_CODE,
  SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
  CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
  CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
  (
  CASE
    WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
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
  /* PER JACKIE'S REQUEST ON 5/24/07 IF FAIL DATE = 1/1/1900 OR NULL THEN SET WARRANTY TYPE TO NO. */
  (
  CASE
    WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY')
    OR TD1.FULL_DATE IS NULL
    THEN 'NO'
    ELSE FCW.WA_POLICY_TYPE
  END) AS WARRANTY_TYPE,
  (
  CASE
    WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR'
    THEN 'Out of Standard Warranty'
    ELSE(
      CASE
        WHEN FCW.WA_RANGE = '1'
        THEN '1st Year Standard Warranty'
        WHEN FCW.WA_RANGE = '2'
        THEN '2nd-5th Year Standard Warranty'
        WHEN FCW.WA_RANGE = '5'
        THEN '> 5th Year Standard Warranty'
        ELSE 'Out of Standard Warranty'
      END)
  END) AS WARRANTY_DURATION,
  CCN_DATA.TRX_CURRENCY AS CURRENCY,
  (
  CASE
    WHEN GLA.R12_ENTITY NOT IN('5773', '5588')
      /* -SS- ASX.NATION_CURR='USD' */
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
  GLA.R12_COST_CENTER
  /* -SS- COST_CENTER */
  AS GL_DEPT
  /* 2-5Year Specific */
  ,
  CASE
    WHEN a.CLAIM_NUMBER IS NULL
    THEN 10000 *(
      CASE
        WHEN
          --(PCS.PROD_CODE='0061' and CCN_DATA.CLAIM_TYPE ='MATERIAL')
          /* BR6 */
          (PCS.PROD_CODE IN('0054', '0197'))
          /* BR4 */
        OR(NVL(FCW.WA_RANGE, '0') NOT IN('2', '5'))
          /* BR3 */
        OR(ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) > 91)
          /* BR5 */
        OR(ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) > 24)
          /*BR7*/
        THEN 0
        ELSE RES_PCT.RESERVE_PCT
      END)
    ELSE res_PCT1.RESERVE_PCT
  END AS IN_RESERVE_PERCENT,
  ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
  ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) AS Start_Lag,
  100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH
  --,CCN_DATA.DOLLAR_AMOUNT*(CASE WHEN PCS.PROD_CODE='0061' THEN 0 ELSE RES_PCT.RESERVE_PCT  END)  AS EXPENSE_AMT_IN_RES
  ,
  0 AS EXPENSE_AMT_IN_RES
  --,CCN_DATA.DOLLAR_AMOUNT*(1-(CASE WHEN PCS.PROD_CODE='0061' THEN 0 ELSE RES_PCT.RESERVE_PCT  END))  AS EXPENSE_AMT_NOT_IN_RES
  ,
  0 AS EXPENSE_AMT_NOT_IN_RES
FROM
  (
  /* THIS IS THE CORE PORTION FOR CONCESSION CLAIM TYPE TO RETRIEVE EXPENSE RELATED INFORMATION */
  SELECT
    /* + NO_CPU_COSTING  */
    'TRANE_MATERIAL' AS TYPE,
    MLR.CLAIM_NBR,
    MLR.RETRO_ID,
    'CONCESSION' AS CLAIM_TYPE,
    'TRANE COMPANY' AS EXPENSE_TYPE_DESCR,
    'MATERIAL' AS EXPENSE_TYPE_CATG,
    LR.CHARGE_COMM_PCT,
    LR.CHARGE_COMPANY_PCT,
    MAX(((LR.APPR_SUBLET_MAT_AMT + LR.APPR_SUBLET_REF_AMT + LR.APPR_SUBLET_SERV_AMT) /
    (SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
    ) * LR.CHARGE_COMPANY_PCT)) AS DOLLAR_AMOUNT,
    MLR.STEP_NBR
    /* DATES FROM DAY_TIME TABLE */
    ,
    MLR.CCN_TRX_DATE_KEY,
    MLR.ORIGINAL_SHIP_DATE_KEY,
    MLR.FAIL_DATE_KEY,
    MLR.START_DATE_KEY,
    MLR.GL_ACCOUNT_SCD_KEY
    /* R12_GL_ACCOUNT_SCD /* -SS- */
    .GL_ACCOUNT_SCD_KEY */,
    MLR.PROD_CODE_SCD_KEY
    /* PROD_CODE_SCD.PROD_CODE_SCD_KEY */
    ,
    MLR.CUST_ACCOUNT_SCD_KEY
    /* CUST_ACCOUNT_SCD.CUST_ACCOUNT_SCD_KEY */
    ,
    MLR.SUBMIT_OFFICE_SCD_KEY
    /* SUBMIT_OFFICE_SCD.SUBMIT_OFFICE_SCD_KEY */
    ,
    MLR.TRX_CURRENCY
  FROM WC_MAT_LBR_ROLLUP MLR 
  INNER JOIN WC_LABOR_ROLLUP LR ON 
      MLR.CCN_TRX_DATE_KEY = LR.CCN_TRX_DATE_KEY
      AND MLR.DETAIL_NBR = LR.DETAIL_NBR
      AND MLR.CLAIM_NBR = LR.CLAIM_NBR
  INNER JOIN TIME_DAY TD ON 
      TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY
      AND TD.TIME_KEY = LR.CCN_TRX_DATE_KEY
    /* -SS- */
  INNER JOIN R12_GL_ACCOUNT SCD ON  GLA
      GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY
  WHERE 1 = 1
    /* CONCESSION CLAIM TYPE ONLY */
  AND MLR.CLAIM_TYPE_SCD_KEY = 11
    --AND ABS(MONTHS_BETWEEN(TD.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1))) < 24
  AND TD.FULL_DATE >= TO_DATE('1/1/2000', 'MM/DD/YYYY')
  AND TD.FULL_DATE < TO_DATE('12/31/2050', 'MM/DD/YYYY')
    --AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(TD.full_date))<=12
    --AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(TD.full_date))>=1
    /* WARRANTY LIMITATION */
    --AND (GLA.R12_ENTITY /* -SS- COMPANY */ = 'CSD' OR GLA.R12_ENTITY /* -SS- COMPANY */='CAN')
  AND(GLA.R12_ACCOUNT
    /* -SS- ACCOUNT */
    LIKE '0620%'
  OR GLA.R12_ACCOUNT
    /* -SS- ACCOUNT */
    LIKE '8062%')
    --AND CT.CLAIM_TYPE_CODE ='CONCESSION'
    --AND MLR.CLAIM_NBR = 1682063
  GROUP BY MLR.CLAIM_NBR,
    LR.CHARGE_COMM_PCT,
    LR.CHARGE_COMPANY_PCT,
    MLR.CCN_TRX_DATE_KEY,
    MLR.ORIGINAL_SHIP_DATE_KEY,
    MLR.FAIL_DATE_KEY,
    MLR.START_DATE_KEY,
    MLR.STEP_NBR,
    MLR.GL_ACCOUNT_SCD_KEY,
    MLR.PROD_CODE_SCD_KEY,
    MLR.CUST_ACCOUNT_SCD_KEY,
    MLR.SUBMIT_OFFICE_SCD_KEY,
    MLR.TRX_CURRENCY,
    MLR.RETRO_ID
  UNION
  SELECT
    /* + NO_CPU_COSTING  */
    'TRANE_LABOR' AS TYPE,
    MLR.CLAIM_NBR,
    MLR.RETRO_ID,
    'CONCESSION' AS CLAIM_TYPE,
    'TRANE COMPANY' AS EXPENSE_TYPE_DESCR,
    'LABOR' AS EXPENSE_TYPE_CATG,
    LR.CHARGE_COMM_PCT,
    LR.CHARGE_COMPANY_PCT,
    ((SUM((LR2.APPR_AMT)) + MAX((LR.APPR_DIAGNOSTIC_AMT + LR.APPR_TRAVEL_AMT) /
    (SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
    ))) * LR.CHARGE_COMPANY_PCT) AS DOLLAR_AMOUNT,
    MLR.STEP_NBR
    /* DATES FROM DAY_TIME TABLE */
    ,
    MLR.CCN_TRX_DATE_KEY,
    MLR.ORIGINAL_SHIP_DATE_KEY,
    MLR.FAIL_DATE_KEY,
    MLR.START_DATE_KEY,
    MLR.GL_ACCOUNT_SCD_KEY
    /* R12_GL_ACCOUNT_SCD /* -SS- */
    .GL_ACCOUNT_SCD_KEY */,
    MLR.PROD_CODE_SCD_KEY
    /* PROD_CODE_SCD.PROD_CODE_SCD_KEY */
    ,
    MLR.CUST_ACCOUNT_SCD_KEY
    /* CUST_ACCOUNT_SCD.CUST_ACCOUNT_SCD_KEY */
    ,
    MLR.SUBMIT_OFFICE_SCD_KEY
    /* SUBMIT_OFFICE_SCD.SUBMIT_OFFICE_SCD_KEY */
    ,
    MLR.TRX_CURRENCY
  FROM WC_MAT_LBR_ROLLUP MLR,
  INNER JOIN WC_LABOR_ROLLUP LR 0N 
        MLR.CCN_TRX_DATE_KEY = LR.CCN_TRX_DATE_KEY
        AND MLR.DETAIL_NBR = LR.DETAIL_NBR
        AND MLR.CLAIM_NBR = LR.CLAIM_NBR
        AND MLR.STEP_NBR = LR.STEP_NBR
    /* -SS- */
  INNER JOIN R12_GL_ACCOUNT_SCD GLA 0N 
      GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY
      AND GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
  INNER JOIN (SELECT DISTINCT CLAIM_NBR 0N 
      DETAIL_NBR 0N 
      STEP_NBR 0N 
      APPR_AMT 0N 
      CCN_TRX_DATE_KEY ON 
    FROM WC_LABOR_ROLLUP LR1
    WHERE CLAIM_TYPE_SCD_KEY = 11
    AND EXISTS
      (SELECT 'X'
      FROM R12_GL_ACCOUNT_SCD
        /* -SS- */
      WHERE lr1.GL_ACCOUNT_SCD_KEY = GL_ACCOUNT_SCD_KEY
      AND(ACCOUNT LIKE '0620%'
      OR ACCOUNT LIKE '8062%')
      )
    ) LR2 ON 
      MLR.CCN_TRX_DATE_KEY = LR2.CCN_TRX_DATE_KEY
      AND MLR.STEP_NBR = LR2.STEP_NBR
      AND MLR.DETAIL_NBR = LR2.DETAIL_NBR
      AND MLR.CLAIM_NBR = LR2.CLAIM_NBR
  INNER JOIN TIME_DAY TD 0N 
      TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY
      AND TD.TIME_KEY = LR.CCN_TRX_DATE_KEY
      AND TD.TIME_KEY = LR2.CCN_TRX_DATE_KEY
  WHERE 1 = 1
    /* CONCESSION CLAIM TYPE ONLY */
  AND MLR.CLAIM_TYPE_SCD_KEY = 11
    --AND ABS(MONTHS_BETWEEN(TD.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1))) < 24
  AND TD.FULL_DATE >= TO_DATE('1/1/2000', 'MM/DD/YYYY')
  AND TD.FULL_DATE < TO_DATE('12/31/2050', 'MM/DD/YYYY')
    --AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(TD.full_date))<=12
    --AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(TD.full_date))>=1
    /* WARRANTY LIMITATION */
    --AND (GLA.COMPANY = 'CSD' OR GLA.COMPANY='CAN')
  /* -SS- ACCOUNT */
  AND(GLA.R12_ACCOUNT LIKE '0620%'
    /* -SS- ???? */ /* -SS- ACCOUNT */
  OR GLA.R12_ACCOUNT  LIKE '8062%'
    /* -SS- ???? */
    )
    --AND CT.CLAIM_TYPE_CODE ='CONCESSION'
    --AND MLR.CLAIM_NBR = 1682063
  GROUP BY MLR.CLAIM_NBR,
    LR.CHARGE_COMM_PCT,
    LR.CHARGE_COMPANY_PCT,
    MLR.CCN_TRX_DATE_KEY,
    MLR.ORIGINAL_SHIP_DATE_KEY,
    MLR.FAIL_DATE_KEY,
    MLR.START_DATE_KEY,
    MLR.STEP_NBR,
    MLR.GL_ACCOUNT_SCD_KEY,
    MLR.PROD_CODE_SCD_KEY,
    MLR.CUST_ACCOUNT_SCD_KEY,
    MLR.SUBMIT_OFFICE_SCD_KEY,
    MLR.TRX_CURRENCY,
    MLR.RETRO_ID
  ) CCN_DATA
  LEFT OUTER JOIN DM_FAL_CLAIMS_WARRANTY_XRF FCW 0N 
      CCN_DATA.CLAIM_NBR = FCW.CLAIM_NBR
      AND CCN_DATA.STEP_NBR = FCW.STEP_NBR
      --AND CCN_DATA.DETAIL_NBR=FCW.DETAIL_NBR
  INNER JOIN TIME_DAY TD3 0N CCN_DATA.CCN_TRX_DATE_KEY = TD3.TIME_KEY   /* TD3 FOR TRX DATE */
  INNER JOIN TIME_DAY TD2 0N CCN_DATA.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY /* TD2 FOR ORIGINAL SHIP DATE */
  INNER JOIN TIME_DAY TD1 0N CCN_DATA.FAIL_DATE_KEY = TD1.TIME_KEY /* TD1 FOR FAIL DATE */
  INNER JOIN TIME_DAY TD 0N CCN_DATA.START_DATE_KEY = TD.TIME_KEY /* TD FOR START DATE */
  /* CONCESSION CLAIM TYPE */
  INNER JOIN R12_GL_ACCOUNT_SCD GLA ON CCN_DATA.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY 
  /* -SS- */
  --,EXPENSE_TYPE_SCD ETS
  INNER JOIN PROD_CODE_SCD PCS 0N CCN_DATA.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
  INNER JOIN CUST_ACCOUNT_SCD CACCT 0N CCN_DATA.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
  INNER JOIN SUBMIT_OFFICE_SCD SOS 0N CCN_DATA.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
  INNER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP ON 
      GLA.R12_ENTITY = PRODGRP.GL_LEDGER /* -SS- COMPANY */
      AND PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE
  /* -SS- ,ACTUATE_SEC_XREF ASX */
  DM_WAR_CSN_RSV_PCT_REF RES_PCT 0N 
      CCN_DATA.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR
      AND CCN_DATA.EXPENSE_TYPE_CATG = UPPER(RES_PCT.EXPENSE_TYPE_CATG)
  LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ a ON CCN_DATA.CLAIM_NBR = a.CLAIM_NUMBER
  LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT1 0N a.claim_type = RES_PCT1.claim_type
WHERE 1 = 1
  --AND CCN_DATA.EXPENSE_TYPE_SCD_KEY= ETS.EXPENSE_TYPE_SCD_KEY
  /* NATION CURRENCY */
  /* -SS- AND GLA.COMPANY = ASX.PSGL(+) */
  /* RESERVE PERCENT FROM LAB/MAT CLASSIFICATION */
AND(
  CASE
    WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR'
    THEN 'EXTENDED PURCHASED LABOR'
    ELSE CCN_DATA.CLAIM_TYPE
  END) = RES_PCT.CLAIM_TYPE
AND 
AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
AND(
  CASE
    WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
    THEN 'Y'
    ELSE 'N'
  END) = RES_PCT.CUST_CREDIT_CATG_CODE
  /* FOR RESERVE GROUP */
  /* -SS- FIXME */
  --AND CASE WHEN GLA.PROD_CODE IS NULL OR GLA.PROD_CODE = ' ' THEN PCS.PROD_CODE ELSE GLA.PROD_CODE END = PRODGRP.MANF_PROD_CODE
AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
  --and CCN_DATA.CLAIM_NBR in (5783003,6235032)
UNION

  /* Material and Retrofit Material */
  (
  SELECT
    /* + NO_CPU_COSTING  */
    MLR.CLAIM_NBR AS CLAIM_NUMBER,
    MLR.STEP_NBR AS STEP_NUMBER,
    GLA.R12_ENTITY
    /* -SS- COMPANY */
    AS BUSINESS_UNIT,
    PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
    CTYPES.CLAIM_TYPE_DESCR AS CLAIM_TYPE,
    SUM(MLR.EXP_TYPE_AMOUNT * - 1) AS EXPENSE_AMOUNT,
    SUM(100 *(MLR.EXP_TYPE_AMOUNT * - 1 - TRUNC(MLR.EXP_TYPE_AMOUNT * - 1))) AS EXPENSE_AMOUNT_DEC,
    RES_PCT.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
    GLA.R12_ACCOUNT
    /* -SS- ACCOUNT */
    AS GL_ACCOUNT,
    ETS.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
    SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
    CASE
      WHEN GLA.R12_PRODUCT
        /* -SS- PROD_CODE */
        IS NULL
      OR GLA.R12_PRODUCT
        /* -SS- PROD_CODE */
        = ''
      THEN PCS.PROD_CODE
      ELSE GLA.R12_PRODUCT
        /* -SS- PROD_CODE */
    END AS GL_PROD_CODE,
    PCS.PROD_CODE AS MANF_PROD_CODE,
    SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
    CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
    CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
    (
    CASE
      WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
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
    /* PER JACKIE'S REQUEST ON 5/24/07 IF FAIL DATE = 1/1/1900 OR NULL THEN SET WARRANTY TYPE TO NO. */
    (
    CASE
      WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY')
      OR TD1.FULL_DATE IS NULL
      THEN 'NO'
      ELSE FCW.WA_POLICY_TYPE
    END) AS WARRANTY_TYPE,
    (
    CASE
      WHEN FCW.WA_RANGE = '1'
      THEN '1st Year Standard Warranty'
      WHEN FCW.WA_RANGE = '2'
      THEN '2nd-5th Year Standard Warranty'
      WHEN FCW.WA_RANGE = '5'
      THEN '> 5th Year Standard Warranty'
      ELSE 'Out of Standard Warranty'
    END) AS WARRANTY_DURATION,
    MLR.TRX_CURRENCY AS CURRENCY,
    (
    CASE
      WHEN GLA.R12_ENTITY NOT IN('5773', '5588')
        /* -SS- ASX.NATION_CURR='USD' */
      THEN 'USA'
      ELSE 'CAN'
        /* -SS-
        WHEN ASX.NATION_CURR='CAD' THEN 'CAN'
        ELSE 'CURRENCY: ' || ASX.NATION_CURR
        */
    END) AS COUNTRY_INDICATOR
    /* NEW FIELDS ADDED 5/21/07 */
    ,
    MLR.RETRO_ID AS RETROFIT_ID,
    GLA.R12_COST_CENTER
    /* -SS- COST_CENTER */
    AS GL_DEPT
    /* 2-5Year Specific */
    ,
    CASE
      WHEN a.CLAIM_NUMBER IS NULL
      THEN 10000 *(
        CASE
          WHEN
            --(PCS.PROD_CODE='0061' and CTYPES.CLAIM_TYPE_DESCR='MATERIAL') /* BR6 */
            (PCS.PROD_CODE IN('0054', '0197'))
            /* BR4 */
          OR(NVL(FCW.WA_RANGE, '0') NOT IN('2', '5'))
            /* BR3 */
          OR(ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) > 91)
            /* BR5 */
          OR(ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) > 24)
          THEN 0
          ELSE RES_PCT.RESERVE_PCT
        END)
      ELSE res_PCT1.RESERVE_PCT
    END AS IN_RESERVE_PERCENT
    --, 10000*(CASE WHEN PCS.PROD_CODE='0061'  or FCW.WA_RANGE<>'1' THEN 0 ELSE RES_PCT.RESERVE_PCT  END) AS IN_RESERVE_PERCENT
    ,
    ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
    ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) AS Start_Lag,
    100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH
    --,MLR.EXP_TYPE_AMOUNT *(CASE WHEN PCS.PROD_CODE='0061' then 0 ELSE RES_PCT.RESERVE_PCT  END)*-1  AS EXPENSE_AMT_IN_RES
    ,
    0 AS EXPENSE_AMT_IN_RES
    --,MLR.EXP_TYPE_AMOUNT *(1-(CASE WHEN PCS.PROD_CODE='0061' then 0 ELSE RES_PCT.RESERVE_PCT  END))*-1  AS EXPENSE_AMT_NOT_IN_RES
    ,
    0 AS EXPENSE_AMT_NOT_IN_RES
  FROM WC_MAT_LBR_ROLLUP MLR,
    EXPENSE_TYPE_SCD ET,
    DM_FAL_CLAIMS_WARRANTY_XRF FCW,
    TIME_DAY TD3,
    TIME_DAY TD2,
    TIME_DAY TD1,
    TIME_DAY TD,
    CLAIM_TASK_SCD CTASKS,
    CLAIM_TYPE_SCD CTYPES,
    R12_GL_ACCOUNT_SCD
    /* -SS- */
    GLA,
    EXPENSE_TYPE_SCD ETS,
    PROD_CODE_SCD PCS,
    CUST_ACCOUNT_SCD CACCT,
    SUBMIT_OFFICE_SCD SOS,
    PROD_CODE_XREF_RCPO_DR PRODGRP
    /* -SS- ,ACTUATE_SEC_XREF ASX */
    ,
    DM_WAR_CSN_RSV_PCT_REF RES_PCT,
    DM_WAR_CSN_RSV_PCT_REF RES_PCT1,
    UD_031_STDWTY_RSV_CLM_ADJ a
  WHERE 1 = 1
    --and MLR.CLAIM_NBR =1617369
    /*  this portion for 'MATERIAL','RETROFIT MATERIAL'  */
  AND(MLR.CLAIM_TYPE_SCD_KEY = 3
  OR MLR.CLAIM_TYPE_SCD_KEY = 10)
  AND MLR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY
  AND MLR.CLAIM_NBR = FCW.CLAIM_NBR (+)
  AND MLR.DETAIL_NBR = FCW.DETAIL_NBR (+)
  AND MLR.STEP_NBR = FCW.STEP_NBR(+)
    /* TD3 FOR TRX DATE */
  AND MLR.CCN_TRX_DATE_KEY = TD3.TIME_KEY
    /* TD2 FOR ORIGINAL SHIP DATE */
  AND MLR.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
    /* TD1 FOR FAIL DATE */
  AND MLR.FAIL_DATE_KEY = TD1.TIME_KEY
    /* TD FOR START DATE */
  AND MLR.START_DATE_KEY = TD.TIME_KEY
  AND MLR.CLAIM_TASK_SCD_KEY = CTASKS.CLAIM_TASK_SCD_KEY
  AND MLR.CLAIM_TYPE_SCD_KEY = CTYPES.CLAIM_TYPE_SCD_KEY
  AND MLR.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
  AND MLR.EXPENSE_TYPE_SCD_KEY = ETS.EXPENSE_TYPE_SCD_KEY
  AND MLR.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
  AND MLR.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
  AND MLR.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
    /* NATION CURRENCY */
    /* -SS- AND GLA.COMPANY=ASX.PSGL(+) */
    /* RESERVE PERCENT AND LAB/MAT CLASSIFICATION */
  AND CTYPES.CLAIM_TYPE_DESCR = RES_PCT.CLAIM_TYPE
  AND ETS.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR
  AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
  AND(
    CASE
      WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
      THEN 'Y'
      ELSE 'N'
    END) = RES_PCT.CUST_CREDIT_CATG_CODE
    /* FOR RESERVE GROUP */
  AND GLA.R12_ENTITY
    /* -SS- COMPANY */
    = PRODGRP.GL_LEDGER
    /* -SS- FIXME */
    --AND CASE WHEN GLA.PROD_CODE IS NULL OR GLA.PROD_CODE = ' ' THEN PCS.PROD_CODE ELSE GLA.PROD_CODE END = PRODGRP.MANF_PROD_CODE
  AND PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE
  AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
    /* Warranty specific */
    /* 6/27/07 msun only past 12 month needed */
    --AND TD3.FULL_DATE>=TO_DATE('6/1/2006','MM/DD/YYYY') AND TD3.FULL_DATE<TO_DATE('7/1/2015','MM/DD/YYYY')
  AND TD3.FULL_DATE >= TO_DATE('1/1/2000', 'MM/DD/YYYY')
  AND TD3.FULL_DATE < TO_DATE('12/31/2050', 'MM/DD/YYYY')
    --AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(td3.full_date))<=12
    --AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(TD3.full_date))>=1
  AND(GLA.R12_ACCOUNT
    /* -SS- ACCOUNT */
    LIKE '8062%'
    /* -SS- ???? */
  OR GLA.R12_ACCOUNT
    /* -SS- ACCOUNT */
    LIKE '0620%'
    /* -SS- ???? */
    )
    --and mlr.CLAIM_NBR in (5783003,6235032)
  AND mlr.CLAIM_NBR = a.CLAIM_NUMBER (+)
  AND a.claim_type = RES_PCT1.claim_type(+)
  GROUP BY MLR.CLAIM_NBR,
    MLR.STEP_NBR,
    GLA.R12_ENTITY
    /* -SS- COMPANY */
    ,
    PRODGRP.PRODUCT_CATEGORY,
    CTYPES.CLAIM_TYPE_DESCR,
    RES_PCT.EXPENSE_TYPE_CATG,
    GLA.R12_ACCOUNT
    /* -SS- ACCOUNT */
    ,
    ETS.EXPENSE_TYPE_DESCR,
    SOS.SUBMIT_OFFICE_NAME,
    GLA.R12_PRODUCT
    /* -SS- PROD_CODE */
    ,
    PCS.PROD_CODE,
    SOS.COMPANY_OWNED_IND,
    CACCT.ACCOUNT_NUMBER,
    CACCT.CUST_ACCT_NAME,
    (
    CASE
      WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
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
    CASE
      WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY')
      OR TD1.FULL_DATE IS NULL
      THEN 'NO'
      ELSE FCW.WA_POLICY_TYPE
    END),
    (
    CASE
      WHEN FCW.WA_RANGE = '1'
      THEN '1st Year Standard Warranty'
      WHEN FCW.WA_RANGE = '2'
      THEN '2nd-5th Year Standard Warranty'
      WHEN FCW.WA_RANGE = '5'
      THEN '> 5th Year Standard Warranty'
      ELSE 'Out of Standard Warranty'
    END),
    MLR.TRX_CURRENCY,
    (
    CASE
      WHEN GLA.R12_ENTITY NOT IN('5773', '5588')
        /* -SS- ASX.NATION_CURR='USD' */
      THEN 'USA'
      ELSE 'CAN'
        /* -SS-
        WHEN ASX.NATION_CURR='CAD' THEN 'CAN'
        ELSE 'CURRENCY: ' || ASX.NATION_CURR
        */
    END)
    /* NEW FIELDS ADDED 5/21/07 */
    ,
    MLR.RETRO_ID,
    GLA.R12_COST_CENTER
    /* -SS- COST_CENTER */
    /* 2-5Year Specific */
    ,
    CASE
      WHEN a.CLAIM_NUMBER IS NULL
      THEN 10000 *(
        CASE
          WHEN
            -- (PCS.PROD_CODE='0061' and CTYPES.CLAIM_TYPE_DESCR='MATERIAL') /* BR6 */
            (PCS.PROD_CODE IN('0054', '0197'))
            /* BR4 */
          OR(NVL(FCW.WA_RANGE, '0') NOT IN('2', '5'))
            /* BR3 */
          OR(ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) > 91)
            /* BR5 */
          OR(ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) > 24)
          THEN 0
          ELSE RES_PCT.RESERVE_PCT
        END)
      ELSE res_PCT1.RESERVE_PCT
    END,
    ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42),
    ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42),
    100 * TD3.YEAR + TD3.MONTH
  )
UNION ALL

  /*SPD, Retrofit Labor, Extended Purchase Labor   */
  (
  SELECT
    /* + NO_CPU_COSTING  */
    CCN_DATA.CLAIM_NBR AS CLAIM_NUMBER,
    CCN_DATA.STEP_NBR AS STEP_NUMBER,
    GLA.R12_ENTITY
    /* -SS- COMPANY */
    AS BUSINESS_UNIT,
    PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
    CCN_DATA.CLAIM_TYPE AS CLAIM_TYPE,
    CCN_DATA.DOLLAR_AMOUNT AS EXPENSE_AMOUNT,
    100 *(CCN_DATA.DOLLAR_AMOUNT - TRUNC(CCN_DATA.DOLLAR_AMOUNT)) AS EXPENSE_AMOUNT_DEC,
    CCN_DATA.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
    GLA.R12_ACCOUNT
    /* -SS- ACCOUNT */
    AS GL_ACCOUNT,
    CCN_DATA.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
    SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
    CASE
      WHEN GLA.R12_PRODUCT
        /* -SS- PROD_CODE */
        IS NULL
      OR GLA.R12_PRODUCT
        /* -SS- PROD_CODE */
        = ''
      THEN PCS.PROD_CODE
      ELSE GLA.R12_PRODUCT
        /* -SS- PROD_CODE */
    END AS GL_PROD_CODE,
    PCS.PROD_CODE AS MANF_PROD_CODE,
    SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
    CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
    CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
    (
    CASE
      WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
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
    /* PER JACKIE'S REQUEST ON 5/24/07 IF FAIL DATE = 1/1/1900 OR NULL THEN SET WARRANTY TYPE TO NO. */
    (
    CASE
      WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY')
      OR TD1.FULL_DATE IS NULL
      THEN 'NO'
      ELSE FCW.WA_POLICY_TYPE
    END) AS WARRANTY_TYPE,
    (
    CASE
      WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR'
      THEN 'Out of Standard Warranty'
      ELSE(
        CASE
          WHEN FCW.WA_RANGE = '1'
          THEN '1st Year Standard Warranty'
          WHEN FCW.WA_RANGE = '2'
          THEN '2nd-5th Year Standard Warranty'
          WHEN FCW.WA_RANGE = '5'
          THEN '> 5th Year Standard Warranty'
          ELSE 'Out of Standard Warranty'
        END)
    END) AS WARRANTY_DURATION,
    CCN_DATA.TRX_CURRENCY AS CURRENCY,
    (
    CASE
      WHEN GLA.R12_ENTITY NOT IN('5773', '5588')
        /* -SS- ASX.NATION_CURR='USD' */
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
    GLA.R12_COST_CENTER
    /* -SS- COST_CENTER */
    AS GL_DEPT
    /* 2-5Year Specific */
    ,
    CASE
      WHEN a.CLAIM_NUMBER IS NULL
      THEN 10000 *(
        CASE
          WHEN
            --(PCS.PROD_CODE='0061' and CCN_DATA.CLAIM_TYPE ='MATERIAL') /* BR6 */
            (PCS.PROD_CODE IN('0054', '0197'))
            /* BR4 */
          OR(NVL(FCW.WA_RANGE, '0') NOT IN('2', '5'))
            /* BR3 */
          OR(ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) > 91)
            /* BR5 */
          OR(ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) > 24)
            /*BR7*/
          THEN 0
          ELSE RES_PCT.RESERVE_PCT
        END)
      ELSE res_PCT1.RESERVE_PCT
    END AS IN_RESERVE_PERCENT
    --, 10000*(CASE WHEN PCS.PROD_CODE='0061'  or FCW.WA_RANGE<>'1' THEN 0 ELSE RES_PCT.RESERVE_PCT  END) AS IN_RESERVE_PERCENT
    ,
    ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
    ROUND((TD.FULL_DATE - TD2.FULL_DATE) / 30.42) AS Start_Lag,
    100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH
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
      /* + NO_CPU_COSTING  */
      'SPD/Retrofit Labor/Extended Purchased Labor' AS TYPE,
      LR.CLAIM_NBR,
      LR.RETRO_ID,
      CT.CLAIM_TYPE_CODE AS CLAIM_TYPE,
      (
      CASE
        WHEN EXPENSE_TYPE_SCD_KEY IN(58, 60, 61)
        THEN 'MATERIAL'
        ELSE 'LABOR'
      END) AS EXPENSE_TYPE_DESCR,
      (
      CASE
        WHEN EXPENSE_TYPE_SCD_KEY IN(58, 60, 61)
        THEN 'MATERIAL'
        ELSE 'LABOR'
      END) AS EXPENSE_TYPE_CATG,
      LR.CHARGE_COMM_PCT,
      LR.CHARGE_COMPANY_PCT,
      LR.ALLOCATED_EXP_TYPE_AMOUNT * - 1 AS DOLLAR_AMOUNT,
      LR.STEP_NBR
      /* DATES FROM DAY_TIME TABLE */
      ,
      LR.CCN_TRX_DATE_KEY,
      LR.ORIGINAL_SHIP_DATE_KEY,
      LR.FAIL_DATE_KEY,
      LR.START_DATE_KEY,
      LR.GL_ACCOUNT_SCD_KEY
      /* R12_GL_ACCOUNT_SCD /* -SS- */
      .GL_ACCOUNT_SCD_KEY */,
      LR.PROD_CODE_SCD_KEY
      /* PROD_CODE_SCD.PROD_CODE_SCD_KEY */
      ,
      LR.CUST_ACCOUNT_SCD_KEY
      /* CUST_ACCOUNT_SCD.CUST_ACCOUNT_SCD_KEY */
      ,
      LR.SUBMIT_OFFICE_SCD_KEY
      /* SUBMIT_OFFICE_SCD.SUBMIT_OFFICE_SCD_KEY */
      ,
      LR.TRX_CURRENCY
    FROM WC_LABOR_ROLLUP LR,
      TIME_DAY TD
      --, EXPENSE_TYPE_SCD ET
      ,
      CLAIM_TYPE_SCD CT,
      R12_GL_ACCOUNT_SCD
      /* -SS- */
      GLA
    WHERE 1 = 1
      /* for 'SPD','RETROFIT LABOR','EXTD PURCHASED LABOR' only */
    AND LR.CLAIM_TYPE_SCD_KEY IN(1, 2, 9)
    AND TD.TIME_KEY = LR.CCN_TRX_DATE_KEY
    AND TD.FULL_DATE >= TO_DATE('1/1/2000', 'MM/DD/YYYY')
    AND TD.FULL_DATE < TO_DATE('12/31/2050', 'MM/DD/YYYY')
      --AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(TD.full_date))<=12
      --AND MONTHS_BETWEEN(last_day(SYSDATE), last_day(TD.full_date))>=1
    AND GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
      /* COMMETED OUT PER PAT'S MEETING 6/7/07
      AND LR.EXPENSE_TYPE_SCD_KEY = LR.EXPENSE_TYPE_SCD_KEY
      AND LR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY
      */
    AND LR.CLAIM_TYPE_SCD_KEY = CT.CLAIM_TYPE_SCD_KEY
      --AND CT.CLAIM_TYPE_CODE  IN ('SPD','RETROFIT LABOR','EXTD PURCHASED LABOR')
    AND(GLA.R12_ACCOUNT
      /* -SS- ACCOUNT */
      LIKE '8062%'
      /* -SS- ???? */
    OR GLA.R12_ACCOUNT
      /* -SS- ACCOUNT */
      LIKE '0620%'
      /* -SS- ???? */
      )
      --AND LR.CLAIM_NBR  = 3212568
    ) CCN_DATA,
    (SELECT DISTINCT CLAIM_NBR, STEP_NBR, WA_POLICY_TYPE, WA_RANGE FROM DM_FAL_CLAIMS_WARRANTY_XRF
    ) FCW,
    TIME_DAY TD3,
    TIME_DAY TD2,
    TIME_DAY TD1,
    TIME_DAY TD,
    R12_GL_ACCOUNT_SCD
    /* -SS- */
    GLA
    --,EXPENSE_TYPE_SCD ETS
    ,
    PROD_CODE_SCD PCS,
    CUST_ACCOUNT_SCD CACCT,
    SUBMIT_OFFICE_SCD SOS,
    PROD_CODE_XREF_RCPO_DR PRODGRP
    /* -SS- ,ACTUATE_SEC_XREF ASX */
    ,
    DM_WAR_CSN_RSV_PCT_REF RES_PCT,
    DM_WAR_CSN_RSV_PCT_REF RES_PCT1,
    UD_031_STDWTY_RSV_CLM_ADJ a
  WHERE 1 = 1
    /* CONCESSION CLAIM TYPE */
  AND CCN_DATA.CLAIM_NBR = FCW.CLAIM_NBR (+)
    --AND CCN_DATA.DETAIL_NBR=FCW.DETAIL_NBR
  AND CCN_DATA.STEP_NBR = FCW.STEP_NBR(+)
    /* TD3 FOR TRX DATE */
  AND CCN_DATA.CCN_TRX_DATE_KEY = TD3.TIME_KEY
    /* TD2 FOR ORIGINAL SHIP DATE */
  AND CCN_DATA.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
    /* TD1 FOR FAIL DATE */
  AND CCN_DATA.FAIL_DATE_KEY = TD1.TIME_KEY
    /* TD FOR START DATE */
  AND CCN_DATA.START_DATE_KEY = TD.TIME_KEY
  AND CCN_DATA.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
    --AND CCN_DATA.EXPENSE_TYPE_SCD_KEY= ETS.EXPENSE_TYPE_SCD_KEY
  AND CCN_DATA.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
  AND CCN_DATA.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
  AND CCN_DATA.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
    /* NATION CURRENCY */
    /* -SS- AND GLA.COMPANY=ASX.PSGL(+) */
    /* RESERVE PERCENT FROM LAB/MAT CLASSIFICATION */
  AND(
    CASE
      WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR'
      THEN 'EXTENDED PURCHASED LABOR'
      ELSE CCN_DATA.CLAIM_TYPE
    END) = RES_PCT.CLAIM_TYPE
  AND CCN_DATA.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR
  AND CCN_DATA.EXPENSE_TYPE_CATG = UPPER(RES_PCT.EXPENSE_TYPE_CATG)
  AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
  AND(
    CASE
      WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
      THEN 'Y'
      ELSE 'N'
    END) = RES_PCT.CUST_CREDIT_CATG_CODE
    /* FOR RESERVE GROUP */
  AND GLA.R12_ENTITY
    /* -SS- COMPANY */
    = PRODGRP.GL_LEDGER
    /* -SS- FIXME */
    --AND CASE WHEN GLA.PROD_CODE IS NULL OR GLA.PROD_CODE = ' ' THEN PCS.PROD_CODE ELSE GLA.PROD_CODE END = PRODGRP.MANF_PROD_CODE
  AND PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE
  AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
    --and CCN_DATA.CLAIM_NBR in (5783003,6235032)
  AND CCN_DATA.CLAIM_NBR = a.CLAIM_NUMBER (+)
  AND a.claim_type = RES_PCT1.claim_type(+)
  )