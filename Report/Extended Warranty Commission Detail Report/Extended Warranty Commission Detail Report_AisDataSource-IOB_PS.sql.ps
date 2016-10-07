 
WITH (prmBegin_Trx_Date Timestamp, prmEnd_Trx_Date Timestamp, country varchar) 

SELECT 
( ExtendedSalesDataReport.COUNTRY_INDICATOR   ) AS COUNTRY_INDICATOR,
ExtendedSalesDataReport.JRNL_YEAR_MONTH AS JRNL_YEAR_MONTH,
ExtendedSalesDataReport.BU AS BU, 
ExtendedSalesDataReport.GL_ACCOUNT AS GL_ACCOUNT,
ExtendedSalesDataReport.GL_DEP_ID AS DEPT_ID,
ExtendedSalesDataReport.Query_source AS Query_source,
ExtendedSalesDataReport.GL_PRODUCT_ID AS GL_PRODUCT_ID, 
ExtendedSalesDataReport.JOURNAL_DATE AS JOURNAL_DATE, 
ExtendedSalesDataReport.JOURNAL_ID AS JOURNAL_ID,
ExtendedSalesDataReport.dollar_AMOUNT AS REVENUE_AMOUNT, 
ExtendedSalesDataReport.dollar_AMOUNT_DEC AS REVENUE_AMOUNT_DEC


FROM 
"InformationObjects/ExtendedWarranty/Information Objects/ExtendedCommissionReportData.iob"  AS ExtendedSalesDataReport

WHERE  ExtendedSalesDataReport.COUNTRY_INDICATOR= :country
AND  ExtendedSalesDataReport.JOURNAL_DATE  >=:prmBegin_Trx_Date
AND ExtendedSalesDataReport.JOURNAL_DATE   <=:prmEnd_Trx_Date
ORDER BY COUNTRY_INDICATOR asc, GL_ACCOUNT asc ,JOURNAL_DATE asc
--and ( ExtendedSalesDataReport.GL_DEP_ID is null or ( ExtendedSalesDataReport.GL_DEP_ID ='SL00' ))
--AND ((ExtendedSalesDataReport.GL_DEP_ID = (CASE when ExtendedSalesDataReport.COUNTRY_INDICATOR  IN ('CAN','USA') then   'SL00' end))  OR (ExtendedSalesDataReport.GL_DEP_ID =(CASE when ExtendedSalesDataReport.COUNTRY_INDICATOR ='CAN' then   'TCA0' end)) or ( ExtendedSalesDataReport.GL_DEP_ID IS NULL ))  
