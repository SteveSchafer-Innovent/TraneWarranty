WITH (prmReserveGroup Varchar, Country Varchar) 

SELECT WarrantyActualProjectRate.COUNTRY_INDICATOR AS COUNTRY_INDICATOR, 
WarrantyActualProjectRate.RESERVE_GROUP AS RESERVE_GROUP, WarrantyActualProjectRate.SHIP_ROW AS 
SHIP_ROW, WarrantyActualProjectRate.JRNL_YEAR_MONTH AS JRNL_YEAR_MONTH, 
WarrantyActualProjectRate.REVENUE_AMOUNT AS REVENUE_AMOUNT, WarrantyActualProjectRate.TRX_COLUMN AS 
TRX_COLUMN, WarrantyActualProjectRate.Expense_Rate AS Expense_Rate, 
WarrantyActualProjectRate.EXPENSE_AMOUNT AS EXPENSE_AMOUNT

FROM 
"InformationObjects/WarrantyConcessionIO/Information Objects/WarrantyActualProjectRate.iob"[:Country, 
:prmReserveGroup] AS WarrantyActualProjectRate