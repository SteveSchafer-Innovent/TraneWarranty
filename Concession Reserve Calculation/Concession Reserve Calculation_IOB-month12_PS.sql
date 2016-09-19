WITH (Country Varchar) 

SELECT ConcessionActualProjectRate.COUNTRY_INDICATOR AS COUNTRY_INDICATOR, 
ConcessionActualProjectRate.SHIP_ROW AS SHIP_ROW, ConcessionActualProjectRate.JRNL_YEAR_MONTH AS 
JRNL_YEAR_MONTH, ConcessionActualProjectRate.REVENUE_AMOUNT AS REVENUE_AMOUNT, 
ConcessionActualProjectRate.TRX_COLUMN AS TRX_COLUMN, ConcessionActualProjectRate.Expense_Rate AS 
Expense_Rate, ConcessionActualProjectRate.EXPENSE_AMOUNT AS EXPENSE_AMOUNT

FROM 
"InformationObjects/WarrantyConcessionIO/Information Objects/ConcessionActualProjectRate.iob"[:Country] 
AS ConcessionActualProjectRate