TRUNCATE TABLE TAV_STG;
INSERT INTO TAV_STG (
CLAIM_NUMBER,
BUSINESS_UNIT,
RESERVE_GROUP,
CLAIM_TYPE,
CONCESSION_DAYS,
WARRANTY_DURATION,
EXPENSE_AMOUNT,
EXPENSE_AMOUNT_DEC,
MATERIAL_LABOR,
GL_ACCOUNT,
EXPENSE_TYPE_DESCR,
OFFICE_NAME,
GL_PROD_CODE,
MANF_PROD_CODE,
COMPANY_OWNED,
CUSTOMER_NUMBER,
CUSTOMER_NAME,
INTERNAL_EXTERNAL,
TRX_DATE,
TRX_YEAR,
TRX_MONTH,
INTMONTHS_TRX_TO_BASE,
INTMONTHS_SHIP_TO_BASE,
SHIP_DATE,
SHIP_YEAR_MONTH,
INTMONTHS_SHIP_TO_TRX,
START_DATE,
INTMONTHS_START_TO_TRX,
FAIL_DATE,
INTMONTHS_FAIL_TO_TRX,
WARRANTY_TYPE,
CURRENCY,
COUNTRY_INDICATOR,
RETROFIT_ID,
IN_RESERVE_PERCENT,
IN_RESERVE_PERCENT_25,
TRX_LAG,
START_LAG_25,
TRXYEARMONTH,
EXPENSE_AMT_IN_RES,
EXPENSE_AMT_NOT_IN_RES
)
SELECT
EXT2.CLAIM_NUMBER,
EXT2.SEGMENT1 AS BUSINESS_UNIT,
PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
EXT2.CLAIM_TYPE,
CASE WARRANTY_DURATION_CODE
	WHEN '<' THEN '<= 548 DAYS'
	WHEN '>' THEN '> 548 DAYS'
	ELSE 'NA'
	END AS CONCESSION_DAYS,
CASE WARRANTY_DURATION_CODE
	WHEN '<' THEN '<= 548 DAYS'
	WHEN '>' THEN '> 548 DAYS'
	WHEN '1' THEN '1st Year Standard Warranty'
	WHEN '2' THEN '2nd-5th Year Standard Warranty'
	WHEN '5' THEN '> 5th Year Standard Warranty'
	WHEN '0' THEN 'Out of Standard Warranty'
	ELSE 'NA'
	END AS WARRANTY_DURATION,
