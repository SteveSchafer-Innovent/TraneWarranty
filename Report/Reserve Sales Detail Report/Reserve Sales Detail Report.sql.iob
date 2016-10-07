FILTERS( Case_When_SalesDataReport_COUNTRY_INDICATOR_CAD_Then__CAN_Else__USA_End_ Varchar 
'Case When SalesDataReport.COUNTRY_INDICATOR =\'CAD\' Then  \'CAN\' Else  \'USA\' End ')

WITH (prmBegin_Trx_Date Timestamp, prmEnd_Trx_Date Timestamp ) 

SELECT SalesDataReport.BU AS BU, SalesDataReport.REVENUE_AMOUNT AS REVENUE_AMOUNT, 
SalesDataReport.GL_ACCOUNT AS GL_ACCOUNT, SalesDataReport.DEPT_ID AS DEPT_ID, 
SalesDataReport.DEPT_DESCR AS DEPT_DESCR, SalesDataReport.MANF_PROD_ID AS MANF_PROD_ID, 
SalesDataReport.MANF_PROD_DESCR AS MANF_PROD_DESCR, SalesDataReport.DIST_GL_PRODUCT AS 
DIST_GL_PRODUCT, ( Case When SalesDataReport.RESERVE_GROUP in ( 'LARGE' , 'Large') or 
SalesDataReport.Query_source ='PUEBLO' Then 'Large'  Else 'Light'  End

 ) AS RESERVE_GROUP, SalesDataReport.JRNL_DATE AS JRNL_DATE, SalesDataReport.JRNL_YEAR AS 
JRNL_YEAR, SalesDataReport.JRNL_MONTH AS JRNL_MONTH, SalesDataReport.JRNL_YEAR_MONTH AS 
JRNL_YEAR_MONTH, SalesDataReport.JRNL_ID AS JRNL_ID, SalesDataReport.CURRENCY AS CURRENCY, ( Case 
When SalesDataReport.COUNTRY_INDICATOR ='CAD' Then  'CAN' Else  'USA' End  ) AS COUNTRY_INDICATOR, 
SalesDataReport.Query_source AS Query_source, SalesDataReport.REVENUE_AMOUNT_DEC AS 
REVENUE_AMOUNT_DEC

FROM 
"InformationObjects/WarrantyConcessionIO/Information Objects/SalesDataReport.iob" AS SalesDataReport

WHERE :?Case_When_SalesDataReport_COUNTRY_INDICATOR_CAD_Then__CAN_Else__USA_End_
AND SalesDataReport.JRNL_DATE >=:prmBegin_Trx_Date
AND SalesDataReport.JRNL_DATE <=:prmEnd_Trx_Date

ORDER BY COUNTRY_INDICATOR Asc, JRNL_YEAR Asc, JRNL_MONTH Asc, RESERVE_GROUP Asc