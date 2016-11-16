/* There is no cache table for MAP SALES DATA in TEST, we use table direct
	So the comparison is between the PROD cache table IOB_WC_MAPSL
	and the MAP_SALES_DATA table.
*/

select COUNTRY_INDICATOR, query_source, jrnl_year, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from IOB_WC_MAPSL
group by COUNTRY_INDICATOR, query_source, jrnl_year order by 2,1,3;


-- actu queries
select query_source, jrnl_year, jrnl_month, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from IOB_WC_MAPSL
where query_source = 'P21'
and jrnl_year = 2016
group by query_source, jrnl_year, jrnl_month order by 2,1;

select query_source, jrnl_year, jrnl_month, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from IOB_WC_MAPSL
group by query_source, jrnl_year, jrnl_month order by 2,1,3;


-- DRT queries
select query_source, jrnl_year, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from map_sales_data
group by query_source, jrnl_year order by 2,1;

select query_source, jrnl_year, jrnl_month, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from map_sales_data
group by query_source, jrnl_year, jrnl_month order by 2,1,3;


select query_source, jrnl_year, jrnl_month, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from map_sales_data 
where query_source = 'P21'
and jrnl_year = 2016
group by query_source, jrnl_year, jrnl_month order by 2,1;

select query_source, jrnl_year, jrnl_month, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from map_sales_data
-- where query_source = 'P21'
-- and jrnl_year = 2016
group by query_source, jrnl_year, jrnl_month order by 2,1,3;

-- should match
select COUNTRY_INDICATOR, query_source, jrnl_year, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from IOB_WC_MAPSL
group by COUNTRY_INDICATOR, query_source, jrnl_year order by 2,1,3;
select COUNTRY_INDICATOR, query_source, jrnl_year, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from MAP_SALES_DATA
group by COUNTRY_INDICATOR, query_source, jrnl_year order by 2,1,3;

-- pueblo for 2016
select COUNTRY_INDICATOR, query_source, jrnl_year, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from IOB_WC_MAPSL
where query_source = 'PUEBLO' and jrnl_year = 2016
group by COUNTRY_INDICATOR, query_source, jrnl_year order by 2,1,3;
select COUNTRY_INDICATOR, query_source, jrnl_year, sum(round(revenue_amount,2)), sum(round(revenue_amount_dec,2))
from MAP_SALES_DATA
where query_source = 'PUEBLO' and jrnl_year = 2016
group by COUNTRY_INDICATOR, query_source, jrnl_year order by 2,1,3;