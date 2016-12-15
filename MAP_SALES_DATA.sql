/* $Workfile: MAP_SALES_DATA.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/MAP_SALES_DATA/MAP_SALES_DATA.sql $
*  $Author: Laiqi $
*  $Date: 12/10/16 4:01p $
*
* Description: Loads MAP_SALES_DATA table that is used by the
*           Actuate IOBs for the Warranty and Reserve reports. This table improves IOB caching performance.
*
*           Target:     DRTRNP.DBO.MAP_SALES_DATA
*           Source:     DRTRNP.DBO.
*
* Revisions: 
* 
*   change Date    Description 
*   -----------         ----------- 
*   12/10/2016      Pam Nelson, laiqi, IR - Initial creation for SMART P4 project - TTP 14939
*                           SQL Development done by Innovent Solutions
***********************************************************************************/ 
set timing on
set pause OFF
set feedback on
set echo on

spool MAP_SALES_DATA.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating MAP_SALES_DATA
exec p_truncate_listed_table ('DBO', 'MAP_SALES_DATA');

prompt Inserting DATA into MAP_SALES_DATA
INSERT /*+ APPEND */  INTO MAP_SALES_DATA
(
QUERY_SOURCE,
BU,
REVENUE_AMOUNT,
REVENUE_AMOUNT_DEC,
GL_ACCOUNT,
DEPT_ID,
DEPT_DESCR,
MANF_PROD_ID,
MANF_PROD_DESCR,
DIST_GL_PRODUCT,
RESERVE_GROUP,
JRNL_DATE,
JRNL_YEAR,
JRNL_MONTH,
JRNL_YEAR_MONTH,
JRNL_ID,
CURRENCY,
COUNTRY_INDICATOR,
TWO_FIVE
)
SELECT /*+ NO_CPU_COSTING */
		'RCPO' AS QUERY_SOURCE,
		NVL(PS.GL_BU_ID,(
		CASE
			WHEN PS.CURRENCY_CODE = 'USD' THEN 'GS303'
			WHEN PS.CURRENCY_CODE = 'CAD' THEN 'GS315'
			ELSE NULL -- INVALID CODE
			END)) AS BU,
		SUM(PS.ORDER_AMOUNT) AS REVENUE_AMOUNT,
		SUM(100 *(PS.ORDER_AMOUNT - TRUNC(PS.ORDER_AMOUNT))) AS REVENUE_AMOUNT_DEC,
		PS.R12_ACCOUNT AS GL_ACCOUNT, 
		NVL(PS.R12_LOCATION,(         
		CASE
			WHEN PS.CURRENCY_CODE = 'USD' THEN 97001
			WHEN PS.CURRENCY_CODE = 'CAD' THEN 97011
			ELSE -10
			END)) AS DEPT_ID,
		COALESCE(DP.R12_LOCATION_DESCR, CASE
			WHEN PS.CURRENCY_CODE = 'USD' THEN 'OTHER EQUIPMENT GROUP'
			WHEN PS.CURRENCY_CODE = 'CAD' THEN 'CAN OTHER EQUIPMENT GROUP'
			ELSE 'INVALID CURRENCY-' || PS.CURRENCY_CODE
			END) AS DEPT_DESCR,
		PS.PLNT_GL_PROD AS MANF_PROD_ID,
		PX.MANF_PROD_CODE_DESCR AS MANF_PROD_DESCR,
		CASE
			WHEN PS.PART_TYPE = 'Y' AND PS.PARTS_PROD_CODE_IND = 'PCR' THEN '41204'
			ELSE PS.R12_PRODUCT
			END AS DIST_GL_PRODUCT,
		PX.PRODUCT_CATEGORY AS RESERVE_GROUP,
		PS.JRNL_DATE AS JRNL_DATE,
		CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) AS JRNL_YEAR,
		CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER) AS JRNL_MONTH,
		CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER) AS JRNL_YEAR_MONTH,
		PS.ORGN_JRNL_ID AS JRNL_ID,
		PS.CURRENCY_CODE AS CURRENCY,
		CASE
			WHEN PS.R12_ENTITY IN('5773', '5588') THEN 'CAD'
			WHEN PS.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299') THEN 'USD'
			ELSE '???'
			END AS COUNTRY_INDICATOR,
		'N' AS TWO_FIVE
	FROM
		R12_ORACLE_PS_REV_RCPO PS
	LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO PX
		ON PS.PLNT_GL_BU = PX.GL_LEDGER
		AND PS.PLNT_GL_PROD = PX.MANF_PROD_CODE
	LEFT OUTER JOIN R12_LOCATION_STG DP
		ON DP.R12_LOCATION = PS.R12_LOCATION
	WHERE
		PS.JRNL_DATE BETWEEN TO_DATE('01/01/2005', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
		AND PS.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299')
	GROUP BY
		PS.GL_BU_ID,
		PS.R12_ACCOUNT,
		PS.R12_LOCATION,
		DP.R12_LOCATION_DESCR,
		PS.PLNT_GL_PROD,
		PX.MANF_PROD_CODE_DESCR,
		CASE WHEN PS.PART_TYPE = 'Y' AND PS.PARTS_PROD_CODE_IND = 'PCR' THEN '41204'
			ELSE PS.R12_PRODUCT
			END,
		PX.PRODUCT_CATEGORY,
		PS.JRNL_DATE,
		CAST(TO_CHAR(PS.JRNL_DATE, 'YYYY') AS INTEGER),
		CAST(TO_CHAR(PS.JRNL_DATE, 'MM') AS INTEGER),
		CAST(TO_CHAR(PS.JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(PS.JRNL_DATE, 'MM') AS INTEGER),
		PS.ORGN_JRNL_ID,
		PS.CURRENCY_CODE,
		CASE
			WHEN PS.R12_ENTITY IN('5773', '5588') THEN 'CAD'
			WHEN PS.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299') THEN 'USD'
			ELSE '???'
			END;

COMMIT;

INSERT /*+ APPEND */ INTO MAP_SALES_DATA
(
QUERY_SOURCE,
BU,
REVENUE_AMOUNT,
REVENUE_AMOUNT_DEC,
GL_ACCOUNT,
DEPT_ID,
DEPT_DESCR,
MANF_PROD_ID,
MANF_PROD_DESCR,
DIST_GL_PRODUCT,
RESERVE_GROUP,
JRNL_DATE,
JRNL_YEAR,
JRNL_MONTH,
JRNL_YEAR_MONTH,
JRNL_ID,
CURRENCY,
COUNTRY_INDICATOR,
TWO_FIVE
)
SELECT /*+ NO_CPU_COSTING */
		'P/S GL' AS QUERY_SOURCE,
		GA.BUSINESS_UNIT AS BU,
		SUM(L.MONETARY_AMOUNT) AS REVENUE_AMOUNT,
		SUM(100 *(L.MONETARY_AMOUNT - TRUNC(L.MONETARY_AMOUNT))) AS REVENUE_AMOUNT_DEC,
		L.R12_ACCOUNT AS GL_ACCOUNT,
		L.R12_LOCATION AS DEPT_ID,
		DP.R12_LOCATION_DESCR AS DEPT_DESCR,
		L.PS_PRODUCT AS MANF_PROD_ID,
		PR.R12_PRODUCT_DESCR AS MANF_PROD_DESCR,
		L.R12_PRODUCT AS DIST_GL_PRODUCT,
		PX.PRODUCT_CATEGORY AS RESERVE_GROUP, 
		GA.JOURNAL_DATE AS JRNL_DATE,
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'YYYY')) AS JRNL_YEAR,
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'MM')) AS JRNL_MONTH,
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'MM')) AS JRNL_YEAR_MONTH,
		GA.JOURNAL_ID AS JRNL_ID,
		L.CURRENCY_CD AS CURRENCY,
		CASE
			WHEN L.R12_ENTITY IN('5773', '5588') THEN 'CAD'
			WHEN L.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299') THEN 'USD'
			ELSE '???'
			END AS COUNTRY_INDICATOR,
		'N' AS TWO_FIVE
	FROM
		R12_JRNL_LN_PS L 
	INNER JOIN R12_JRNL_HEADER_PS GA 
	ON GA.BUSINESS_UNIT = L.BUSINESS_UNIT AND GA.JOURNAL_ID = L.JOURNAL_ID AND GA.JOURNAL_DATE = L.JOURNAL_DATE AND GA.UNPOST_SEQ = L.UNPOST_SEQ
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = L.R12_ACCOUNT
	LEFT OUTER JOIN R12_PRODUCT_STG PR   ON L.R12_PRODUCT = PR.R12_PRODUCT
	LEFT OUTER JOIN R12_LOCATION_STG DP     ON L.R12_LOCATION = DP.R12_LOCATION
	LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO PX ON L.BUSINESS_UNIT = PX.GL_LEDGER
		AND L.PS_PRODUCT = PX.MANF_PROD_CODE
	WHERE
		GA.JRNL_HDR_STATUS IN('P', 'U')
		AND GA.FISCAL_YEAR IN('2003', '2004')
		AND L.LEDGER = 'ACTUALS'
		AND L.PS_ACCOUNT = '700000'
		AND GA.BUSINESS_UNIT IN('CAN', 'CSD')
		AND L.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299') -- -SS- CAN, USA
	GROUP BY
		GA.BUSINESS_UNIT,
		L.R12_ACCOUNT,  
		L.R12_LOCATION, 
		DP.R12_LOCATION_DESCR,
		L.PS_PRODUCT, -- sr MANF_PROD_ID
		L.R12_PRODUCT, 
		PR.R12_PRODUCT_DESCR,
		PX.PRODUCT_CATEGORY,
		GA.JOURNAL_DATE,
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'YYYY')),
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'MM')),
		TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(GA.JOURNAL_DATE, 'MM')),
		GA.JOURNAL_ID,
		L.CURRENCY_CD,
		CASE
			WHEN L.R12_ENTITY IN('5773', '5588') THEN 'CAD'
			WHEN L.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299') THEN 'USD'
			ELSE '???'
			END;

