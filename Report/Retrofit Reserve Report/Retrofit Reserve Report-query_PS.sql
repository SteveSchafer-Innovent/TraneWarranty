select  /* Retrofit Reserve Report Qry */
CASE WHEN RSV.COUNTRY_INDICATOR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR,
CASE WHEN :SCHDATE = 'Use Entered Dates' THEN upper (to_char(to_date(to_char (RSV.RUN_PERIOD ),'yyyy/mm'),'Mon-yy'))
ELSE UPPER(to_char(trunc(sysdate),'Mon-yy')) end  as RUN_PERIOD,
RSV.SHIP_PERIOD,
RSV.CLAIM_AMT,
RSV.SALES_AMT,
RSV.CALCULATED_RATE,
RSV.WEIGHTED_AVG_RATE,
RSV.REMAINING_PDS,
RSV.REMAINING_PDS_FACTOR,
RSV.RESERVE_CALC_AMT,RSV.COUNTRY_INDICATOR
from DBO.DM_031_RETROFIT_RSV RSV 

WHERE RSV.COUNTRY_INDICATOR= DECODE (UPPER(:COUNTRY),'USA','USD','CAN','CAD')
AND CASE WHEN :SCHDATE = 'Use Entered Dates' THEN upper(to_char(to_date(to_char (RSV.RUN_PERIOD ),'yyyy/mm'),'Mon-yy')) ELSE upper(to_char(to_date(to_char (RSV.RUN_PERIOD ),'yyyy/mm'),'Mon-yy')) END =  CASE WHEN :SCHDATE = 'Use Entered Dates' THEN upper(:RUN_DATE) ELSE UPPER(to_char(trunc(sysdate),'Mon-yy')) END

ORDER BY RSV.SHIP_PERIOD