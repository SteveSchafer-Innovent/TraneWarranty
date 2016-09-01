-- OTR_ORACLE_PS_REV_RCPO
-- DR
-- PLNT_GL_ACCT2 -> R12_ACCOUNT
-- GL_PROD -> R12_PRODUCT

select count(*) from OTR_ORACLE_PS_REV_RCPO; -- 44785528 10:15 AM MDT

CREATE TABLE "DBO"."R12_ORACLE_PS_REV_RCPO" (
	-- "PRODUCT_CODE" VARCHAR2(18 BYTE),
	-- "SALES_ORDER_NUMBER" VARCHAR2(50 BYTE), 
	-- "ORDER_LINE_NUMBER" VARCHAR2(30 BYTE), 
	-- "COMMISS_SPLIT_AMOUNT" NUMBER(17,2), 
	-- "COMMISSION_SPLIT_PCT" NUMBER(6,3), 
	-- "PLAN_SHPMT_LN_ORDER_AMOUNT" NUMBER(26,3), 
	"ORDER_AMOUNT" NUMBER(26,8),  -- mapSalesData68, mapSalesData1
	-- "SOURCE_SYSTEM" VARCHAR2(15 BYTE), 
	"GL_DPT_ID" VARCHAR2(10 BYTE), -- mapSalesData1 [not deptid]
	-- "GL_DPT_ID2" VARCHAR2(10 BYTE), 
	"GL_BU_ID" VARCHAR2(5 BYTE), -- mapSalesData68
	-- "GL_BU_ID2" VARCHAR2(5 BYTE), 
	-- "GL_DISTRICT" VARCHAR2(50 BYTE), 
	-- "GL_DISTRICT2" VARCHAR2(50 BYTE), 
	-- "GL_DEPT" VARCHAR2(50 BYTE), 
	-- "GL_DEPT2" VARCHAR2(50 BYTE), 
	-- "PLANNED_SHIPMENT_NUMBER" VARCHAR2(20 BYTE), 
	-- "BUSINESS_UNIT" VARCHAR2(5 BYTE), 
	-- "INVOICE" VARCHAR2(22 BYTE), 
	-- "ACCOUNTING_DT" DATE, 
	-- "LINE_SEQ_NUM" NUMBER(*,0), 
	-- "ACCT_ENTRY_TYPE" VARCHAR2(3 BYTE), 
	-- "DISC_SUR_LVL" NUMBER(*,0), 
	-- "DISC_SUR_ID" VARCHAR2(15 BYTE), 
	-- "LINE_DST_SEQ_NUM" NUMBER(*,0), 
	-- "TAX_AUTHORITY_CD" VARCHAR2(3 BYTE), 
	"JRNL_DATE" DATE,  -- mapSalesData68, mapSalesData1
	"ORGN_JRNL_ID" VARCHAR2(16 BYTE),  -- mapSalesData68, mapSalesData1
	"PLNT_GL_BU" VARCHAR2(5 BYTE),  -- mapSalesData68, mapSalesData1
	-- "PLNT_GL_ACCT" VARCHAR2(10 BYTE),  -- no longer used
	"PS_PLNT_GL_ACCT2" VARCHAR2(10 BYTE),  -- mapSalesData68, mapSalesData1
	-- "PLNT_GL_DEPT" VARCHAR2(10 BYTE), 
	-- "PLNT_GL_PROD" VARCHAR2(15 BYTE),
	"CURRENCY_CODE" VARCHAR2(3 BYTE), -- mapSalesData68, mapSalesData1
	-- "CUST_OFFICE_CODE" VARCHAR2(5 BYTE), 
	-- "CUST_OFFICE_NAME" VARCHAR2(50 BYTE), 
	"PS_GL_PROD" VARCHAR2(6 BYTE),  -- mapSalesData68, mapSalesData1
	-- "EXCHANGE_RATE" NUMBER(10,6), 
	-- "PART_TYPE" VARCHAR2(3 BYTE), 
	-- "PARTS_PROD_CODE_IND" VARCHAR2(3 BYTE), 
	-- "PROD_TYPE_INDICATOR" VARCHAR2(20 BYTE), 
	-- "DATA_SOURCE" VARCHAR2(15 BYTE), 
	-- "COMM_CODE" VARCHAR2(3 BYTE), 
	-- "SALESPERSON_NAME" VARCHAR2(40 BYTE), 
	-- "BILL_TO_CUST_ID" VARCHAR2(15 BYTE), 
	-- "ED_CREATE_DATE" DATE, 
	-- "ED_CREATE_ID" VARCHAR2(32 BYTE), 
	-- "ED_UPDATE_DATE" DATE, 
	-- "ED_UPDATE_ID" VARCHAR2(32 BYTE), 
	-- "GL_PRODUCT_CODE" VARCHAR2(6 BYTE)
	-- R12_PRODUCT_CODE VARCHAR2(18 BYTE),
	-- R12_PLNT_GL_PROD VARCHAR2(15 BYTE),
	R12_PRODUCT VARCHAR2(6 BYTE),
	-- R12_PLNT_GL_ACCT VARCHAR2(10 BYTE),
	R12_ACCOUNT VARCHAR2(10 BYTE)
);

insert into "DBO"."R12_ORACLE_PS_REV_RCPO" (
	-- PRODUCT_CODE,
	ORDER_AMOUNT,
	GL_DPT_ID,
	GL_BU_ID,
	JRNL_DATE,
	ORGN_JRNL_ID,
	PLNT_GL_BU,
	-- PLNT_GL_ACCT,
	PS_PLNT_GL_ACCT2,
	-- PLNT_GL_PROD,
	CURRENCY_CODE,
	PS_GL_PROD,
	-- R12_PRODUCT_CODE,
	-- R12_PLNT_GL_PROD,
	R12_PRODUCT,
	-- R12_PLNT_GL_ACCT,
	R12_ACCOUNT
)
select
	-- PRODUCT_CODE,
	ORDER_AMOUNT,
	GL_DPT_ID,
	GL_BU_ID,
	JRNL_DATE,
	ORGN_JRNL_ID,
	PLNT_GL_BU,
	-- PLNT_GL_ACCT,
	PLNT_GL_ACCT2,
	-- PLNT_GL_PROD,
	CURRENCY_CODE,
	GL_PROD,
	-- DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', NULL, PLNT_GL_ACCT2, NULL, PLNT_GL_PROD, null) as R12_PRODUCT_CODE,
	-- DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', NULL, PLNT_GL_ACCT2, NULL, GL_PROD, null) as R12_PLNT_GL_PROD,
	DBO.F_GET_R12_PRODUCT_ONLY('PRODUCT', NULL, PLNT_GL_ACCT2, NULL, GL_PROD, null) as R12_PRODUCT,
	-- DBO.F_GET_R12_ACCOUNT_ONLY('ACCOUNT', NULL, PLNT_GL_ACCT, NULL, PRODUCT_CODE, NULL) as R12_PLNT_GL_ACCT,
	DBO.F_GET_R12_ACCOUNT_ONLY('ACCOUNT', NULL, PLNT_GL_ACCT2, NULL, GL_PROD, NULL) as R12_ACCOUNT
from
OTR_ORACLE_PS_REV_RCPO;

