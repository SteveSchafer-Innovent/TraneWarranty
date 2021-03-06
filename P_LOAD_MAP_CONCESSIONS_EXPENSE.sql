CREATE OR REPLACE PROCEDURE DBO.P_LOAD_MAP_CONCESSIONS_EXPENSE
/**********************************************************************************
* $Workfile: P_LOAD_MAP_CONCESSIONS_EXPENSE.sql $
*  $Revision: 2 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/MAP_CONCESSION_EXPENSE_DATA/P_LOAD_MAP_CONCESSIONS_EXPENSE.sql $
*  $Author: Laiqi $
*  $Date: 12/10/16 2:20p $
*
* Description: Procedure load the MAP_CONCESSION_EXPENSE_DATA table that is used by the
*           Actuate IOBs for the Warranty and Reserve reports. This table improves IOB caching performance.
*
*           Target:     DWTRNP.DBO.MAP_CONCESSION_EXPENSE_DATA
*           Source:     DWTRNP.DBO.
*
* Revisions: 
* 
*   change Date    Description 
*   -----------         ----------- 
*   12/10/2016      Pam Nelson, laiqi, IR - Initial creation for SMART P4 project - TTP 14939
*                           SQL Development done by Innovent Solutions
***********************************************************************************/ 
as

BEGIN

P_TRUNCATE_LISTED_TABLE( 'DBO','MAP_CONCESSION_EXPENSE_DATA');
 
--Load table MAP_CONCESSIONS_EXPENSE_DATA

INSERT /*+ APPEND */
    INTO MAP_CONCESSION_EXPENSE_DATA
