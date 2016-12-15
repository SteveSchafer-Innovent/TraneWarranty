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
   SELECT
		/*+ NO_CPU_COSTING */
         CASE
             WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
             END AS COUNTRY_INDICATOR,
          TO_CHAR (A.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          A.R12_ENTITY AS BU,                                  -- -SS- COMPANY
          A.R12_ACCOUNT AS GL_ACCOUNT,
          A.COST_CENTER AS GL_DEP_ID,
          'Oracle Ledger' AS QUERY_SOURCE,
          A.PRODUCT_CODE AS GL_PRODUCT_ID,
          A.GL_POSTED_DATE AS JOURNAL_DATE,
          CAST (A.POSTING_CONTROL_ID AS VARCHAR2 (10)) AS JOURNAL_ID,
          A.AMOUNT * -1 AS REVENUE_AMOUNT,
          (100 * (A.AMOUNT * -1 - TRUNC(A.AMOUNT * -1)))
             AS REVENUE_AMOUNT_DEC
     FROM R12_AP_030_ARC_BILL A
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
    WHERE 1 = 1
          AND A.GL_POSTED_DATE BETWEEN TO_DATE ('01/01/2000', 'MM/DD/YYYY')
                                   AND TO_DATE ('12/31/2004', 'MM/DD/YYYY')
          AND A.CATEGORY = 'Sales Invoices'
          AND AFU.LIKE_52_53_54 = 'Y'

   UNION ALL

   SELECT /*+ NO_CPU_COSTING */
         CASE
             WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CAD'
             ELSE 'USD'
             END AS COUNTRY_INDICATOR,
          TO_CHAR (A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
          A.R12_ENTITY AS BU,
          A.R12_ACCOUNT AS GL_ACCOUNT,
          A.R12_LOCATION AS GL_DEP_ID,
          'P/S Ledger' AS QUERY_SOURCE,
          A.R12_PRODUCT AS GL_PRODUCT_ID,
          A.JOURNAL_DATE AS JOURNAL_DATE,
          (A.JOURNAL_ID) AS JOURNAL_ID,
          A.MONETARY_AMOUNT * -1 AS REVENUE_AMOUNT,
          (100 * (A.MONETARY_AMOUNT * -1 - TRUNC (A.MONETARY_AMOUNT * -1)))
             AS REVENUE_AMOUNT_DEC
     FROM DBO.R12_BI_ACCT_ENTRY_PSB A
          INNER JOIN DBO.R12_TRNBI_BI_HDR_PSB B
             ON     A.BUSINESS_UNIT = B.BUSINESS_UNIT
                AND A.INVOICE = B.INVOICE
          INNER JOIN DBO.R12_BI_HDR_PSB C
             ON     B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
                AND B.INVOICE = C.INVOICE
          INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
             ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
    WHERE A.JOURNAL_DATE BETWEEN TO_DATE ('01/01/2003', 'MM/DD/YYYY')
                             AND TO_DATE ('12/31/2050', 'MM/DD/YYYY')
			AND A.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
          AND C.ENTRY_TYPE = 'IN'
			AND AFU.LIKE_52_53_54 = 'Y'

   UNION ALL

	SELECT
			/*+ NO_CPU_COSTING */
			CASE WHEN A.R12_ENTITY IN('5773', '5588')
				THEN 'CAD'
				ELSE 'USD'
			END AS COUNTRY_INDICATOR,
			TO_CHAR(A.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
			A.R12_ENTITY AS BU,
			A.R12_ACCOUNT AS GL_ACCOUNT,
			A.R12_LOCATION AS GL_DEP_ID,
			'R12 Ledger' AS QUERY_SOURCE,
			A.R12_PRODUCT AS GL_PRODUCT_ID,
			A.JOURNAL_DATE AS JOURNAL_DATE,
			A.JOURNAL_ID AS JOURNAL_ID,
			A.MONETARY_AMOUNT * - 1 AS REVENUE_AMOUNT,
			100 * (A.MONETARY_AMOUNT * - 1 - TRUNC(A.MONETARY_AMOUNT * - 1)) AS REVENUE_AMOUNT_DEC
		FROM
			DBO.R12_BI_ACCT_ENTRY_STG A
		INNER JOIN DBO.R12_TRNBI_BI_HDR_STG B ON A.INVOICE = B.INVOICE AND A.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
		INNER JOIN DBO.R12_BI_HDR_STG C       ON B.INVOICE = C.INVOICE AND B.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
		INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
		WHERE
			A.JOURNAL_DATE BETWEEN TO_DATE('01/01/2003', 'MM/DD/YYYY') AND TO_DATE('12/31/2050', 'MM/DD/YYYY')
			AND A.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
			AND C.ENTRY_TYPE = 'INV'
			AND AFU.LIKE_52_53_54 = 'Y'

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
          INNER JOIN
             R12_ACCOUNT_FILTER_UPD AFU
          ON AFU.R12_ACCOUNT = UPD.R12_ACCOUNT
    WHERE UPD.JRNL_DATE BETWEEN TO_DATE ('01/01/1998', 'MM/DD/YYYY')
                            AND TO_DATE ('12/31/2003', 'MM/DD/YYYY')
          AND AFU.LIKE_52_53_54 = 'Y'
   WITH READ ONLY ;


GRANT SELECT ON DBO.MAP_EXTWARRANTYSALESDATA_VW TO ENT_RPT;
GRANT SELECT ON DBO.MAP_EXTWARRANTYSALESDATA_VW TO ENT_REPORTING;
GRANT SELECT ON DBO.MAP_EXTWARRANTYSALESDATA_VW TO READ_ONLY;
