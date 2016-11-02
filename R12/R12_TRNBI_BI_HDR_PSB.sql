-- R12_TRNBI_BI_HDR_PSB;
SELECT DISTINCT
		'NA' AS BUSINESS_UNIT,
		RCT.TRX_NUMBER AS INVOICE,
		RCT.ATTRIBUTE9 AS TRNBI_PROJECT_TYPE,
		'' AS SRC_ED_CREATE_DATE,
		'' AS SRC_ED_CREATE_ID,
		'' AS ED_CREATE_DATE,
		'' AS ED_CREATE_ID,
		RCT.CUSTOMER_TRX_ID AS CUSTOMER_TRX_ID
	FROM
		RA_CUSTOMER_TRX_ALL RCT
	INNER JOIN RA_BATCH_SOURCES_ALL RBS ON RBS.BATCH_SOURCE_ID = RCT.BATCH_SOURCE_ID AND RBS.ORG_ID = RCT.ORG_ID
	WHERE
		0 = 0
		AND RCT.ATTRIBUTE9 = '7'
		AND RBS.BATCH_SOURCE_ID IN('90003', '90006', '87004', '87003', '90005')
	ORDER BY 1 ;
/*
select distinct rct.batch_source_id
from ra_customer_trx_all rct, ra_batch_sources_all bs
where rct.batch_source_id = bs.batch_source_id
and rct.org_id = bs.org_id
and rct.org_id in ('456', '457')
and rct.attribute9 = '7'
order by 1
*/
;