/* $Workfile: R12_BI_HDR_PSB.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/R12_BI_HDR_PSB/R12_BI_HDR_PSB.sql $
*  $Author: Laiqi $
*  $Date: 8/26/16 1:19p $
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

spool R12_BI_HDR_PSB.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_BI_HDR_PSB
exec p_truncate_listed_table ('DBO', 'R12_BI_HDR_PSB');

prompt Inserting DATA into R12_BI_HDR_PSB
INSERT /*+ APPEND */  INTO R12_BI_HDR_PSB
(
BUSINESS_UNIT, -- VARCHAR2(5), DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySalesData1, mapExtendedYTD, mapSalesData1
INVOICE, -- VARCHAR2(22), DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySalesData1, mapExtendedYTD, mapSalesData1
BILL_SOURCE_ID, -- VARCHAR2(10), mapSalesData68, mapSalesData1
ENTRY_TYPE, -- VARCHAR2(5), DM_030_EXT_SALES_MVW, mapExtendedWarrantySalesData1, mapExtendedYTD
R12_ENTITY
)
select
BUSINESS_UNIT,
INVOICE,
BILL_SOURCE_ID,
ENTRY_TYPE,
/* Is there any data in ACCOUNT, DEPTID, PRODUCT */
DBO.F_GET_R12_ENTITY_ONLY('ENTITY', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, null) as R12_ENTITY
from
OTR_BI_HDR_PSB
WHERE
    business_Unit IN ( 'BIUSA', 'BICAN');

commit;