-- CREATE TABLE R12_GL_ACCOUNT_SCD LIKE GL_ACCOUNT_SCD
-- DW
-- ADD R12_ACCOUNT VARCHAR(10?);
-- ADD R12_ENTITY VARCHAR(6?)
-- ADD R12_PRODUCT
-- ADD R12_COST_CENTER

-- assumptions:
-- COMPANY = BUSINESS_UNIT
-- ACCOUNT = ACCOUNT
-- COST_CENTER = DEPT_ID
-- PROD_CODE = PRODUCT

select count(*) from dbo.gl_account_scd; -- 9574 8/26 9:30 am mdt

CREATE TABLE "DBO"."R12_GL_ACCOUNT_SCD" (
  	"GL_ACCOUNT_SCD_KEY" NUMBER(9,0) NOT NULL ENABLE, 
	-- "GL_ACCOUNT" VARCHAR2(35 BYTE) NOT NULL ENABLE, 
	"COMPANY" VARCHAR2(6 BYTE) NOT NULL ENABLE, 
	"ACCOUNT" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"COST_CENTER" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"PROD_CODE" VARCHAR2(6 BYTE) NOT NULL ENABLE, 
	-- "ACTIVE" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	-- "CREATED_BY" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	-- "CREATED_ON" DATE NOT NULL ENABLE, 
	"R12_ACCOUNT" VARCHAR2(10 BYTE) NOT NULL ENABLE,
	"R12_ENTITY" VARCHAR(6 BYTE) NOT NULL ENABLE,
	"R12_PRODUCT" VARCHAR(6 BYTE) NOT NULL ENABLE,
	"R12_COST_CENTER" VARCHAR(10 BYTE) NOT NULL ENABLE,
	--  CONSTRAINT "Y_OR_N_VALUE113" CHECK (active IN ('N', 'Y')) ENABLE, 
	 CONSTRAINT "XPK_R12_GL_ACCOUNT_SCD" PRIMARY KEY("GL_ACCOUNT_SCD_KEY")
);

