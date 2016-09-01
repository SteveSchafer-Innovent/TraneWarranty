/* $Workfile: R12_TRNBI_BI_HDR_PSB.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/R12_TRNBI_BI_HDR_PSB/R12_TRNBI_BI_HDR_PSB.sql $
*  $Author: Laiqi $
*  $Date: 8/26/16 1:21p $
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

spool R12_TRNBI_BI_HDR_PSB.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_TRNBI_BI_HDR_PSB
exec p_truncate_listed_table ('DBO', 'R12_TRNBI_BI_HDR_PSB');

prompt Inserting DATA into R12_TRNBI_BI_HDR_PSB
INSERT /*+ APPEND */  INTO R12_TRNBI_BI_HDR_PSB
(
BUSINESS_UNIT, -- VARCHAR2(5), DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySaleData1, mapExtendedYTD, mapSalesData1
INVOICE, -- VARCHAR2(22), DM_030_EXT_SALES_MVW, mapSalesData68, mapExtendedWarrantySaleData1, mapExtendedYTD, mapSalesData1
TRNBI_PROJECT_TYPE, -- VARCHAR2(10), mapSalesData68, mapSalesData1
R12_ENTITY
)
select
BUSINESS_UNIT, -- VARCHAR2(5)
INVOICE, -- VARCHAR2(22)
TRNBI_PROJECT_TYPE, -- VARCHAR2(10)
/* BUSINESS_UNIT is not GL BU and none of the rest of the fields exist in the source table.  I see no value in source table that can be converted to R12. */
--DBO.F_GET_R12_ENTITY_ONLY('ENTITY', BUSINESS_UNIT, ACCOUNT, DEPTID, PRODUCT, null) as R12_ENTITY
NULL as R12_ENTITY
from
OTR_TRNBI_BI_HDR_PSB
WHERE
    business_Unit IN ( 'BIUSA', 'BICAN');

commit;