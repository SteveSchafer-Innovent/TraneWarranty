/* Prepaid Comm Cost detail Dollar AMT*/ 
-- 66.705 sec USA/JAN-16
-- 67.825 sec CAN/JAN-16
SELECT /*+ NO_CPU_COSTING */ 
 sum(A.MONETARY_AMOUNT),
/*TAY: A.ACCOUNT,*/
 A.R12_ACCOUNT as Account, 
 PSA.DESCR AS ACCOUNT_DESC,
/*TAY: case when A.currency_cd = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END AS COUNTRY_INDICATOR*/
CASE WHEN A.R12_ENTITY IN ('5773', '5588') THEN 'CAN' ELSE 'USA' END AS COUNTRY_INDICATOR
/*TAY: FROM  OTR_BI_ACCT_ENTRY_PSB A, OTR_TRNBI_BI_HDR_PSB B, OTR_BI_HDR_PSB C, OTR_TRANE_ACCOUNTS_PS PSA WIP*/
FROM  R12_BI_ACCT_ENTRY_PSB A, OTR_TRNBI_BI_HDR_PSB B, OTR_BI_HDR_PSB C, R12_TRANE_ACCOUNTS_PS PSA
WHERE A.JOURNAL_DATE >= TO_DATE('1-'||:RunDate,'dd-mon-yy') 
  AND JOURNAL_DATE <= LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy'))
  AND A.BUSINESS_UNIT IN ('BIUSA','BICAN','BIUSC') 
/*TAY: AND A.BUSINESS_UNIT_GL IN ('CSD','CAN')*/
  AND A.R12_ENTITY IN ('CSD','CAN')
/*TAY: AND A.ACCOUNT like '5%' WIP*/
  AND A.PS_ACCOUNT like '5%'
/*TAY: AND A.DEPTID = 'SL00' WIP*/
  -- -SS- NEW
  AND((A.PS_DEPTID    = 'NA'
  AND A.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
  OR(A.PS_DEPTID     <> 'NA'
  AND A.PS_DEPTID    = 'SL00'))
  -- -SS- /NEW
  -- -SS- AND A.PS_DEPTID = 'SL00'
  and case when A.CURRENCY_CD = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END= UPPER(:COUNTRY)
  AND A.BUSINESS_UNIT = B.BUSINESS_UNIT 
  AND A.INVOICE = B.INVOICE 
/*TAY:  AND B.BUSINESS_UNIT = C.BUSINESS_UNIT WIP*/
  AND B.BUSINESS_UNIT = C.BUSINESS_UNIT 
  AND B.INVOICE = C.INVOICE 
/*TAY:  AND A.ACCOUNT = PSA.ACCOUNT (+)*/
  AND A.R12_ACCOUNT = PSA.R12_ACCOUNT (+)
  AND PSA.TRANE_ACCOUNT_IND='X'
--and c.BILL_SOURCE_ID = 'FAL'
  AND C.ENTRY_TYPE  ='CR'
/*TAY: GROUP BY A.ACCOUNT,PSA.DESCR,case when A.CURRENCY_CD = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END*/
GROUP BY A.R12_ACCOUNT,PSA.DESCR,/*TAY: case when A.CURRENCY_CD = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END*/ A.R12_ENTITY 
--ORDER BY A.ACCOUNT,case when A.CURRENCY_CD = 'USD' then 'USA' when A.CURRENCY_CD = 'CAD' THEN 'CAN' END

union
/* Qry to fetch accounts wich does not exist in OTR_BI_ACCT_ENTRY_PSB table */
SELECT  /*+ NO_CPU_COSTING */ 
 0 as MONETARY_AMOUNT,
/*TAY: PSA.ACCOUNT, */
 PSA.R12_ACCOUNT as Account, 
 PSA.DESCR AS ACCOUNT_DESC,
 '' AS COUNTRY_INDICATOR
/*TAY: FROM dbo.otr_TRANE_ACCOUNTS_ps psa*/
FROM dbo.R12_TRANE_ACCOUNTS_PS psa
WHERE  PSA.TRANE_ACCOUNT_IND='X'
/*TAY:  AND PSA.ACCOUNT LIKE '5%' WIP*/ 
  AND PSA.PS_ACCOUNT LIKE '5%' 
  and not EXISTS
   (select 'X'
/*TAY: FROM OTR_BI_ACCT_ENTRY_PSB dist,dbo.ACTUATE_SEC_XREF ASX,OTR_BI_HDR_PSB C WIP*/
    FROM R12_BI_ACCT_ENTRY_PSB dist, 
         --dbo.ACTUATE_SEC_XREF ASX, 
	 OTR_BI_HDR_PSB C 
    WHERE /*TAY: DIST.PS_BUSINESS_UNIT_GL= ASX.PSGL   
      and*/ dist.JOURNAL_DATE >= TO_DATE('1-'||:RunDate,'dd-mon-yy') 
      AND dist.JOURNAL_DATE< = LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy'))
/*TAY:      AND DIST.ACCOUNT LIKE '5%' WIP*/
      AND DIST.PS_ACCOUNT LIKE '5%'
/*TAY:      and CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)*/
      and CASE WHEN dist.R12_ENTITY IN ('5773', '5588') THEN 'CAN' ELSE 'USA' END = UPPER(:COUNTRY)
      AND dist.BUSINESS_UNIT = C.BUSINESS_UNIT 
      AND dist.INVOICE = C.INVOICE 
/*TAY:      AND dist.ACCOUNT = PSA.ACCOUNT*/ 
      AND dist.R12_ACCOUNT = PSA.R12_ACCOUNT  
      aND PSA.TRANE_ACCOUNT_IND='X'
      AND C.ENTRY_TYPE  ='CR'
   )
/*TAY: ORDER BY PSA.ACCOUNT WIP*/
ORDER BY ACCOUNT

