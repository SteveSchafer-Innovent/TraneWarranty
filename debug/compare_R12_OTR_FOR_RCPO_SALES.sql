Select a.jrnl_date, a.revenue_amount otr_amt, b.revenue_amount r12_amt, a.revenue_amount - b.revenue_amount diff 
from 
(
SELECT
	/* 'RCPO' Source Query */
	sum(abs(PS.ORDER_AMOUNT)) * - 1 AS REVENUE_AMOUNT,
	jrnl_date,
	-- NVL(AOL.NATION_CURR, PS.CURRENCY_CODE) AS COUNTRY_INDICATOR,
	'otr'
FROM
	OTR_ORACLE_PS_REV_RCPO PS 
	left outer join ACTUATE_OFFICE_LOCATION AOL on PS.GL_DPT_ID = AOL.DEPT_ID  AND PS.GL_BU_ID = AOL.BU_UNIT
WHERE 0=0
	and AOL.NATION_CURR = 'USD'
	and JRNL_DATE > '01-oct-16'
	group by jrnl_date
) a
left outer join (
SELECT /*+ NO_CPU_COSTING */
	sum(abs(PS.ORDER_AMOUNT)) * -1 AS REVENUE_AMOUNT,
	PS.JRNL_DATE AS JRNL_DATE,
	'r12'
	FROM
		R12_ORACLE_PS_REV_RCPO PS
	WHERE
		JRNL_DATE > '01-oct-16'
		and PS.R12_ENTITY IN('5575', '5612', '5743', '9256', '9258', '9298', '9299')
	group by jrnl_date
) b on b.jrnl_date = a.jrnl_date
order by 1
;

select a.country_indicator, A.Ship_Period, A.Revenue_Amt, B.REVENUE_AMT, A.REVENUE_AMT-B.REVENUE_AMT DIFF
from DBO.SY_031_SALES_SUM_STG a
LEFT OUTER join (

		SELECT
				JRNL_YEAR_MONTH AS SHIP_PERIOD,
				COUNTRY_INDICATOR,
				NVL(SUM(REVENUE_AMOUNT), 0) AS REVENUE_AMT
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
				WHERE
					JRNL_DATE BETWEEN TRUNC(ADD_MONTHS(SYSDATE, - 24), 'MM') AND TRUNC(ADD_MONTHS(LAST_DAY(SYSDATE), - 1))
				GROUP BY
					CAST(TO_CHAR(JRNL_DATE, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(JRNL_DATE, 'MM') AS INTEGER),
					COUNTRY_INDICATOR
			)
			GROUP BY
				JRNL_YEAR_MONTH,
				COUNTRY_INDICATOR

) B ON B.SHIP_PERIOD = A.SHIP_PERIOD AND B.COUNTRY_INDICATOR=A.COUNTRY_INDICATOR
ORDER BY COUNTRY_INDICATOR, SHIP_PERIOD
;
	select b.country_indicator, B.Jrnl_Year_Month, sum(B.Revenue_Amount)
	from map_sales_data b
	where jrnl_year_month > 201502
	group by b.country_indicator, B.Gl_Account,B.Jrnl_Year_Month
;
	
