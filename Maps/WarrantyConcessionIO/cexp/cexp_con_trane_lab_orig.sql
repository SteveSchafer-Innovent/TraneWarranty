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
								 					and td.year = 2016
													and td.month = 10
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
                 MLR.RETRO_ID;
								 
