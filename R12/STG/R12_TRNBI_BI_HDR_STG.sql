-- R12_TRNBI_BI_HDR_STG
SELECT DISTINCT
		RCT.TRX_NUMBER AS INVOICE,
		RCT.ATTRIBUTE9 AS TRNBI_PROJECT_TYPE,
		RCT.CUSTOMER_TRX_ID AS CUSTOMER_TRX_ID
	FROM
		RA_CUSTOMER_TRX_ALL RCT
	INNER JOIN RA_BATCH_SOURCES_ALL RBS ON RBS.BATCH_SOURCE_ID = RCT.BATCH_SOURCE_ID AND RBS.ORG_ID = RCT.ORG_ID
	WHERE
		0 = 0
		AND RCT.ATTRIBUTE9 = '7'
		AND RBS.BATCH_SOURCE_ID IN('90003', '90006', '87004', '87003', '90005')
	ORDER BY
		1
;