TRUNCATE TABLE R12_GL_ACCOUNT_SCD;
INSERT INTO R12_GL_ACCOUNT_SCD
(
GL_ACCOUNT_SCD_KEY, -- mapExpenseWarrantyData68, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
-- GL_ACCOUNT,
COMPANY, -- mapExpenseWarrantyData68, mapExtendedTrxLagRules, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
ACCOUNT, -- mapExpenseWarrantyData68, mapExtendedTrxLagRules, mapExtendedWarrantyCostFlow, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
COST_CENTER, -- mapExpenseWarrantyData68, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
PROD_CODE, -- mapExpenseWarrantyData68, mapExtendedWarrantyCostFlowtest, mapExtendedWarrantyExpenseData, mapExpenseConcessionData, mapExpenseWarrantyData
-- ACTIVE,
-- CREATED_BY,
-- CREATED_ON,
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
DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', COMPANY, ACCOUNT, COST_CENTER, PROD_CODE, null) as R12_ACCOUNT,
DBO.F_GET_R12_ACCOUNT_STRING ('ENTITY', COMPANY, ACCOUNT, COST_CENTER, PROD_CODE, null) as R12_ENTITY,
DBO.F_GET_R12_ACCOUNT_STRING ('PRODUCT', COMPANY, ACCOUNT, COST_CENTER, PROD_CODE, null) as R12_PRODUCT,
DBO.F_GET_R12_ACCOUNT_STRING ('COSTCENTER', COMPANY, ACCOUNT, COST_CENTER, PROD_CODE, null) as R12_COST_CENTER
FROM
GL_ACCOUNT_SCD;

-- updates

-- SY_030_CALC_SUM_STG add columns
-- DW

select count(*) from SY_030_CALC_SUM_STG; -- 12936 10:00 AM MDT
alter table SY_030_CALC_SUM_STG add R12_ACCOUNT varchar(10);

update SY_030_CALC_SUM_STG
set
R12_ACCOUNT = DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', null, GL_ACCOUNT, null, null, null);

-- SY_030_COST_FLOW_STG add columns
-- DW

select count(*) from SY_030_COST_FLOW_STG; -- 717066 10:00 AM MDT
alter table SY_030_COST_FLOW_STG add R12_ACCOUNT varchar(10); -- 10?
alter table SY_030_COST_FLOW_STG add R12_ENTITY varchar(6); -- 6?

update SY_030_COST_FLOW_STG
set
R12_ACCOUNT = DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', BUSINESS_UNIT, GL_ACCOUNT, null, null, null),
R12_ENTITY = DBO.F_GET_R12_ACCOUNT_STRING ('ENTITY', BUSINESS_UNIT, GL_ACCOUNT, null, null, null);

-- SY_030_FORECAST_COMM_STG add columns
-- DW

select count(*) from SY_030_FORECAST_COMM_STG; -- 1088502 10:00 AM MDT
alter table SY_030_FORECAST_COMM_STG add R12_ACCOUNT varchar(10);

update SY_030_FORECAST_COMM_STG
set
R12_ACCOUNT = DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', null, GL_ACCOUNT, null, null, null);

-- SY_030_FORECAST_REV_STG add columns
-- DW

select count(*) from SY_030_FORECAST_REV_STG; -- 1088502 10:00 AM MDT
alter table SY_030_FORECAST_REV_STG add R12_ACCOUNT varchar(10);

update SY_030_FORECAST_REV_STG
set
R12_ACCOUNT = DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', null, GL_ACCOUNT, null, null, null);

-- TEMP_030_LAG_RULE_YR_XRF add columns
-- DW

select count(*) from TEMP_030_LAG_RULE_YR_XRF; -- 0 10:05 AM MDT
alter table TEMP_030_LAG_RULE_YR_XRF add R12_ACCOUNT varchar(10);

update TEMP_030_LAG_RULE_YR_XRF
set
R12_ACCOUNT = DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', null, GL_ACCOUNT, null, null, null);

-- TEMP_030_COST_FLOW add columns
-- DW

select count(*) from TEMP_030_COST_FLOW; -- 0 10:05 AM MDT
alter table TEMP_030_COST_FLOW add R12_ACCOUNT varchar(10); -- 10?
alter table TEMP_030_COST_FLOW add R12_ENTITY varchar(6); -- 6?

update TEMP_030_COST_FLOW
set
R12_ACCOUNT = DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', BUSINESS_UNIT, GL_ACCOUNT, null, null, null),
R12_ENTITY = DBO.F_GET_R12_ACCOUNT_STRING ('ENTITY', BUSINESS_UNIT, GL_ACCOUNT, null, null, null);

-- TEMP_030_CS_CF_DLR_PVT add columns
-- DW

select count(*) from TEMP_030_CS_CF_DLR_PVT; -- 0 10:05 AM MDT
alter table TEMP_030_CS_CF_DLR_PVT add R12_ACCOUNT varchar(10);

update TEMP_030_CS_CF_DLR_PVT
set
R12_ACCOUNT = DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', null, GL_ACCOUNT, null, null, null);

-- TEMP_030_CS_RATE_PVT add columns
-- DW

select count(*) from TEMP_030_CS_RATE_PVT; -- 0 10:05 AM MDT
alter table TEMP_030_CS_RATE_PVT add R12_ACCOUNT varchar(10);

update TEMP_030_CS_RATE_PVT
set
R12_ACCOUNT = DBO.F_GET_R12_ACCOUNT_STRING ('ACCOUNT', null, GL_ACCOUNT, null, null, null);

-- PROD_CODE_XREF_RCPO_DR add columns
-- DW

select count(*) from PROD_CODE_XREF_RCPO_DR; -- 3374 10:05 AM MDT
alter table PROD_CODE_XREF_RCPO_DR add R12_PRODUCT varchar2(6); -- 6?

update PROD_CODE_XREF_RCPO_DR
set
R12_PRODUCT = DBO.F_GET_R12_ACCOUNT_STRING ('PRODUCT', GL_LEDGER, null, null, MANF_PROD_CODE, null);
-- GL_LEDGER = BUSINESS_UNIT?


