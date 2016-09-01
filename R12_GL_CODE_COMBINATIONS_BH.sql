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

spool R12_GL_CODE_COMBINATIONS.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_GL_CODE_COMBINATIONS
exec p_truncate_listed_table ('BH', 'R12_GL_CODE_COMBINATIONS');

prompt Inserting DATA into BH  R12_GL_CODE_COMBINATIONS
INSERT /*+ APPEND */  INTO BH.R12_GL_CODE_COMBINATIONS
(
CODE_COMBINATION_ID, -- DM_030_EXT_COMM_MVW
SEGMENT1, -- DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
SEGMENT2, -- DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
SEGMENT3, -- DM_030_EXT_COMM_MVW, mapExtendedWarrantyCommissionData
SEGMENT4, -- mapExtendedWarrantyCommissionData
R12_ACCOUNT,
R12_PRODUCT,
R12_LOCATION,
R12_ENTITY
)
SELECT
CODE_COMBINATION_ID,
SEGMENT1,
SEGMENT2,
SEGMENT3,
SEGMENT4,
DBO.F_GET_R12_ACCOUNT_ONLY('ACCOUNT', SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, null) as R12_ACCOUNT,
DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, null) as R12_PRODUCT,
DBO.F_GET_R12_LOCATION_ONLY('LOCATION', SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, null) as R12_LOCATION,
DBO.F_GET_R12_ENTITY_ONLY('ENTITY', SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, null) as R12_ENTITY
FROM
BH.GL_CODE_COMBINATIONS;


commit;