/*EW Seasonalized Revenue Release Report 25-66 Months qry*/
select a.*,
a.rec_rev_mnthly +0.000004 as Total_Recognized_Rev,
a.DEFERRED_REVENUE +0.000004 AS Deferred_Revenues,
a.SHORT_TERM_DR +0.000004 as short_term,
a.LONG_TERM_DR +0.000004 as Long_term,
a.REC_REV_PRE_MNTHLY +0.000004 as PreviousTotal_RR,
a.REC_REV_FOR_PERIOD +0.000004 as Recognized_Revenue_Period,
A.FORECAST_YR_TOTAL +0.000004 as Total_Year,
A.REV_RELEASE_TOTAL +0.000004  AS Recognized_Revenue
from DM_030_REV_RELEASE a
where a.country_indicator  IN ('USA','CAN')
AND a.RUN_PERIOD >= to_date('1-'||:RunDate,'dd-mon-yy')
and  a.RUN_PERIOD<add_months(to_date('1-'||:RunDate,'dd-mon-yy'),1)
AND  a.report_type = '25-66'