COMMIT;

INSERT /*+ APPEND */ INTO MAP_SALES_DATA
(
QUERY_SOURCE,
BU,
REVENUE_AMOUNT,
REVENUE_AMOUNT_DEC,
GL_ACCOUNT,
DEPT_ID,
DEPT_DESCR,
MANF_PROD_ID,
MANF_PROD_DESCR,
DIST_GL_PRODUCT,
RESERVE_GROUP,
JRNL_DATE,
JRNL_YEAR,
JRNL_MONTH,
JRNL_YEAR_MONTH,
JRNL_ID,
CURRENCY,
COUNTRY_INDICATOR,
TWO_FIVE
)
SELECT
		/*+ NO_CPU_COSTING */
		'P/S LEDGER' AS QUERY_SOURCE,
		PS.BUSINESS_UNIT AS BU,
		SUM(PS.POSTED_TOTAL_AMT) AS REVENUE_AMOUNT,
		SUM(100 *(PS.POSTED_TOTAL_AMT - TRUNC(PS.POSTED_TOTAL_AMT))) AS REVENUE_AMOUNT_DEC,
		PS.R12_ACCOUNT AS GL_ACCOUNT, 
		PS.R12_LOCATION AS DEPT_ID, 
		DP.R12_LOCATION_DESCR AS DEPT_DESCR,
		PS.PS_PRODUCT AS MANF_PROD_ID, 
		PR.R12_PRODUCT_DESCR AS MANF_PROD_DESCR,
		PS.R12_PRODUCT AS DIST_GL_PRODUCT, 
		NVL(PX.PRODUCT_CATEGORY, 'INVALID PROD CODE - '|| PS.R12_PRODUCT) AS RESERVE_GROUP, 
		TO_DATE('15-' || PS.ACCOUNTING_PERIOD || '-' || PS.FISCAL_YEAR, 'DD-MM-YYYY') AS JRNL_DATE,
		PS.FISCAL_YEAR AS JRNL_YEAR,
		PS.ACCOUNTING_PERIOD AS JRNL_MONTH,
		PS.FISCAL_YEAR * 100 + PS.ACCOUNTING_PERIOD AS JRNL_YEAR_MONTH,
		'ZZZZZZ' AS JRNL_ID,
		PS.CURRENCY_CD AS CURRENCY,
		CASE
			WHEN PS.BUSINESS_UNIT = 'CSD' THEN 'USD'
			WHEN PS.BUSINESS_UNIT = 'CAN' THEN 'CAD'
			ELSE ''
			END AS COUNTRY_INDICATOR,
		'N' AS TWO_FIVE
	FROM
		R12_LEDGER2_PS PS
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = PS.R12_ACCOUNT
	LEFT OUTER JOIN R12_PRODUCT_STG PR ON PS.R12_PRODUCT = PR.R12_PRODUCT -- R12_2_R12_ok  
	LEFT OUTER JOIN R12_LOCATION_STG DP     ON PS.R12_LOCATION = DP.R12_LOCATION -- R12_2_R12_ok 
	LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO PX ON PS.PS_PRODUCT = PX.MANF_PROD_CODE -- (+)
		AND PS.BUSINESS_UNIT = PX.GL_LEDGER
	WHERE
		PS.FISCAL_YEAR IN('2001', '2002')
		AND PS.ACCOUNTING_PERIOD <= '12'
		-- SR PS Data Only
		AND PS.PS_ACCOUNT = '700000'
		AND PS.LEDGER = 'ACTUALS'
	GROUP BY
		PS.BUSINESS_UNIT,
		PS.R12_ACCOUNT,  
		PS.R12_LOCATION, 
		DP.R12_LOCATION_DESCR,
		PS.PS_PRODUCT,
		PS.R12_PRODUCT, 
		PR.R12_PRODUCT_DESCR,
		PX.PRODUCT_CATEGORY,
		TO_DATE('15-' || PS.ACCOUNTING_PERIOD || '-' || PS.FISCAL_YEAR, 'DD-MM-YYYY'),
		PS.FISCAL_YEAR,
		PS.ACCOUNTING_PERIOD,
		PS.FISCAL_YEAR * 100 + PS.ACCOUNTING_PERIOD,
		PS.CURRENCY_CD,
		CASE
			WHEN PS.BUSINESS_UNIT = 'CSD' THEN 'USD'
			WHEN PS.BUSINESS_UNIT = 'CAN' THEN 'CAD'
			ELSE ''
			END;

