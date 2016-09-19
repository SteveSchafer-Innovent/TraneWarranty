WITH (Country Varchar) 

SELECT SeasonalizationReportData.COUNTRY AS COUNTRY, SeasonalizationReportData.TRX_YEAR AS 
TRX_YEAR, SeasonalizationReportData.TRX_MONTH AS TRX_MONTH, 
SeasonalizationReportData.EXPENSE_SUM_MONTH_YEAR AS EXPENSE_SUM_MONTH_YEAR

FROM 
"InformationObjects/ExtendedWarranty/Information Objects/SeasonalizationReportData.iob"[:Country] 
AS SeasonalizationReportData