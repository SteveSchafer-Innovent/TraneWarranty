DROP PUBLIC SYNONYM DM_030_EXT_COMM_MVW;
CREATE OR REPLACE PUBLIC SYNONYM DM_030_EXT_COMM_MVW FOR DBO.DM_030_EXT_COMM_MVW;
	DROP MATERIALIZED VIEW DBO.DM_030_EXT_COMM_MVW;
CREATE MATERIALIZED VIEW DBO.DM_030_EXT_COMM_MVW(COUNTRY_INDICATOR, JRNL_YEAR_MONTH, GL_ACCOUNT, JOURNAL_DATE, COMMISSION_AMOUNT) TABLESPACE D1_AA NOCACHE LOGGING NOCOMPRESS NOPARALLEL BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
WITH PRIMARY KEY AS
/* Formatted on 8/9/2016 5:45:19 PM (QP5 v5.163.1008.3004) */
SELECT COUNTRY_INDICATOR,
	JRNL_YEAR_MONTH,
	GL_ACCOUNT,
	JOURNAL_DATE,
	NVL(SUM(COMMISSION_AMOUNT), 0) AS COMMISSION_AMOUNT
FROM
	(SELECT
		CASE
			WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
			ELSE 'USA'
		END
		/* -SS- CASE UPPER (TRIM (asx.nation_curr))
		WHEN 'CAD' THEN 'CAN'
		WHEN 'USD' THEN 'USA'
		ELSE NULL
		END
		*/
		                                     AS COUNTRY_INDICATOR,
		TO_CHAR(DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		DIST.R12_ACCOUNT -- -SS- ACCOUNT
		                               AS GL_ACCOUNT,
		TRUNC(DIST.JOURNAL_DATE, 'MM') AS JOURNAL_DATE,
		CASE
			WHEN DIST.DEBIT_AMT = 0 OR DIST.DEBIT_AMT IS NULL OR DIST.CREDIT_AMOUNT <> '' THEN DIST.CREDIT_AMOUNT * - 1
			ELSE DIST.DEBIT_AMT
		END AS COMMISSION_AMOUNT
	FROM DBO.R12_TRNCO_CM_DIST_PSB DIST  -- -SS- OTR
	INNER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR, dbo.actuate_sec_xref asx
	ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
		-- -SS- /NEW
	WHERE
		-- -SS- dist.ACCOUNT = PSA.ACCOUNT AND
		DIST.R12_ENTITY NOT IN('5773', '5588')
		-- -SS- asx.nation_curr = 'USD'
		-- -SS- AND PSA.trane_account_ind = 'X'
		-- -SS- AND dist.business_unit_gl = asx.psgl
	AND((DIST.PS_DEPTID   = 'NA'
	AND DIST.R12_LOCATION IN('113602, 115615, 119001, 119007, 129001, 129003, 129004'))
	OR(DIST.PS_DEPTID     <> 'NA'
	AND DIST.PS_DEPTID    IN('TCA0', 'SL00')))
	AND
		-- -SS- AND (dist.deptid IS NULL OR dist.deptid = 'SL00')
		DIST.JOURNAL_DATE BETWEEN '1-NOV-2004' AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
		-- -SS- NEW
	AND((DIST.PS_ACCOUNT  = 'NA'
	AND AFU.LIKE_52_53_54 = 'Y')
	OR(DIST.PS_ACCOUNT   <> 'NA'
	AND(DIST.PS_ACCOUNT LIKE '52%'
	OR DIST.PS_ACCOUNT LIKE '53%'
	OR DIST.PS_ACCOUNT LIKE '54%')))
	-- -SS- /NEW
	-- -SS- AND (dist.ACCOUNT LIKE '52%' OR dist.ACCOUNT LIKE '53%' OR
	-- dist.ACCOUNT LIKE '54%')
	UNION ALL
	SELECT
		CASE
			WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
			ELSE 'USA'
		END
		/* -SS- CASE UPPER (TRIM (asx.nation_curr))
		WHEN 'CAD' THEN 'CAN'
		WHEN 'USD' THEN 'USA'
		ELSE NULL
		END */
		                                     AS COUNTRY_INDICATOR,
		TO_CHAR(DIST.JOURNAL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		DIST.R12_ACCOUNT -- -SS- ACCOUNT
		                               AS GL_ACCOUNT,
		TRUNC(DIST.JOURNAL_DATE, 'MM') AS JOURNAL_DATE,
		CASE
			WHEN DIST.DEBIT_AMT = 0 OR DIST.DEBIT_AMT IS NULL OR DIST.CREDIT_AMOUNT <> '' THEN DIST.CREDIT_AMOUNT * - 1
			ELSE DIST.DEBIT_AMT
		END AS COMMISSION_AMOUNT
	FROM DBO.R12_TRNCO_CM_DIST_PSB DIST  -- -SS- OTR
	INNER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR
	ON DIST.R12_ACCOUNT       = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = DIST.R12_ACCOUNT
		-- -SS- /NEW
		/* -SS- , dbo.actuate_sec_xref asx */
	WHERE
		-- -SS- dist.ACCOUNT = PSA.ACCOUNT AND
		DIST.R12_ENTITY IN('5773', '5588')
		-- -SS- asx.nation_curr = 'CAD'
		-- -SS- AND PSA.trane_account_ind = 'X'
		-- -SS- AND dist.business_unit_gl = asx.psgl
	AND((DIST.PS_DEPTID   = 'NA'
	AND DIST.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
	OR(DIST.PS_DEPTID     <> 'NA'
	AND DIST.PS_DEPTID    IN('TCA0', 'SL00')))
		-- -SS- AND(dist.deptid IS NULL OR dist.deptid IN('TCA0', 'SL00'))
	AND DIST.JOURNAL_DATE BETWEEN '1-NOV-2004' AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
		-- -SS- NEW
	AND((DIST.PS_ACCOUNT  = 'NA'
	AND AFU.LIKE_52_53_54 = 'Y')
	OR(DIST.PS_ACCOUNT   <> 'NA'
	AND(DIST.PS_ACCOUNT LIKE '52%'
	OR DIST.PS_ACCOUNT LIKE '53%'
	OR DIST.PS_ACCOUNT LIKE '54%')))
	-- -SS- /NEW
	-- -SS- AND (dist.ACCOUNT LIKE '52%' OR dist.ACCOUNT LIKE '53%' OR
	-- dist.ACCOUNT LIKE '54%')
	UNION ALL
	SELECT
		CASE
			WHEN GL_CODE.R12_ENTITY IN('5773', '5588') THEN 'CAN'
			ELSE 'USA'
		END
		/* -SS- CASE UPPER (TRIM (asx.nation_curr))
		WHEN 'CAD' THEN 'CAN'
		WHEN 'USD' THEN 'USA'
		ELSE NULL
		END */
		                                       AS COUNTRY_INDICATOR,
		TO_CHAR(COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		GL_CODE.R12_ACCOUNT
		-- -SS- SEGMENT2
		                                 AS GL_ACCOUNT,
		TRUNC(COMM.GL_POSTED_DATE, 'MM') AS JOURNAL_DATE,
		CASE
			WHEN COMM.DEBIT_AMOUNT = 0 OR COMM.DEBIT_AMOUNT IS NULL OR COMM.CREDIT_AMOUNT <> '' THEN COMM.CREDIT_AMOUNT * - 1
			ELSE COMM.DEBIT_AMOUNT
		END AS COMMISSION_AMOUNT
	FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
	INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE -- -SS- OTR
	ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR
	ON GL_CODE.R12_ACCOUNT    = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		/* -SS- ,
		actuate_sec_xref asx */
	WHERE
		-- -SS- comm.code_combination_id = gl_code.code_combination_id AND
		GL_CODE.R12_ENTITY NOT IN('5773', '5588')
		-- -SS- asx.nation_curr = 'USD'
		-- -SS- AND GL_CODE.SEGMENT2 = PSA.ACCOUNT (+)
		-- -SS- AND PSA.trane_account_ind = 'X'
		-- -SS- AND gl_code.segment1 = asx.psgl(+)
	AND((GL_CODE.PS_SEGMENT3 = 'NA'
	AND GL_CODE.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
	OR(GL_CODE.PS_SEGMENT3   <> 'NA'
	AND GL_CODE.PS_SEGMENT3   = 'SL00'))
		-- -SS- AND(GL_CODE.SEGMENT3 IS NULL OR GL_CODE.SEGMENT3 = 'SL00')
	AND COMM.GL_POSTED_DATE BETWEEN '1-JAN-2000' AND '31-OCT-2004'
		-- -SS- NEW
	AND((GL_CODE.PS_SEGMENT2 = 'NA'
	AND AFU.LIKE_52_53_54    = 'Y')
	OR(GL_CODE.PS_SEGMENT2  <> 'NA'
	AND(GL_CODE.PS_SEGMENT2 LIKE '52%'
	OR GL_CODE.PS_SEGMENT2 LIKE '53%'
	OR GL_CODE.PS_SEGMENT2 LIKE '54%')))
	-- -SS- /NEW
	-- -SS- AND (GL_CODE.SEGMENT2 LIKE '52%' OR GL_CODE.SEGMENT2 LIKE '53%' OR
	-- GL_CODE.SEGMENT2 LIKE '54%')
	UNION ALL
	SELECT
		CASE
			WHEN GL_CODE.R12_ENTITY IN('5773', '5588') THEN 'CAN'
			ELSE 'USA'
		END
		/* -SS- CASE UPPER (TRIM (asx.nation_curr))
		WHEN 'CAD' THEN 'CAN'
		WHEN 'USD' THEN 'USA'
		ELSE NULL
		END */
		                                       AS COUNTRY_INDICATOR,
		TO_CHAR(COMM.GL_POSTED_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		GL_CODE.R12_ACCOUNT
		-- -SS- SEGMENT2
		                                 AS GL_ACCOUNT,
		TRUNC(COMM.GL_POSTED_DATE, 'MM') AS JOURNAL_DATE,
		CASE
			WHEN COMM.DEBIT_AMOUNT = 0 OR COMM.DEBIT_AMOUNT IS NULL OR COMM.CREDIT_AMOUNT <> '' THEN COMM.CREDIT_AMOUNT * - 1
			ELSE COMM.DEBIT_AMOUNT
		END AS COMMISSION_AMOUNT
	FROM BH.CMS_COMMISSION_DISTRIBUTIONS COMM
	INNER JOIN BH.R12_GL_CODE_COMBINATIONS GL_CODE -- -SS- OTR
	ON COMM.CODE_COMBINATION_ID = GL_CODE.CODE_COMBINATION_ID
		-- -SS- NEW
	INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
	ON AFU.R12_ACCOUNT = GL_CODE.R12_ACCOUNT
		-- -SS- /NEW
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR
	ON GL_CODE.R12_ACCOUNT    = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
		/* -SS- ,
		actuate_sec_xref asx */
	WHERE
		-- -SS- comm.code_combination_id = gl_code.code_combination_id AND
		GL_CODE.R12_ENTITY IN('5773', '5588')
		-- -SS- asx.nation_curr = 'CAD'
		-- -SS- AND GL_CODE.SEGMENT2 = PSA.ACCOUNT (+)
		-- -SS- AND PSA.trane_account_ind = 'X'
		-- -SS- AND gl_code.segment1 = asx.psgl(+)
	AND((GL_CODE.PS_SEGMENT3 = 'NA'
	AND GL_CODE.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
	OR(GL_CODE.PS_SEGMENT3   <> 'NA'
	AND GL_CODE.PS_SEGMENT3  IN('TCA0', 'SL00')))
		-- -SS- AND(GL_CODE.SEGMENT3 IS NULL OR GL_CODE.SEGMENT3 IN('TCA0', 'SL00
		-- '))
	AND COMM.GL_POSTED_DATE BETWEEN '1-JAN-2000' AND '31-OCT-2004'
		-- -SS- NEW
	AND((GL_CODE.PS_SEGMENT2 = 'NA'
	AND AFU.LIKE_52_53_54    = 'Y')
	OR(GL_CODE.PS_SEGMENT2  <> 'NA'
	AND(GL_CODE.PS_SEGMENT2 LIKE '52%'
	OR GL_CODE.PS_SEGMENT2 LIKE '53%'
	OR GL_CODE.PS_SEGMENT2 LIKE '54%')))
	-- -SS- /NEW
	-- -SS- AND(GL_CODE.SEGMENT2 LIKE '52%' OR GL_CODE.SEGMENT2 LIKE '53%' OR
	-- GL_CODE.SEGMENT2 LIKE '54%')
	UNION ALL
	SELECT UPD.COUNTRY_INDICATOR      AS COUNTRY_INDICATOR,
		TO_CHAR(UPD.JRNL_DATE, 'YYYYMM') AS JRNL_YEAR_MONTH,
		UPD.R12_ACCOUNT
		-- -SS- gl_account
		                           AS GL_ACCOUNT,
		TRUNC(UPD.JRNL_DATE, 'MM') AS JOURNAL_DATE,
		UPD.REVENUE_AMOUNT         AS COMMISSION_AMOUNT
	FROM MD_030_COMMISSION_DTL_UPD UPD
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR
	ON UPD.R12_ACCOUNT        = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
	WHERE
		-- -SS- upd.gl_account = PSA.ACCOUNT (+) AND
		UPD.JRNL_DATE BETWEEN '1-JAN-1998' AND '31-DEC-1999'
	UNION ALL
	SELECT DISTINCT UPD.COUNTRY_INDICATOR AS COUNTRY_INDICATOR,
		TO_CHAR(UPD.JRNL_DATE, 'YYYYMM')     AS JRNL_YEAR_MONTH,
		UPD.R12_ACCOUNT
		-- -SS- gl_account
		                                             AS GL_ACCOUNT,
		TRUNC(ADD_MONTHS(UPD.JRNL_DATE, - 24), 'MM') AS JOURNAL_DATE,
		0                                            AS COMMISSION_AMOUNT
	FROM MD_030_COMMISSION_DTL_UPD UPD
	LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA -- -SS- OTR
	ON UPD.R12_ACCOUNT        = PSA.R12_ACCOUNT
	AND PSA.TRANE_ACCOUNT_IND = 'X'
	WHERE
		-- -SS- upd.gl_account = PSA.ACCOUNT (+) AND
		UPD.JRNL_DATE BETWEEN '1-JAN-1998' AND '31-DEC-1999'
	)
WHERE JOURNAL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE, - 144), 'MM') AND LAST_DAY(ADD_MONTHS(SYSDATE, - 1))
GROUP BY COUNTRY_INDICATOR,
	JRNL_YEAR_MONTH,
	GL_ACCOUNT,
	JOURNAL_DATE;
COMMENT ON MATERIALIZED VIEW DBO.DM_030_EXT_COMM_MVW
IS
	'snapshot table for snapshot DBO.DM_030_EXT_COMM_MVW';
	CREATE INDEX DBO.XIE1DM_030_EXT_COMM_MVW ON DBO.DM_030_EXT_COMM_MVW
		(
			COUNTRY_INDICATOR,
			GL_ACCOUNT
		)
		LOGGING TABLESPACE I1_AA PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE
		(
			INITIAL 80K NEXT 1M MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0 BUFFER_POOL DEFAULT
		)
		NOPARALLEL;
	GRANT
	SELECT ON DBO.DM_030_EXT_COMM_MVW TO ACTUATE_SECURITY;
	GRANT
	SELECT ON DBO.DM_030_EXT_COMM_MVW TO READ_DBO;
