TRUNCATE TABLE TAV_TEMP;
INSERT INTO TAV_TEMP (
		QUERY_SOURCE,
		CLAIM_NUMBER,
		BUSINESS_UNIT,
		RESERVE_GROUP,
		CLAIM_TYPE,
		WARRANTY_DURATION_CODE,
		CONCESSION_DAYS,
		WARRANTY_DURATION,
		EXPENSE_AMOUNT,
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
		TRX_LAG,
		START_LAG_25,
		TRXYEARMONTH,
		EXPENSE_AMT_IN_RES,
		EXPENSE_AMT_NOT_IN_RES,
		ACCEPTED_AMT_LABOR,
		ACCEPTED_AMT_MATERIAL,
		CREDIT_TO_THIRD_PARTY
)
SELECT
		EXT2.QUERY_SOURCE,
		EXT2.CLAIM_NUMBER,
		EXT2.SEGMENT1 AS BUSINESS_UNIT,
		PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
		CASE EXT2.CLAIM_TYPE
			WHEN 'RETROFIT' THEN
				CASE AFU.R12_ACCOUNT
					WHEN '511706' THEN 'RETROFIT MATERIAL'
					WHEN '685211' THEN 'RETROFIT MATERIAL'
					ELSE UPPER(EXT2.CLAIM_TYPE || ' ' || EXT2.MATERIAL_LABOR)
					END
			ELSE EXT2.CLAIM_TYPE
			END AS CLAIM_TYPE,
		EXT2.WARRANTY_DURATION_CODE,
		CASE EXT2.WARRANTY_DURATION_CODE
			WHEN '<' THEN '<= 548 DAYS'
			WHEN '>' THEN '> 548 DAYS'
			ELSE 'NA'
			END AS CONCESSION_DAYS,
		CASE EXT2.WARRANTY_DURATION_CODE
			WHEN '1' THEN '1st Year Standard Warranty'
			WHEN '2' THEN '2nd-5th Year Standard Warranty'
			WHEN '5' THEN '> 5th Year Standard Warranty'
			WHEN '0' THEN 'Out of Standard Warranty'
			ELSE 'NA'
			END AS WARRANTY_DURATION,
		EXT2.GL_EXPENSE_AMT AS EXPENSE_AMOUNT,
		EXT2.MATERIAL_LABOR,
		EXT2.SEGMENT4 AS GL_ACCOUNT,
		EXT2.EXPENSE_TYPE_DESCR,
		EXT2.OFFICE_NAME,
		EXT2.SEGMENT5 AS GL_PROD_CODE,
		EXT2.MANF_PROD_CODE,
		EXT2.COMPANY_OWNED_IND AS COMPANY_OWNED,
		EXT2.CUSTOMER_NUMBER,
		EXT2.CUSTOMER_NAME,
		EXT2.INTERNAL_IND AS INTERNAL_EXTERNAL,
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
		EXT2.WARRANTY_TYPE,
		EXT2.GL_EXPENSE_CURR AS CURRENCY,
		CASE
			WHEN EXT2.SEGMENT1 IN('5773', '5588') THEN 'CAD'
			WHEN EXT2.SEGMENT1 IN('5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984') THEN 'USD'
			ELSE 'other'
			END AS COUNTRY_INDICATOR,
		CAMPAIGN.CODE AS RETROFIT_ID,
		ROUND((TRUNC(EXT2.FILED_ON_DATE) - TRUNC(EXT2.SHIP_DATE)) / 30.42) AS TRX_LAG,
		ROUND((TRUNC(EXT2.START_DATE) - TRUNC(EXT2.SHIP_DATE)) / 30.42) AS START_LAG_25,
		TO_NUMBER(TO_CHAR(TO_DATE(EXT2.FILED_ON_DATE), 'YYYY')) * 100 + TO_NUMBER(TO_CHAR(TO_DATE(EXT2.FILED_ON_DATE), 'MM')) AS TRXYEARMONTH,
		0 AS EXPENSE_AMT_IN_RES,
		0 AS EXPENSE_AMT_NOT_IN_RES,
		CLAIM_LEVEL.ACCEPTED_AMT_LABOR,
		CLAIM_LEVEL.ACCEPTED_AMT_MATERIAL,
		EXT2.CREDIT_TO_THIRD_PARTY
	FROM
		(
			-- EXT2
			SELECT
					EXTRACT.*,
					-- warranty_type
					CASE TAVANT_WARRANTY_TYPE
						WHEN 'EXTENDED' THEN 'EXT'
						WHEN 'GOODWILL' THEN 'GW'
						WHEN 'STANDARD' THEN 'STD'
						ELSE CASE TAVANT_CLAIM_TYPE
							WHEN 'CAMPAIGN' THEN CASE COST_CATEGORY
								WHEN 'Additional Travel Hours' THEN 'CL'
								WHEN 'Freight' THEN 'CM'
								WHEN 'Labor' THEN 'CL'
								WHEN 'Local Purchase' THEN 'CM'
								WHEN 'Non Oem Parts' THEN 'CM'
								WHEN 'Oem Parts' THEN 'CM'
								WHEN 'Others' THEN 'CL'
								WHEN 'Rebate' THEN 'CM'
								WHEN 'Travel by Hours' THEN 'CL'
								WHEN 'Travel by Perdiem' THEN 'CL'
								ELSE 'NO'
								END
							ELSE CASE COMMERCIAL_POLICY
								WHEN 1 THEN 'CP'
								ELSE 'NO'
								END
							END
						END AS WARRANTY_TYPE,
					-- CLAIM_TYPE
					CASE
						WHEN TAVANT_WARRANTY_TYPE = 'EXTENDED' AND COMMERCIAL_POLICY = 0 AND TAVANT_CLAIM_TYPE = 'MACHINE'
							THEN 'EXT'
						WHEN TAVANT_WARRANTY_TYPE = 'GOODWILL' AND COMMERCIAL_POLICY = 0 AND TAVANT_CLAIM_TYPE = 'MACHINE'
							THEN 'CONCESSION'
						WHEN TAVANT_WARRANTY_TYPE = 'STANDARD' AND COMMERCIAL_POLICY = 0 AND TAVANT_CLAIM_TYPE = 'MACHINE'
							THEN 'MATERIAL'
						WHEN TAVANT_CLAIM_TYPE = 'CAMPAIGN'
							THEN 'RETROFIT'
						WHEN TAVANT_WARRANTY_TYPE IS NULL AND COMMERCIAL_POLICY = 1 AND TAVANT_CLAIM_TYPE = 'MACHINE'
							THEN 'CONCESSION'
						ELSE 'ERROR'
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
						WHEN 'Tolls' 	THEN 'OTHER'
						WHEN 'Travel By Distance'  THEN 'OTHER'
						WHEN 'Travel By Trip' THEN 'OTHER'
						WHEN 'Travel by Hours' THEN 'LABOR'
						WHEN 'Travel by Perdiem' THEN 'LABOR'
						WHEN 'Commissions' THEN 'COMMISSION'
						ELSE CASE QUERY_SOURCE
							WHEN 'REBATE' THEN 'REBATE'
							ELSE 'unknown'
							END
						END AS EXPENSE_TYPE_DESCR,
					MONTHS_BETWEEN(FAILURE_DATE, SHIP_DATE) AS SHIP2FAIL,
					MONTHS_BETWEEN(FAILURE_DATE, START_DATE) AS START2FAIL,
					CASE
						WHEN TAVANT_WARRANTY_TYPE = 'EXTENDED' THEN 'E'
						WHEN TAVANT_WARRANTY_TYPE = 'GOODWILL' OR COMMERCIAL_POLICY = 1 THEN CASE WHEN TRUNC(FAILURE_DATE) - TRUNC(SHIP_DATE) < 548 THEN '<'
							ELSE '>'
							END
						ELSE CASE
							WHEN MONTHS_BETWEEN(FAILURE_DATE, SHIP_DATE) <= 18 OR MONTHS_BETWEEN(FAILURE_DATE, START_DATE) <= 12
								THEN '1'
							WHEN MONTHS_BETWEEN(FAILURE_DATE, SHIP_DATE) <= 66 OR MONTHS_BETWEEN(FAILURE_DATE, START_DATE) <= 60
								THEN '2'
							WHEN MONTHS_BETWEEN(FAILURE_DATE, SHIP_DATE) <= 66 AND MONTHS_BETWEEN(FAILURE_DATE, START_DATE) <= 60
								THEN '5'
							ELSE '0'
							END
						END AS WARRANTY_DURATION_CODE,
					CASE
						WHEN INSTR(UPPER(DEALER_GROUP_NAME), 'INDEPENDENT') = 0 THEN 'Y'
						ELSE 'N'
						END AS COMPANY_OWNED_IND,
					CASE UPPER(DEALER_GROUP_NAME)
						WHEN 'USA COMPANY OWNED PARTS' THEN 'Y'
						WHEN 'USA COMPANY OWNED SERVICE' THEN 'Y'
						WHEN 'CANADA COMPANY OWNED PARTS' THEN 'Y'
						WHEN 'CANADA COMPANY OWNED SERVICE' THEN 'Y'
						ELSE 'N'
						END AS INTERNAL_IND
				FROM
					(
						-- EXTRACT
						SELECT
								PAYMENTS.CLAIM_NUMBER,
								PAYMENTS.TAVANT_CLAIM_TYPE,
								PAYMENTS.COMMERCIAL_POLICY,
								PAYMENTS.QUERY_SOURCE,
								PAYMENTS.TAVANT_WARRANTY_TYPE,
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
								PAYMENTS.FAILURE_DATE,
								PAYMENTS.FILED_ON_DATE,
								PAYMENTS.CREDIT_TO_THIRD_PARTY,
								PAYMENTS.CAMPAIGN_ID,
								ITEMS.SHIP_DATE,
								ITEMS.START_DATE,
								ITEMS.MANF_PROD_CODE,
								ITEMS.DEALER_GROUP_NAME,
								ITEMS.CUSTOMER_NUMBER,
								ITEMS.CUSTOMER_NAME,
								ITEMS.OFFICE_NAME
							FROM
								TAV_PAYMENT_RAW PAYMENTS
							INNER JOIN
								(
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
										COUNT(DISTINCT DEALER_GROUP_NAME) AS
										COUNT_OF_DEALER_GROUP_NAME,
										MIN(CUSTOMER_NUMBER) AS CUSTOMER_NUMBER,
										COUNT(DISTINCT CUSTOMER_NUMBER) AS COUNT_OF_CUSTOMER_NUMBER,
										MIN(CUSTOMER_NAME) AS CUSTOMER_NAME,
										COUNT(DISTINCT CUSTOMER_NAME) AS COUNT_OF_CUSTOMER_NAME,
										MIN(OFFICE_NAME) AS OFFICE_NAME,
										COUNT(DISTINCT OFFICE_NAME) AS COUNT_OF_OFFICE_NAME
											-- ,LISTAGG(PRODUCT_DEFINITION_CODE, ', ') WITHIN GROUP (ORDER BY PRODUCT_DEFINITION_CODE) AS PD_CODES
										FROM TAV_ITEM_RAW
										GROUP BY CLAIM_NUMBER
								) ITEMS ON ITEMS.CLAIM_NUMBER = PAYMENTS.CLAIM_NUMBER
							WHERE
								0 = 0
					) EXTRACT
		) EXT2
	INNER JOIN (
		SELECT
			CLAIM_NUMBER,
			SUM(CASE COST_CATEGORY
				WHEN 'Additional Travel Hours' THEN ACCEPTED_AMT
				WHEN 'Labor' THEN ACCEPTED_AMT
				WHEN 'Others' THEN ACCEPTED_AMT
				WHEN 'Travel by Hours' THEN ACCEPTED_AMT
				WHEN 'Travel by Perdiem' THEN ACCEPTED_AMT
				ELSE 0
				END) AS ACCEPTED_AMT_LABOR,
			SUM(CASE COST_CATEGORY
				WHEN 'Freight' THEN ACCEPTED_AMT
				WHEN 'Local Purchase' THEN ACCEPTED_AMT
				WHEN 'Non Oem Parts' THEN ACCEPTED_AMT
				WHEN 'Oem Parts' THEN ACCEPTED_AMT
				WHEN 'Rebate' THEN ACCEPTED_AMT
				ELSE 0
				END) AS ACCEPTED_AMT_MATERIAL
			FROM TAV_PAYMENT_RAW PAYMENTS
			GROUP BY
				CLAIM_NUMBER
		) CLAIM_LEVEL ON CLAIM_LEVEL.CLAIM_NUMBER = EXT2.CLAIM_NUMBER
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU          ON EXT2.SEGMENT4 = AFU.R12_ACCOUNT
	LEFT OUTER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP ON EXT2.MANF_PROD_CODE = PRODGRP.MANF_PROD_CODE AND 'CSD' = PRODGRP.GL_LEDGER
	LEFT OUTER JOIN TAV_CAMPAIGN_RAW CAMPAIGN      ON EXT2.CAMPAIGN_ID = CAMPAIGN.ID
	WHERE
		0 = 0;
		-- AND GL_EXPENSE_AMT <> 0 ;
