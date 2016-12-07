-- R12_BI_ACCT_ENTRY_STG.sql
SELECT
		RCT.TRX_NUMBER AS INVOICE,
		RCTL.LINE_NUMBER AS LINE_SEQ_NUM,
		RCT.REASON_CODE AS ACCT_ENTRY_TYPE,
		'ACTUALS' AS LEDGER,
		RCTGD.AMOUNT AS MONETARY_AMOUNT,
		GJH.NAME AS JOURNAL_ID,
		RCTGD.GL_DATE AS JOURNAL_DATE,
		RCT.INVOICE_CURRENCY_CODE AS CURRENCY_CD,
		GCC.SEGMENT4 AS R12_ACCOUNT,
		GCC.SEGMENT5 AS R12_PRODUCT,
		GCC.SEGMENT1 AS R12_ENTITY,
		GCC.SEGMENT2 AS R12_LOCATION,
		RCT.CUSTOMER_TRX_ID AS CUSTOMER_TRX_ID
	FROM
		RA_CUSTOMER_TRX_ALL RCT
	INNER JOIN RA_CUSTOMER_TRX_LINES_ALL RCTL     ON RCTL.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
	INNER JOIN RA_BATCH_SOURCES_ALL RBS           ON RBS.BATCH_SOURCE_ID = RCT.BATCH_SOURCE_ID AND RBS.ORG_ID = RCT.ORG_ID
	INNER JOIN RA_CUST_TRX_LINE_GL_DIST_ALL RCTGD ON RCTGD.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
	INNER JOIN XLA_DISTRIBUTION_LINKS XDL         ON RCTGD.CUST_TRX_LINE_GL_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1 AND RCTGD.EVENT_ID = XDL.EVENT_ID
	INNER JOIN XLA_AE_LINES AEL                   ON XDL.AE_HEADER_ID = AEL.AE_HEADER_ID AND XDL.AE_LINE_NUM = AEL.AE_LINE_NUM
	LEFT OUTER JOIN GL_IMPORT_REFERENCES GIR      ON GIR.GL_SL_LINK_TABLE = AEL.GL_SL_LINK_TABLE AND GIR.GL_SL_LINK_ID = AEL.GL_SL_LINK_ID
	LEFT OUTER JOIN GL_JE_LINES GJL               ON GJL.JE_HEADER_ID = GIR.JE_HEADER_ID AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
	LEFT OUTER JOIN GL_JE_HEADERS GJH             ON GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
	LEFT OUTER JOIN GL_CODE_COMBINATIONS_KFV GCC  ON AEL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
	WHERE
		0 = 0
		AND RCT.ATTRIBUTE9 = '7'
		AND RBS.BATCH_SOURCE_ID IN('90003', '90006', '87004', '87003', '90005')
		AND RCT.ORG_ID IN(456, 457) -- US TCS and CA TCS  Only
		AND RCTL.LINE_TYPE = 'LINE'  -- eliminates Tax
		AND RCTGD.GL_DATE > '01-OCT-16' 
		AND RCT.COMPLETE_FLAG = 'Y'  
		AND NVL(RCTGD.LATEST_REC_FLAG, 'Y') = 'Y'
		AND RCTGD.ACCOUNT_CLASS = 'REC'
		AND XDL.SOURCE_DISTRIBUTION_TYPE = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
		AND XDL.APPLICATION_ID = 222
		AND GJH.JE_SOURCE = 'Receivables'
;