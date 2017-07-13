/* Formatted on 2016/06/14 16:37 (Formatter Plus v4.8.8) */
-- Billing Detail Line Report Query
SELECT
		RCTL.CUSTOMER_TRX_LINE_ID,
		RCTGD.CUST_TRX_LINE_GL_DIST_ID,
		RCT.TRX_NUMBER TRAN_NBR,
		RCT.INVOICE_CURRENCY_CODE CURRENCY,
		RCT.PURCHASE_ORDER PO_NBR,
		RCT.TRX_DATE SHIP_DATE,
		RCT.TRX_DATE INV_DATE,
		HCA_BILLTO.ACCOUNT_NUMBER BILL_CUST_ACCT,
		HCSU_BILLTO.LOCATION BILL_TO_LOCATION,
		DECODE(RBS.NAME, 'P21', RCT.INTERFACE_HEADER_ATTRIBUTE2, NVL(RCTL.SALES_ORDER, RCTL.INTERFACE_LINE_ATTRIBUTE1)) SALES_ORD_NBR,
		NVL(APS.AMOUNT_DUE_ORIGINAL,
		(
			SELECT
					SUM(NVL(RCTL1.EXTENDED_AMOUNT, 0))
				FROM
					RA_CUSTOMER_TRX_LINES_ALL RCTL1
				WHERE
					RCTL1.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
		)
		) HEADER_TOTAL,
		HCA_SHIPTO.ACCOUNT_NUMBER SHIP_CUST_ACCT,
		HCSU_SHIPTO.LOCATION SHIP_TO_LOCATION,
		HCA_BILLTO.ACCOUNT_NAME BILL_CUST_NAME,
		LOC_BILLTO.ADDRESS1 BILL_CUST_ADDRESS1,
		LOC_BILLTO.ADDRESS2 BILL_CUST_ADDRESS2,
		LOC_BILLTO.ADDRESS3 BILL_CUST_ADDRESS3,
		LOC_BILLTO.ADDRESS4 BILL_CUST_ADDRESS4,
		LOC_BILLTO.CITY BILL_CITY,
		NVL(LOC_BILLTO.STATE, LOC_BILLTO.PROVINCE) BILL_STATE,
		LOC_BILLTO.COUNTY BILL_COUNTY,
		LOC_BILLTO.POSTAL_CODE BILL_POSTAL,
		RCT.ATTRIBUTE8 CRD_JOB_NBR,
		RCT.INTERNAL_NOTES CRD_JOB_NAME
		--,Decode(rbs.NAME ,'ORDER ENTRY',interface_line_attribute3 , null) planned_shipment
		,
		NULL PLANNED_SHIPMENT,
		RCT.ATTRIBUTE9 PROJ_TYPE
		-- ,(SELECT NAME  FROM hr_organization_units_v houv  WHERE houv.organization_id = rctl.warehouse_id and rownum=1) business_unit -- for p21 it will be sale office name
		,
		NULL BUSINESS_UNIT
		--        ,Decode(rbs.NAME ,'P21' ,
		--           ( select resource_name from jtf_rs_resource_extns_tl jrt where jrt.resource_id = jrre.resource_id and rownum =1)
		--           ,(SELECT mtl.ORGANIZATION_CODE  FROM mtl_parameters mtl  WHERE mtl.organization_id = rctl.warehouse_id and rownum=1)) plant_loc
		,
		NULL PLANT_LOC,
		HCA_SHIPTO.ACCOUNT_NAME SHIP_CUST_NAME,
		LOC_SHIPTO.ADDRESS1 SHIP_CUST_ADDRESS1,
		LOC_SHIPTO.ADDRESS2 SHIP_CUST_ADDRESS2,
		LOC_SHIPTO.ADDRESS3 SHIP_CUST_ADDRESS3,
		LOC_SHIPTO.ADDRESS4 SHIP_CUST_ADDRESS4,
		LOC_SHIPTO.CITY SHIP_CITY,
		NVL(LOC_SHIPTO.STATE, LOC_SHIPTO.PROVINCE) SHIP_STATE,
		LOC_SHIPTO.COUNTY SHIP_COUNTY,
		LOC_SHIPTO.POSTAL_CODE SHIP_POSTAL,
		RCT.COMMENTS HDR_NOTE
		--,jrs.name Sales_Branch
		,
		JRRE1.RESOURCE_NAME SALES_BRANCH
		-- ,NVL( jrre.attribute1,DECODE (rct.org_id, 456, 'D2', 457, 'CH', 'NA')) sales_office_code
		,
		JRRE.ATTRIBUTE1 SALES_OFFICE_CODE,
		(
			SELECT
					FFVC1.DESCRIPTION
				FROM
					FND_FLEX_VALUES_VL FFVC,
					FND_FLEX_VALUES_VL FFVC1,
					FND_FLEX_VALUES_VL FFVC2,
					FND_FLEX_VALUE_NORM_HIERARCHY FFVCP1,
					FND_FLEX_VALUE_NORM_HIERARCHY FFVCP2
				WHERE
					GCC.SEGMENT2 = FFVC.FLEX_VALUE
					AND FFVC.FLEX_VALUE_SET_ID = 1014929
					AND FFVC.ENABLED_FLAG = 'Y'
					AND FFVC.FLEX_VALUE BETWEEN FFVCP1.CHILD_FLEX_VALUE_LOW AND FFVCP1.CHILD_FLEX_VALUE_HIGH
					AND FFVCP1.PARENT_FLEX_VALUE LIKE 'P%'
					--AND ffvcp1.RANGE_ATTRIBUTE ='C'
					AND FFVCP1.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND SYSDATE BETWEEN NVL(FFVCP1.START_DATE_ACTIVE, SYSDATE) AND NVL(FFVCP1.END_DATE_ACTIVE, SYSDATE)
					AND FFVCP2.PARENT_FLEX_VALUE LIKE 'P%'
					--AND ffvcp2.RANGE_ATTRIBUTE ='C'
					AND SYSDATE BETWEEN NVL(FFVCP2.START_DATE_ACTIVE, SYSDATE) AND NVL(FFVCP2.END_DATE_ACTIVE, SYSDATE)
					AND FFVCP2.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND FFVCP1.PARENT_FLEX_VALUE BETWEEN FFVCP2.CHILD_FLEX_VALUE_LOW AND FFVCP2.CHILD_FLEX_VALUE_HIGH
					AND FFVC1.ENABLED_FLAG = 'Y'
					AND FFVC2.ENABLED_FLAG = 'Y'
					AND FFVC1.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND FFVC2.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND FFVC1.FLEX_VALUE = FFVCP1.PARENT_FLEX_VALUE
					AND FFVC2.FLEX_VALUE = FFVCP2.PARENT_FLEX_VALUE
					AND ROWNUM = 1
		)
		SALES_DISTRICT,
		(
			SELECT
					FFVC3.DESCRIPTION
				FROM
					FND_FLEX_VALUES_VL FFVC,
					FND_FLEX_VALUES_VL FFVC1,
					FND_FLEX_VALUES_VL FFVC2,
					FND_FLEX_VALUES_VL FFVC3,
					FND_FLEX_VALUE_NORM_HIERARCHY FFVCP1,
					FND_FLEX_VALUE_NORM_HIERARCHY FFVCP2,
					FND_FLEX_VALUE_NORM_HIERARCHY FFVCP3
				WHERE
					GCC.SEGMENT2 = FFVC.FLEX_VALUE
					AND FFVC.FLEX_VALUE_SET_ID = 1014929
					AND FFVC.ENABLED_FLAG = 'Y'
					AND FFVC.FLEX_VALUE BETWEEN FFVCP1.CHILD_FLEX_VALUE_LOW AND FFVCP1.CHILD_FLEX_VALUE_HIGH
					AND FFVCP1.PARENT_FLEX_VALUE LIKE 'P%'
					--AND ffvcp1.RANGE_ATTRIBUTE ='C'
					AND FFVCP1.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND SYSDATE BETWEEN NVL(FFVCP1.START_DATE_ACTIVE, SYSDATE) AND NVL(FFVCP1.END_DATE_ACTIVE, SYSDATE)
					AND FFVCP2.PARENT_FLEX_VALUE LIKE 'P%'
					--AND ffvcp2.RANGE_ATTRIBUTE ='C'
					AND SYSDATE BETWEEN NVL(FFVCP2.START_DATE_ACTIVE, SYSDATE) AND NVL(FFVCP2.END_DATE_ACTIVE, SYSDATE)
					AND FFVCP2.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND FFVCP1.PARENT_FLEX_VALUE BETWEEN FFVCP2.CHILD_FLEX_VALUE_LOW AND FFVCP2.CHILD_FLEX_VALUE_HIGH
					AND FFVCP3.PARENT_FLEX_VALUE LIKE 'P%'
					--AND ffvcp2.RANGE_ATTRIBUTE ='C'
					AND SYSDATE BETWEEN NVL(FFVCP3.START_DATE_ACTIVE, SYSDATE) AND NVL(FFVCP3.END_DATE_ACTIVE, SYSDATE)
					AND FFVCP3.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND FFVCP2.PARENT_FLEX_VALUE BETWEEN FFVCP3.CHILD_FLEX_VALUE_LOW AND FFVCP3.CHILD_FLEX_VALUE_HIGH
					AND FFVC1.ENABLED_FLAG = 'Y'
					AND FFVC2.ENABLED_FLAG = 'Y'
					AND FFVC3.ENABLED_FLAG = 'Y'
					AND FFVC1.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND FFVC2.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND FFVC3.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
					AND FFVC1.FLEX_VALUE = FFVCP1.PARENT_FLEX_VALUE
					AND FFVC2.FLEX_VALUE = FFVCP2.PARENT_FLEX_VALUE
					AND FFVC3.FLEX_VALUE = FFVCP3.PARENT_FLEX_VALUE
					AND ROWNUM = 1
		)
		TERRITORY,
		(
			SELECT
					FLL.DESCRIPTION
				FROM
					FND_FLEX_VALUES_VL FLL
				WHERE
					FLL.FLEX_VALUE_SET_ID = 1014929 -- location
					AND FLL.FLEX_VALUE = GCC.SEGMENT2
		)
		LOCATION_DESC,
		GCC.SEGMENT1 REC_GL_ACCT_ENTITY,
		GCC.SEGMENT2 REC_GL_ACCT_LOCATION,
		GCC.SEGMENT3 REC_GL_ACCT_COST_CENTER,
		GCC.SEGMENT4 REC_GL_ACCT_ACCOUNT,
		GCC.SEGMENT5 REC_GL_ACCT_PRODUCT,
		GCC.SEGMENT6 REC_GL_ACCT_INTERCOMPANY,
		GCC.SEGMENT7 REC_GL_ACCT_FUTURE1,
		GCC.SEGMENT8 REC_GL_ACCT_FUTURE2,
		NVL(RBS.NAME, 0) BATCH_SOURCE,
		DECODE(RBS.NAME, 'P21', RCT.INTERFACE_HEADER_ATTRIBUTE10, RCT.INTERFACE_HEADER_ATTRIBUTE2) BILLING_TYPE,
		NVL(HOU.NAME, 0) OU_NAME,
		RCTL.LINE_NUMBER INVOICE_LINE_NUMBER,
		NVL(RCTL.TRANSLATED_DESCRIPTION, RCTL.DESCRIPTION) INVOIE_LINE_DESCRIPTION,
		NVL(RCTL.QUANTITY_INVOICED, RCTL.QUANTITY_CREDITED) INVOICE_LINE_QUANTITY,
		RCTL.UNIT_SELLING_PRICE INVOICE_LINE_UNIT_PRICE,
		RCTL.EXTENDED_AMOUNT INVOICE_LINE_AMOUNT,
		RCTL.LINE_TYPE INVOICE_LINE_TYPE,
		RCTL.ATTRIBUTE6 LINE_ATTRIBUTE6,
		(
			SELECT
					SUM(NVL(RCTL1.EXTENDED_AMOUNT, 0))
				FROM
					RA_CUSTOMER_TRX_LINES_ALL RCTL1
				WHERE
					RCTL1.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
					AND NVL(RCTL1.ATTRIBUTE6, 'X') NOT IN('FREIGHT', 'TAX', 'MTAX')
					AND RCTL1.LINE_TYPE NOT IN('FREIGHT', 'TAX')
		)
		"SUBTOTAL",
		(
			SELECT
					SUM(NVL(RCTL1.EXTENDED_AMOUNT, 0))
				FROM
					RA_CUSTOMER_TRX_LINES_ALL RCTL1
				WHERE
					RCTL1.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
					AND(NVL(RCTL1.ATTRIBUTE6, 'X') = 'FREIGHT'
					OR RCTL1.LINE_TYPE = 'FREIGHT')
		)
		"SUBTOTAL FREIGHT",
		(
			SELECT
					SUM(NVL(RCTL1.EXTENDED_AMOUNT, 0))
				FROM
					RA_CUSTOMER_TRX_LINES_ALL RCTL1
				WHERE
					RCTL1.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
					AND(NVL(RCTL1.ATTRIBUTE6, 'X') IN('MTAX', 'TAX')
					OR RCTL1.LINE_TYPE = 'TAX')
		)
		"SUBTOTAL TAX",
		NVL(APS.AMOUNT_DUE_ORIGINAL,
		(
			SELECT
					SUM(NVL(RCTL1.EXTENDED_AMOUNT, 0))
				FROM
					RA_CUSTOMER_TRX_LINES_ALL RCTL1
				WHERE
					RCTL1.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
		)
		) "TOTAL OF TOTALS",
		RCT.ATTRIBUTE5 "RELATED TRX NUMBER",
		NVL(APS.GL_DATE, RCTGD.GL_DATE) GL_DATE,
		RCT.EXCHANGE_RATE,
		GJH.NAME JOURNAL_NAME,
		NULL JOURNAL_ID,
		GJB.NAME GL_BATCH_NAME,
		GJB.POSTED_DATE,
		DECODE(RBS.NAME, 'P21', SUBSTR(RCTL.DESCRIPTION, 1, INSTR(RCTL.DESCRIPTION, '~', 1, 1) - 1), MSI.SEGMENT1) ITEM_NUMBER,
		DECODE(RBS.NAME, 'P21', SUBSTR(RCTL.DESCRIPTION, INSTR(RCTL.DESCRIPTION, '~', 1, 1) + 1), NVL(RCTL.TRANSLATED_DESCRIPTION, RCTL.DESCRIPTION)) ITEM_DESC,
		DECODE(RBS.NAME, 'P21', DECODE(RCT.INTERFACE_HEADER_ATTRIBUTE10, 'SER', RCT.PURCHASE_ORDER, NULL), NULL) TRNBI_SRV_CALL_ID,
		(
			SELECT
					MIC.SEGMENT1||'.'|| MIC.SEGMENT2 ||'.'|| MIC.SEGMENT3 ||'.'|| MIC.SEGMENT4 ||'.'|| MIC.SEGMENT5 ||'.'|| MIC.SEGMENT6
				FROM
					MTL_ITEM_CATEGORIES_V MIC,
					MTL_SYSTEM_ITEMS MSI1
				WHERE
					MIC.INVENTORY_ITEM_ID = MSI1.INVENTORY_ITEM_ID
					AND MSI1.SEGMENT1 = DECODE(RBS.NAME, 'P21', SUBSTR(RCTL.DESCRIPTION, 1, INSTR(RCTL.DESCRIPTION, '~', 1, 1) - 1), MSI.SEGMENT1)
					AND MIC.CATEGORY_SET_NAME = 'IRPLN SIOP CATEGORY'
					AND MIC.ORGANIZATION_ID = MSI1.ORGANIZATION_ID
					AND MSI1.ORGANIZATION_ID = NVL(RCTL.WAREHOUSE_ID, 99)
					AND ROWNUM = 1
		)
		SIOP_NUMBER,
		NULL ORIG_SYS_NBR,
		NULL PRIOR_TRX_NBR,
		NULL MULTIPLIER,
		NULL PROD_CODE,
		NULL INVOICE_AMT_PRETAX,
		NULL IDENTIFIER,
		NULL PROJECT_ID
		-- added by Anand Pingle for EC customer derivation
		,
		HPS_BILLTO.PARTY_SITE_NUMBER R12_CUST_SITE_NUMBER,
		(
			SELECT
					HOSR.ORIG_SYSTEM_REFERENCE
				FROM
					HZ_ORIG_SYS_REFERENCES HOSR
				WHERE
					HOSR.OWNER_TABLE_NAME = 'HZ_CUST_ACCT_SITES_ALL'
					AND HOSR.ORIG_SYSTEM = 'TCS_ENT_CUSTOMER'
					AND HCAS_BILLTO.CUST_ACCT_SITE_ID = HOSR.OWNER_TABLE_ID
					AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(HOSR.START_DATE_ACTIVE), TRUNC(SYSDATE)) AND NVL(TRUNC(HOSR.END_DATE_ACTIVE), TRUNC(SYSDATE))
					AND HOSR.STATUS = 'A'
					AND ROWNUM = 1
		)
		EC_CUST_NUMBER,
		HCAS_BILLTO.ATTRIBUTE6 DEFAULT_BRANCH,
		(
			SELECT
					NAME
				FROM
					HR_ORGANIZATION_UNITS_V HOUV
				WHERE
					HOUV.ORGANIZATION_ID = RCTL.WAREHOUSE_ID
					AND ROWNUM = 1
		)
		INV_ORG,
		' ' AS REV_GL_ACCT_ACCOUNT
		-- ,msi.description R12_ITEM_DESCCRIPTION -- Added by Rijo 02/27/2017
		,
		DECODE(RBS.NAME, 'P21', SUBSTR(RCTL.DESCRIPTION, INSTR(RCTL.DESCRIPTION, '~', 1, 1) + 1, LENGTH(RCTL.DESCRIPTION)), NVL(MSI.DESCRIPTION, RCTL.DESCRIPTION)) R12_ITEM_DESCCRIPTION -- Added by Rijo 04/19/2017
	FROM
		RA_CUSTOMER_TRX_ALL RCT
	LEFT OUTER JOIN AR_PAYMENT_SCHEDULES_ALL APS ON APS.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
	INNER JOIN RA_CUSTOMER_TRX_LINES_ALL RCTL    ON RCTL.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
	INNER JOIN RA_BATCH_SOURCES_ALL RBS          ON RBS.BATCH_SOURCE_ID = RCT.BATCH_SOURCE_ID -- fud
		AND RBS.ORG_ID = RCT.ORG_ID
	LEFT OUTER JOIN JTF_RS_SALESREPS JRS ON JRS.SALESREP_ID = RCT.PRIMARY_SALESREP_ID -- fud
		AND JRS.ORG_ID = RCT.ORG_ID
	LEFT OUTER JOIN JTF_RS_RESOURCE_EXTNS JRRE     ON JRS.RESOURCE_ID = JRRE.RESOURCE_ID
	LEFT OUTER JOIN JTF_RS_RESOURCE_EXTNS_TL JRRE1 ON JRRE.RESOURCE_ID = JRRE1.RESOURCE_ID -- Added for SALES_BRANCH column
		AND JRRE1.LANGUAGE = 'US'                                                                       -- Added for SALES_BRANCH column
	INNER JOIN HZ_CUST_ACCOUNTS HCA_BILLTO        ON RCT.BILL_TO_CUSTOMER_ID = HCA_BILLTO.CUST_ACCOUNT_ID
	INNER JOIN HZ_PARTIES HP_BILLTO               ON HCA_BILLTO.PARTY_ID = HP_BILLTO.PARTY_ID
	INNER JOIN HZ_CUST_SITE_USES_ALL HCSU_BILLTO  ON RCT.BILL_TO_SITE_USE_ID = HCSU_BILLTO.SITE_USE_ID
	INNER JOIN HZ_CUST_ACCT_SITES_ALL HCAS_BILLTO ON HCSU_BILLTO.CUST_ACCT_SITE_ID = HCAS_BILLTO.CUST_ACCT_SITE_ID
	INNER JOIN HZ_PARTY_SITES HPS_BILLTO          ON HPS_BILLTO.PARTY_SITE_ID = HCAS_BILLTO.PARTY_SITE_ID
	INNER JOIN HZ_LOCATIONS LOC_BILLTO            ON LOC_BILLTO.LOCATION_ID = HPS_BILLTO.LOCATION_ID
	INNER JOIN HZ_CUST_ACCOUNTS HCA_SHIPTO        ON NVL(RCT.SHIP_TO_CUSTOMER_ID, RCT.BILL_TO_CUSTOMER_ID) = HCA_SHIPTO.CUST_ACCOUNT_ID
	INNER JOIN HZ_PARTIES HP_SHIPTO               ON HCA_SHIPTO.PARTY_ID = HP_SHIPTO.PARTY_ID
	INNER JOIN HZ_CUST_SITE_USES_ALL HCSU_SHIPTO  ON NVL(RCT.SHIP_TO_SITE_USE_ID, RCT.BILL_TO_SITE_USE_ID) = HCSU_SHIPTO.SITE_USE_ID
	INNER JOIN HZ_CUST_ACCT_SITES_ALL HCAS_SHIPTO ON HCSU_SHIPTO.CUST_ACCT_SITE_ID = HCAS_SHIPTO.CUST_ACCT_SITE_ID
	INNER JOIN HZ_PARTY_SITES HPS_SHIPTO          ON HPS_SHIPTO.PARTY_SITE_ID = HCAS_SHIPTO.PARTY_SITE_ID
	INNER JOIN HZ_LOCATIONS LOC_SHIPTO            ON LOC_SHIPTO.LOCATION_ID = HPS_SHIPTO.LOCATION_ID
	INNER JOIN RA_CUST_TRX_LINE_GL_DIST_ALL RCTGD ON RCTGD.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
	INNER JOIN GL_CODE_COMBINATIONS_KFV GCC       ON 0 = 0
	INNER JOIN HR_OPERATING_UNITS HOU             ON HOU.ORGANIZATION_ID = RCT.ORG_ID
	INNER JOIN XLA_DISTRIBUTION_LINKS XDL         ON RCTGD.CUST_TRX_LINE_GL_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1 -- fud
		AND RCTGD.EVENT_ID = XDL.EVENT_ID
	INNER JOIN XLA_AE_LINES AEL   ON AEL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
	INNER JOIN XLA_AE_HEADERS AEH ON XDL.AE_HEADER_ID = AEH.AE_HEADER_ID -- fud
		AND XDL.AE_HEADER_ID = AEL.AE_HEADER_ID                                       -- fud
		AND XDL.AE_LINE_NUM = AEL.AE_LINE_NUM
	INNER JOIN GL_JE_HEADERS GJH             ON GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
	LEFT OUTER JOIN GL_IMPORT_REFERENCES GIR ON GIR.GL_SL_LINK_TABLE = AEL.GL_SL_LINK_TABLE
	LEFT OUTER JOIN GL_JE_LINES GJL          ON GJL.JE_HEADER_ID = GIR.JE_HEADER_ID -- fud
		AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM                                                    -- fud
		AND GIR.GL_SL_LINK_ID = AEL.GL_SL_LINK_ID
	INNER JOIN GL_JE_BATCHES GJB         ON GJB.JE_BATCH_ID = GJH.JE_BATCH_ID
	INNER JOIN GL_LEDGERS GLL            ON GJH.LEDGER_ID = GLL.LEDGER_ID
	LEFT OUTER JOIN MTL_SYSTEM_ITEMS MSI ON MSI.INVENTORY_ITEM_ID = RCTL.INVENTORY_ITEM_ID -- fud
		AND MSI.ORGANIZATION_ID = NVL(RCTL.WAREHOUSE_ID, 99)
	INNER JOIN
		(SELECT AL.EXTERNALLY_VISIBLE_FLAG, HOU.ORGANIZATION_ID ORG_ID FROM AR_LOOKUPS AL, HR_OPERATING_UNITS HOU WHERE AL.LOOKUP_TYPE = 'XXAR_BILLING_RPT_OU_SOURCE' AND AL.ENABLED_FLAG = 'Y' AND TRUNC(SYSDATE) BETWEEN NVL(AL.START_DATE_ACTIVE, SYSDATE - 1) AND NVL(AL.END_DATE_ACTIVE, SYSDATE + 1) AND HOU.NAME = AL.DESCRIPTION AND NVL(AL.ATTRIBUTE1, 'XX') NOT IN('INTERNATIONAL')
		) ALL_SOURCE ON RCT.ORG_ID = ALL_SOURCE.ORG_ID -- US TCS and CA TCS  Only
		AND RBS.NAME = ALL_SOURCE.EXTERNALLY_VISIBLE_FLAG        -- fud
		AND RBS.ORG_ID = ALL_SOURCE.ORG_ID
	WHERE
		0 = 0
		AND RCT.COMPLETE_FLAG = 'Y'
		AND NVL(RCTGD.LATEST_REC_FLAG, 'Y') = 'Y'
		AND RCTGD.ACCOUNT_CLASS = 'REC'
		AND XDL.SOURCE_DISTRIBUTION_TYPE = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
		AND XDL.APPLICATION_ID = 222
		AND GJH.JE_SOURCE = 'Receivables'
		AND GLL.LEDGER_CATEGORY_CODE = 'PRIMARY'
		AND(RCT.LAST_UPDATE_DATE > TRUNC(SYSDATE - 1)
		OR RCTL.LAST_UPDATE_DATE > TRUNC(SYSDATE - 1)
		OR RCTGD.LAST_UPDATE_DATE > TRUNC(SYSDATE - 1)
		OR HCA_BILLTO.LAST_UPDATE_DATE > TRUNC(SYSDATE - 1)
		OR HCA_SHIPTO.LAST_UPDATE_DATE > TRUNC(SYSDATE - 1)
		OR LOC_BILLTO.LAST_UPDATE_DATE > TRUNC(SYSDATE - 1)
		OR LOC_SHIPTO.LAST_UPDATE_DATE > TRUNC(SYSDATE - 1)) ;
--  OR jrre.last_update_date > trunc(sysdate-1) -- Commented for Performance improvement
--  OR gjb.last_update_date > trunc(sysdate-1))