EXT2.GL_EXPENSE_AMT AS EXPENSE_AMOUNT,
100 * (EXT2.GL_EXPENSE_AMT - TRUNC(EXT2.GL_EXPENSE_AMT)) AS EXPENSE_AMOUNT_DEC,
EXT2.MATERIAL_LABOR,
EXT2.SEGMENT4 AS GL_ACCOUNT,
EXT2.EXPENSE_TYPE_DESCR,
'unknown' AS OFFICE_NAME,
EXT2.SEGMENT5 AS GL_PROD_CODE,
EXT2.MANF_PROD_CODE,
CASE WHEN EXT2.COMPANY_OWNED_IND <> 0 THEN 'Y' ELSE 'N' END AS COMPANY_OWNED,
EXT2.CUSTOMER_NUMBER,
EXT2.CUSTOMER_NAME,
CASE WHEN EXT2.INTERNAL_IND <> 0 THEN 'Y' ELSE 'N' END AS INTERNAL_EXTERNAL,
EXT2.FILED_ON_DATE AS TRX_DATE, -- IS THIS RIGHT?
TO_NUMBER(TO_CHAR(TO_DATE(EXT2.FILED_ON_DATE), 'YYYY')) AS TRX_YEAR,
TO_NUMBER(TO_CHAR(TO_DATE(EXT2.FILED_ON_DATE), 'MM')) AS TRX_MONTH,
MONTHS_BETWEEN(SYSDATE, EXT2.FILED_ON_DATE) AS INTMONTHS_TRX_TO_BASE,
CEIL(MONTHS_BETWEEN(SYSDATE, EXT2.SHIP_DATE)) AS INTMONTHS_SHIP_TO_BASE,
EXT2.SHIP_DATE,
TO_NUMBER(TO_CHAR(TO_DATE(EXT2.SHIP_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(EXT2.SHIP_DATE), 'MM')) AS SHIP_YEAR_MONTH,
CEIL(MONTHS_BETWEEN(EXT2.FILED_ON_DATE, EXT2.SHIP_DATE)) AS INTMONTHS_SHIP_TO_TRX,
EXT2.START_DATE,
MONTHS_BETWEEN(EXT2.FILED_ON_DATE, EXT2.START_DATE) AS INTMONTHS_START_TO_TRX,
EXT2.FAILURE_DATE AS FAIL_DATE,
MONTHS_BETWEEN(EXT2.FAILURE_DATE, EXT2.FILED_ON_DATE) AS INTMONTHS_FAIL_TO_TRX,
CASE EXT2.WARRANTY_TYPE
	WHEN 'EXTENDED' THEN 'EXT'
	WHEN 'GOODWILL' THEN 'GW'
	WHEN 'STANDARD' THEN 'STD'
	ELSE 'NO'
	END AS WARRANTY_TYPE,
EXT2.GL_EXPENSE_CURR AS CURRENCY,
CASE
	WHEN EXT2.SEGMENT1 IN('5773', '5588') THEN 'CAD'
	WHEN EXT2.SEGMENT1 IN('5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984') THEN 'USD'
	ELSE 'other'
	END AS COUNTRY_INDICATOR,
'unknown' AS RETROFIT_ID,

CASE
	WHEN SRCA.CLAIM_NUMBER IS NULL -- ALWAYS TRUE
		THEN 10000 * COALESCE(RES_PCT.RESERVE_PCT, -1)
	ELSE RES_PCT1.RESERVE_PCT
	END AS IN_RESERVE_PERCENT,
CASE
	WHEN SRCA.CLAIM_NUMBER IS NULL -- ALWAYS TRUE
		THEN 10000 * (CASE
			WHEN
				( -- PCS.PROD_CODE
					EXT2.MANF_PROD_CODE IN('0054', '0197'))
				OR (EXT2.WARRANTY_DURATION_CODE NOT IN('2', '5'))
				OR(ROUND(( -- CCN_DATA.TRX_FULL_DATE
					EXT2.FILED_ON_DATE - -- TD2.FULL_DATE
					EXT2.SHIP_DATE) / 30.42) > 91)
				OR(ROUND(( -- TD.FULL_DATE
					EXT2.START_DATE - -- TD2.FULL_DATE
					EXT2.SHIP_DATE) / 30.42) > 24)
				THEN 0
			ELSE COALESCE(RES_PCT.RESERVE_PCT, -1)
			END
		)
	ELSE RES_PCT1.RESERVE_PCT
	END AS IN_RESERVE_PERCENT_25,

ROUND((TRUNC(EXT2.FILED_ON_DATE) - TRUNC(EXT2.SHIP_DATE)) / 30.42) AS TRX_LAG,
ROUND((TRUNC(EXT2.START_DATE) - TRUNC(EXT2.SHIP_DATE)) / 30.42) AS START_LAG_25,
TO_NUMBER(TO_CHAR(TO_DATE(EXT2.FILED_ON_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(EXT2.FILED_ON_DATE), 'MM')) AS TRXYEARMONTH,
0 AS EXPENSE_AMT_IN_RES,
0 AS EXPENSE_AMT_NOT_IN_RES
FROM (

-- EXT2
SELECT 
EXTRACT.*,
-- CLAIM_TYPE
CASE COMMERCIAL_POLICY
	WHEN 0 THEN CASE TAVANT_CLAIM_TYPE
		WHEN 'MACHINE' THEN CASE WARRANTY_TYPE
			WHEN 'EXTENDED' THEN 'NA'
			WHEN 'GOODWILL' THEN 'CONCESSION'
			WHEN 'STANDARD' THEN 'MATERIAL'
			ELSE 'NA'
			END
		WHEN 'CAMPAIGN' THEN CASE
			-- NOT SURE ABOUT THIS - LOCAL PURCHASE?
			WHEN (UPPER(COST_CATEGORY) IN ('LABOR') OR UPPER(COST_CATEGORY) LIKE 'TRAVEL%') THEN 'RETROFIT LABOR'
			ELSE 'RETROFIT MATERIAL'
			END
		ELSE 'UNKNOWN TAVANT_CLAIM_TYPE'
		END
	WHEN 1 THEN CASE TAVANT_CLAIM_TYPE
		WHEN 'MACHINE' THEN 'CONCESSION'
		WHEN 'CAMPAIGN' THEN 'NA'
		ELSE 'UNKNOWN TAVANT_CLAIM_TYPE'
		END
	ELSE 'UNKNOWN COMMERCIAL_POLICY'
	END AS CLAIM_TYPE,
CASE COST_CATEGORY
	WHEN 'Additional Travel Hours' THEN 'Labor'
	WHEN 'Freight' THEN 'Material'
	WHEN 'Labor' THEN 'Labor'
	WHEN 'Local Purchase' THEN 'Material'
	WHEN 'Non Oem Parts' THEN 'Material'
	WHEN 'Oem Parts' THEN 'Material'
	WHEN 'Others' THEN 'Labor'
	WHEN 'Rebate' THEN 'Material'
	WHEN 'Travel by Hours' THEN 'Labor'
	WHEN 'Travel by Perdiem' THEN 'Labor'
	ELSE 'unknown'
	END AS MATERIAL_LABOR,
CASE COST_CATEGORY
	WHEN 'Additional Travel Hours' THEN 'LABOR'
	WHEN 'Freight' THEN 'FREIGHT'
	WHEN 'Item Freight And Duty' THEN 'FREIGHT'
	WHEN 'Labor' THEN 'LABOR'
	WHEN 'Local Purchase' THEN 'MATERIAL'
	WHEN 'Meals' THEN 'OTHER'
	WHEN 'Miscellaneous Parts' THEN 'OTHER'
	WHEN 'Non Oem Parts' THEN 'MATERIAL'
	WHEN 'Oem Parts' THEN 'MATERIAL'
	WHEN 'Other Freight And Duty' THEN 'OTHER'
	WHEN 'Others' THEN 'LABOR'
	WHEN 'Parking' THEN 'OTHER'
	WHEN 'Per Diem' THEN 'OTHER'
	WHEN 'Rebate' THEN 'REBATE'
	WHEN 'Rental Charges' THEN 'OTHER'
	WHEN 'Tolls' THEN 'OTHER'
	WHEN 'Travel By Distance' THEN 'OTHER'
	WHEN 'Travel By Trip' THEN 'OTHER'
	WHEN 'Travel by Hours' THEN 'LABOR'
	WHEN 'Travel by Perdiem' THEN 'LABOR'
	ELSE CASE
		WHEN REBATES_GL_AMT IS NOT NULL THEN 'REBATE'
		ELSE 'unknown'
		END
	END AS EXPENSE_TYPE_DESCR,
MONTHS_BETWEEN(FAILURE_DATE, SHIP_DATE) AS SHIP2FAIL,
MONTHS_BETWEEN(FAILURE_DATE, START_DATE) AS START2FAIL,
CASE WARRANTY_TYPE
	WHEN 'EXTENDED' THEN 'NA'
	WHEN 'GOODWILL' THEN CASE
		WHEN TRUNC(FAILURE_DATE) - TRUNC(SHIP_DATE) < 548 THEN '<'
		ELSE '>'
		END
	ELSE CASE
		WHEN MONTHS_BETWEEN(FAILURE_DATE, SHIP_DATE) <= 18 OR MONTHS_BETWEEN(FAILURE_DATE, START_DATE) <= 12 THEN '1'
		WHEN MONTHS_BETWEEN(FAILURE_DATE, SHIP_DATE) <= 66 OR MONTHS_BETWEEN(FAILURE_DATE, START_DATE) <= 60 THEN '2'
		WHEN MONTHS_BETWEEN(FAILURE_DATE, SHIP_DATE) <= 66 AND MONTHS_BETWEEN(FAILURE_DATE, START_DATE) <= 60 THEN '5'
		ELSE '0'
		END
	END AS WARRANTY_DURATION_CODE,
	CASE WHEN INSTR(UPPER(DEALER_GROUP_NAME), 'INDEPENDENT') = 0 THEN 1 ELSE 0 END AS COMPANY_OWNED_IND,
	CASE UPPER(DEALER_GROUP_NAME)
		WHEN 'USA COMPANY OWNED PARTS' THEN 1
		WHEN 'USA COMPANY OWNED SERVICE' THEN 1
		WHEN 'CANADA COMPANY OWNED PARTS' THEN 1
		WHEN 'CANADA COMPANY OWNED SERVICE' THEN 1
		ELSE 0
		END AS INTERNAL_IND
FROM (

-- EXTRACT
SELECT
		PAYMENTS.CLAIM_NUMBER,
		PAYMENTS.TAVANT_CLAIM_TYPE,
		PAYMENTS.COMMERCIAL_POLICY,
		PAYMENTS.QUERY_SOURCE,
		PAYMENTS.WARRANTY_TYPE,
		PAYMENTS.PRIORITY,
		PAYMENTS.PART_NBR,
		PAYMENTS.COST_CATEGORY,
		PAYMENTS.GL_EXPENSE_STRING,
		PAYMENTS.SEGMENT1,
		PAYMENTS.SEGMENT2,
		PAYMENTS.SEGMENT3,
		PAYMENTS.SEGMENT4,
		PAYMENTS.SEGMENT5,
		PAYMENTS.SEGMENT6,
		PAYMENTS.SEGMENT7,
		PAYMENTS.SEGMENT8,
		PAYMENTS.GL_EXPENSE_AMT,
		PAYMENTS.GL_EXPENSE_CURR,
		PAYMENTS.REBATES_GL_NAME,
		PAYMENTS.REBATES_GL_CODE_WNTY_EXP_REV,
		PAYMENTS.REBATES_GL_AMT,
		PAYMENTS.REBATES_GL_CURR,
		PAYMENTS.FAILURE_DATE,
		PAYMENTS.FILED_ON_DATE,
		ITEMS.SHIP_DATE,
		ITEMS.START_DATE,
		ITEMS.MANF_PROD_CODE,
		ITEMS.DEALER_GROUP_NAME,
		ITEMS.CUSTOMER_NUMBER,
		ITEMS.CUSTOMER_NAME
	FROM
		TAV_PAYMENT_RAW PAYMENTS
	INNER JOIN (
		-- ITEMS - AGGREGATE
		SELECT
		CLAIM_NUMBER,
		COUNT(DISTINCT CLAIMED_ITEM_ID) AS ITEM_COUNT,
		MIN(ITEM_REF_INV_ITEM) AS MIN_ITEM_REF_INV_ITEM,
		COUNT(DISTINCT ITEM_REF_INV_ITEM) AS COUNT_OF_ITEM_REF_INV_ITEM,
		MIN(SHIPMENT_DATE) AS SHIP_DATE,
		COUNT(DISTINCT SHIPMENT_DATE) AS COUNT_OF_SHIP_DATE,
		MIN(DELIVERY_DATE) AS START_DATE,
		COUNT(DISTINCT DELIVERY_DATE) AS COUNT_OF_START_DATE,
		MIN(SALES_ORDER_NUMBER) AS MIN_SALES_ORDER_NUMBER,
		COUNT(DISTINCT SALES_ORDER_NUMBER) AS COUNT_OF_SALES_ORDER_NUMBER,
		MIN(MFG) AS MIN_MFG,
		COUNT(DISTINCT MFG) AS COUNT_OF_MFG,
		MIN(ORIGINAL_SOURCE_ID) AS MIN_ORIGINAL_SOURCE_ID,
		COUNT(DISTINCT ORIGINAL_SOURCE_ID) AS COUNT_OF_ORIGINAL_SOURCE_ID,
		MIN(SIOP_SEGMENT6) AS MANF_PROD_CODE,
		COUNT(DISTINCT SIOP_SEGMENT6) AS COUNT_OF_MANF_PROD_CODE,
		MIN(DEALER_GROUP_NAME) AS DEALER_GROUP_NAME,
		COUNT(DISTINCT DEALER_GROUP_NAME) AS COUNT_OF_DEALER_GROUP_NAME,
		MIN(CUSTOMER_NUMBER) AS CUSTOMER_NUMBER,
		COUNT(DISTINCT CUSTOMER_NUMBER) AS COUNT_OF_CUSTOMER_NUMBER,
		MIN(CUSTOMER_NAME) AS CUSTOMER_NAME,
		COUNT(DISTINCT CUSTOMER_NAME) AS COUNT_OF_CUSTOMER_NAME
		-- ,LISTAGG(PRODUCT_DEFINITION_CODE, ', ') WITHIN GROUP (ORDER BY PRODUCT_DEFINITION_CODE) AS PD_CODES
		FROM
			TAV_ITEM_RAW
		GROUP BY
			CLAIM_NUMBER
	) ITEMS
		ON ITEMS.CLAIM_NUMBER = PAYMENTS.CLAIM_NUMBER
	WHERE
		0 = 0
-- AND CLAIM.CLAIM_NUMBER = 'C-10764292'
-- order by 1, 2, 3, 4, 5

) EXTRACT
) EXT2

	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
		ON EXT2.SEGMENT4 = AFU.R12_ACCOUNT

	LEFT OUTER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP
		ON EXT2.MANF_PROD_CODE = PRODGRP.MANF_PROD_CODE AND 'CSD' = PRODGRP.GL_LEDGER

	-- does not contain any tavant claims:
	LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ SRCA
		ON SRCA.CLAIM_NUMBER = EXT2.CLAIM_NUMBER

	-- big multiplier
	LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT
		ON UPPER(EXT2.CLAIM_TYPE) = UPPER(RES_PCT.CLAIM_TYPE)
		AND UPPER(EXT2.EXPENSE_TYPE_DESCR) = UPPER(RES_PCT.EXPENSE_TYPE_DESCR)
		AND UPPER(EXT2.MATERIAL_LABOR) = UPPER(RES_PCT.EXPENSE_TYPE_CATG)
		AND CASE EXT2.COMPANY_OWNED_IND WHEN 1 THEN 'Y' ELSE 'N' END = RES_PCT.COMPANY_OWNED_IND
	
	LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RES_PCT1
		ON SRCA.CLAIM_TYPE = RES_PCT1.CLAIM_TYPE

WHERE 0=0
	AND GL_EXPENSE_AMT <> 0
	;
COMMIT;
