/* $Workfile: R12_TRANE_PRODUCTS_PS.sql $
*  $Revision: 1 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Tables/R12_TRANE_PRODUCTS_PS/R12_TRANE_PRODUCTS_PS.sql $
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

spool R12_TRANE_PRODUCTS_PS.log
whenever SQLERROR exit failure;

prompt User and DATABASE Connected To:
select user, NAME from v$database;

prompt Truncating R12_TRANE_PRODUCTS_PS
exec p_truncate_listed_table ('DBO', 'R12_TRANE_PRODUCTS_PS');

prompt Inserting DATA into R12_TRANE_PRODUCTS_PS
INSERT /*+ APPEND */  INTO R12_TRANE_PRODUCTS_PS
(
PRODUCT, --  VARCHAR2(6), mapSalesData68, mapSalesData1
DESCR, -- VARCHAR2(30), mapSalesData68, mapSalesData1
R12_PRODUCT
)
select
PRODUCT,
DESCR,
DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', null, null, null, PRODUCT, null) as R12_PRODUCT
from
OTR_TRANE_PRODUCTS_PS;

commit;