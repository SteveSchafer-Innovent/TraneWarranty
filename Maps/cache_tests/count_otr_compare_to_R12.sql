Select 'AP_030_ARC_BILL', (select count(*) from AP_030_ARC_BILL ) otr
, (select count(*) from R12_AP_030_ARC_BILL ) r12
From Dual union all
Select 'BH.GL_CODE_COMBINATIONS', (select count(*) from BH.GL_CODE_COMBINATIONS ) otr
, (select count(*) from BH.R12_GL_CODE_COMBINATIONS ) r12
From Dual union all
Select 'OTR_BI_ACCT_ENTRY_PSB', (select count(*) from OTR_BI_ACCT_ENTRY_PSB ) otr
, (select count(*) from R12_BI_ACCT_ENTRY_PSB ) r12
From Dual union all
Select 'OTR_BI_HDR_PSB', (select count(*) from OTR_BI_HDR_PSB ) otr
, (select count(*) from R12_BI_HDR_PSB ) r12
From Dual union all
Select 'OTR_BI_LINE_PSB', (select count(*) from OTR_BI_LINE_PSB ) otr
, (select count(*) from R12_BI_LINE_PSB ) r12
From Dual union all
Select 'OTR_COM_SALES_RS_LEDGER', (select count(*) from OTR_COM_SALES_RS_LEDGER ) otr
, (select count(*) from R12_COM_SALES_RS_LEDGER ) r12
From Dual union all
Select 'OTR_JRNL_HEADER_PS', (select count(*) from OTR_JRNL_HEADER_PS ) otr
, (select count(*) from R12_JRNL_HEADER_PS ) r12
From Dual union all
Select 'OTR_JRNL_LN_PS', (select count(*) from OTR_JRNL_LN_PS ) otr
, (select count(*) from R12_JRNL_LN_PS ) r12
From Dual union all
Select 'OTR_LEDGER2_PS', (select count(*) from OTR_LEDGER2_PS ) otr
, (select count(*) from R12_LEDGER2_PS ) r12
From Dual union all
Select 'OTR_ORACLE_PS_REV_RCPO', (select count(*) from OTR_ORACLE_PS_REV_RCPO ) otr
, (select count(*) from R12_ORACLE_PS_REV_RCPO ) r12
From Dual union all
Select 'OTR_PROJ_RESOURCE_PS', (select count(*) from OTR_PROJ_RESOURCE_PS ) otr
, (select count(*) from R12_PROJ_RESOURCE_PS ) r12
From Dual union all
Select 'OTR_TRANE_ACCOUNTS_PS', (select count(*) from OTR_TRANE_ACCOUNTS_PS ) otr
, (select count(*) from R12_TRANE_ACCOUNTS_PS ) r12
From Dual union all
Select 'OTR_TRANE_DEPTS_PS', (select count(*) from OTR_TRANE_DEPTS_PS ) otr
, (select count(*) from R12_TRANE_LOCATIONS ) r12
From Dual union all
Select 'OTR_TRANE_PRODUCTS_PS', (select count(*) from OTR_TRANE_PRODUCTS_PS ) otr
, (select count(*) from R12_TRANE_PRODUCTS_PS ) r12
From Dual union all
Select 'OTR_TRNBI_BI_HDR_PSB', (select count(*) from OTR_TRNBI_BI_HDR_PSB ) otr
, (select count(*) from R12_TRNBI_BI_HDR_PSB ) r12
From Dual union all
Select 'OTR_TRNCO_CM_DIST_PSB', (select count(*) from OTR_TRNCO_CM_DIST_PSB ) otr
, (select count(*) from R12_TRNCO_CM_DIST_PSB ) r12
From Dual;
