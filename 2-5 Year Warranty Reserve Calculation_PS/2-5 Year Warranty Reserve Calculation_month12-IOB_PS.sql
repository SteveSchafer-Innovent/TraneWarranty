WITH (Country Varchar) 

SELECT WarrantyActualProjectRate68.COUNTRY_INDICATOR AS COUNTRY_INDICATOR, 
WarrantyActualProjectRate68.SHIP_ROW AS SHIP_ROW, WarrantyActualProjectRate68.JRNL_YEAR_MONTH AS 
JRNL_YEAR_MONTH, WarrantyActualProjectRate68.REVENUE_AMOUNT AS REVENUE_AMOUNT, 
WarrantyActualProjectRate68.TRX_COLUMN AS TRX_COLUMN, WarrantyActualProjectRate68.Expense_Rate AS 
Expense_Rate, WarrantyActualProjectRate68.EXPENSE_AMOUNT AS EXPENSE_AMOUNT, 
WarrantyActualProjectRate68.TrxFilter AS TrxFilter

FROM 
"InformationObjects/2-5 Year Standard Warranty/Information Objects/WarrantyActualProjectRate68.iob"[:Country] 
AS WarrantyActualProjectRate68