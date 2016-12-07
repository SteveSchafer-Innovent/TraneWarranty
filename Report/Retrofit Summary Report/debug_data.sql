select * from DM_031_RETROFIT_RSV
where country_indicator = 'USD';

select max(ed_update_date) from DM_031_RETROFIT_RSV;

select distinct country_indicator, run_period  from DM_031_RETROFIT_RSV order by 1,2;

select distinct country_indicator, ship_period  from DM_031_RETROFIT_RSV order by 1,2;

select distinct country_indicator, run_period  from DM_031_RETROFIT_RSV order by 1,2;

select country_indicator, min(Rr.Ship_Period), max(Ship_Period) 
from DM_031_RETROFIT_RSV rr
where Run_Period = 201611
group by country_indicator
order by 1,2;