SELECT 
        /*+ NO_CPU_COSTING */
        CCN_DATA.CLAIM_NBR AS CLAIM_NUMBER,
        CCN_DATA.STEP_NBR AS STEP_NUMBER,
        GLA.R12_ENTITY AS BUSINESS_UNIT,
        CCN_DATA.CLAIM_TYPE AS CLAIM_TYPE,
        CASE WHEN TD1.FULL_DATE - TD2.FULL_DATE <= 548
            THEN '<= 548 DAYS'
            ELSE '> 548 DAYS'
        END AS CONCESSION_DAYS,
        ROUND(CCN_DATA.DOLLAR_AMOUNT, 2) AS EXPENSE_AMOUNT,
        100 *(CCN_DATA.DOLLAR_AMOUNT - TRUNC(CCN_DATA.DOLLAR_AMOUNT)) AS EXPENSE_AMOUNT_DEC,
        CCN_DATA.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
        GLA.R12_ACCOUNT AS GL_ACCOUNT, -- -SS- ACCOUNT
        CCN_DATA.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
        SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
        GLA.R12_PRODUCT AS GL_PROD_CODE, -- -SS- PROD_CODE
        PCS.PROD_CODE AS MANF_PROD_CODE,
        SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
        CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
        CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
        (
        CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
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
        0 AS INTMONTHS_SHIP_TO_TRX,
        TD.FULL_DATE AS START_DATE,
        ((TD3.TIME_KEY - TD.TIME_KEY) / 30.42) AS INTMONTHS_START_TO_TRX,
        TD1.FULL_DATE AS FAIL_DATE,
        ((TD3.TIME_KEY - TD1.TIME_KEY) / 30.42) AS INTMONTHS_FAIL_TO_TRX,
        CCN_DATA.TRX_CURRENCY AS CURRENCY,
        (
        CASE WHEN GLA.R12_ENTITY IN('5773', '5588')
            THEN 'CAN'
            ELSE 'USA'
        END) AS COUNTRY_INDICATOR,
        CCN_DATA.RETRO_ID AS RETROFIT_ID,
        --GLA.R12_COST_CENTER AS GL_DEPT,
        GLA.PS_COST_CENTER AS GL_DEPT,
        CASE WHEN A.CLAIM_NUMBER IS NULL
            THEN 10000 *(
                CASE WHEN TD1.FULL_DATE - TD2.FULL_DATE > 548
                    THEN 0
                    ELSE RES_PCT.RESERVE_PCT
                END)
            ELSE RES_PCT1.RESERVE_PCT
        END AS IN_RESERVE_PERCENT,
        ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
        100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH,
        0 AS EXPENSE_AMT_IN_RES,
        0 AS EXPENSE_AMT_NOT_IN_RES
    FROM
        (
            /* THIS IS THE CORE PORTION FOR CONCESSION CLAIM TYPE TO RETRIEVE EXPENSE RELATED INFORMATION */
            SELECT
                    /*+ NO_CPU_COSTING */
                    'TRANE_MATERIAL' AS TYPE,
                    MLR.CLAIM_NBR,
                    MLR.RETRO_ID,
                    'CONCESSION' AS CLAIM_TYPE,
                    'TRANE COMPANY' AS EXPENSE_TYPE_DESCR,
                    'MATERIAL' AS EXPENSE_TYPE_CATG,
                    LR.CHARGE_COMM_PCT,
                    LR.CHARGE_COMPANY_PCT,
                    MAX(((LR.APPR_SUBLET_MAT_AMT + LR.APPR_SUBLET_REF_AMT + LR.APPR_SUBLET_SERV_AMT) /
                    (
                        SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
                    )
                    * LR.CHARGE_COMPANY_PCT)) AS DOLLAR_AMOUNT,
                    MLR.STEP_NBR,
                    MLR.CCN_TRX_DATE_KEY,
                    MLR.ORIGINAL_SHIP_DATE_KEY,
                    MLR.FAIL_DATE_KEY,
                    MLR.START_DATE_KEY,
                    MLR.GL_ACCOUNT_SCD_KEY,
                    MLR.PROD_CODE_SCD_KEY,
                    MLR.CUST_ACCOUNT_SCD_KEY,
                    MLR.SUBMIT_OFFICE_SCD_KEY,
                    MLR.TRX_CURRENCY
                FROM
                    WC_MAT_LBR_ROLLUP MLR
                INNER JOIN WC_LABOR_ROLLUP LR         ON MLR.DETAIL_NBR = LR.DETAIL_NBR AND MLR.CLAIM_NBR = LR.CLAIM_NBR AND MLR.STEP_NBR = LR.STEP_NBR
                INNER JOIN TIME_DAY TD                ON TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY
                INNER JOIN R12_GL_ACCOUNT_SCD GLA     ON GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY
                INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
                WHERE
                    /* CONCESSION CLAIM TYPE ONLY */
                    MLR.CLAIM_TYPE_SCD_KEY = 11
                    AND(GLA.R12_ENTITY IN('5773', '5588', '5575', '5743', '9256', '9258', '9298', '9299')
                    OR(GLA.R12_ENTITY = '9999' AND GLA.PS_COMPANY NOT LIKE 'GL%'))
                    AND TD.FULL_DATE >= TO_DATE('1/1/2001', 'MM/DD/YYYY')
                    AND(AFU.EQUAL_710000 = 'Y'
                    OR AFU.EQUAL_806300 = 'Y') -- SR one to one match
                GROUP BY
                    MLR.CLAIM_NBR,
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
            UNION ALL
            -- CONCESSION - COMM_MATERIAL
            SELECT 
                    /*+ NO_CPU_COSTING */
                    'COMM_MATERIAL' AS TYPE,
                    MLR.CLAIM_NBR,
                    MLR.RETRO_ID,
                    'CONCESSION' AS CLAIM_TYPE,
                    'COMMISSION' AS EXPENSE_TYPE_DESCR,
                    'MATERIAL' AS EXPENSE_TYPE_CATG,
                    LR.CHARGE_COMM_PCT,
                    LR.CHARGE_COMPANY_PCT,
                    MAX(((LR.APPR_SUBLET_MAT_AMT + LR.APPR_SUBLET_REF_AMT + LR.APPR_SUBLET_SERV_AMT) /
                    (
                        SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
                    )
                    * LR.CHARGE_COMM_PCT)) AS DOLLAR_AMOUNT,
                    MLR.STEP_NBR,
                    MLR.CCN_TRX_DATE_KEY,
                    MLR.ORIGINAL_SHIP_DATE_KEY,
                    MLR.FAIL_DATE_KEY,
                    MLR.START_DATE_KEY,
                    MLR.GL_ACCOUNT_SCD_KEY,
                    MLR.PROD_CODE_SCD_KEY,
                    MLR.CUST_ACCOUNT_SCD_KEY,
                    MLR.SUBMIT_OFFICE_SCD_KEY,
                    MLR.TRX_CURRENCY
                FROM
                    WC_MAT_LBR_ROLLUP MLR
                INNER JOIN WC_LABOR_ROLLUP LR ON MLR.DETAIL_NBR = LR.DETAIL_NBR
                INNER JOIN TIME_DAY TD        ON TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY AND MLR.CLAIM_NBR = LR.CLAIM_NBR AND MLR.STEP_NBR = LR.STEP_NBR
                INNER JOIN R12_GL_ACCOUNT_SCD GLA -- -SS- OTR
                                                      ON GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY
                INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
                WHERE
                    /* CONCESSION CLAIM TYPE ONLY */
                    MLR.CLAIM_TYPE_SCD_KEY = 11
                    AND(GLA.R12_ENTITY IN('5773', '5588', '5575', '5743', '9256', '9258', '9298', '9299')
                    OR(GLA.R12_ENTITY = '9999' AND GLA.PS_COMPANY NOT LIKE 'GL%'))
                    AND TD.FULL_DATE >= TO_DATE('1/1/2001', 'MM/DD/YYYY')
                    AND AFU.EQUAL_428000 = 'Y'
                GROUP BY
                    MLR.CLAIM_NBR,
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
            UNION ALL
            -- CONCESSION - TRANE_LABOR
            SELECT 
                    /*+ NO_CPU_COSTING */
                    'TRANE_LABOR' AS TYPE,
                    MLR.CLAIM_NBR,
                    MLR.RETRO_ID,
                    'CONCESSION' AS CLAIM_TYPE,
                    'TRANE COMPANY' AS EXPENSE_TYPE_DESCR,
                    'LABOR' AS EXPENSE_TYPE_CATG,
                    LR.CHARGE_COMM_PCT,
                    LR.CHARGE_COMPANY_PCT,
                    ((SUM((LR2.APPR_AMT)) + MAX((LR.APPR_DIAGNOSTIC_AMT + LR.APPR_TRAVEL_AMT) /
                    (
                        SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
                    )
                    )) * LR.CHARGE_COMPANY_PCT) AS DOLLAR_AMOUNT,
                    MLR.STEP_NBR,
                    MLR.CCN_TRX_DATE_KEY,
                    MLR.ORIGINAL_SHIP_DATE_KEY,
                    MLR.FAIL_DATE_KEY,
                    MLR.START_DATE_KEY,
                    MLR.GL_ACCOUNT_SCD_KEY,
                    MLR.PROD_CODE_SCD_KEY,
                    MLR.CUST_ACCOUNT_SCD_KEY,
                    MLR.SUBMIT_OFFICE_SCD_KEY,
                    MLR.TRX_CURRENCY
                FROM
                    WC_MAT_LBR_ROLLUP MLR
                INNER JOIN WC_LABOR_ROLLUP LR ON MLR.DETAIL_NBR = LR.DETAIL_NBR AND MLR.CLAIM_NBR = LR.CLAIM_NBR AND MLR.STEP_NBR = LR.STEP_NBR
                INNER JOIN TIME_DAY TD        ON TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY
                INNER JOIN
                    (SELECT DISTINCT CLAIM_NBR, DETAIL_NBR, STEP_NBR, APPR_AMT FROM WC_LABOR_ROLLUP LR1 WHERE CLAIM_TYPE_SCD_KEY = 11 AND EXISTS
                                (SELECT 'X' FROM R12_GL_ACCOUNT_SCD GLA
                                        INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
                                        WHERE
                                            LR1.GL_ACCOUNT_SCD_KEY = GL_ACCOUNT_SCD_KEY
                                            AND(AFU.EQUAL_710000 = 'Y'
                                            OR AFU.EQUAL_806300 = 'Y') -- SR One to One
                                )
                    )
                    LR2 ON MLR.STEP_NBR = LR2.STEP_NBR
                    AND MLR.DETAIL_NBR = LR2.DETAIL_NBR
                    AND MLR.CLAIM_NBR = LR2.CLAIM_NBR
                INNER JOIN R12_GL_ACCOUNT_SCD GLA     ON GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY AND GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
                INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
                WHERE
                    /* CONCESSION CLAIM TYPE ONLY */
                    MLR.CLAIM_TYPE_SCD_KEY = 11
                    AND(GLA.R12_ENTITY IN('5773', '5588', '5575', '5743', '9256', '9258', '9298', '9299')
                    OR(GLA.R12_ENTITY = '9999' AND GLA.PS_COMPANY NOT LIKE 'GL%'))
                    AND TD.FULL_DATE >= TO_DATE('1/1/2001', 'MM/DD/YYYY')
                    AND(AFU.EQUAL_710000 = 'Y'
                    OR AFU.EQUAL_806300 = 'Y') -- SR One to One Match
                GROUP BY
                    MLR.CLAIM_NBR,
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
            UNION ALL
            -- CONCESSION - COMM_LABOR
            SELECT 
                    /*+ NO_CPU_COSTING */
                    'COMM_LABOR' AS TYPE,
                    MLR.CLAIM_NBR,
                    MLR.RETRO_ID,
                    'CONCESSION' AS CLAIM_TYPE,
                    'COMMISSION' AS EXPENSE_TYPE_DESCR,
                    'LABOR' AS EXPENSE_TYPE_CATG,
                    LR.CHARGE_COMM_PCT,
                    LR.CHARGE_COMPANY_PCT,
                    ((SUM((LR2.APPR_AMT)) + MAX((LR.APPR_DIAGNOSTIC_AMT + LR.APPR_TRAVEL_AMT) /
                    (
                        SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
                    )
                    )) * LR.CHARGE_COMM_PCT) AS DOLLAR_AMOUNT,
                    MLR.STEP_NBR,
                    MLR.CCN_TRX_DATE_KEY,
                    MLR.ORIGINAL_SHIP_DATE_KEY,
                    MLR.FAIL_DATE_KEY,
                    MLR.START_DATE_KEY,
                    MLR.GL_ACCOUNT_SCD_KEY,
                    MLR.PROD_CODE_SCD_KEY,
                    MLR.CUST_ACCOUNT_SCD_KEY,
                    MLR.SUBMIT_OFFICE_SCD_KEY,
                    MLR.TRX_CURRENCY
                FROM
                    WC_MAT_LBR_ROLLUP MLR
                INNER JOIN WC_LABOR_ROLLUP LR ON MLR.DETAIL_NBR = LR.DETAIL_NBR AND MLR.CLAIM_NBR = LR.CLAIM_NBR AND MLR.STEP_NBR = LR.STEP_NBR
                INNER JOIN TIME_DAY TD        ON TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY
                INNER JOIN
                    (SELECT DISTINCT CLAIM_NBR, DETAIL_NBR, STEP_NBR, APPR_AMT FROM WC_LABOR_ROLLUP LR1 WHERE CLAIM_TYPE_SCD_KEY = 11 AND EXISTS
                                (SELECT 'X' FROM R12_GL_ACCOUNT_SCD DIST
                                        INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
                                        WHERE
                                            LR1.GL_ACCOUNT_SCD_KEY = GL_ACCOUNT_SCD_KEY
                                            AND AFU.EQUAL_428000 = 'Y'
                                )
                    )
                    LR2 ON MLR.STEP_NBR = LR2.STEP_NBR
                    AND MLR.DETAIL_NBR = LR2.DETAIL_NBR
                    AND MLR.CLAIM_NBR = LR2.CLAIM_NBR
                INNER JOIN R12_GL_ACCOUNT_SCD GLA     ON GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY AND GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
                INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
                WHERE
                    /* CONCESSION CLAIM TYPE ONLY */
                    MLR.CLAIM_TYPE_SCD_KEY = 11
                    AND(GLA.R12_ENTITY IN('5773', '5588', '5575', '5743', '9256', '9258', '9298', '9299')
                    OR(GLA.R12_ENTITY = '9999' AND GLA.PS_COMPANY NOT LIKE 'GL%'))
                    AND TD.FULL_DATE >= TO_DATE('1/1/2001', 'MM/DD/YYYY')
                    AND AFU.EQUAL_428000 = 'Y'
                GROUP BY
                    MLR.CLAIM_NBR,
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
            UNION ALL

            /* THIS IS THE CORE PORTION FOR SPD CLAIM TYPE TO RETRIEVE EXPENSE RELATED INFORMATION */
            -- SPD - TRANE_MATERIAL
            SELECT 
                    /*+ NO_CPU_COSTING */
                    'TRANE_MATERIAL' AS TYPE,
                    MLR.CLAIM_NBR,
                    MLR.RETRO_ID,
                    'SPD' AS CLAIM_TYPE,
                    'MATERIAL' AS EXPENSE_TYPE_DESCR,
                    'MATERIAL' AS EXPENSE_TYPE_CATG,
                    LR.CHARGE_COMM_PCT,
                    LR.CHARGE_COMPANY_PCT,
                    MAX(((LR.APPR_SUBLET_MAT_AMT + LR.APPR_SUBLET_REF_AMT + LR.APPR_SUBLET_SERV_AMT) /
                    (
                        SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
                    )
                    * LR.CHARGE_COMPANY_PCT)) AS DOLLAR_AMOUNT,
                    MLR.STEP_NBR,
                    MLR.CCN_TRX_DATE_KEY,
                    MLR.ORIGINAL_SHIP_DATE_KEY,
                    MLR.FAIL_DATE_KEY,
                    MLR.START_DATE_KEY,
                    MLR.GL_ACCOUNT_SCD_KEY,
                    MLR.PROD_CODE_SCD_KEY,
                    MLR.CUST_ACCOUNT_SCD_KEY,
                    MLR.SUBMIT_OFFICE_SCD_KEY,
                    MLR.TRX_CURRENCY
                FROM
                    WC_MAT_LBR_ROLLUP MLR
                INNER JOIN WC_LABOR_ROLLUP LR         ON MLR.DETAIL_NBR = LR.DETAIL_NBR AND MLR.CLAIM_NBR = LR.CLAIM_NBR AND MLR.STEP_NBR = LR.STEP_NBR
                INNER JOIN TIME_DAY TD                ON TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY
                INNER JOIN R12_GL_ACCOUNT_SCD GLA     ON GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY --  /* -SS- */
                INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
                WHERE
                    /* SPD CLAIM TYPE ONLY */
                    MLR.CLAIM_TYPE_SCD_KEY = 1
                    AND(GLA.R12_ENTITY IN('5773', '5588', '5575', '5743', '9256', '9258', '9298', '9299')
                    OR(GLA.R12_ENTITY = '9999' AND GLA.PS_COMPANY NOT LIKE 'GL%'))
                    AND TD.FULL_DATE >= TO_DATE('1/1/2001', 'mm/dd/yyyy')
                    AND(AFU.EQUAL_710000 = 'Y'
                    OR AFU.EQUAL_806300 = 'Y')
                GROUP BY
                    MLR.CLAIM_NBR,
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
            UNION ALL
            -- SPD - TRANE_LABOR
            SELECT 
                    /*+ NO_CPU_COSTING */
                    'TRANE_LABOR' AS TYPE,
                    MLR.CLAIM_NBR,
                    MLR.RETRO_ID,
                    'SPD' AS CLAIM_TYPE,
                    'LABOR' AS EXPENSE_TYPE_DESCR,
                    'LABOR' AS EXPENSE_TYPE_CATG,
                    LR.CHARGE_COMM_PCT,
                    LR.CHARGE_COMPANY_PCT,
                    ((SUM(DISTINCT(LR.APPR_AMT)) + MAX((LR.APPR_DIAGNOSTIC_AMT + LR.APPR_TRAVEL_AMT) /
                    (
                        SELECT COUNT(DISTINCT LRS.STEP_NBR) FROM WC_LABOR_ROLLUP LRS WHERE LRS.CLAIM_NBR = LR.CLAIM_NBR
                    )
                    )) * LR.CHARGE_COMPANY_PCT) AS DOLLAR_AMOUNT,
                    MLR.STEP_NBR,
                    MLR.CCN_TRX_DATE_KEY,
                    MLR.ORIGINAL_SHIP_DATE_KEY,
                    MLR.FAIL_DATE_KEY,
                    MLR.START_DATE_KEY,
                    MLR.GL_ACCOUNT_SCD_KEY,
                    MLR.PROD_CODE_SCD_KEY,
                    MLR.CUST_ACCOUNT_SCD_KEY,
                    MLR.SUBMIT_OFFICE_SCD_KEY,
                    MLR.TRX_CURRENCY
                FROM
                    WC_MAT_LBR_ROLLUP MLR
                INNER JOIN WC_LABOR_ROLLUP LR         ON MLR.DETAIL_NBR = LR.DETAIL_NBR AND MLR.CLAIM_NBR = LR.CLAIM_NBR AND MLR.STEP_NBR = LR.STEP_NBR
                INNER JOIN TIME_DAY TD                ON TD.TIME_KEY = MLR.CCN_TRX_DATE_KEY
                INNER JOIN R12_GL_ACCOUNT_SCD GLA     ON GLA.GL_ACCOUNT_SCD_KEY = MLR.GL_ACCOUNT_SCD_KEY
                INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
                WHERE
                    /* SPD CLAIM TYPE ONLY */
                    MLR.CLAIM_TYPE_SCD_KEY = 1
                    AND(GLA.R12_ENTITY IN('5773', '5588', '5575', '5743', '9256', '9258', '9298', '9299')
                    OR(GLA.R12_ENTITY = '9999' AND GLA.PS_COMPANY NOT LIKE 'GL%'))
                    AND TD.FULL_DATE >= TO_DATE('1/1/2001', 'mm/dd/yyyy')
                    AND(AFU.EQUAL_710000 = 'Y'
                    OR AFU.EQUAL_806300 = 'Y')
                GROUP BY
                    MLR.CLAIM_NBR,
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
        )
        CCN_DATA
    INNER JOIN TIME_DAY TD3                         ON CCN_DATA.CCN_TRX_DATE_KEY = TD3.TIME_KEY
    INNER JOIN TIME_DAY TD2                         ON CCN_DATA.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
    INNER JOIN TIME_DAY TD1                         ON CCN_DATA.FAIL_DATE_KEY = TD1.TIME_KEY
    INNER JOIN TIME_DAY TD                          ON CCN_DATA.START_DATE_KEY = TD.TIME_KEY
    INNER JOIN R12_GL_ACCOUNT_SCD GLA               ON CCN_DATA.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
    INNER JOIN PROD_CODE_SCD PCS                    ON CCN_DATA.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
    INNER JOIN CUST_ACCOUNT_SCD CACCT               ON CCN_DATA.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
    INNER JOIN SUBMIT_OFFICE_SCD SOS                ON CCN_DATA.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
    INNER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT       ON CCN_DATA.CLAIM_TYPE = RES_PCT.CLAIM_TYPE AND CCN_DATA.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR AND CCN_DATA.EXPENSE_TYPE_CATG = UPPER(RES_PCT.EXPENSE_TYPE_CATG) AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
    LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ A     ON CCN_DATA.CLAIM_NBR = A.CLAIM_NUMBER
    LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT1 ON A.CLAIM_TYPE = RES_PCT1.CLAIM_TYPE
    WHERE(
        CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
            THEN 'Y'
            ELSE 'N'
        END) = RES_PCT.CUST_CREDIT_CATG_CODE;
        
COMMIT;
/* Core Portion for Material */

INSERT /*+ APPEND */
    INTO MAP_CONCESSION_EXPENSE_DATA
SELECT 
        /*+ NO_CPU_COSTING */
        MLR.CLAIM_NBR AS CLAIM_NUMBER,
        MLR.STEP_NBR AS STEP_NUMBER,
        GLA.R12_ENTITY AS BUSINESS_UNIT,
        'MATERIAL' AS CLAIM_TYPE,
        CASE WHEN TD1.FULL_DATE - TD2.FULL_DATE <= 548
            THEN '<= 548 DAYS'
            ELSE '> 548 DAYS'
        END AS CONCESSION_DAYS,
        MLR.EXP_TYPE_AMOUNT * - 1 AS EXPENSE_AMOUNT,
        100 *(MLR.EXP_TYPE_AMOUNT * - 1 - TRUNC(MLR.EXP_TYPE_AMOUNT * - 1)) AS EXPENSE_AMOUNT_DEC,
        RES_PCT.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
        GLA.R12_ACCOUNT AS GL_ACCOUNT,
        ETS.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
        SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
        GLA.R12_PRODUCT AS GL_PROD_CODE,
        PCS.PROD_CODE AS MANF_PROD_CODE,
        SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
        CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
        CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
        (
        CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
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
        0 AS INTMONTHS_SHIP_TO_TRX,
        TD.FULL_DATE AS START_DATE,
        ((TD3.TIME_KEY - TD.TIME_KEY) / 30.42) AS INTMONTHS_START_TO_TRX,
        TD1.FULL_DATE AS FAIL_DATE,
        ((TD3.TIME_KEY - TD1.TIME_KEY) / 30.42) AS INTMONTHS_FAIL_TO_TRX,
        MLR.TRX_CURRENCY AS CURRENCY,
        (
        CASE WHEN GLA.R12_ENTITY IN('5773', '5588')
            THEN 'CAN'
            ELSE 'USA'
        END) AS COUNTRY_INDICATOR,
        MLR.RETRO_ID AS RETROFIT_ID,
        --GLA.R12_COST_CENTER AS GL_DEPT,
        GLA.PS_COST_CENTER AS GL_DEPT,
        CASE WHEN A.CLAIM_NUMBER IS NULL
            THEN 10000 *(
                CASE WHEN TD1.FULL_DATE - TD2.FULL_DATE > 548
                    THEN 0
                    ELSE RES_PCT.RESERVE_PCT
                END)
            ELSE RES_PCT1.RESERVE_PCT
        END AS IN_RESERVE_PERCENT,
        ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
        100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH,
        0 AS EXPENSE_AMT_IN_RES,
        0 AS EXPENSE_AMT_NOT_IN_RES
    FROM
        WC_MAT_LBR_ROLLUP MLR
-- SR Not used - No affect        INNER JOIN EXPENSE_TYPE_SCD ET                  ON MLR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY
    INNER JOIN TIME_DAY TD3                         ON MLR.CCN_TRX_DATE_KEY = TD3.TIME_KEY       -- /* TD3 FOR TRX DATE */
    INNER JOIN TIME_DAY TD2                         ON MLR.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY -- /* TD2 FOR ORIGINAL SHIP DATE */
    INNER JOIN TIME_DAY TD1                         ON MLR.FAIL_DATE_KEY = TD1.TIME_KEY          -- /* TD1 FOR FAIL DATE */
    INNER JOIN TIME_DAY TD                          ON MLR.START_DATE_KEY = TD.TIME_KEY          -- /* TD FOR START DATE */
-- SR Not used - No affect    INNER JOIN CLAIM_TASK_SCD CTASKS                ON MLR.CLAIM_TASK_SCD_KEY = CTASKS.CLAIM_TASK_SCD_KEY
    INNER JOIN R12_GL_ACCOUNT_SCD GLA               ON MLR.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
    INNER JOIN EXPENSE_TYPE_SCD ETS                 ON MLR.EXPENSE_TYPE_SCD_KEY = ETS.EXPENSE_TYPE_SCD_KEY
    INNER JOIN PROD_CODE_SCD PCS                    ON MLR.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
    INNER JOIN CUST_ACCOUNT_SCD CACCT               ON MLR.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
    INNER JOIN SUBMIT_OFFICE_SCD SOS                ON MLR.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
    INNER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT       ON ETS.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
    INNER JOIN R12_ACCOUNT_FILTER_UPD AFU           ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
    LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ A     ON MLR.CLAIM_NBR = A.CLAIM_NUMBER
    LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT1 ON A.CLAIM_TYPE = RES_PCT1.CLAIM_TYPE
    WHERE
        /* for MATERIAL only */
        MLR.CLAIM_TYPE_SCD_KEY = 10
        AND(GLA.R12_ENTITY IN('5773', '5588', '5575', '5743', '9256', '9258', '9298', '9299')
        OR (GLA.R12_ENTITY = '9999' AND GLA.PS_COMPANY NOT LIKE 'GL%'))
        AND 'MATERIAL' = RES_PCT.CLAIM_TYPE
        AND(
        CASE WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1'
            THEN 'Y'
            ELSE 'N'
        END) = RES_PCT.CUST_CREDIT_CATG_CODE
        AND TD3.FULL_DATE >= TO_DATE('1/1/2001', 'MM/DD/YYYY')
        AND(AFU.EQUAL_428000 = 'Y'
        OR AFU.EQUAL_710000 = 'Y'
        OR AFU.EQUAL_806300 = 'Y');
COMMIT;


--Needed for Appwrox to run successfully. Do not remove
dbms_output.put_line(constants.LOAD_SUCCESS_STR);

EXCEPTION
    WHEN OTHERS
    THEN raise_application_error(-20100,'Error: '||SQLERRM);
    
    --Needed for Appwrox to run successfully. Do not remove
     dbms_output.put_line(constants.LOAD_FAILURE_STR); 
END;
/
