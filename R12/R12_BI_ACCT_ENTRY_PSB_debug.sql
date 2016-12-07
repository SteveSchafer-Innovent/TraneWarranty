-- note:  took 2.6 hours to run on 10/13
SELECT
		'NA' AS BUSINESS_UNIT,
		RCT.TRX_NUMBER AS INVOICE,
		RCTL.LINE_NUMBER AS LINE_SEQ_NUM,
		RCT.REASON_CODE AS ACCT_ENTRY_TYPE,
		'NA' AS PS_BUSINESS_UNIT_GL,
		'ACTUALS' AS LEDGER,
		'NA' AS PS_ACCOUNT,
		'NA' AS PS_DEPTID,
		'NA' AS PS_PRODUCT,
		RCTGD.AMOUNT AS MONETARY_AMOUNT,
		GJH.NAME AS JOURNAL_ID,
		RCTGD.GL_DATE AS JOURNAL_DATE,
		RCT.INVOICE_CURRENCY_CODE AS CURRENCY_CD,
		GCC.SEGMENT4 AS R12_ACCOUNT,
		GCC.SEGMENT5 AS R12_PRODUCT,
		GCC.SEGMENT1 AS R12_ENTITY,
		GCC.SEGMENT2 AS R12_LOCATION,
		'' AS ED_CREATE_DATE,
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
	INNER JOIN GL_JE_HEADERS GJH                  ON GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
	INNER JOIN GL_CODE_COMBINATIONS_KFV GCC       ON AEL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
	WHERE
		0 = 0
		AND RCT.ATTRIBUTE9 = '7'
		AND RBS.BATCH_SOURCE_ID IN('90003', '90006', '87004', '87003', '90005')
		AND RCT.ORG_ID IN(456, 457) -- US TCS and CA TCS  Only
		AND RCTL.LINE_TYPE = 'LINE'
		--  AND RCTL.LINE_NUMBER = 1
		AND RCT.COMPLETE_FLAG = 'Y'
		--  AND NVL(RCTGD.LATEST_REC_FLAG, 'Y') = 'Y'
		AND RCTGD.ACCOUNT_CLASS = 'REC'
		AND XDL.SOURCE_DISTRIBUTION_TYPE = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
		AND XDL.APPLICATION_ID = 222
		--  AND GJH.JE_SOURCE = 'Receivables'
		;
--  123,582,160 or 104X duplicate values
-- 88,0005 lines, 40,235 Transactions 
-- 312098	138996 (all October)
SELECT COUNT(*) cnt, count(distinct RCT.TRX_NUMBER) numTransactions
	FROM
		RA_CUSTOMER_TRX_ALL RCT
	INNER JOIN RA_CUSTOMER_TRX_LINES_ALL RCTL     ON RCTL.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
	INNER JOIN RA_BATCH_SOURCES_ALL RBS           ON RBS.BATCH_SOURCE_ID = RCT.BATCH_SOURCE_ID AND RBS.ORG_ID = RCT.ORG_ID
	INNER JOIN RA_CUST_TRX_LINE_GL_DIST_ALL RCTGD ON RCTGD.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID -- and rctgd.CUSTOMER_TRX_LINE_ID = rctl.CUSTOMER_TRX_LINE_ID
	INNER JOIN XLA_DISTRIBUTION_LINKS XDL         ON RCTGD.CUST_TRX_LINE_GL_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1 AND RCTGD.EVENT_ID = XDL.EVENT_ID
