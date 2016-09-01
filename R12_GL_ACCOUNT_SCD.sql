/* $Workfile: EDW_Generic_Loadscript_Template.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/_Documentation/EDW_Generic_Loadscript_Template.sql $
*  $Author: Laiqi $
*  $Date: 8/14/15 5:10p $
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

spool R12_GL_ACCOUNT_SCD.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_GL_ACCOUNT_SCD
exec p_truncate_listed_table ('DBO', 'R12_GL_ACCOUNT_SCD');

prompt Inserting DATA into R12_GL_ACCOUNT_SCD
INSERT /*+ APPEND */  INTO R12_GL_ACCOUNT_SCD
(
GL_ACCOUNT_SCD_KEY, -- mapExpenseWarrantyData68, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData

COMPANY, -- mapExpenseWarrantyData68, mapExtendedTrxLagRules, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
ACCOUNT, -- mapExpenseWarrantyData68, mapExtendedTrxLagRules, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
COST_CENTER, -- mapExpenseWarrantyData68, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
PROD_CODE, -- mapExpenseWarrantyData68, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
R12_ACCOUNT,
R12_ENTITY,
R12_PRODUCT,
R12_COST_CENTER
)
SELECT
GL_ACCOUNT_SCD_KEY,
-- GL_ACCOUNT,
COMPANY,
ACCOUNT,
COST_CENTER,
PROD_CODE,
-- ACTIVE,
-- CREATED_BY,
-- CREATED_ON,
DBO.F_GET_R12_ACCOUNT_ONLY('ACCOUNT', COMPANY, ACCOUNT, COST_CENTER, PROD_CODE, null) as R12_ACCOUNT,
DBO.F_GET_R12_ENTITY_ONLY('ENTITY', COMPANY, ACCOUNT, COST_CENTER, PROD_CODE, null) as R12_ENTITY,
DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', COMPANY, ACCOUNT, COST_CENTER, PROD_CODE, null) as R12_PRODUCT,
DBO.F_GET_R12_COSTCENTER_ONLY('COSTCENTER', COMPANY, ACCOUNT, COST_CENTER, PROD_CODE, null) as R12_COST_CENTER
FROM
GL_ACCOUNT_SCD;

commit;