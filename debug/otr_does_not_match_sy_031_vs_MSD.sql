		SELECT
				msd.JRNL_YEAR_MONTH AS SHIP_PERIOD,
				msd.COUNTRY_INDICATOR,
				msd.REVENUE_AMOUNT AS REVENUE_AMT,
				sy.revenue_amt rev_amt
			FROM
			(
					SELECT
					CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER) JRNL_YEAR_MONTH,
					COUNTRY_INDICATOR,
					-- For PUEBLO data, leave sign as is. Reverse the sign for all other values.      
					SUM(case when query_source = 'PUEBLO' 
						then REVENUE_AMOUNT
						else revenue_amount * -1
					end) as revenue_amount
				FROM
					MAP_SALES_DATA
				WHERE 0=0
					-- and JRNL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE, - 24), 'MM') AND TRUNC(ADD_MONTHS(LAST_DAY(SYSDATE), - 1))
					-- and CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER) = 201702
				GROUP BY
					CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER),
					COUNTRY_INDICATOR

			) msd
			inner join (
				select Sy_031_Sales_Sum_Stg.Country_Indicator, Sy_031_Sales_Sum_Stg.Revenue_Amt, Sy_031_Sales_Sum_Stg.Ship_Period
				from sy_031_sales_sum_stg
			) sy on sy.ship_period = msd.JRNL_YEAR_MONTH and sy.country_indicator = msd.country_indicator
;