-- base trans and lines
	INNER JOIN XLA_AE_LINES AEL                   ON XDL.AE_HEADER_ID = AEL.AE_HEADER_ID AND XDL.AE_LINE_NUM = AEL.AE_LINE_NUM
	LEFT OUTER JOIN GL_IMPORT_REFERENCES GIR      ON GIR.GL_SL_LINK_TABLE = AEL.GL_SL_LINK_TABLE AND GIR.GL_SL_LINK_ID = AEL.GL_SL_LINK_ID
	LEFT OUTER JOIN GL_JE_LINES GJL               ON GJL.JE_HEADER_ID = GIR.JE_HEADER_ID AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
	LEFT JOIN GL_JE_HEADERS GJH                  ON GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
	LEFT JOIN GL_CODE_COMBINATIONS_KFV GCC       ON AEL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
	WHERE
		0 = 0
		AND RCT.ATTRIBUTE9 = '7'
		AND RBS.BATCH_SOURCE_ID IN('90003', '90006', '87004', '87003', '90005')
		AND RCT.ORG_ID IN(456, 457) -- US TCS and CA TCS  Only
		-- AND RCT.TRX_NUMBER IN(1521904, 1519059)
		AND RCTL.LINE_TYPE = 'LINE'  -- eliminates Tax
		AND RCTGD.GL_DATE > '01-OCT-16' 
		-- AND RCTL.LINE_NUMBER = 1
		AND RCT.COMPLETE_FLAG = 'Y'  -- no change
		AND NVL(RCTGD.LATEST_REC_FLAG, 'Y') = 'Y'
		AND RCTGD.ACCOUNT_CLASS = 'REC'
		AND XDL.SOURCE_DISTRIBUTION_TYPE = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
		AND XDL.APPLICATION_ID = 222
		AND GJH.JE_SOURCE = 'Receivables'
		;
SELECT
		RCT.TRX_NUMBER AS INVOICE,
--		RCTL.LINE_NUMBER AS LINE_SEQ_NUM,
		RCT.CUSTOMER_TRX_ID AS CUSTOMER_TRX_ID,
--		RCTL.LINE_TYPE,
--		RCTL.LINE_NUMBER,
--	rct.*
	'==========',
	rbs.*
--	, rctl.*
--		rctgd.*
/*	
		RCT.COMPLETE_FLAG,
		RCT.REASON_CODE AS ACCT_ENTRY_TYPE,
		RCT.INVOICE_CURRENCY_CODE AS CURRENCY_CD,
		RCTGD.LATEST_REC_FLAG,
		RCTGD.ACCOUNT_CLASS,
		RCTGD.AMOUNT AS MONETARY_AMOUNT,
		RCTGD.GL_DATE AS JOURNAL_DATE
*/		
	FROM
		RA_CUSTOMER_TRX_ALL RCT
	INNER JOIN RA_BATCH_SOURCES_ALL RBS           ON RBS.BATCH_SOURCE_ID = RCT.BATCH_SOURCE_ID AND RBS.ORG_ID = RCT.ORG_ID
/*	
	INNER JOIN RA_CUSTOMER_TRX_LINES_ALL RCTL ON RCTL.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
	INNER JOIN RA_CUST_TRX_LINE_GL_DIST_ALL RCTGD ON RCTGD.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID and rctgd.CUSTOMER_TRX_LINE_ID = rctl.CUSTOMER_TRX_LINE_ID
	INNER JOIN XLA_DISTRIBUTION_LINKS XDL         ON RCTGD.CUST_TRX_LINE_GL_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1 AND RCTGD.EVENT_ID = XDL.EVENT_ID
*/
	WHERE 0=0 -- ROWNUM < 10
	AND RBS.BATCH_SOURCE_ID IN('90003', '90006', '87004', '87003', '90005')
	AND	RCT.TRX_NUMBER IN('1521904', '1519059') 
--	AND RCTL.LINE_TYPE = 'LINE'  -- eliminates Tax
--	AND RCTGD.ACCOUNT_CLASS = 'REC'
	
--	AND XDL.SOURCE_DISTRIBUTION_TYPE = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
--	AND XDL.APPLICATION_ID = 222
		;
		
		select rctgd.account_class, rctgd.comments, count(*)
		from RA_CUST_TRX_LINE_GL_DIST_ALL RCTGD
		group by rctgd.account_class, rctgd.comments;