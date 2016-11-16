/* Formatted on 9/25/2015 3:38:23 PM (QP5 v5.277) */
SELECT /*+ NO_CPU_COSTING */
      CCN_DATA.CLAIM_NBR AS CLAIM_NUMBER,
       CCN_DATA.STEP_NBR AS STEP_NUMBER,
       GLA.COMPANY AS BUSINESS_UNIT,
       CCN_DATA.CLAIM_TYPE AS CLAIM_TYPE,
       /* 1 -- IN 548 DAYS; 0 -- OUT OF 548 DAYS */
       CASE
          WHEN TD1.FULL_DATE - TD2.FULL_DATE <= 548 THEN '<= 548 DAYS'
          ELSE '> 548 DAYS'
       END
          AS CONCESSION_DAYS,
       ROUND (CCN_DATA.DOLLAR_AMOUNT, 2) AS EXPENSE_AMOUNT,
       100 * (CCN_DATA.DOLLAR_AMOUNT - TRUNC (CCN_DATA.DOLLAR_AMOUNT))
          AS EXPENSE_AMOUNT_DEC,
       CCN_DATA.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
       GLA.ACCOUNT AS GL_ACCOUNT,
       CCN_DATA.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
       SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
       GLA.PROD_CODE AS GL_PROD_CODE,
       PCS.PROD_CODE AS MANF_PROD_CODE,
       SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
       CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
       CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
       (CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1' THEN 'Y' ELSE 'N' END)
          AS INTERNAL_EXTERNAL,
       TD3.FULL_DATE AS TRX_DATE,
       TO_CHAR (TD3.YEAR) AS TRX_YEAR,
       TO_CHAR (TD3.MONTH) AS TRX_MONTH,
         CEIL (
            ABS (
               MONTHS_BETWEEN (TD3.FULL_DATE,
                               ADD_MONTHS (TRUNC (SYSDATE, 'MM'), -1))))
       + 1
          AS INTMONTHS_TRX_TO_BASE,
         CEIL (
            ABS (
               MONTHS_BETWEEN (TD2.FULL_DATE,
                               ADD_MONTHS (TRUNC (SYSDATE, 'MM'), -1))))
       + 1
          AS INTMONTHS_SHIP_TO_BASE,
       TD2.FULL_DATE AS SHIP_DATE,
       (TD2.YEAR * 100 + TD2.MONTH) AS SHIP_YEAR_MONTH,
       /* 7/30 Jackie requested   */
       --CEIL( ( (TD3.TIME_KEY - TD2.TIME_KEY) / 30.42 ) ) + 1 AS INTMONTHS_SHIP_TO_TRX,
       0 AS INTMONTHS_SHIP_TO_TRX,
       TD.FULL_DATE AS START_DATE,
       ( (TD3.TIME_KEY - TD.TIME_KEY) / 30.42) AS INTMONTHS_START_TO_TRX,
       TD1.FULL_DATE AS FAIL_DATE,
       ( (TD3.TIME_KEY - TD1.TIME_KEY) / 30.42) AS INTMONTHS_FAIL_TO_TRX,
       CCN_DATA.TRX_CURRENCY AS CURRENCY,
       (CASE
           WHEN ASX.NATION_CURR = 'USD' THEN 'USA'
           WHEN ASX.NATION_CURR = 'CAD' THEN 'CAN'
           ELSE 'CURRENCY:' || ASX.NATION_CURR
        END)
          AS COUNTRY_INDICATOR/* NEW FIELDS ADDED 5/21/07 */
       ,
       CCN_DATA.RETRO_ID AS RETROFIT_ID,
       GLA.COST_CENTER AS GL_DEPT/*New Logic by Jackie (6/12/07)Only for concession detail Report(All >548 days are ‘Not In Reserve no matter what) */
       ,
       CASE
          WHEN a.CLAIM_NUMBER IS NULL
          THEN
               10000
             * (CASE
                   WHEN TD1.FULL_DATE - TD2.FULL_DATE > 548 THEN 0
                   ELSE RES_PCT.RESERVE_PCT
                END)
          ELSE
             res_PCT1.RESERVE_PCT
       END
          AS IN_RESERVE_PERCENT,
       ROUND ( (TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
       100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH--,CASE WHEN TD1.FULL_DATE-TD2.FULL_DATE <=548 THEN  CCN_DATA.DOLLAR_AMOUNT*RES_PCT.RESERVE_PCT ELSE 0 END   AS EXPENSE_AMT_IN_RES
       ,
       0 AS EXPENSE_AMT_IN_RES--,CASE WHEN TD1.FULL_DATE-TD2.FULL_DATE >548 THEN CCN_DATA.DOLLAR_AMOUNT else CCN_DATA.DOLLAR_AMOUNT*(1-RES_PCT.RESERVE_PCT) END   AS EXPENSE_AMT_NOT_IN_RES
       ,
       0 AS EXPENSE_AMT_NOT_IN_RES
  FROM (  /* THIS IS THE CORE PORTION FOR CONCESSION CLAIM TYPE TO RETRIEVE EXPENSE RELATED INFORMATION */

          SELECT /*+ NO_CPU_COSTING */
                'TRANE_LABOR' AS TYPE,
                 MLR.CLAIM_NBR,
                 MLR.RETRO_ID,
                 'CONCESSION' AS CLAIM_TYPE,
                 'TRANE COMPANY' AS EXPENSE_TYPE_DESCR,
                 'LABOR' AS EXPENSE_TYPE_CATG,
                 LR.CHARGE_COMM_PCT,
                 LR.CHARGE_COMPANY_PCT,
                 (  (  SUM ( (LR2.APPR_AMT))
                     + MAX (  (LR.APPR_DIAGNOSTIC_AMT + LR.APPR_TRAVEL_AMT)
                            / (SELECT COUNT (DISTINCT LRS.STEP_NBR)
                                 FROM WC_LABOR_ROLLUP LRS
                                WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR)))
                  * LR.CHARGE_COMPANY_PCT)
                    AS DOLLAR_AMOUNT,
                 MLR.STEP_NBR/* DATES FROM DAY_TIME TABLE */
                 ,
                 MLR.CCN_TRX_DATE_KEY,
                 MLR.ORIGINAL_SHIP_DATE_KEY,
                 MLR.FAIL_DATE_KEY,
                 MLR.START_DATE_KEY,
                 MLR.GL_ACCOUNT_SCD_KEY /* GL_ACCOUNT_SCD.GL_ACCOUNT_SCD_KEY */
                                       ,
                 MLR.PROD_CODE_SCD_KEY   /* PROD_CODE_SCD.PROD_CODE_SCD_KEY */
                                      ,
                 MLR.CUST_ACCOUNT_SCD_KEY /* CUST_ACCOUNT_SCD.CUST_ACCOUNT_SCD_KEY */
                                         ,
                 MLR.SUBMIT_OFFICE_SCD_KEY /* SUBMIT_OFFICE_SCD.SUBMIT_OFFICE_SCD_KEY */
                                          ,
                 MLR.TRX_CURRENCY
            FROM WC_MAT_LBR_ROLLUP MLR,
                 WC_LABOR_ROLLUP LR,
                 TIME_DAY TD,
                 (SELECT DISTINCT CLAIM_NBR,
                                  DETAIL_NBR,
                                  STEP_NBR,
                                  APPR_AMT
                    FROM WC_LABOR_ROLLUP LR1
                   WHERE     CLAIM_TYPE_SCD_KEY = 11
                         AND EXISTS
                                (SELECT 'X'
                                   FROM GL_ACCOUNT_SCD
                                  WHERE     lr1.GL_ACCOUNT_SCD_KEY =
                                               GL_ACCOUNT_SCD_KEY
                                        AND ACCOUNT IN ('710000', '806300')))
                 LR2--, CLAIM_TYPE_SCD CT
                 ,
                 GL_ACCOUNT_SCD GLA
           WHERE     TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY
                 /* CONCESSION CLAIM TYPE ONLY */
                 AND MLR.CLAIM_TYPE_SCD_KEY = 11
                 --AND TD.FULL_DATE>=TO_DATE('1/1/2006','MM/DD/YYYY') and TD.FULL_DATE < TO_DATE('6/1/2007','MM/DD/YYYY')
                 AND TD.FULL_DATE >= TO_DATE ('1/1/2001', 'MM/DD/YYYY')
                 AND MLR.DETAIL_NBR = LR.DETAIL_NBR
                 AND MLR.CLAIM_NBR = LR.CLAIM_NBR
                 AND MLR.STEP_NBR = LR.STEP_NBR
                 AND MLR.STEP_NBR = LR2.STEP_NBR
                 AND MLR.DETAIL_NBR = LR2.DETAIL_NBR
                 AND MLR.CLAIM_NBR = LR2.CLAIM_NBR
                 /* COMMETED OUT PER PAT'S MEETING 6/7/07
                 AND MLR.EXPENSE_TYPE_SCD_KEY = LR.EXPENSE_TYPE_SCD_KEY
                 AND MLR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY
                 */
                 --AND MLR.CLAIM_TYPE_SCD_KEY = CT.CLAIM_TYPE_SCD_KEY
                 --AND CT.CLAIM_TYPE_CODE ='CONCESSION'
                 AND GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY
                 AND GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
                 AND GLA.ACCOUNT IN ('710000', '806300')
								 AND MLR.CLAIM_NBR IN ('9070848','9100994')
--                 AND MLR.CLAIM_NBR IN ('8705840',
--                                       '8667362',
--                                       '8728663',
--                                       '8707634',
--                                       '8727943',
--                                       '8618275')
        GROUP BY MLR.CLAIM_NBR--, CT.CLAIM_TYPE_CODE
                 ,
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
				) CCN_DATA,
       TIME_DAY TD3,
       TIME_DAY TD2,
       TIME_DAY TD1,
       TIME_DAY TD,
       GL_ACCOUNT_SCD GLA--,EXPENSE_TYPE_SCD ETS
       ,
       PROD_CODE_SCD PCS,
       CUST_ACCOUNT_SCD CACCT,
       SUBMIT_OFFICE_SCD SOS,
       ACTUATE_SEC_XREF ASX,
       DM_WAR_CSN_RSV_PCT_REF RES_PCT,
       DM_WAR_CSN_RSV_PCT_REF RES_PCT1,
       UD_031_STDWTY_RSV_CLM_ADJ a
 WHERE     1 = 1
       /* TD3 FOR TRX DATE */
       AND CCN_DATA.CCN_TRX_DATE_KEY = TD3.TIME_KEY
       /* TD2 FOR ORIGINAL SHIP DATE */
       AND CCN_DATA.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
       /* TD1 FOR FAIL DATE */
       AND CCN_DATA.FAIL_DATE_KEY = TD1.TIME_KEY
       /* TD FOR START DATE */
       AND CCN_DATA.START_DATE_KEY = TD.TIME_KEY
       AND CCN_DATA.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
       AND CCN_DATA.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
       AND CCN_DATA.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
       AND CCN_DATA.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
       /* NATION CURRENCY */
       AND GLA.COMPANY = ASX.PSGL(+)
       /* RESERVE PERCENT FROM LAB/MAT CLASSIFICATION */
       AND CCN_DATA.CLAIM_TYPE = RES_PCT.CLAIM_TYPE
       AND CCN_DATA.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR
       AND CCN_DATA.EXPENSE_TYPE_CATG = UPPER (RES_PCT.EXPENSE_TYPE_CATG)
       AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
       AND (CASE
               WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1' THEN 'Y'
               ELSE 'N'
            END) = RES_PCT.CUST_CREDIT_CATG_CODE
       /* CONCESSION SPECIFIC */
       ---AND (GLA.COMPANY ='CSD' OR GLA.COMPANY ='CAN'   OR GLA.COMPANY LIKE 'GS%')
       --AND (GLA.ACCOUNT IN ('710000','806300'))
       AND CCN_DATA.CLAIM_NBR = a.CLAIM_NUMBER(+)
       AND a.claim_type = RES_PCT1.claim_type(+)
;
