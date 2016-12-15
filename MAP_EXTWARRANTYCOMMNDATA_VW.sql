-- Unable to render VIEW DDL for object DBO.MAP_EXTWARRANTYCOMMNDATA_VW with DBMS_METADATA attempting internal generator.
CREATE VIEW DBO.MAP_EXTWARRANTYCOMMNDATA_VW
AS SELECT CASE
             WHEN DIST.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          DIST.R12_ENTITY AS BU,
          DIST.R12_ACCOUNT AS GL_ACCOUNT,
          DIST.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          DIST.R12_PRODUCT AS GL_PRODUCT_ID,
          DIST.JOURNAL_DATE AS JOURNAL_DATE,
          DIST.JOURNAL_ID AS JOURNAL_ID,
          CASE
             WHEN    DIST.DEBIT_AMT = 0
                  OR DIST.DEBIT_AMT IS NULL
                  OR DIST.CREDIT_AMOUNT <> ''
             THEN
                DIST.CREDIT_AMOUNT * -1
             ELSE
                DIST.DEBIT_AMT
          END
             AS DOLLAR_AMOUNT,
          (100 * (DIST.DEBIT_AMT - TRUNC (DIST.DEBIT_AMT)))
             AS DOLLAR_AMOUNT_DEC
     FROM    DBO.R12_TRNCO_CM_DIST_PSB DIST
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
    WHERE     1 = 1
          AND DIST.JOURNAL_DATE > TO_DATE ('11/01/2004', 'MM/DD/YYYY')
          AND AFU.LIKE_52 = 'Y'
          AND DIST.R12_ENTITY IN
                 ('5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')
          AND ( (DIST.PS_DEPTID = 'NA'
                 AND (DIST.R12_LOCATION IS NULL
                      OR DIST.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (DIST.PS_DEPTID <> 'NA'
                   AND (DIST.PS_DEPTID IS NULL OR DIST.PS_DEPTID = 'SL00')))
   UNION ALL
   SELECT CASE
             WHEN DIST.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          DIST.R12_ENTITY AS BU,
          DIST.R12_ACCOUNT AS GL_ACCOUNT,
          DIST.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          DIST.R12_PRODUCT AS GL_PRODUCT_ID,
          DIST.JOURNAL_DATE AS JOURNAL_DATE,
          DIST.JOURNAL_ID AS JOURNAL_ID,
          CASE
             WHEN    DIST.DEBIT_AMT = 0
                  OR DIST.DEBIT_AMT IS NULL
                  OR DIST.CREDIT_AMOUNT <> ''
             THEN
                DIST.CREDIT_AMOUNT * -1
             ELSE
                DIST.DEBIT_AMT
          END
             AS DOLLAR_AMOUNT,
          (100 * (DIST.DEBIT_AMT - TRUNC (DIST.DEBIT_AMT)))
             AS DOLLAR_AMOUNT_DEC
     FROM    DBO.R12_TRNCO_CM_DIST_PSB DIST
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
    WHERE     1 = 1
          AND DIST.JOURNAL_DATE > TO_DATE ('11/01/2004', 'MM/DD/YYYY')
          AND AFU.LIKE_53 = 'Y'
          AND DIST.R12_ENTITY IN
                 ('5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')
          AND ( (DIST.PS_DEPTID = 'NA'
                 AND (DIST.R12_LOCATION IS NULL
                      OR DIST.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (DIST.PS_DEPTID <> 'NA'
                   AND (DIST.PS_DEPTID IS NULL OR DIST.PS_DEPTID = 'SL00')))
   UNION ALL
   SELECT CASE
             WHEN DIST.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          DIST.R12_ENTITY AS BU,
          DIST.R12_ACCOUNT AS GL_ACCOUNT,
          DIST.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          DIST.R12_PRODUCT AS GL_PRODUCT_ID,
          DIST.JOURNAL_DATE AS JOURNAL_DATE,
          DIST.JOURNAL_ID AS JOURNAL_ID,
          CASE
             WHEN    DIST.DEBIT_AMT = 0
                  OR DIST.DEBIT_AMT IS NULL
                  OR DIST.CREDIT_AMOUNT <> ''
             THEN
                DIST.CREDIT_AMOUNT * -1
             ELSE
                DIST.DEBIT_AMT
          END
             AS DOLLAR_AMOUNT,
          (100 * (DIST.DEBIT_AMT - TRUNC (DIST.DEBIT_AMT)))
             AS DOLLAR_AMOUNT_DEC
     FROM    DBO.R12_TRNCO_CM_DIST_PSB DIST
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
    WHERE     1 = 1
          AND DIST.JOURNAL_DATE > TO_DATE ('11/01/2004', 'MM/DD/YYYY')
          AND AFU.LIKE_54 = 'Y'
          AND DIST.R12_ENTITY IN
                 ('5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')
          AND ( (DIST.PS_DEPTID = 'NA'
                 AND (DIST.R12_LOCATION IS NULL
                      OR DIST.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (DIST.PS_DEPTID <> 'NA'
                   AND (DIST.PS_DEPTID IS NULL OR DIST.PS_DEPTID = 'SL00')))
   UNION ALL
   SELECT CASE
             WHEN DIST.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          DIST.R12_ENTITY AS BU,
          DIST.R12_ACCOUNT AS GL_ACCOUNT,
          DIST.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          DIST.R12_PRODUCT AS GL_PRODUCT_ID,
          DIST.JOURNAL_DATE AS JOURNAL_DATE,
          DIST.JOURNAL_ID AS JOURNAL_ID,
          CASE
             WHEN    DIST.DEBIT_AMT = 0
                  OR DIST.DEBIT_AMT IS NULL
                  OR DIST.CREDIT_AMOUNT <> ''
             THEN
                DIST.CREDIT_AMOUNT * -1
             ELSE
                DIST.DEBIT_AMT
          END
             AS DOLLAR_AMOUNT,
          (100 * (DIST.DEBIT_AMT - TRUNC (DIST.DEBIT_AMT)))
             AS DOLLAR_AMOUNT_DEC
     FROM    DBO.R12_TRNCO_CM_DIST_PSB DIST
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
    WHERE     1 = 1
          AND DIST.JOURNAL_DATE > TO_DATE ('11/01/2004', 'MM/DD/YYYY')
          AND AFU.LIKE_52 = 'Y'
          AND DIST.R12_ENTITY IN ('5773', '5588')
          AND ( (DIST.PS_DEPTID = 'NA'
                 AND (DIST.R12_LOCATION IS NULL
                      OR DIST.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (DIST.PS_DEPTID <> 'NA'
                   AND (DIST.PS_DEPTID IS NULL
                        OR DIST.PS_DEPTID IN ('TCA0', 'SL00'))))
   UNION ALL
   SELECT CASE
             WHEN DIST.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          DIST.R12_ENTITY AS BU,
          DIST.R12_ACCOUNT AS GL_ACCOUNT,
          DIST.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          DIST.R12_PRODUCT AS GL_PRODUCT_ID,
          DIST.JOURNAL_DATE AS JOURNAL_DATE,
          DIST.JOURNAL_ID AS JOURNAL_ID,
          CASE
             WHEN    DIST.DEBIT_AMT = 0
                  OR DIST.DEBIT_AMT IS NULL
                  OR DIST.CREDIT_AMOUNT <> ''
             THEN
                DIST.CREDIT_AMOUNT * -1
             ELSE
                DIST.DEBIT_AMT
          END
             AS DOLLAR_AMOUNT,
          (100 * (DIST.DEBIT_AMT - TRUNC (DIST.DEBIT_AMT)))
             AS DOLLAR_AMOUNT_DEC
     FROM    DBO.R12_TRNCO_CM_DIST_PSB DIST
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
    WHERE     1 = 1
          AND DIST.JOURNAL_DATE > TO_DATE ('11/01/2004', 'MM/DD/YYYY')
          AND AFU.LIKE_53 = 'Y'
          AND DIST.R12_ENTITY IN ('5773', '5588')
          AND ( (DIST.PS_DEPTID = 'NA'
                 AND (DIST.R12_LOCATION IS NULL
                      OR DIST.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (DIST.PS_DEPTID <> 'NA' AND DIST.PS_DEPTID IS NULL
                   OR DIST.PS_DEPTID IN ('TCA0', 'SL00')))
   UNION ALL
   SELECT CASE
             WHEN DIST.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          DIST.R12_ENTITY AS BU,
          DIST.R12_ACCOUNT AS GL_ACCOUNT,
          DIST.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          DIST.R12_PRODUCT AS GL_PRODUCT_ID,
          DIST.JOURNAL_DATE AS JOURNAL_DATE,
          DIST.JOURNAL_ID AS JOURNAL_ID,
          CASE
             WHEN    DIST.DEBIT_AMT = 0
                  OR DIST.DEBIT_AMT IS NULL
                  OR DIST.CREDIT_AMOUNT <> ''
             THEN
                DIST.CREDIT_AMOUNT * -1
             ELSE
                DIST.DEBIT_AMT
          END
             AS DOLLAR_AMOUNT,
          (100 * (DIST.DEBIT_AMT - TRUNC (DIST.DEBIT_AMT)))
             AS DOLLAR_AMOUNT_DEC
     FROM    DBO.R12_TRNCO_CM_DIST_PSB DIST
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
    WHERE     1 = 1
          AND DIST.JOURNAL_DATE > TO_DATE ('11/01/2004', 'MM/DD/YYYY')
          AND AFU.LIKE_54 = 'Y'
          AND DIST.R12_ENTITY IN ('5773', '5588')
          AND ( (DIST.PS_DEPTID = 'NA'
                 AND (DIST.R12_LOCATION IS NULL
                      OR DIST.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (DIST.PS_DEPTID <> 'NA' AND DIST.PS_DEPTID IS NULL
                   OR DIST.PS_DEPTID IN ('TCA0', 'SL00')))
   UNION ALL
   SELECT CASE
             WHEN GL_CODE.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          GL_CODE.R12_ENTITY AS BU,
          GL_CODE.R12_ACCOUNT AS GL_ACCOUNT,
          GL_CODE.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          GL_CODE.R12_PRODUCT AS GL_PRODUCT_ID,
          COMM.GL_POSTED_DATE AS JOURNAL_DATE,
          CAST (COMM.CMS_POSTING_ID AS VARCHAR2 (10 BYTE)) AS JOURNAL_ID,
          CASE
             WHEN    COMM.DEBIT_AMOUNT = 0
                  OR COMM.DEBIT_AMOUNT IS NULL
                  OR COMM.CREDIT_AMOUNT <> ''
             THEN
                COMM.CREDIT_AMOUNT * -1
             ELSE
                COMM.DEBIT_AMOUNT
          END
             AS DOLLAR_AMOUNT,
          (100 * (COMM.DEBIT_AMOUNT - TRUNC (COMM.DEBIT_AMOUNT)))
             AS REVENUE_AMOUNT_DEC
     FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
          INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
             ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID -- -SS-
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
    WHERE 1 = 1
          AND COMM.GL_POSTED_DATE BETWEEN TO_DATE ('1/01/2000', 'MM/DD/YYYY')
                                      AND TO_DATE ('10/31/2004',
                                                   'MM/DD/YYYY')
          AND AFU.LIKE_52 = 'Y'
          AND GL_CODE.R12_ENTITY IN
                 ('5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')
          AND ( (GL_CODE.PS_SEGMENT3 = 'NA'
                 AND (GL_CODE.R12_LOCATION IS NULL
                      OR GL_CODE.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (GL_CODE.PS_SEGMENT3 <> 'NA'
                   AND GL_CODE.PS_SEGMENT3 IS NULL
                   OR GL_CODE.PS_SEGMENT3 = 'SL00'))
   UNION ALL
   SELECT CASE
             WHEN GL_CODE.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          GL_CODE.R12_ENTITY AS BU,
          GL_CODE.R12_ACCOUNT AS GL_ACCOUNT,
          GL_CODE.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          GL_CODE.R12_PRODUCT AS GL_PRODUCT_ID,
          COMM.GL_POSTED_DATE AS JOURNAL_DATE,
          CAST (COMM.CMS_POSTING_ID AS VARCHAR2 (10 BYTE)) AS JOURNAL_ID,
          CASE
             WHEN    COMM.DEBIT_AMOUNT = 0
                  OR COMM.DEBIT_AMOUNT IS NULL
                  OR COMM.CREDIT_AMOUNT <> ''
             THEN
                COMM.CREDIT_AMOUNT * -1
             ELSE
                COMM.DEBIT_AMOUNT
          END
             AS DOLLAR_AMOUNT,
          (100 * (COMM.DEBIT_AMOUNT - TRUNC (COMM.DEBIT_AMOUNT)))
             AS REVENUE_AMOUNT_DEC
     FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
          INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
             ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID --/* -SS- */
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
    WHERE 1 = 1
          AND COMM.GL_POSTED_DATE BETWEEN TO_DATE ('1/01/2000', 'MM/DD/YYYY')
                                      AND TO_DATE ('10/31/2004',
                                                   'MM/DD/YYYY')
          AND AFU.LIKE_53 = 'Y'
          AND GL_CODE.R12_ENTITY IN
                 ('5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')
          AND ( (GL_CODE.PS_SEGMENT3 = 'NA'
                 AND (GL_CODE.R12_LOCATION IS NULL
                      OR GL_CODE.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (GL_CODE.PS_SEGMENT3 <> 'NA'
                   AND GL_CODE.PS_SEGMENT3 IS NULL
                   OR GL_CODE.PS_SEGMENT3 = 'SL00'))
   UNION ALL
   SELECT CASE
             WHEN GL_CODE.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          GL_CODE.R12_ENTITY AS BU,
          GL_CODE.R12_ACCOUNT AS GL_ACCOUNT,
          GL_CODE.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          GL_CODE.R12_PRODUCT AS GL_PRODUCT_ID,
          COMM.GL_POSTED_DATE AS JOURNAL_DATE,
          CAST (COMM.CMS_POSTING_ID AS VARCHAR2 (10 BYTE)) AS JOURNAL_ID,
          CASE
             WHEN    COMM.DEBIT_AMOUNT = 0
                  OR COMM.DEBIT_AMOUNT IS NULL
                  OR COMM.CREDIT_AMOUNT <> ''
             THEN
                COMM.CREDIT_AMOUNT * -1
             ELSE
                COMM.DEBIT_AMOUNT
          END
             AS DOLLAR_AMOUNT,
          (100 * (COMM.DEBIT_AMOUNT - TRUNC (COMM.DEBIT_AMOUNT)))
             AS REVENUE_AMOUNT_DEC
     FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
          INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
             ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID --/* -SS- */
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
    WHERE 1 = 1
          AND COMM.GL_POSTED_DATE BETWEEN TO_DATE ('1/01/2000', 'MM/DD/YYYY')
                                      AND TO_DATE ('10/31/2004',
                                                   'MM/DD/YYYY')
          AND AFU.LIKE_54 = 'Y'
          AND GL_CODE.R12_ENTITY IN
                 ('5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')            -- /* -SS- AND ASX.NATION_CURR = 'USD' */
          AND ( (GL_CODE.PS_SEGMENT3 = 'NA'
                 AND (GL_CODE.R12_LOCATION IS NULL
                      OR GL_CODE.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (GL_CODE.PS_SEGMENT3 <> 'NA'
                   AND GL_CODE.PS_SEGMENT3 IS NULL
                   OR GL_CODE.PS_SEGMENT3 = 'SL00'))
   UNION ALL
   SELECT CASE
             WHEN GL_CODE.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          GL_CODE.R12_ENTITY AS BU,
          GL_CODE.R12_ACCOUNT AS GL_ACCOUNT,
          GL_CODE.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          GL_CODE.R12_PRODUCT AS GL_PRODUCT_ID,
          COMM.GL_POSTED_DATE AS JOURNAL_DATE,
          CAST (COMM.CMS_POSTING_ID AS VARCHAR2 (10 BYTE)) AS JOURNAL_ID,
          CASE
             WHEN    COMM.DEBIT_AMOUNT = 0
                  OR COMM.DEBIT_AMOUNT IS NULL
                  OR COMM.CREDIT_AMOUNT <> ''
             THEN
                COMM.CREDIT_AMOUNT * -1
             ELSE
                COMM.DEBIT_AMOUNT
          END
             AS DOLLAR_AMOUNT,
          (100 * (COMM.DEBIT_AMOUNT - TRUNC (COMM.DEBIT_AMOUNT)))
             AS REVENUE_AMOUNT_DEC
     FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
          INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
             ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID -- /* -SS- */
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
    WHERE 1 = 1
          AND COMM.GL_POSTED_DATE BETWEEN TO_DATE ('1/01/2000', 'MM/DD/YYYY')
                                      AND TO_DATE ('10/31/2004',
                                                   'MM/DD/YYYY')
          AND AFU.LIKE_52 = 'Y'
          AND GL_CODE.R12_ENTITY IN ('5773', '5588')
          AND ( (GL_CODE.PS_SEGMENT3 = 'NA'
                 AND (GL_CODE.R12_LOCATION IS NULL
                      OR GL_CODE.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (GL_CODE.PS_SEGMENT3 <> 'NA'
                   AND GL_CODE.PS_SEGMENT3 IS NULL
                   OR GL_CODE.PS_SEGMENT3 IN ('SL00', 'TCA0')))
   UNION ALL
   SELECT CASE
             WHEN GL_CODE.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          GL_CODE.R12_ENTITY AS BU,
          GL_CODE.R12_ACCOUNT AS GL_ACCOUNT,
          GL_CODE.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          GL_CODE.R12_PRODUCT AS GL_PRODUCT_ID,
          COMM.GL_POSTED_DATE AS JOURNAL_DATE,
          CAST (COMM.CMS_POSTING_ID AS VARCHAR2 (10 BYTE)) AS JOURNAL_ID,
          CASE
             WHEN    COMM.DEBIT_AMOUNT = 0
                  OR COMM.DEBIT_AMOUNT IS NULL
                  OR COMM.CREDIT_AMOUNT <> ''
             THEN
                COMM.CREDIT_AMOUNT * -1
             ELSE
                COMM.DEBIT_AMOUNT
          END
             AS DOLLAR_AMOUNT,
          (100 * (COMM.DEBIT_AMOUNT - TRUNC (COMM.DEBIT_AMOUNT)))
             AS REVENUE_AMOUNT_DEC
     FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
          INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
             ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID --  /* -SS- */
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
    WHERE 1 = 1
          AND COMM.GL_POSTED_DATE BETWEEN TO_DATE ('1/01/2000', 'MM/DD/YYYY')
                                      AND TO_DATE ('10/31/2004',
                                                   'MM/DD/YYYY')
          AND AFU.LIKE_53 = 'Y'
          AND GL_CODE.R12_ENTITY IN ('5773', '5588')
          AND ( (GL_CODE.PS_SEGMENT3 = 'NA'
                 AND (GL_CODE.R12_LOCATION IS NULL
                      OR GL_CODE.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (GL_CODE.PS_SEGMENT3 <> 'NA'
                   AND GL_CODE.PS_SEGMENT3 IS NULL
                   OR GL_CODE.PS_SEGMENT3 IN ('SL00', 'TCA0')))
   UNION ALL
   SELECT CASE
             WHEN GL_CODE.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             AS COUNTRY_INDICATOR,
          TO_CHAR (COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          GL_CODE.R12_ENTITY AS BU,
          GL_CODE.R12_ACCOUNT AS GL_ACCOUNT,
          GL_CODE.R12_LOCATION AS GL_DEP_ID,
          'P/S LEDGER' AS QUERY_SOURCE,
          GL_CODE.R12_PRODUCT AS GL_PRODUCT_ID,
          COMM.GL_POSTED_DATE AS JOURNAL_DATE,
          CAST (COMM.CMS_POSTING_ID AS VARCHAR2 (10 BYTE)) AS JOURNAL_ID,
          CASE
             WHEN    COMM.DEBIT_AMOUNT = 0
                  OR COMM.DEBIT_AMOUNT IS NULL
                  OR COMM.CREDIT_AMOUNT <> ''
             THEN
                COMM.CREDIT_AMOUNT * -1
             ELSE
                COMM.DEBIT_AMOUNT
          END
             AS DOLLAR_AMOUNT,
          (100 * (COMM.DEBIT_AMOUNT - TRUNC (COMM.DEBIT_AMOUNT)))
             AS REVENUE_AMOUNT_DEC
     FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
          INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE
             ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID -- /* -SS- */
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
    WHERE 1 = 1
          AND COMM.GL_POSTED_DATE BETWEEN TO_DATE ('1/01/2000', 'MM/DD/YYYY')
                                      AND TO_DATE ('10/31/2004',
                                                   'MM/DD/YYYY')
          AND AFU.LIKE_54 = 'Y'
          AND GL_CODE.R12_ENTITY IN ('5773', '5588')
          AND ( (GL_CODE.PS_SEGMENT3 = 'NA'
                 AND (GL_CODE.R12_LOCATION IS NULL
                      OR GL_CODE.R12_LOCATION IN
                            ('113602',
                             '115615',
                             '119001',
                             '119007',
                             '129001',
                             '129003',
                             '129004')))
               OR (GL_CODE.PS_SEGMENT3 <> 'NA'
                   AND GL_CODE.PS_SEGMENT3 IS NULL
                   OR GL_CODE.PS_SEGMENT3 IN ('SL00', 'TCA0')))
   UNION ALL
   /* COMMISSION DATA BACK FROM 1998 TO 1999*/
   SELECT CASE WHEN UPD.COUNTRY_INDICATOR = 'CAN' THEN 'CAD' ELSE 'USD' END
             AS COUNTRY_INDICATOR,
          TO_CHAR (UPD.JRNL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          'NA' AS BU,
          UPD.GL_ACCOUNT AS GL_ACCOUNT,
          'NA' AS GL_DEP_ID,
          'COMM 1998' AS QUERY_SOURCE,
          'NA' AS GL_PRODUCT_ID,
          UPD.JRNL_DATE AS JOURNAL_DATE,
          'NA' AS JOURNAL_ID,
          UPD.REVENUE_AMOUNT AS REVENUE_AMOUNT,
          (100 * (UPD.REVENUE_AMOUNT - TRUNC (UPD.REVENUE_AMOUNT)))
             AS REVENUE_AMOUNT_DEC
     FROM    MD_030_COMMISSION_DTL_UPD UPD
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = UPD.R12_ACCOUNT
    WHERE 1 = 1 AND AFU.LIKE_52_53_54 = 'Y'
          AND UPD.JRNL_DATE BETWEEN TO_DATE ('01/01/1998', 'MM/DD/YYYY')
                                AND TO_DATE ('12/31/1999', 'MM/DD/YYYY')
