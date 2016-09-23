/* SR: NOT USED ANY PLACE 
	Query is probably not corrected as LAG table does is not bound to other queries.
	In addition LAG query is DWT, but OTR_TRANE_ACCOUNTS_PS is in DRT
	
*/

select DISTINCT GLA.R12_ACCOUNT /* -SS- ACCOUNT */,
(
	CASE
	WHEN GLA.R12_ENTITY NOT IN ('5773', '5588') /* -SS- ASX.NATION_CURR='USD' */ THEN 'USA'
	ELSE 'CAN'
	/* -SS-
	WHEN ASX.NATION_CURR='CAD' THEN 'CAN' 
	ELSE 'CURRENCY: ' || ASX.NATION_CURR 
	*/
	END
) AS COUNTRY_INDICATOR
,PSA.descr as description
,lag.report_type
,cast(lag.trx_lag as integer)as trx_lag
,LAG.FACTOR
from R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
,R12_GL_ACCOUNT_SCD /* -SS- */ GLA
-- -SS- ,ACTUATE_SEC_XREF ASX
,sy_ext_lag_rules_upd Lag
WHERE
 GLA.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */ (+)
-- -SS- AND GLA.COMPANY=(CASE WHEN ASX.PSGL IS NULL  THEN GLA.COMPANY ELSE ASX.PSGL END ) 
AND PSA.TRANE_ACCOUNT_IND='X'
AND GLA.R12_ACCOUNT /* -SS- ACCOUNT */ IN  (
	'523500' /* -SS- ???? */,
	'526892' /* -SS- ???? */,
	'526893' /* -SS- ???? */,
	'528100' /* -SS- ???? */,
	'528200' /* -SS- ???? */,
	'528300' /* -SS- ???? */,
	'532100' /* -SS- ???? */)
and lag.report_type ='2-16'
--AND CASE WHEN ASX.NATION_CURR='USD' THEN 'USA'WHEN ASX.NATION_CURR='CAD' THEN 'CAN' ELSE 'CURRENCY: ' ||ASX.NATION_CURR END ='CAN'

--select report_type, cast(trx_lag as number(12)) trx_lag, factor,
--case when REPORT_TYPE ='1-15' then '523500'  end as account,
--case when REPORT_TYPE ='1-15' then 'USA'  end AS  COUNTRY_INDICATOR,
--case when REPORT_TYPE ='1-15' THEN '1st Year Labor Warr' END  DESCRIPTION
-- from sy_ext_lag_rules_upd