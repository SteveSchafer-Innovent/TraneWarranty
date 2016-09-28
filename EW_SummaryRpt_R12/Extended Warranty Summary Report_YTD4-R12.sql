/* Prepaid Comm claims detail Dollar AMT*/
-- 69.874 sec USA/JAN-16
-- 1.343 sec CAN/JAN-16
SELECT
	/*+ NO_CPU_COSTING */
	SUM(A.MONETARY_AMOUNT),
	/*TAY: A.ACCOUNT, */
	A.R12_ACCOUNT AS Account,
	PSA.DESCR     AS ACCOUNT_DESC,
	/*TAY:  case when A.CURRENCY_CD = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END AS COUNTRY_INDICATOR*/
	CASE
		WHEN A.r12_entity IN(5773, 5588) THEN 'CAN'
		ELSE 'USA'
	END AS COUNTRY_INDICATOR
	/*TAY: FROM  OTR_BI_ACCT_ENTRY_PSB A,
	OTR_TRNBI_BI_HDR_PSB B,
	OTR_BI_HDR_PSB C,
	OTR_TRANE_ACCOUNTS_PS PSA*/
FROM R12_BI_ACCT_ENTRY_PSB A
INNER JOIN R12_TRNBI_BI_HDR_PSB B
ON A.BUSINESS_UNIT = B.BUSINESS_UNIT
AND A.INVOICE      = B.INVOICE
INNER JOIN R12_BI_HDR_PSB C
ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
AND B.INVOICE      = C.INVOICE
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
	-- -SS- /NEW
LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA
ON A.R12_ACCOUNT          = PSA.R12_ACCOUNT
AND PSA.TRANE_ACCOUNT_IND = 'X'
WHERE A.JOURNAL_DATE     >= TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
AND JOURNAL_DATE         <= LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
AND A.BUSINESS_UNIT      IN('BIUSA', 'BICAN', 'BIUSC')
	/*TAY:  AND A.BUSINESS_UNIT_GL IN ('CSD','CAN')*/
AND A.R12_ENTITY IN('CSD', 'CAN')
	/*TAY:  AND A.ACCOUNT like '5%' WIP*/
	-- -SS- NEW
AND((A.PS_ACCOUNT = 'NA'
AND AFU.LIKE_5    = 'Y')
OR(A.PS_ACCOUNT  <> 'NA'
AND A.PS_ACCOUNT LIKE '5%'))
	-- -SS- /NEW
	-- -SS- AND A.ACCOUNT LIKE '5%'
	/*TAY:  AND A.DEPTID = 'SL00' WIP*/
	-- -SS- NEW
AND((A.PS_DEPTID    = 'NA'
AND A.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
OR(A.PS_DEPTID     <> 'NA'
AND A.PS_DEPTID     = 'SL00'))
	-- -SS- /NEW
	-- -SS- AND A.PS_DEPTID = 'SL00'
	/*TAY:  and case when A.CURRENCY_CD = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END= UPPER(:COUNTRY)*/
AND
	CASE
		WHEN A.r12_entity IN(5773, 5588) THEN 'CAN'
		ELSE 'USA'
	END = UPPER(:COUNTRY)
	-- -SS- AND A.BUSINESS_UNIT = B.BUSINESS_UNIT
	-- -SS- AND A.INVOICE = B.INVOICE
	/*TAY:  AND B.BUSINESS_UNIT = C.BUSINESS_UNIT*/
	-- -SS- AND B.R12_ENTITY = C.R12_ENTITY
	-- -SS- AND B.INVOICE = C.INVOICE
	-- -SS- AND A.R12_ACCOUNT = PSA.R12_ACCOUNT (+)
	-- -SS- AND PSA.TRANE_ACCOUNT_IND='X'
	--and c.BILL_SOURCE_ID = 'FAL'
AND C.ENTRY_TYPE = 'CR'
	/*TAY: GROUP BY A.ACCOUNT,PSA.DESCR,case when A.CURRENCY_CD = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END*/
GROUP BY A.R12_ACCOUNT,
	PSA.DESCR,
	CASE
		WHEN A.r12_entity IN(5773, 5588) THEN 'CAN'
		ELSE 'USA'
	END
--ORDER BY A.ACCOUNT,case when A.CURRENCY_CD = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END
UNION

/* Qry to fetch accounts wich does not exist in OTR_BI_ACCT_ENTRY_PSB table */
SELECT
	/*+ NO_CPU_COSTING */
	0 AS MONETARY_AMOUNT,
	/*TAY: PSA.ACCOUNT,*/
	PSA.R12_ACCOUNT AS Account,
	PSA.DESCR       AS ACCOUNT_DESC,
	''              AS COUNTRY_INDICATOR
	/*TAY: FROM dbo.otr_TRANE_ACCOUNTS_ps psa */
FROM dbo.R12_TRANE_ACCOUNTS_PS psa
	-- -SS- NEW
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
ON AFU.R12_ACCOUNT = PSA.R12_ACCOUNT
	-- -SS- /NEW
WHERE PSA.TRANE_ACCOUNT_IND = 'X'
	/*TAY:  AND PSA.ACCOUNT LIKE '5%' WIP*/
	-- -SS- NEW
AND((PSA.PS_ACCOUNT = 'NA'
AND AFU.LIKE_5      = 'Y')
OR(PSA.PS_ACCOUNT  <> 'NA'
AND PSA.PS_ACCOUNT LIKE '5%'))
	-- -SS- /NEW
	-- -SS- AND PSA.ACCOUNT LIKE '5%'
AND NOT EXISTS
	(SELECT 'X'
		/*TAY: FROM OTR_BI_ACCT_ENTRY_PSB dist,
		dbo.ACTUATE_SEC_XREF ASX,
		OTR_BI_HDR_PSB C WIP*/
	FROM R12_BI_ACCT_ENTRY_PSB dist
		--dbo.ACTUATE_SEC_XREF ASX,
	INNER JOIN R12_BI_HDR_PSB C
	ON dist.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
	AND dist.INVOICE      = C.INVOICE
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
		-- -SS- /NEW
	WHERE
		/*TAY: DIST.BUSINESS_UNIT_GL= ASX.PSGL
		and*/
		dist.JOURNAL_DATE   >= TRUNC(TO_DATE(TO_DATE('1-'||:RunDate, 'dd-mon-yy')), 'YEAR')
	AND dist.JOURNAL_DATE < = LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
		/*TAY:      AND DIST.ACCOUNT LIKE '5%' WIP*/
		-- -SS- NEW
	AND((DIST.PS_ACCOUNT = 'NA'
	AND AFU.LIKE_5       = 'Y')
	OR(DIST.PS_ACCOUNT  <> 'NA'
	AND DIST.PS_ACCOUNT LIKE '5%'))
		-- -SS- /NEW
		-- -SS- AND DIST.ACCOUNT LIKE '5%'
		/*TAY:      and CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)*/
	AND
		CASE
			WHEN dist.R12_ENTITY IN('5773', '5588') THEN 'CAN'
			ELSE 'USA'
		END = UPPER(:COUNTRY)
		/*TAY:      AND dist.BUSINESS_UNIT = C.BUSINESS_UNIT*/
		-- -SS- AND dist.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
		-- -SS- AND dist.INVOICE = C.INVOICE
		/*TAY:      AND dist.ACCOUNT = PSA.ACCOUNT*/
	AND dist.R12_ACCOUNT      = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
	AND C.ENTRY_TYPE          = 'CR'
	)
	/*TAY: ORDER BY ACCOUNT*/
ORDER BY ACCOUNT ;