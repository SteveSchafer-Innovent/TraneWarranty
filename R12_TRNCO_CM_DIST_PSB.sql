/* $Workfile: R12_TRNCO_CM_DIST_PSB.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/R12_TRNCO_CM_DIST_PSB/R12_TRNCO_CM_DIST_PSB.sql $
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

spool R12_TRNCO_CM_DIST_PSB.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_TRNCO_CM_DIST_PSB
exec p_truncate_listed_table ('DBO', 'R12_TRNCO_CM_DIST_PSB');

prompt Inserting DATA into R12_TRNCO_CM_DIST_PSB
INSERT /*+ APPEND */  INTO R12_TRNCO_CM_DIST_PSB
(
BUSINESS_UNIT, -- VARCHAR2(5), mapExtendedWarrantyCommissionData
BUSINESS_UNIT_GL, -- VARCHAR2(5), DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
ACCOUNT, -- VARCHAR2(10), DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
DEPTID, -- VARCHAR2(10), DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
PRODUCT, -- VARCHAR2(6), mapExtendedWarrantyCommissionData
DEBIT_AMT, -- NUMBER(15,2), DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
CREDIT_AMOUNT, -- NUMBER(15,2), DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
JOURNAL_ID, -- VARCHAR2(10), DM_030_EXT_COMM_MVW
JOURNAL_DATE, -- DATE, DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
R12_ACCOUNT,
R12_PRODUCT,
R12_ENTITY,
R12_LOCATION
)
select
BUSINESS_UNIT, -- VARCHAR2(5)
BUSINESS_UNIT_GL, -- VARCHAR2(5)
ACCOUNT, -- VARCHAR2(10)
DEPTID, -- VARCHAR2(10)
PRODUCT, -- VARCHAR2(6)
DEBIT_AMT, -- NUMBER(15,2)
CREDIT_AMOUNT, -- NUMBER(15,2)
JOURNAL_ID, -- VARCHAR2(10)
JOURNAL_DATE, -- DATE
/* business_unit_gl has values like CAN and CSD in it. Is that right. */
DBO.F_GET_R12_ACCOUNT_ONLY('ACCOUNT', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, null) as R12_ACCOUNT,
DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, null) as R12_PRODUCT,
DBO.F_GET_R12_ENTITY_ONLY('ENTITY', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, null) as R12_ENTITY,
DBO.F_GET_R12_LOCATION_ONLY('LOCATION', BUSINESS_UNIT_GL, ACCOUNT, DEPTID, PRODUCT, null) as R12_LOCATION
from
OTR_TRNCO_CM_DIST_PSB
WHERE
    business_Unit IN ( 'BIUSA', 'BICAN');

commit;