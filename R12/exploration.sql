select * from RA_CUSTOMER_TRX_ALL;
select distinct segment2 as location from gl_code_combinations_kfv;

-- r12_bi_hdr_psb
select
'unknown' as BILL_SOURCE_ID,
RCT.REASON_CODE as ENTRY_TYPE,
RCT.TRX_NUMBER as INVOICE,
RCT.CUSTOMER_TRX_ID,
null as PS_BUSINESS_UNIT
from
RA_CUSTOMER_TRX_ALL RCT;

-- r12_bi_line_psb
select
'unknown' as BUSINESS_UNIT,
RCT.TRX_NUMBER as INVOICE,
RCTL.LINE_NUMBER LINE_SEQ_NUM,
'unknown' as PS_IDENTIFIER,
GCC.SEGMENT5 as R12_PRODUCT,
'unknown' as SRC_ED_CREATE_DATE,
'unknown' as SRC_ED_CREATE_ID,
'unknown' as ED_CREATE_DATE,
'unknown' as ED_CREATE_ID,
RCT.CUSTOMER_TRX_ID as CUSTOMER_TRX_ID
from
RA_CUSTOMER_TRX_ALL RCT
inner join
RA_CUSTOMER_TRX_LINES_ALL RCTL
on RCTL.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
inner join
RA_CUST_TRX_LINE_GL_DIST_ALL RCTGD
on RCTGD.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
AND NVL(RCTGD.CUSTOMER_TRX_LINE_ID, RCTL.CUSTOMER_TRX_LINE_ID) = RCTL.CUSTOMER_TRX_LINE_ID
AND RCTGD.ACCOUNT_CLASS <> 'REC' -- ????
inner join
XLA_DISTRIBUTION_LINKS XDL
on RCTGD.CUST_TRX_LINE_GL_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1
AND RCTGD.EVENT_ID = XDL.EVENT_ID
AND XDL.SOURCE_DISTRIBUTION_TYPE = 'RA_CUST_TRX_LINE_GL_DIST_ALL' -- ????
AND XDL.APPLICATION_ID = 222 -- ????
inner join
XLA_AE_LINES AEL
on XDL.AE_HEADER_ID = AEL.AE_HEADER_ID
AND XDL.AE_LINE_NUM = AEL.AE_LINE_NUM
inner join
GL_CODE_COMBINATIONS_KFV GCC
on AEL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
;