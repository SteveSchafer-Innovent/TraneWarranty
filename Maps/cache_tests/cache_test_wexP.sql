SELECT
		TRX_YEAR,
		TRX_MONTH,
		CLAIM_TYPE,
		SUM(ROUND(EXPENSE_AMOUNT,2))
	FROM
		IOB_WC_WEXP
	WHERE
		TRX_YEAR > 2008
	GROUP BY
		TRX_YEAR,
		TRX_MONTH,
		CLAIM_TYPE
	ORDER BY 1,2,3;
	
	select *
from iob_25_wrrc68 
where jrnl_year_month > 201500
order by jrnl_year_month desc, 1;

select country_indicator, jrnl_year_month, months_from_base, sum(round(revenue_amount,2)) rev
from IOB_25_WSMT68
group by country_indicator, jrnl_year_month, months_from_base
order by 1,2,3,4;

SELECT
		COUNTRY_INDICATOR,
		SHIP_ROW,
		TRX_COLUMN,
		ROW_PLUS_COLUMN,
		REVENUE_AMOUNT,
		JRNL_YEAR_MONTH
	FROM
		IOB_25_WRRC68 
	where rowNum < 10;
	
-- MAP_EXPENSEWARRANTYDATA68_VW
SELECT
		claim_number,
		count(*)
	FROM
		IOB_WC_WEXP
	WHERE TRX_YEAR > 2014
	and TRX_MONTH = 9
	and CLAIM_TYPE = 'MATERIAL'
	group by claim_number
	ORDER BY 1;
	
	
select * from iob_WC_WEXP where claim_type = 'SPD' and rownum < 100 and trx_year = 2016;
select distinct trx_year from iob_WC_WEXP where claim_type = 'SPD';
select distinct trx_year from iob_WC_CEXP where claim_type = 'SPD';

select * from iob_WC_CEXP where claim_number = '9352074';

/*
9144282
9144285
9144286
9144299
9147049
*/