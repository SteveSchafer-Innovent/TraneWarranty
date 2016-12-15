select count(*) from iob_25_wrrc68;
select a.* 
from Iob_25_Wrrc68 a 
-- where A."revenue_amount" > 0 
order by 1, 2, 3, 4;

select * from Iob_25_Wrrc68 a
where A.Ship_Row = 85
and A.Trx_Column = 83
and A.Country_Indicator = 'USA';