COMMIT;
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
	IN_RESERVE_PERCENT_KNOWN,
	TRX_LAG,
	START_LAG_25,
	TRXYEARMONTH,
	EXPENSE_AMT_IN_RES,
	EXPENSE_AMT_NOT_IN_RES,
	CREDIT_TO_THIRD_PARTY
)
SELECT
	A.CLAIM_NUMBER,
	A.BUSINESS_UNIT,
	A.RESERVE_GROUP,
	A.CLAIM_TYPE,
	A.CONCESSION_DAYS,
	A.WARRANTY_DURATION,
	A.EXPENSE_AMOUNT,
	(A.EXPENSE_AMOUNT - TRUNC(A.EXPENSE_AMOUNT)) * 100.0 AS EXPENSE_AMOUNT_DEC,
	A.MATERIAL_LABOR,
	A.GL_ACCOUNT,
	A.EXPENSE_TYPE_DESCR,
	A.OFFICE_NAME,
	A.GL_PROD_CODE,
	A.MANF_PROD_CODE,
	A.COMPANY_OWNED,
	A.CUSTOMER_NUMBER,
	A.CUSTOMER_NAME,
	A.INTERNAL_EXTERNAL,
	A.TRX_DATE,
	A.TRX_YEAR,
	A.TRX_MONTH,
	A.INTMONTHS_TRX_TO_BASE,
	A.INTMONTHS_SHIP_TO_BASE,
	A.SHIP_DATE,
	A.SHIP_YEAR_MONTH,
	A.INTMONTHS_SHIP_TO_TRX,
	A.START_DATE,
	A.INTMONTHS_START_TO_TRX,
	A.FAIL_DATE,
	A.INTMONTHS_FAIL_TO_TRX,
	A.WARRANTY_TYPE,
	A.CURRENCY,
	A.COUNTRY_INDICATOR,
	A.RETROFIT_ID,
	10000 * COALESCE(RES_PCT.RESERVE_PCT, 0) AS IN_RESERVE_PERCENT,
	10000 * (CASE
		WHEN A.MANF_PROD_CODE IN ('0054', '0197')
				OR A.WARRANTY_DURATION_CODE NOT IN('2', '5')
				OR ROUND((A.TRX_DATE - A.SHIP_DATE) / 30.42) > 91
				OR ROUND((A.START_DATE - A.SHIP_DATE) / 30.42) > 24
			THEN 0
		ELSE COALESCE(RES_PCT.RESERVE_PCT, 0)
		END) AS IN_RESERVE_PERCENT_25,
	CASE
		WHEN RES_PCT.RESERVE_PCT IS NULL THEN 'N'
		ELSE 'Y'
		END AS IN_RESERVE_PERCENT_KNOWN,
	A.TRX_LAG,
	A.START_LAG_25,
	A.TRXYEARMONTH,
	A.EXPENSE_AMT_IN_RES,
	A.EXPENSE_AMT_NOT_IN_RES,
	A.CREDIT_TO_THIRD_PARTY