COMMIT;

INSERT /*+ APPEND */ INTO MAP_SALES_DATA
(
QUERY_SOURCE,
BU,
REVENUE_AMOUNT,
REVENUE_AMOUNT_DEC,
GL_ACCOUNT,
DEPT_ID,
DEPT_DESCR,
MANF_PROD_ID,
MANF_PROD_DESCR,
DIST_GL_PRODUCT,
RESERVE_GROUP,
JRNL_DATE,
JRNL_YEAR,
JRNL_MONTH,
JRNL_YEAR_MONTH,
JRNL_ID,
CURRENCY,
COUNTRY_INDICATOR,
TWO_FIVE
)
SELECT
		/*+ NO_CPU_COSTING */
		'PBS' AS QUERY_SOURCE,
		BUSINESS_UNIT AS BU,
		SUM(P7_TOTAL) AS REVENUE_AMOUNT,
		SUM(100 *(P7_TOTAL - TRUNC(P7_TOTAL))) AS REVENUE_AMOUNT_DEC,
		GL_ACCOUNT AS GL_ACCOUNT,
		DEPTID AS DEPT_ID,
		DEPT_DESCR,
		PRODCODE AS MANF_PROD_ID,
		PROD_DESCR AS MANF_PROD_DESCR,
		GL_PRODCODE AS DIST_GL_PRODUCT,
		NVL(RESERVE_GROUP, 'LARGE') AS RESERVE_GROUP,
		JRNL_DATE AS JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) AS JRNL_YEAR,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_MONTH,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_YEAR_MONTH,
		JRNL_ID AS JRNL_ID,
		CURRENCY AS CURRENCY,
		NATION_CURR AS COUNTRY_INDICATOR,
		'N' AS TWO_FIVE
	FROM (
			SELECT
					/*+ NO_CPU_COSTING */
					D.R12_ENTITY AS BUSINESS_UNIT, 
					D.INVOICE AS INVOICE,
					D.LINE_SEQ_NUM AS SEQ_NUM,
					D.ACCT_ENTRY_TYPE AS ENTRY_TYPE,
					D.JOURNAL_ID AS JRNL_ID,
					D.JOURNAL_DATE AS JRNL_DATE,
					D.R12_ACCOUNT AS GL_ACCOUNT, 
					D.MONETARY_AMOUNT AS P7_TOTAL,
					D.R12_LOCATION AS DEPTID, 
					DP.R12_LOCATION_DESCR AS DEPT_DESCR,
					PR.R12_PRODUCT_DESCR AS PROD_DESCR,
					X.PRODUCT_CATEGORY AS RESERVE_GROUP,
					A.MANF_PROD_ID AS PRODCODE, 
					CASE
						WHEN D.R12_PRODUCT IN('41204', '41198') THEN '41204'
						ELSE D.R12_PRODUCT
						END AS GL_PRODCODE,
					D.CURRENCY_CD AS CURRENCY,
					CASE
						WHEN D.R12_ENTITY IN('5773', '5588') THEN 'CAD'
						WHEN D.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299') THEN 'USD'
						ELSE '???'
						END	AS NATION_CURR
				FROM
					R12_BI_LINE_PSB A 
				INNER JOIN R12_BI_ACCT_ENTRY_PSB D 
				ON D.LINE_SEQ_NUM = A.LINE_SEQ_NUM
					AND D.INVOICE = A.INVOICE AND D.BUSINESS_UNIT = A.BUSINESS_UNIT
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = D.R12_ACCOUNT
				INNER JOIN R12_BI_HDR_PSB BH ON 1=1
					AND BH.BILL_SOURCE_ID = 'PBS'
					AND D.INVOICE = BH.INVOICE
					AND D.BUSINESS_UNIT = BH.PS_BUSINESS_UNIT
				INNER JOIN R12_TRNBI_BI_HDR_PSB TBH ON 1=1
					AND '7' = TBH.TRNBI_PROJECT_TYPE
					AND D.INVOICE = TBH.INVOICE
					AND D.BUSINESS_UNIT = TBH.BUSINESS_UNIT
				LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO X ON D.PS_PRODUCT = X.MANF_PROD_CODE AND D.BUSINESS_UNIT = X.GL_LEDGER
				LEFT OUTER JOIN R12_PRODUCT_STG PR ON D.R12_PRODUCT = PR.R12_PRODUCT
				LEFT OUTER JOIN R12_LOCATION_STG DP ON D.R12_LOCATION = DP.R12_LOCATION 
				WHERE
					D.JOURNAL_DATE BETWEEN TO_DATE('03/01/2006', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
					AND 'ACTUALS' = D.LEDGER
					-- SR PS Data Only
					AND D.PS_ACCOUNT = '700000'
					AND D.PS_PRODUCT <> '804180' 
					AND D.PS_PRODUCT <> '804120' 
					AND D.PS_PRODUCT <> '804190'
					AND D.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299') -- -SS- CAN, USA
		)
	GROUP BY
		BUSINESS_UNIT,
		GL_ACCOUNT,
		DEPTID,
		DEPT_DESCR,
		PROD_DESCR,
		PRODCODE, --ADD BY ALEX
		GL_PRODCODE, --ADD BY ALEX
		NVL(RESERVE_GROUP, 'LARGE'),
		JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		JRNL_ID,
		CURRENCY,
		NATION_CURR;

COMMIT;

INSERT /*+ APPEND */ INTO MAP_SALES_DATA
(
QUERY_SOURCE,
BU,
REVENUE_AMOUNT,
REVENUE_AMOUNT_DEC,
GL_ACCOUNT,
DEPT_ID,
DEPT_DESCR,
MANF_PROD_ID,
MANF_PROD_DESCR,
DIST_GL_PRODUCT,
RESERVE_GROUP,
JRNL_DATE,
JRNL_YEAR,
JRNL_MONTH,
JRNL_YEAR_MONTH,
JRNL_ID,
CURRENCY,
COUNTRY_INDICATOR,
TWO_FIVE
)
SELECT
		/*+ NO_CPU_COSTING */
		'P21' AS QUERY_SOURCE,
		BUSINESS_UNIT AS BU,
		SUM(P7_TOTAL) AS REVENUE_AMOUNT,
		SUM(100 *(P7_TOTAL - TRUNC(P7_TOTAL))) AS REVENUE_AMOUNT_DEC,
		GL_ACCOUNT AS GL_ACCOUNT,
		DEPTID AS DEPT_ID,
		DEPT_DESCR AS DEPT_DESCR,
		MANF_PROD_ID AS MANF_PROD_ID,
		PROD_DESCR AS MANF_PROD_DESCR,
		GL_PRODCODE AS DIST_GL_PRODUCT,
		NVL(RESERVE_GROUP, 'LARGE') AS RESERVE_GROUP,
		JRNL_DATE AS JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) AS JRNL_YEAR,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_MONTH,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_YEAR_MONTH,
		JRNL_ID AS JRNL_ID,
		CURRENCY AS CURRENCY,
		NATION_CURR AS COUNTRY_INDICATOR,
		'N' AS TWO_FIVE
	FROM
		(
			/* SR This is truly nasty code. Under the old system some parts did not have a MANF_PROD_CODE on the Line
			These parts use the MANF_PROD_CODE in the GL_PROD (PS_PRODUCT) field on the R12_BI_ACCT_ENTRY_PSB table
			In order to make this work, we need to keep the old query for PS, and add a new one for R12
			*/
			-- Query for PeopleSoft Products using the R12_BI_ACCT_ENTRY_PSB.PS_PRODUCT field
			SELECT
					/*+ NO_CPU_COSTING */
					D.R12_ENTITY AS BUSINESS_UNIT, 
					D.INVOICE AS INVOICE,
					D.LINE_SEQ_NUM AS SEQ_NUM,
					D.ACCT_ENTRY_TYPE AS ENTRY_TYPE,
					D.JOURNAL_ID AS JRNL_ID,
					D.JOURNAL_DATE AS JRNL_DATE,
					D.R12_ACCOUNT AS GL_ACCOUNT, 
					D.MONETARY_AMOUNT AS P7_TOTAL,
					D.R12_LOCATION AS DEPTID, 
					DP.R12_LOCATION_DESCR AS DEPT_DESCR,
					PR.R12_PRODUCT_DESCR AS PROD_DESCR,
					X.PRODUCT_CATEGORY AS RESERVE_GROUP,
					A.MANF_PROD_ID AS MANF_PROD_ID, 
					CASE
						WHEN D.R12_PRODUCT IN('41204', '41198') THEN '41204'
						ELSE D.R12_PRODUCT
						END AS GL_PRODCODE,
					D.CURRENCY_CD AS CURRENCY,
					CASE
						WHEN D.R12_ENTITY IN('5773', '5588') THEN 'CAD'
						WHEN D.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299') THEN 'USD'
						ELSE '???'
						END	AS NATION_CURR
				FROM
					R12_BI_LINE_PSB A 
				INNER JOIN R12_BI_ACCT_ENTRY_PSB D ON D.LINE_SEQ_NUM = A.LINE_SEQ_NUM
					AND D.INVOICE = A.INVOICE AND D.BUSINESS_UNIT = A.BUSINESS_UNIT
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = D.R12_ACCOUNT
				INNER JOIN R12_BI_HDR_PSB BH ON 1=1
					AND BH.BILL_SOURCE_ID = 'P21'
					AND D.INVOICE = BH.INVOICE
					AND D.BUSINESS_UNIT = BH.PS_BUSINESS_UNIT
				INNER JOIN R12_TRNBI_BI_HDR_PSB TBH ON 1=1
					AND '7' = TBH.TRNBI_PROJECT_TYPE
					AND D.INVOICE = TBH.INVOICE
					AND D.BUSINESS_UNIT = TBH.BUSINESS_UNIT
				LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO X ON D.PS_PRODUCT = X.MANF_PROD_CODE AND D.BUSINESS_UNIT = X.GL_LEDGER -- (+)
				LEFT OUTER JOIN R12_PRODUCT_STG PR ON D.R12_PRODUCT = PR.R12_PRODUCT -- R12_2_R12_ok 
				LEFT OUTER JOIN R12_LOCATION_STG DP ON D.R12_LOCATION = DP.R12_LOCATION 
				WHERE
					D.PS_PRODUCT <> 'NA'
					-- Gets PeopleSoft Data only. Will not pull R12 data.
					AND D.JOURNAL_DATE BETWEEN TO_DATE('01/11/2014', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
					-- SR PS Data Only
					AND D.PS_ACCOUNT = '700000'
					AND 'ACTUALS' = D.LEDGER
					AND D.PS_PRODUCT NOT IN ('805100', '802921', '801270', '803270', '804140')
					AND D.R12_ENTITY IN ('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299') -- -SS- CAN, USA
		)
	GROUP BY
		BUSINESS_UNIT,
		GL_ACCOUNT,
		DEPTID,
		DEPT_DESCR,
		PROD_DESCR,
		MANF_PROD_ID,
		GL_PRODCODE,
		NVL(RESERVE_GROUP, 'LARGE'),
		JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		JRNL_ID,
		CURRENCY,
		NATION_CURR;

COMMIT;

INSERT /*+ APPEND */ INTO MAP_SALES_DATA
(
QUERY_SOURCE,
BU,
REVENUE_AMOUNT,
REVENUE_AMOUNT_DEC,
GL_ACCOUNT,
DEPT_ID,
DEPT_DESCR,
MANF_PROD_ID,
MANF_PROD_DESCR,
DIST_GL_PRODUCT,
RESERVE_GROUP,
JRNL_DATE,
JRNL_YEAR,
JRNL_MONTH,
JRNL_YEAR_MONTH,
JRNL_ID,
CURRENCY,
COUNTRY_INDICATOR,
TWO_FIVE
)
SELECT
		/*+ NO_CPU_COSTING */
		'P21R12' AS QUERY_SOURCE,
		BUSINESS_UNIT AS BU,
		SUM(P7_TOTAL) AS REVENUE_AMOUNT,
		SUM(100 *(P7_TOTAL - TRUNC(P7_TOTAL))) AS REVENUE_AMOUNT_DEC,
		GL_ACCOUNT AS GL_ACCOUNT,
		DEPTID AS DEPT_ID,
		DEPT_DESCR AS DEPT_DESCR,
		MANF_PROD_ID AS MANF_PROD_ID,
		PROD_DESCR AS MANF_PROD_DESCR,
		GL_PRODCODE AS DIST_GL_PRODUCT,
		NVL(RESERVE_GROUP, 'LARGE') AS RESERVE_GROUP,
		JRNL_DATE AS JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) AS JRNL_YEAR,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_MONTH,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')) AS JRNL_YEAR_MONTH,
		JRNL_ID AS JRNL_ID,
		CURRENCY AS CURRENCY,
		NATION_CURR AS COUNTRY_INDICATOR,
		'N' AS TWO_FIVE
	FROM
		(
			SELECT
					/*+ NO_CPU_COSTING */
					D.R12_ENTITY AS BUSINESS_UNIT, 
					D.INVOICE AS INVOICE,
					D.LINE_SEQ_NUM AS SEQ_NUM,
					D.ACCT_ENTRY_TYPE AS ENTRY_TYPE,
					D.JOURNAL_ID AS JRNL_ID,
					D.JOURNAL_DATE AS JRNL_DATE,
					D.R12_ACCOUNT AS GL_ACCOUNT, 
					D.MONETARY_AMOUNT AS P7_TOTAL,
					D.R12_LOCATION AS DEPTID, 
					DP.R12_LOCATION_DESCR AS DEPT_DESCR,
					PR.R12_PRODUCT_DESCR AS PROD_DESCR,
					X.PRODUCT_CATEGORY AS RESERVE_GROUP,
					A.MANF_PROD_ID AS MANF_PROD_ID, 
					CASE
						WHEN D.R12_PRODUCT IN('41204', '41198') THEN '41204'
						ELSE D.R12_PRODUCT
						END AS GL_PRODCODE,
					D.CURRENCY_CD AS CURRENCY,
					CASE
						WHEN D.R12_ENTITY IN('5773', '5588') THEN 'CAD'
						WHEN D.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299') THEN 'USD'
						ELSE '???'
						END	AS NATION_CURR
				FROM
					R12_BI_LINE_STG A 
				INNER JOIN R12_BI_ACCT_ENTRY_STG D
					ON D.LINE_SEQ_NUM = A.LINE_SEQ_NUM
					AND D.INVOICE = A.INVOICE 
					AND D.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
				INNER JOIN R12_BI_HDR_STG BH
					ON D.INVOICE = BH.INVOICE
					AND D.CUSTOMER_TRX_ID = BH.CUSTOMER_TRX_ID
				INNER JOIN R12_TRNBI_BI_HDR_STG TBH
					ON D.INVOICE = TBH.INVOICE
					AND D.CUSTOMER_TRX_ID = TBH.CUSTOMER_TRX_ID
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
					ON AFU.R12_ACCOUNT = D.R12_ACCOUNT
				LEFT OUTER JOIN OTR_PROD_CODE_XREF_RCPO X
					ON A.MANF_PROD_ID = X.MANF_PROD_CODE
				LEFT OUTER JOIN R12_PRODUCT_STG PR
					ON D.R12_PRODUCT = PR.R12_PRODUCT 
				LEFT OUTER JOIN R12_LOCATION_STG DP
					ON D.R12_LOCATION = DP.R12_LOCATION 
				WHERE
					 D.JOURNAL_DATE BETWEEN TO_DATE('01/11/2014', 'MM/DD/YYYY') AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
					AND BH.BILL_SOURCE_ID = 'P21'
					AND TBH.TRNBI_PROJECT_TYPE = '7'
					AND D.LEDGER = 'ACTUALS'
					AND X.GL_LEDGER = 'CSD'
					AND AFU.EQUAL_700000 = 'Y'
					AND D.R12_PRODUCT NOT IN ('41208', '41399', '41132', '41499', '41205')
					AND D.R12_ENTITY IN ('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299')
					-- Kelly is undecided about this:
					-- AND A.MANF_PROD_ID IS NOT NULL
		)
	GROUP BY
		BUSINESS_UNIT,
		GL_ACCOUNT,
		DEPTID,
		DEPT_DESCR,
		PROD_DESCR,
		MANF_PROD_ID,
		GL_PRODCODE,
		NVL(RESERVE_GROUP, 'LARGE'),
		JRNL_DATE,
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(JRNL_DATE), 'MM')),
		JRNL_ID,
		CURRENCY,
		NATION_CURR;

