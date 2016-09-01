/* $Workfile: R12_BI_LINE_PSB.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/R12_BI_LINE_PSB/R12_BI_LINE_PSB.sql $
*  $Author: Laiqi $
*  $Date: 8/26/16 1:20p $
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

spool R12_BI_LINE_PSB.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_BI_LINE_PSB
exec p_truncate_listed_table ('DBO', 'R12_BI_LINE_PSB');

prompt Inserting DATA into R12_BI_LINE_PSB
INSERT /*+ APPEND */  INTO R12_BI_LINE_PSB
(
    BUSINESS_UNIT,
    INVOICE,
    LINE_SEQ_NUM,
    IDENTIFIER,
    R12_PRODUCT,
    SRC_ED_CREATE_DATE,
    SRC_ED_CREATE_ID,
    ED_CREATE_DATE,
    ED_CREATE_ID
)
SELECT
    BUSINESS_UNIT,
    INVOICE,
    LINE_SEQ_NUM,
    IDENTIFIER,
    DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', null, null, null, IDENTIFIER, null) as R12_PRODUCT,
    ED_CREATE_DATE as SRC_ED_CREATE_DATE,
    ED_CREATE_ID as SRC_ED_CREATE_ID,
    sysdate as ED_CREATE_DATE,
    'R12_BI_LINE_PSB.sql' as ED_CREATE_ID
FROM
    OTR_BI_LINE_PSB
WHERE
    business_Unit IN ( 'BIUSA', 'BICAN');

commit;

EXIT