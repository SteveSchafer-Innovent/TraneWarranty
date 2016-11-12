select '1_25_MSD68', count(*) from IOB_25_MSD68;
select '1_25_MSD68', count(*) from IOB_25_MSD68 union all
select '2_25_RC79', count(*) from IOB_25_RC79 union all
select '3_25_WEXD68', count(*) from IOB_25_WEXD68 union all
select '3_25_WSMT68', count(*) from IOB_25_WSMT68 union all
select '3_25_WRRC68', count(*) from IOB_25_WRRC68 union all

-- select '1_IOB_WC_MAPSL', count(*) from IOB_WC_MAPSL union all
select '2_IOB_WC_CEXP', count(*) from IOB_WC_CEXP union all
select '3_IOB_WC_WEXP', count(*) from IOB_WC_WEXP union all
select '4_IOB_WC_RC66', count(*) from IOB_WC_RC66 union all
select '5_IOB_WC_CSMT', count(*) from IOB_WC_CSMT union all
select '6_IOB_WC_WSMT', count(*) from IOB_WC_WSMT union all
select '7_IOB_WC_CRRC', count(*) from IOB_WC_CRRC union all
select '8_IOB_WC_WRRC', count(*) from IOB_WC_WRRC;

desc IOB_25_WRRC68;

/*
truncate table IOB_25_MSD68 drop storage;
truncate table IOB_25_RC79 drop storage;
truncate table IOB_25_WEXD68 drop storage;
truncate table IOB_25_WSMT68 drop storage;
truncate table IOB_25_WRRC68 drop storage;
truncate table IOB_WC_CEXP drop storage;
truncate table IOB_WC_WEXP drop storage;
truncate table IOB_WC_RC66 drop storage;
truncate table IOB_WC_CSMT drop storage;
truncate table IOB_WC_WSMT drop storage;
truncate table IOB_WC_CRRC drop storage;
truncate table IOB_WC_WRRC drop storage;
*/


select query_source, jrnl_year, round(sum(revenue_amount),6), round(sum(revenue_amount_dec),6)
from iob_25_MSD68 
-- where query_source = 'RCPO' 
group by query_source, jrnl_year order by 2,1;

select jrnl_year, sum(revenue_amount), sum(revenue_amount_dec) from iob_25_MSD68_2 group by jrnl_year order by 1;

select query_source, count(*) from IOB_25_MSD68 group by query_source order by 1;
select query_source, count(*) from IOB_25_MSD68 group by query_source order by 1;

create table IOB_25_MSD68_back as Select * from IOB_25_MSD68;

select count(*) from dbo.map_warranty_expense_data;
