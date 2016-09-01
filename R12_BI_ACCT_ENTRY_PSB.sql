/* $Workfile: R12_BI_ACCT_ENTRY_PSB.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/R12_BI_ACCT_ENTRY_PSB/R12_BI_ACCT_ENTRY_PSB.sql $
*  $Author: Laiqi $
*  $Date: 8/26/16 1:18p $
*
* Description: 
*
*           Target:     DRTRNT.DBO.
*           Source:     DRTRNT.DBO.
* Revisions: 
* 
*   change Date    Description 
*   -----------         ----------- 
*   08/23/2016      Pam Nelson, laiqi, IR - Initial creation for SMART P4 project
* 
***********************************************************************************/ 
set timing on
set pause OFF
set feedback on
set echo on

spool R12_BI_ACCT_ENTRY_PSB.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_BI_ACCT_ENTRY_PSB
exec p_truncate_listed_table ('DBO', 'R12_BI_ACCT_ENTRY_PSB');

prompt Inserting DATA into R12_BI_ACCT_ENTRY_PSB
INSERT /*+ APPEND */  INTO R12_BI_ACCT_ENTRY_PSB
(
BUSINESS_UNIT, -- VARCHAR2(5), DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySalesData1, mapExtendedYTD, mapSalesData1
INVOICE, -- VARCHAR2(22), DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySalesData1, mapExtendedYTD, mapSalesData1
LINE_SEQ_NUM, -- NUMBER(38), mapSalesData68, mapSalesData1
ACCT_ENTRY_TYPE, -- VARCHAR2(3), mapSalesData68, mapSalesData1
BUSINESS_UNIT_GL, -- VARCHAR2(5), DM_030_EXT_SALES_MVW, mapExtendedWarrantySalesData1, mapExtendedYTD, mapSalesData1
LEDGER, -- VARCHAR2(10), mapSalesData68, mapSalesData1
ACCOUNT, -- VARCHAR2(10), DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySalesData1, mapExtendedYTD, mapSalesData1
DEPTID, -- VARCHAR2(10), mapSalesData68, mapExtendedWarrantySalesData1, mapSalesData1
PRODUCT, -- VARCHAR2(6), mapSalesData68, mapExtendedWarrantySalesData1, mapSalesData1
MONETARY_AMOUNT, -- NUMBER(26,3), DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySalesData1, mapExtendedYTD, mapSalesData1
JOURNAL_ID, -- VARCHAR2(10), mapSalesData68, mapExtendedWarrantySalesData1, mapSalesData1
JOURNAL_DATE, -- DATE, DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySalesData1, mapExtendedYTD, mapSalesData1
CURRENCY_CD, -- VARCHAR2(3), mapSalesData68, mapSalesData1
R12_ACCOUNT,
R12_PRODUCT,
R12_ENTITY,
R12_LOCATION
)
select
BUSINESS_UNIT, -- VARCHAR2(5)
INVOICE, -- VARCHAR2(22)
LINE_SEQ_NUM, -- NUMBER(38)
ACCT_ENTRY_TYPE, -- VARCHAR2(3)
BUSINESS_UNIT_GL, -- VARCHAR2(5)
LEDGER, -- VARCHAR2(10)
ACCOUNT, -- VARCHAR2(10)
DEPTID, -- VARCHAR2(10)
PRODUCT, -- VARCHAR2(6)
MONETARY_AMOUNT, -- NUMBER(26,3)
JOURNAL_ID, -- VARCHAR2(10)
JOURNAL_DATE, -- DATE
CURRENCY_CD, -- VARCHAR2(3)
/*  8/25/16 I don't see any data in AFFILIATE */
DBO.F_GET_R12_ACCOUNT_ONLY('ACCOUNT', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, AFFILIATE) as R12_ACCOUNT,
DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, AFFILIATE) as R12_PRODUCT,
DBO.F_GET_R12_ENTITY_ONLY('ENTITY', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, AFFILIATE) as R12_ENTITY,
DBO.F_GET_R12_LOCATION_ONLY('LOCATION', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, AFFILIATE) as R12_LOCATION
from
DBO.OTR_BI_ACCT_ENTRY_PSB
WHERE
business_Unit IN ( 'BIUSA', 'BICAN');

commit;