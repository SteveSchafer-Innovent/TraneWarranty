		SELECT
				JRNL_YEAR_MONTH AS SHIP_PERIOD,
				COUNTRY_INDICATOR,
				query_source,
				NVL(SUM(REVENUE_AMOUNT), 0) AS REVENUE_AMT
			FROM
			(
					SELECT
					CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER) JRNL_YEAR_MONTH,
					COUNTRY_INDICATOR,
					Map_Sales_Data.Query_Source,
					-- For PUEBLO data, leave sign as is. Reverse the sign for all other values.      
					SUM(case when query_source = 'PUEBLO' 
						then REVENUE_AMOUNT
						else revenue_amount * -1
					end) as revenue_amount
				FROM
					MAP_SALES_DATA
				WHERE 0=0
					-- and JRNL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE, - 24), 'MM') AND TRUNC(ADD_MONTHS(LAST_DAY(SYSDATE), - 1))
					and CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER) = 201702
				GROUP BY
					CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER),
					COUNTRY_INDICATOR,
					Map_Sales_Data.Query_Source

			)
			GROUP BY
				JRNL_YEAR_MONTH,
				COUNTRY_INDICATOR,
				query_source