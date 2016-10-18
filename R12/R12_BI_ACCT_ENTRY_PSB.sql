-- note:  took 2.6 hours to run on 10/13
select
'NA' as BUSINESS_UNIT,
RCT.TRX_NUMBER as INVOICE,
RCTL.LINE_NUMBER as LINE_SEQ_NUM,
RCT.REASON_CODE as ACCT_ENTRY_TYPE,
'NA' as PS_BUSINESS_UNIT_GL,
'' as LEDGER, -- don't probably need this
'NA' as PS_ACCOUNT,
'NA' as PS_DEPTID,
'NA' as PS_PRODUCT,
RCTGD.AMOUNT as MONETARY_AMOUNT,
GJH.NAME as JOURNAL_ID,
RCTGD.GL_DATE as JOURNAL_DATE,
RCT.INVOICE_CURRENCY_CODE as CURRENCY_CD,
GCC.SEGMENT4 as R12_ACCOUNT,
GCC.SEGMENT5 as R12_PRODUCT,
GCC.SEGMENT1 as R12_ENTITY,
GCC.SEGMENT2 as R12_LOCATION,
'' as ED_CREATE_DATE,
RCT.CUSTOMER_TRX_ID as CUSTOMER_TRX_ID
from
RA_CUSTOMER_TRX_ALL RCT
inner join RA_CUSTOMER_TRX_LINES_ALL RCTL on RCTL.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
inner join RA_CUST_TRX_LINE_GL_DIST_ALL RCTGD on RCTGD.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
inner join XLA_DISTRIBUTION_LINKS XDL on RCTGD.CUST_TRX_LINE_GL_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1 AND RCTGD.EVENT_ID = XDL.EVENT_ID
inner join XLA_AE_LINES AEL on XDL.AE_HEADER_ID = AEL.AE_HEADER_ID AND XDL.AE_LINE_NUM = AEL.AE_LINE_NUM
left outer join GL_IMPORT_REFERENCES GIR on GIR.GL_SL_LINK_TABLE = AEL.GL_SL_LINK_TABLE AND GIR.GL_SL_LINK_ID = AEL.GL_SL_LINK_ID
left outer join GL_JE_LINES GJL on GJL.JE_HEADER_ID = GIR.JE_HEADER_ID AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
inner join GL_JE_HEADERS GJH on GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
inner join GL_CODE_COMBINATIONS_KFV GCC on AEL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
where 0=0
and RCTL.LINE_TYPE = 'LINE'
and RCTL.LINE_NUMBER = 1
and RCT.ORG_ID IN(456, 457) -- US TCS and CA TCS  Only
and RCT.COMPLETE_FLAG = 'Y'
and NVL(RCTGD.LATEST_REC_FLAG, 'Y') = 'Y'
and RCTGD.ACCOUNT_CLASS = 'REC'
and XDL.SOURCE_DISTRIBUTION_TYPE = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
and XDL.APPLICATION_ID = 222
and GJH.JE_SOURCE = 'Receivables'
;