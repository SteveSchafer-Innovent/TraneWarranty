/* MTD4 */
SELECT
  SUM(A.MONETARY_AMOUNT),
  A.R12_ACCOUNT AS Account, 
  AFU.DESCR AS ACCOUNT_DESC,  
  CASE
    WHEN A.R12_ENTITY IN('5773', '5588')
    THEN 'CAN'
    ELSE 'USA'
  END AS COUNTRY_INDICATOR
  
FROM R12_BI_ACCT_ENTRY_PSB A
INNER JOIN R12_TRNBI_BI_HDR_PSB B
  ON A.BUSINESS_UNIT = B.BUSINESS_UNIT
  AND A.INVOICE = B.INVOICE
INNER JOIN R12_BI_HDR_PSB C
  ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
  AND B.INVOICE = C.INVOICE
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
  ON AFU.R12_ACCOUNT = A.R12_ACCOUNT

WHERE A.JOURNAL_DATE >= TO_DATE('1-'||:RunDate, 'dd-mon-yy')
AND JOURNAL_DATE <= LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
AND A.BUSINESS_UNIT IN('BIUSA', 'BICAN', 'BIUSC')
AND A.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
AND AFU.LIKE_5 = 'Y'
AND((A.PS_DEPTID = 'NA'
AND A.R12_LOCATION IN('113602', '115615' /* USA */, '129003' /* CANADA */))
OR(A.PS_DEPTID <> 'NA'
AND A.PS_DEPTID = 'SL00'))
AND CASE
  WHEN A.CURRENCY_CD = 'USD' THEN 'USA'
  WHEN A.CURRENCY_CD = 'CAD' THEN 'CAN'
  END = UPPER(:COUNTRY)
AND C.ENTRY_TYPE = 'CR'

GROUP BY A.R12_ACCOUNT, 
  AFU.DESCR, 
  A.R12_ENTITY

UNION

-- R12 data
SELECT
  SUM(A.MONETARY_AMOUNT),
  A.R12_ACCOUNT AS Account, 
  AFU.DESCR AS ACCOUNT_DESC,  
  CASE
    WHEN A.R12_ENTITY IN('5773', '5588')
    THEN 'CAN'
    ELSE 'USA'
  END AS COUNTRY_INDICATOR
  
FROM R12_BI_ACCT_ENTRY_STG A
INNER JOIN R12_TRNBI_BI_HDR_STG B
  ON A.INVOICE = B.INVOICE AND A.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
INNER JOIN R12_BI_HDR_STG C
  ON B.INVOICE = C.INVOICE AND B.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
  ON AFU.R12_ACCOUNT = A.R12_ACCOUNT

WHERE A.JOURNAL_DATE >= TO_DATE('1-'||:RunDate, 'dd-mon-yy')
AND JOURNAL_DATE <= LAST_DAY(to_date('1-'||:RunDate, 'dd-mon-yy'))
-- AND A.BUSINESS_UNIT IN('BIUSA', 'BICAN', 'BIUSC')
AND A.R12_ENTITY IN('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
AND AFU.LIKE_5 = 'Y'
AND A.R12_LOCATION IN ('113602', '115615' /* USA */, '129003' /* CANADA */)
AND CASE
  WHEN A.CURRENCY_CD = 'USD' THEN 'USA'
  WHEN A.CURRENCY_CD = 'CAD' THEN 'CAN'
  END = UPPER(:COUNTRY)
AND C.ENTRY_TYPE  in ('CR','CM','INV')

GROUP BY A.R12_ACCOUNT, 
  AFU.DESCR, 
  A.R12_ENTITY

UNION

SELECT
  0 AS MONETARY_AMOUNT,
  AFU.R12_ACCOUNT AS ACCOUNT, 
  AFU.DESCR AS ACCOUNT_DESC, 
  '' AS COUNTRY_INDICATOR
  
FROM
R12_ACCOUNT_FILTER_UPD AFU
  
WHERE 1=1
AND AFU.LIKE_5 = 'Y'
AND NOT EXISTS (
  SELECT 'X'
  FROM R12_BI_ACCT_ENTRY_PSB DIST
  INNER JOIN R12_BI_HDR_PSB C
    ON DIST.BUSINESS_UNIT = C.PS_BUSINESS_UNIT
    AND DIST.INVOICE = C.INVOICE
    
  WHERE
    DIST.JOURNAL_DATE >= TO_DATE('1-'||:RunDate, 'dd-mon-yy')
  AND DIST.JOURNAL_DATE < = LAST_DAY(TO_DATE('1-'||:RunDate, 'dd-mon-yy'))
  AND CASE
    WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
    ELSE 'USA'
    END = UPPER(:COUNTRY)
  AND DIST.R12_ENTITY IN ('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
  AND DIST.R12_ACCOUNT = AFU.R12_ACCOUNT 
  AND C.ENTRY_TYPE = 'CR'

  UNION ALL

  SELECT 'X'
  FROM R12_BI_ACCT_ENTRY_STG DIST
  INNER JOIN R12_BI_HDR_STG C
    ON DIST.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
    AND DIST.INVOICE = C.INVOICE
    
  WHERE
    DIST.JOURNAL_DATE >= TO_DATE('1-'||:RunDate, 'dd-mon-yy')
  AND DIST.JOURNAL_DATE < = LAST_DAY(TO_DATE('1-'||:RunDate, 'dd-mon-yy'))
  AND CASE
    WHEN DIST.R12_ENTITY IN('5773', '5588') THEN 'CAN'
    ELSE 'USA'
    END = UPPER(:COUNTRY)
  AND DIST.R12_ENTITY IN ('5773', '5588', '5575', '5612', '5743', '9256', '9258', '9298', '9299', '9984')
  AND DIST.R12_ACCOUNT = AFU.R12_ACCOUNT 
  AND C.ENTRY_TYPE  in ('CR','CM','INV')

)
  
ORDER BY ACCOUNT
