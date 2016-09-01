/* $Workfile: R12_AP_030_ARC_BILL.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/R12_AP_030_ARC_BILL/R12_AP_030_ARC_BILL.sql $
*  $Author: Laiqi $
*  $Date: 8/26/16 1:13p $
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

spool R12_AP_030_ARC_BILL.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_AP_030_ARC_BILL
exec p_truncate_listed_table ('DBO', 'R12_AP_030_ARC_BILL');

prompt Inserting DATA into R12_AP_030_ARC_BILL
INSERT /*+ APPEND */  INTO R12_AP_030_ARC_BILL
(
CATEGORY, -- DM_030_EXT_SALES_MVW
AMOUNT, -- DM_030_EXT_SALES_MVW
GL_POSTED_DATE, -- DM_030_EXT_SALES_MVW
COMPANY, -- DM_030_EXT_SALES_MVW
ACCOUNT, -- DM_030_EXT_SALES_MVW
R12_ACCOUNT,
R12_ENTITY
)
SELECT
CATEGORY,
AMOUNT,
GL_POSTED_DATE,
COMPANY,
ACCOUNT,
DBO.F_GET_R12_ACCOUNT_ONLY('ACCOUNT', COMPANY, ACCOUNT, COST_CENTER, PRODUCT_CODE, null) as R12_ACCOUNT,
DBO.F_GET_R12_ENTITY_ONLY('ENTITY', COMPANY, ACCOUNT, COST_CENTER, PRODUCT_CODE, null) as R12_ENTITY
FROM
AP_030_ARC_BILL;

commit;