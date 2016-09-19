FILTERS( Case_When_ExtendedSalesDataReport_COUNTRY_INDICATOR_CAD_Then__CAN_Else__USA_End_ Varchar 
'Case When ExtendedSalesDataReport.COUNTRY_INDICATOR =\'CAD\' Then  \'CAN\' Else  \'USA\' End ')

WITH (prmBegin_Trx_Date Timestamp, prmEnd_Trx_Date Timestamp) 

SELECT 
(Case When ExtendedSalesDataReport.COUNTRY_INDICATOR ='CAD' Then  'CAN' Else  'USA' End  ) AS COUNTRY_INDICATOR,
ExtendedSalesDataReport.JRNL_YEAR_MONTH AS JRNL_YEAR_MONTH,
ExtendedSalesDataReport.BU AS BU, 
ExtendedSalesDataReport.GL_ACCOUNT AS GL_ACCOUNT,
ExtendedSalesDataReport.GL_DEP_ID AS DEPT_ID,
ExtendedSalesDataReport.Query_source AS Query_source,
ExtendedSalesDataReport.GL_PRODUCT_ID AS GL_PRODUCT_ID, 
ExtendedSalesDataReport.JOURNAL_DATE AS JOURNAL_DATE, 
ExtendedSalesDataReport.JOURNAL_ID AS JOURNAL_ID,
ExtendedSalesDataReport.REVENUE_AMOUNT AS REVENUE_AMOUNT, 
ExtendedSalesDataReport.REVENUE_AMOUNT_DEC AS REVENUE_AMOUNT_DEC


FROM 
"InformationObjects/ExtendedWarranty/Information Objects/ExtendedSalesReportData.iob"  AS ExtendedSalesDataReport

WHERE :?Case_When_ExtendedSalesDataReport_COUNTRY_INDICATOR_CAD_Then__CAN_Else__USA_End_
AND  ExtendedSalesDataReport.JOURNAL_DATE  >=:prmBegin_Trx_Date
AND ExtendedSalesDataReport.JOURNAL_DATE   <=:prmEnd_Trx_Date
and  not (ExtendedSalesDataReport.Query_source  IN('Oracle Ledger','P/S Ledger'  )AND ExtendedSalesDataReport.JRNL_YEAR_MONTH >='199801'  and ExtendedSalesDataReport.JRNL_YEAR_MONTH <='200312'
and ExtendedSalesDataReport.GL_ACCOUNT    in  ('526880',
'526881',
'526882',
'526883',
'526884',
'526885',
'526886',
'526887',
'526888',
'526889',
'526890',
'526891',
'526892',
'526893',
'526895') )
ORDER BY COUNTRY_INDICATOR asc, GL_ACCOUNT asc ,JOURNAL_DATE asc