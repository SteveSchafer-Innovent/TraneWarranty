-- OTR_TRANE_ACCOUNTS_PS

select count(*) from otr_trane_accounts_ps;

CREATE TABLE "DBO"."R12_TRANE_ACCOUNTS_PS" (
  	"PS_ACCOUNT" VARCHAR2(10 BYTE), -- DM_030_EXT_COMM_MVW, mapExtendedTrxLagRules, mapExtendedWarrantyCommissionData, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExtendedWarrantySalesData1, mapExtendedYTD, PKG_030_EXT_WARRANTY
  	R12_ACCOUNT VARCHAR2(10 BYTE),
	"DESCR" VARCHAR2(30 BYTE), -- mapExtendedTrxLagRules, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedYTD, PKG_030_EXT_WARRANTY
	-- "DESCRSHORT" VARCHAR2(10 BYTE), 
	-- "ACCOUNT_TYPE" VARCHAR2(1 BYTE), 
	-- "UNIT_OF_MEASURE" VARCHAR2(3 BYTE), 
	-- "OPEN_ITEM" VARCHAR2(1 BYTE), 
	-- "OPEN_ITEM_DESCR" VARCHAR2(10 BYTE), 
	-- "OPEN_ITEM_EDIT_REC" VARCHAR2(15 BYTE), 
	-- "OPEN_ITEM_EDIT_FLD" VARCHAR2(18 BYTE), 
	-- "STATISTICS_ACCOUNT" VARCHAR2(1 BYTE), 
	-- "TRANE_RSV_ACCT_FLG" VARCHAR2(1 BYTE), 
	"TRANE_ACCOUNT_IND" VARCHAR2(1 BYTE) -- DM_030_EXT_COMM_MVW, mapExtendedTrxLagRules, mapExtendedWarrantyCommissionData, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExtendedWarrantySalesData1, mapExtendedYTD, PKG_030_EXT_WARRANTY
);

insert into DBO.R12_TRANE_ACCOUNTS_PS (
	PS_ACCOUNT,
	R12_ACCOUNT,
	DESCR,
	TRANE_ACCOUNT_IND
)
select
	ACCOUNT as PS_ACCOUNT,
	DBO.F_GET_R12_ACCOUNT_ONLY('ACCOUNT', null, ACCOUNT, null, null, null) as R12_ACCOUNT,
	DESCR,
	TRANE_ACCOUNT_IND
from
OTR_TRANE_ACCOUNTS_PS;