FROM (
	SELECT
		CLAIM_NUMBER,
		BUSINESS_UNIT,
		RESERVE_GROUP,
		CLAIM_TYPE,
		WARRANTY_DURATION_CODE,
		CONCESSION_DAYS,
		WARRANTY_DURATION,
		EXPENSE_AMOUNT,
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
		EXPENSE_AMT_NOT_IN_RES,
		CREDIT_TO_THIRD_PARTY
	FROM TAV_TEMP
	WHERE QUERY_SOURCE <> 'COMM' AND EXPENSE_AMOUNT <> 0
	UNION ALL
	SELECT
		CLAIM_NUMBER,
		BUSINESS_UNIT,
		RESERVE_GROUP,
		CLAIM_TYPE,
		WARRANTY_DURATION_CODE,
		CONCESSION_DAYS,
		WARRANTY_DURATION,
		EXPENSE_AMOUNT * ACCEPTED_AMT_LABOR / (ACCEPTED_AMT_LABOR + ACCEPTED_AMT_MATERIAL) AS EXPENSE_AMOUNT,
		'LABOR' AS MATERIAL_LABOR,
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
		EXPENSE_AMT_NOT_IN_RES,
		CREDIT_TO_THIRD_PARTY
	FROM TAV_TEMP
	WHERE QUERY_SOURCE = 'COMM'
	AND EXPENSE_AMOUNT <> 0
	AND ACCEPTED_AMT_LABOR <> 0
	UNION ALL
	SELECT
		CLAIM_NUMBER,
		BUSINESS_UNIT,
		RESERVE_GROUP,
		CLAIM_TYPE,
		WARRANTY_DURATION_CODE,
		CONCESSION_DAYS,
		WARRANTY_DURATION,
		EXPENSE_AMOUNT * ACCEPTED_AMT_MATERIAL / (ACCEPTED_AMT_LABOR + ACCEPTED_AMT_MATERIAL) AS EXPENSE_AMOUNT,
		'MATERIAL' AS MATERIAL_LABOR,
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
		EXPENSE_AMT_NOT_IN_RES,
		CREDIT_TO_THIRD_PARTY
	FROM TAV_TEMP
	WHERE QUERY_SOURCE = 'COMM'
	AND EXPENSE_AMOUNT <> 0
	AND ACCEPTED_AMT_MATERIAL <> 0
) A
LEFT OUTER JOIN
	DM_WAR_CSN_RSV_PCT_REF RES_PCT
		ON UPPER(A.EXPENSE_TYPE_DESCR) = UPPER(RES_PCT.EXPENSE_TYPE_DESCR)
		AND UPPER(A.MATERIAL_LABOR) = UPPER(RES_PCT.EXPENSE_TYPE_CATG)
		AND A.COMPANY_OWNED = RES_PCT.COMPANY_OWNED_IND
		AND CASE A.CREDIT_TO_THIRD_PARTY
			WHEN 'N' THEN 'Y'
			ELSE 'N'
			END =  RES_PCT.CUST_CREDIT_CATG_CODE
		AND CASE A.CLAIM_TYPE
			WHEN 'EXT' THEN CASE UPPER(A.MATERIAL_LABOR)
				WHEN 'LABOR' THEN 'EXTENDED PURCHASED LABOR'
				ELSE 'EXTENDED PURCHASED MATERIAL'
				END
			WHEN 'RETROFIT' THEN
				CASE A.GL_ACCOUNT
					WHEN '511706' THEN 'RETROFIT MATERIAL'
					WHEN '685211' THEN 'RETROFIT MATERIAL'
					ELSE UPPER(A.CLAIM_TYPE || ' ' || A.MATERIAL_LABOR)
					END
			ELSE A.CLAIM_TYPE
			END = RES_PCT.CLAIM_TYPE
;
COMMIT;