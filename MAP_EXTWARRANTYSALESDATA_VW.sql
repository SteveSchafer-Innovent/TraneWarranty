/* $Workfile: MAP_EXTWARRANTYSALESDATA_VW.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Views/MAP_EXTWARRANTYSALESDATA_VW/MAP_EXTWARRANTYSALESDATA_VW.sql $
*  $Author: Laiqi $
*  $Date: 12/09/16 8:29p $
*
* Revisions: 
* 
*   change Date    Description 
*   -----------         ----------- 
*   12/9/2016      Pam Nelson, laiqi, IR - Initial script creation for SMART P4 Warranty Reserve Reports project - TTP 14939
*                           Development done by Innovent Solutions
**********************************************************************************/ 

CREATE OR REPLACE FORCE VIEW DBO.MAP_EXTWARRANTYSALESDATA_VW
(
   COUNTRY_INDICATOR,
   JRNL_YEAR_MONTH,
   BU,
   GL_ACCOUNT,
   GL_DEP_ID,
   QUERY_SOURCE,
   GL_PRODUCT_ID,
   JOURNAL_DATE,
   JOURNAL_ID,
   REVENUE_AMOUNT,
   REVENUE_AMOUNT_DEC
)
AS
   SELECT                                                /*+ NO_CPU_COSTING */
         CASE
             WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             /* ASX.NATION_CURR */
             AS COUNTRY_INDICATOR,
          TO_CHAR (A.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          A.R12_ENTITY AS BU,                                  -- -SS- COMPANY
          A.R12_ACCOUNT AS GL_ACCOUNT,
          A.COST_CENTER AS GL_DEP_ID,
          'Oracle Ledger' AS QUERY_SOURCE,
          A.PRODUCT_CODE AS GL_PRODUCT_ID,
          A.GL_POSTED_DATE AS JOURNAL_DATE,
          CAST (A.POSTING_CONTROL_ID AS VARCHAR2 (10)) AS JOURNAL_ID,
          --A.posting_control_id AS JOURNAL_ID,
          A.AMOUNT * -1 AS REVENUE_AMOUNT,
          (100 * (A.AMOUNT * -1 - TRUNC (A.AMOUNT * -1)))
             AS REVENUE_AMOUNT_DEC
     FROM    R12_AP_030_ARC_BILL A -- not used any more per Pam DBO.AP_030_ARC_BILL_MVW A
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
    -- -SS- issue 88: INNER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT  -- R12_2_R12 -- -SS- issues 23, 35

    -- -SS- ,dbo.ACTUATE_SEC_XREF ASX
    WHERE 1 = 1
          -- -SS- issue 88: PSA.TRANE_ACCOUNT_IND = 'X'
          -- -SS- A.ACCOUNT = PSA.ACCOUNT
          -- -SS- and PSA.TRANE_ACCOUNT_IND = 'X'
          -- -SS- A.COMPANY= ASX.PSGL(+) and
          -- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
          AND A.GL_POSTED_DATE BETWEEN TO_DATE ('01/01/2000', 'MM/DD/YYYY')
                                   AND TO_DATE ('12/31/2004', 'MM/DD/YYYY')
          AND A.CATEGORY = 'Sales Invoices'
          -- -SS- NEW
          AND AFU.LIKE_52_53_54 = 'Y'
   -- -SS- /NEW
   -- -SS- and ( A.ACCOUNT like '52%' or A.ACCOUNT like '53%' or A.ACCOUNT like '54%')
   UNION ALL
   SELECT                                                /*+ NO_CPU_COSTING */
         CASE
             WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             /* ASX.NATION_CURR */
             AS COUNTRY_INDICATOR,
          TO_CHAR (A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          A.R12_ENTITY AS BU,                         -- -SS- BUSINESS_UNIT_GL
          A.R12_ACCOUNT AS GL_ACCOUNT,                         -- -SS- ACCOUNT
          A.R12_LOCATION AS GL_DEP_ID,                          -- -SS- DEPTID
          'P/S Ledger' AS QUERY_SOURCE,
          A.R12_PRODUCT AS GL_PRODUCT_ID,                      -- -SS- PRODUCT
          A.JOURNAL_DATE AS JOURNAL_DATE,
          (A.JOURNAL_ID) AS JOURNAL_ID,
          A.MONETARY_AMOUNT * -1 AS REVENUE_AMOUNT,
          (100 * (A.MONETARY_AMOUNT * -1 - TRUNC (A.MONETARY_AMOUNT * -1)))
             AS REVENUE_AMOUNT_DEC
     FROM DBO.R12_BI_ACCT_ENTRY_PSB A                              -- -SS- OTR
          INNER JOIN DBO.R12_TRNBI_BI_HDR_PSB B                    -- -SS- OTR
             ON     A.BUSINESS_UNIT = B.BUSINESS_UNIT
                AND A.INVOICE = B.INVOICE
                AND A.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
          INNER JOIN DBO.R12_BI_HDR_PSB C                          -- -SS- OTR
             ON     B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
                AND B.INVOICE = C.INVOICE
                AND B.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
          -- -SS- NEW
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
    -- -SS- /NEW
    -- -SS- issue 88: INNER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT  -- R12_2_R12 -- /* -SS- ACCOUNT */ /* -SS- ACCOUNT */ (+) -- /* -SS- OTR */
    /* --SS- ,dbo.ACTUATE_SEC_XREF ASX */
    WHERE A.JOURNAL_DATE BETWEEN TO_DATE ('01/01/2003', 'MM/DD/YYYY')
                             AND TO_DATE ('12/31/2050', 'MM/DD/YYYY')
          AND A.R12_ENTITY IN
                 ('5773',
                  '5588',
                  '5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')
          -- -SS- AND A.BUSINESS_UNIT_GL IN('CAN', 'CSD')
          -- -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+)
          -- -SS- issue 88: AND PSA.TRANE_ACCOUNT_IND = 'X'
          AND C.ENTRY_TYPE = 'IN'
          -- -SS- NEW
          AND AFU.LIKE_52 = 'Y'
   -- -SS- /NEW
   -- -SS- AND A.ACCOUNT LIKE '52%'
   UNION ALL
   SELECT                                                /*+ NO_CPU_COSTING */
         CASE
             WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             /* ASX.NATION_CURR */
             AS COUNTRY_INDICATOR,
          TO_CHAR (A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          A.R12_ENTITY AS BU,                         -- -SS- BUSINESS_UNIT_GL
          A.R12_ACCOUNT AS GL_ACCOUNT,                         -- -SS- ACCOUNT
          A.R12_LOCATION AS GL_DEP_ID,                          -- -SS- DEPTID
          'P/S Ledger' AS QUERY_SOURCE,
          A.R12_PRODUCT AS GL_PRODUCT_ID,                      -- -SS- PRODUCT
          A.JOURNAL_DATE AS JOURNAL_DATE,
          (A.JOURNAL_ID) AS JOURNAL_ID,
          A.MONETARY_AMOUNT * -1 AS REVENUE_AMOUNT,
          (100 * (A.MONETARY_AMOUNT * -1 - TRUNC (A.MONETARY_AMOUNT * -1)))
             AS REVENUE_AMOUNT_DEC
     FROM DBO.R12_BI_ACCT_ENTRY_PSB A                              -- -SS- OTR
          INNER JOIN DBO.R12_TRNBI_BI_HDR_PSB B                    -- -SS- OTR
             ON     A.BUSINESS_UNIT = B.BUSINESS_UNIT
                AND A.INVOICE = B.INVOICE
                AND A.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
          INNER JOIN DBO.R12_BI_HDR_PSB C                          -- -SS- OTR
             ON     B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
                AND B.INVOICE = C.INVOICE
                AND B.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
          -- -SS- NEW
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
    -- -SS- /NEW
    -- -SS- issue 88: INNER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT  -- R12_2_R12 --  /* -SS- ACCOUNT *//* -SS- ACCOUNT */ (+) -- /* -SS- OTR */
    -- -SS- ,dbo.ACTUATE_SEC_XREF ASX
    WHERE A.JOURNAL_DATE BETWEEN TO_DATE ('01/01/2003', 'MM/DD/YYYY')
                             AND TO_DATE ('12/31/2050', 'MM/DD/YYYY')
          AND A.R12_ENTITY IN
                 ('5773',
                  '5588',
                  '5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')
          -- -SS- AND A.BUSINESS_UNIT_GL IN('CAN', 'CSD')
          -- -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+)
          -- -SS- issue 88: AND PSA.TRANE_ACCOUNT_IND = 'X'
          AND C.ENTRY_TYPE = 'IN'
          -- -SS- NEW
          AND AFU.LIKE_53 = 'Y'
   -- -SS- /NEW
   -- -SS- AND A.ACCOUNT LIKE '53%'
   UNION ALL
   SELECT                                                /*+ NO_CPU_COSTING */
         CASE
             WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
          END
             /* ASX.NATION_CURR */
             AS COUNTRY_INDICATOR,
          TO_CHAR (A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          A.R12_ENTITY AS BU,                         -- -SS- BUSINESS_UNIT_GL
          A.R12_ACCOUNT AS GL_ACCOUNT,                         -- -SS- ACCOUNT
          A.R12_LOCATION AS GL_DEP_ID,                          -- -SS- DEPTID
          'P/S Ledger' AS QUERY_SOURCE,
          A.R12_PRODUCT AS GL_PRODUCT_ID,                      -- -SS- PRODUCT
          A.JOURNAL_DATE AS JOURNAL_DATE,
          (A.JOURNAL_ID) AS JOURNAL_ID,
          A.MONETARY_AMOUNT * -1 AS REVENUE_AMOUNT,
          (100 * (A.MONETARY_AMOUNT * -1 - TRUNC (A.MONETARY_AMOUNT * -1)))
             AS REVENUE_AMOUNT_DEC
     FROM DBO.R12_BI_ACCT_ENTRY_PSB A                              -- -SS- OTR
          INNER JOIN DBO.R12_TRNBI_BI_HDR_PSB B                    -- -SS- OTR
             ON     A.BUSINESS_UNIT = B.BUSINESS_UNIT
                AND A.INVOICE = B.INVOICE
                AND A.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
          INNER JOIN DBO.R12_BI_HDR_PSB C                          -- -SS- OTR
             ON     B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
                AND B.INVOICE = C.INVOICE
                AND B.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
                AND C.ENTRY_TYPE = 'IN'
          -- -SS- NEW
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
    -- -SS- /NEW
    -- -SS- issue 88: INNER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT -- R12_2_R12  -- -SS- OTR

    -- -SS- ,dbo.ACTUATE_SEC_XREF ASX
    WHERE A.JOURNAL_DATE BETWEEN TO_DATE ('01/01/2003', 'MM/DD/YYYY')
                             AND TO_DATE ('12/31/2050', 'MM/DD/YYYY')
          AND A.R12_ENTITY IN
                 ('5773',
                  '5588',
                  '5575',
                  '5612',
                  '5743',
                  '9256',
                  '9258',
                  '9298',
                  '9299',
                  '9984')
          -- -SS- issue 88: AND PSA.TRANE_ACCOUNT_IND = 'X'
          -- -SS- AND A.BUSINESS_UNIT_GL IN('CAN', 'CSD')
          -- -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+)
          -- -SS- AND A.ACCOUNT = PSA.ACCOUNT (+)
          -- -SS- AND PSA.TRANE_ACCOUNT_IND = 'X'
          -- -SS- AND A.BUSINESS_UNIT       = B.BUSINESS_UNIT
          -- -SS- AND A.INVOICE             = B.INVOICE
          -- -SS- AND B.BUSINESS_UNIT       = C.BUSINESS_UNIT
          -- -SS- AND B.INVOICE             = C.INVOICE
          -- -SS- AND C.ENTRY_TYPE          = 'IN'
          -- -SS- NEW
          AND AFU.LIKE_54 = 'Y'
   -- -SS- /NEW
   -- -SS- AND A.ACCOUNT LIKE '54%'
   UNION ALL
   /* SALES DATA BACK FROM 1998 TO 1999*/
   SELECT                                                /*+ NO_CPU_COSTING */
         UPD.COUNTRY_INDICATOR AS COUNTRY_INDICATOR,
          TO_CHAR (UPD.JRNL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          '' AS BU,
          UPD.GL_ACCOUNT AS GL_ACCOUNT,
          '' AS GL_DEP_ID,
          'SALES 1998' AS QUERY_SOURCE,
          '' AS GL_PRODUCT_ID,
          UPD.JRNL_DATE AS JOURNAL_DATE,
          '' AS JOURNAL_ID,
          UPD.REVENUE_AMOUNT AS REVENUE_AMOUNT,
          (100 * (UPD.REVENUE_AMOUNT - TRUNC (UPD.REVENUE_AMOUNT)))
             AS REVENUE_AMOUNT_DEC
     FROM    MD_030_SALES_DTL_UPD UPD
          -- -SS- issue 88: INNER JOIN R12_TRANE_ACCOUNTS_PS PSA ON UPD.R12_ACCOUNT = PSA.R12_ACCOUNT  -- R12_2_R12
          -- -SS- NEW
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = UPD.R12_ACCOUNT
    -- -SS- /NEW
    WHERE UPD.JRNL_DATE BETWEEN TO_DATE ('01/01/1998', 'MM/DD/YYYY')
                            AND TO_DATE ('12/31/2003', 'MM/DD/YYYY')
          -- -SS- AND UPD.ACCOUNT = PSA.ACCOUNT (+)
          -- -SS- issue 88: AND PSA.TRANE_ACCOUNT_IND = 'X'
          -- -SS- NEW issue 88
          AND AFU.LIKE_52_53_54 = 'Y'
   -- -SS- /NEW
   WITH READ ONLY;


GRANT SELECT ON DBO.MAP_EXTWARRANTYSALESDATA_VW TO ENT_RPT;
GRANT SELECT ON DBO.MAP_EXTWARRANTYSALESDATA_VW TO ENT_REPORTING;
GRANT SELECT ON DBO.MAP_EXTWARRANTYSALESDATA_VW TO READ_ONLY;