COMMIT;

INSERT /*+ APPEND */ INTO MAP_SALES_DATA
(
QUERY_SOURCE,
BU,
REVENUE_AMOUNT,
REVENUE_AMOUNT_DEC,
GL_ACCOUNT,
DEPT_ID,
DEPT_DESCR,
MANF_PROD_ID,
MANF_PROD_DESCR,
DIST_GL_PRODUCT,
RESERVE_GROUP,
JRNL_DATE,
JRNL_YEAR,
JRNL_MONTH,
JRNL_YEAR_MONTH,
JRNL_ID,
CURRENCY,
COUNTRY_INDICATOR,
TWO_FIVE
)
SELECT
		/*+   ORDERED NO_CPU_COSTING  INDEX(PR XAK1AP_135_PROJ_RESOURCE)*/
		'PUEBLO' AS QUERY_SOURCE,
		PR.R12_ENTITY AS BU, 
		CD.RESOURCE_AMOUNT AS REVENUE_AMOUNT,
		100 *(CD.RESOURCE_AMOUNT - TRUNC(CD.RESOURCE_AMOUNT)) AS REVENUE_AMOUNT_DEC,
		PR.R12_ACCOUNT AS GL_ACCOUNT, 
		PR.R12_LOCATION AS DEPT_ID,   -- -SS-- DEPTID
		PR.DESCR AS DEPT_DESCR,
		RES.TRNPC_MFG_PROD_CD AS MANF_PROD_ID,
		MPC.PRODUCT_CODE_DESCRIPTION AS MANF_PROD_DESCR,
		MPC.DIST_PROD_CODE AS DIST_GL_PRODUCT,
		'Large' AS RESERVE_GROUP,
		PR.ACCOUNTING_DT AS JRNL_DATE,
		TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT, 'YYYY')) AS JRNL_YEAR,
		TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT, 'MM')) AS JRNL_MONTH,
		TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT, 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(PR.ACCOUNTING_DT, 'MM')) AS JRNL_YEAR_MONTH,
		PR.JOURNAL_ID AS JRNL_ID,
		PR.CURRENCY_CD AS CURRENCY,
		CASE
			WHEN PR.R12_ENTITY IN('5773', '5588') THEN 'CAD'
			WHEN PR.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299') THEN 'USD'
			ELSE '???'
			END AS COUNTRY_INDICATOR,
		'N' AS TWO_FIVE
	FROM
		R12_PROJ_RESOURCE_PS PR
	INNER JOIN AP_135_TRNPC_PROJ_RES RES ON PR.BUSINESS_UNIT = RES.BUSINESS_UNIT
		AND PR.PROJECT_ID = RES.PROJECT_ID AND PR.RESOURCE_ID = RES.RESOURCE_ID AND PR.ACTIVITY_ID = RES.ACTIVITY_ID
	INNER JOIN AP_400_SEL_CRED_JB_CLSS_CD JBCLSCD ON PR.PROJECT_ID = CAST(JBCLSCD.CREDIT_JOB_ID AS VARCHAR2(15 BYTE))
	INNER JOIN AP_400_JOB_CODE JBCD ON JBCD.JOB_CODE_ID = JBCLSCD.JOB_CODE_ID
	INNER JOIN AP_135_TRNPC_COMM_DATA CD ON PR.BUSINESS_UNIT = CD.BUSINESS_UNIT
		AND PR.PROJECT_ID = CD.PROJECT_ID AND PR.RESOURCE_ID = CD.RESOURCE_ID AND PR.ACTIVITY_ID = CD.ACTIVITY_ID
	INNER JOIN AP_400_COMM_CODE CC ON CD.TRNPC_COMM_CODE = CC.COMM_CODE
		AND CD.SALES_OFFICE_ID = CC.SALES_OFFICE_ID
	INNER JOIN MD_PRODUCT_CODE MPC ON RES.TRNPC_MFG_PROD_CD = MPC.PRODUCT_CODE_VALUE
	INNER JOIN MD_SECURITY_ENTITY_DRV SEC ON 1=1 AND PR.ps_BUSINESS_UNIT_GL = SEC.PS_GL AND PR.ps_DEPTID = SEC.PS_DEPT_ID
--	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = PR.R12_ACCOUNT
	WHERE
		PR.BUSINESS_UNIT IN('PCGUS', 'PCGCN')
		AND PR.ANALYSIS_TYPE = 'REV'
		AND PR.PS_ACCOUNT IN('700000', '700020')
		AND PR.GL_DISTRIB_STATUS = 'G'
		AND JBCD.JOB_CLASS_ID = 38
		AND TRUNC(PR.ACCOUNTING_DT) >= TO_DATE('01/01/2007', 'MM/DD/YYYY')
		AND TRUNC(PR.ACCOUNTING_DT) <= TO_DATE('12/31/2050', 'MM/DD/YYYY')
		 -- -SS- CAN, USA
		AND PR.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299');

COMMIT;

EXIT