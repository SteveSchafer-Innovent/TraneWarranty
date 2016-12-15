SELECT
		TRX_YEAR,
		TRX_MONTH,
		CLAIM_TYPE,
		warranty_duration,
		SUM(ROUND(EXPENSE_AMOUNT,2)),
		sum(in_reserve_percent) 
	FROM
		IOB_WC_WEXP
	WHERE
		TRX_YEAR > 2008
	GROUP BY
		TRX_YEAR,
		TRX_MONTH,
		CLAIM_TYPE,
		warranty_duration
	ORDER BY 1,2,3;
	
	
	SELECT
		TRX_YEAR,
		TRX_MONTH,
		CLAIM_TYPE,
		warranty_duration,
		SUM(ROUND(EXPENSE_AMOUNT,2)),
		sum(in_reserve_percent) 
	FROM
		map_warranty_expense_data_ss
	WHERE
		TRX_YEAR > 2008
	GROUP BY
		TRX_YEAR,
		TRX_MONTH,
		CLAIM_TYPE,
		warranty_duration
	ORDER BY 1,2,3;
	
select CLAIM_NUMBER, STEP_NUMBER, BUSINESS_UNIT, RESERVE_GROUP, CLAIM_TYPE, EXPENSE_AMOUNT, EXPENSE_AMOUNT_DEC, MATERIAL_LABOR, GL_ACCOUNT, EXPENSE_TYPE_DESCR, OFFICE_NAME, GL_PROD_CODE, MANF_PROD_CODE, COMPANY_OWNED, CUSTOMER_NUMBER, CUSTOMER_NAME, INTERNAL_EXTERNAL, TRX_DATE, TRX_YEAR, TRX_MONTH, INTMONTHS_TRX_TO_BASE, INTMONTHS_SHIP_TO_BASE, SHIP_DATE, SHIP_YEAR_MONTH, INTMONTHS_SHIP_TO_TRX, START_DATE, INTMONTHS_START_TO_TRX, FAIL_DATE, INTMONTHS_FAIL_TO_TRX, WARRANTY_TYPE, WARRANTY_DURATION, CURRENCY, COUNTRY_INDICATOR, RETROFIT_ID, IN_RESERVE_PERCENT, IN_RESERVE_PERCENT_25, TRX_LAG, START_LAG_25, TRXYEARMONTH, EXPENSE_AMT_IN_RES, EXPENSE_AMT_NOT_IN_RES
from map_warranty_expense_data_ss where trx_year = 2016 and trx_month = 10 -- and manf_prod_code = '64'	
minus
select CLAIM_NUMBER, STEP_NUMBER, BUSINESS_UNIT, RESERVE_GROUP, CLAIM_TYPE, EXPENSE_AMOUNT, EXPENSE_AMOUNT_DEC, MATERIAL_LABOR, GL_ACCOUNT, EXPENSE_TYPE_DESCR, OFFICE_NAME, GL_PROD_CODE, MANF_PROD_CODE, COMPANY_OWNED, CUSTOMER_NUMBER, CUSTOMER_NAME, INTERNAL_EXTERNAL, TRX_DATE, TRX_YEAR, TRX_MONTH, INTMONTHS_TRX_TO_BASE, INTMONTHS_SHIP_TO_BASE, SHIP_DATE, SHIP_YEAR_MONTH, INTMONTHS_SHIP_TO_TRX, START_DATE, INTMONTHS_START_TO_TRX, FAIL_DATE, INTMONTHS_FAIL_TO_TRX, WARRANTY_TYPE, WARRANTY_DURATION, CURRENCY, COUNTRY_INDICATOR, RETROFIT_ID, IN_RESERVE_PERCENT, IN_RESERVE_PERCENT_25, TRX_LAG, START_LAG_25, TRXYEARMONTH, EXPENSE_AMT_IN_RES, EXPENSE_AMT_NOT_IN_RES
from map_warranty_expense_data where trx_year = 2016 and trx_month = 10;

select * from map_warranty_expense_data
where claim_number = 8813444	and step_number = 15671960
;
	
select 200903 from dual
union all
select distinct trxyearmonth
from iob_wc_wexp 
order by 1;

select * from iob_wc_wexp;


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

select manf_prod_code, count(*)
from PROD_CODE_XREF_RCPO_DR
where gl_ledger in ('CSD','CAN')
group by manf_prod_code
having count(*) = 1
;

select * 
from prod_code_xref_rcpo_dr
where manf_prod_code in ('64','153','154','156','158','185','217','254','255','278','290','346','347','354','357','382','419','426','427','474','491','518','536','635','664','703','705','895','898','1009','1010','1109','1150','1164','1250','1254','5283')
order by 2;