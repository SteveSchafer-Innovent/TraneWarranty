/*EW Commission Amortization Report 16-126 qry*/
select /*+ INDEX_FFS ( A XIE1DM_030_COMM_AMORTIZATION) */  a.*,
a.Comm_amort_mnthly +0.000004 as Total_AM_Comm,
a.PREPAID_COMMISSION +0.000004 AS PrepaidComm,
a.short_term_pp_comm +0.000004 as short_term,
a.long_term_pp_comm +0.000004 as Long_term,
a.Comm_amort_prev_mnthly +0.000004 as PreviousTotal_AM_COMM,
a.Comm_amort_for_period +0.000004 as Am_comm_Period,
A.FORECAST_YR_TOTAL +0.000004 as Total_Year,
A.Comm_amort_total +0.000004  AS AM_Comm
from DM_030_COMM_AMORTIZATION a
where a.country_indicator  IN ('USA','CAN')
AND TO_CHAR(a.RUN_PERIOD,'MON-YY') = UPPER(:RunDate)
AND  a.report_type = '16-126'