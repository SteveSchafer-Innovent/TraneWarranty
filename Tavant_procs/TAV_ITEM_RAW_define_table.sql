DROP TABLE TAV_ITEM_RAW;
CREATE TABLE TAV_ITEM_RAW (
CLAIM_NUMBER VARCHAR2(255 CHAR) NOT NULL,
TAVANT_CLAIM_TYPE VARCHAR2(31 CHAR) NOT NULL,
COMMERCIAL_POLICY NUMBER(1),
FAILURE_DATE DATE,
FILED_ON_DATE DATE,
CLAIMED_ITEM_ID NUMBER(19),
ITEM_REF_INV_ITEM NUMBER(19),
SERIAL_NUMBER VARCHAR2(255),
SHIPMENT_DATE DATE,
DELIVERY_DATE DATE,
SALES_ORDER_NUMBER VARCHAR2(20),
MFG VARCHAR2(255),
ORIGINAL_SOURCE_ID VARCHAR2(255),
SIOP_SEGMENT6 VARCHAR2(255 CHAR),
WARRANTY_ID NUMBER(19),
DEALER_GROUP_NAME varchar2(255),
CUSTOMER_NUMBER varchar2(255),
CUSTOMER_NAME varchar2(255),
OFFICE_NAME varchar2(255)
);
COMMIT;