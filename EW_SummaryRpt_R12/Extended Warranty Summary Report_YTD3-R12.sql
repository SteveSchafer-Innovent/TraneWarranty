-- 139.561 sec USA/JAN-16 (R12: 166.198)
-- 140.703 sec CAN/JAN-16 (R12: 156.934)
SELECT   /* Comm detail Dollar Amt*/
 TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  as gl_BeginDate,
 LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
 case when a.COUNTRY_INDICATOR is null then b.COUNTRY_INDICATOR  else a.COUNTRY_INDICATOR end as COUNTRY_INDICATOR   ,
 case when a.GL_ACCOUNT is null then b.account else a.GL_ACCOUNT end as GL_ACCOUNT ,
 NVL(a.DOLLAR_AMOUNT,0)DOLLAR_AMOUNT,
 case when B.GL_ACC_DESCR is null then a.GL_ACC_DESCR  else b.GL_ACC_DESCR  end  as GL_ACC_DESCR,
 nvl(B.Amort_Comm_and_prepaid_comm,0) AS Amort_Comm_and_prepaid_comm,
 nvl(B.SHORT_TERM_COMM,0) AS SHORT_TERM_COMM,
 nvl(B.LONG_TERM_COMM,0)  AS LONG_TERM_COMM
from (SELECT   /*+ NO_CPU_COSTING */
       TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  as gl_BeginDate,
       LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
/*TAY:       CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR,*/
       CASE WHEN DIST.r12_entity IN (5773, 5588) THEN 'CAN' ELSE 'USA' END AS COUNTRY_INDICATOR,
--TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
/*TAY:       DIST.ACCOUNT AS GL_ACCOUNT,*/
       DIST.PS_ACCOUNT AS GL_ACCOUNT,
--DIST.JOURNAL_DATE AS JOURNAL_DATE ,
       SUM(Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end ) AS DOLLAR_AMOUNT,
       psa.DESCR as GL_ACC_DESCR,
       0 AS Amort_Comm_and_prepaid_comm,
       0 AS SHORT_TERM_COMM,
       0  AS LONG_TERM_COMM
/*TAY:      FROM dbo.otr_trnco_cm_dist_psb dist, dbo.otr_TRANE_ACCOUNTS_ps psa, dbo.ACTUATE_SEC_XREF ASX*/
      FROM dbo.R12_TRNCO_CM_DIST_PSB Dist, dbo.R12_TRANE_ACCOUNTS_PS psa --, dbo.ACTUATE_SEC_XREF ASX
/*TAY:      WHERE DIST.ACCOUNT = PSA.ACCOUNT*/
      WHERE DIST.R12_ACCOUNT = PSA.R12_ACCOUNT
        AND PSA.TRANE_ACCOUNT_IND='X'
/*TAY:        AND DIST.BUSINESS_UNIT_GL = ASX.PSGL*/
        --AND DIST.BUSINESS_UNIT_GL = ASX.PSGL
        AND DIST.JOURNAL_DATE BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') AND LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy'))
/*TAY:        AND DIST.ACCOUNT LIKE '5%' WIP*/
        AND DIST.PS_ACCOUNT LIKE '5%'
/*TAY:        and CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)*/
        and CASE WHEN DIST.r12_entity IN (5773, 5588) THEN 'CAN' ELSE 'USA' END = UPPER(:COUNTRY)
/*TAY:        and ASX.NATION_CURR = 'USD' WIP*/ -- Not sure this is correct way to implement
        and DIST.r12_entity NOT IN (5773, 5588)
/*TAY:        and (dist.deptid IS NULL OR (dist.deptid = 'SL00'))*/
        and (dist.PS_deptid IS NULL OR (dist.PS_deptid = 'SL00'))
/*TAY:      GROUP BY CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END, DIST.ACCOUNT, psa.DESCR*/
      GROUP BY CASE WHEN DIST.r12_entity IN (5773, 5588) THEN 'CAN' ELSE 'USA' END, DIST.PS_ACCOUNT, psa.DESCR
      UNION ALL
      SELECT /*+ NO_CPU_COSTING */
       TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  as gl_BeginDate,
       LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
/*TAY:       CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR,*/
       CASE WHEN DIST.r12_entity IN (5773, 5588) THEN 'CAN' ELSE 'USA' END AS COUNTRY_INDICATOR,
--TO_CHAR(dist.journal_date,'YYYYMM')AS JRNL_YEAR_MONTH,
/*TAY:       DIST.ACCOUNT AS GL_ACCOUNT, WIP*/
       DIST.PS_ACCOUNT AS GL_ACCOUNT,
       sum(Case when dist.debit_amt =0 or dist.debit_amt is null or dist.credit_amount<>''then dist.credit_amount*-1 else dist.debit_amt end  )AS DOLLAR_AMOUNT,
       psa.DESCR as GL_ACC_DESCR,
       0 AS Amort_Comm_and_prepaid_comm,
       0 AS SHORT_TERM_COMM,
       0  AS LONG_TERM_COMM
/*TAY:      FROM dbo.otr_trnco_cm_dist_psb dist, dbo.otr_TRANE_ACCOUNTS_ps psa, dbo.ACTUATE_SEC_XREF ASX*/
      FROM dbo.R12_TRNCO_CM_DIST_PSB dist, dbo.R12_TRANE_ACCOUNTS_PS psa --, dbo.ACTUATE_SEC_XREF ASX
/*TAY:      WHERE DIST.ACCOUNT = PSA.ACCOUNT*/
      WHERE DIST.R12_ACCOUNT = PSA.R12_ACCOUNT
        AND PSA.TRANE_ACCOUNT_IND='X'
/*TAY:        AND DIST.BUSINESS_UNIT_GL= ASX.PSGL*/
        --AND DIST.BUSINESS_UNIT_GL= ASX.PSGL
        AND DIST.JOURNAL_DATE BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')   AND LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy'))
/*TAY:        AND DIST.ACCOUNT LIKE '5%' WIP*/
        AND DIST.PS_ACCOUNT LIKE '5%'
/*TAY:        and  CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY)*/
        and CASE WHEN DIST.r12_entity IN (5773, 5588) THEN 'CAN' ELSE 'USA' END = UPPER(:COUNTRY)
/*TAY:        and ASX.NATION_CURR = 'CAD' WIP*/ -- Not sure that this is the right way to get the same effect
        and DIST.r12_entity IN (5773, 5588)
/*TAY:        and ( dist.deptid IS NULL OR (dist.deptid = 'TCA0') OR (dist.deptid = 'SL00') ) WIP*/
        and ( dist.PS_deptid IS NULL OR (dist.PS_deptid = 'TCA0') OR (dist.PS_deptid = 'SL00') )
/*TAY:       GROUP BY CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END, DIST.ACCOUNT, psa.DESCR*/
       GROUP BY CASE WHEN DIST.r12_entity IN (5773, 5588) THEN 'CAN' ELSE 'USA' END, DIST.PS_ACCOUNT, psa.DESCR
     ) a,
     (/* Amort_Comm_and_prepaid_comm_and_long_and_short_term*/
      SELECT /*+ NO_CPU_COSTING */
       TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  as gl_BeginDate,
       LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
       B.country_indicator,
       B.gl_account AS account ,
       0 as DOLLAR_AMOUNT,
       B.GL_ACCOUNT_DESCR as GL_ACC_DESCR ,
       sum(B.Amort_Comm_and_prepaid_comm) AS Amort_Comm_and_prepaid_comm,
       sum(b.SHORT_TERM_COMM) AS SHORT_TERM_COMM,
       SUM(B.LONG_TERM_COMM) AS LONG_TERM_COMM
      FROM (SELECT 
             a.country_indicator,
             a.gl_account,
             A.GL_ACCOUNT_DESCR  AS GL_ACCOUNT_DESCR  ,
             to_date('1-'||:RunDate,'dd-mon-yy'),
             CASE WHEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') = To_date('1-'||:RunDate,'dd-mon-yy')
                  THEN CASE WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate,'dd-mon-yy') 
                            THEN  MAX(a.PREPAID_COMMISSION) ELSE 0 END
                  ELSE (MAX(a.Comm_amort_mnthly)+ CASE WHEN A.FORECAST_PERIOD = to_date('1-'||:RunDate,'dd-mon-yy') 
                                                       THEN  MAX(a.PREPAID_COMMISSION) 
                                                       ELSE 0 END ) END as Amort_Comm_and_prepaid_comm,
             MAX(a.short_term_pp_comm) as SHORT_TERM_COMM,
             MAX(a.long_term_pp_comm) as LONG_TERM_COMM,
             A.forecast_period
/*TAY:             from DM_030_COMM_AMORTIZATION@DW_INTFC_DR.LAX.TRANE.COM a,OTR_TRANE_ACCOUNTS_PS psa*/
            from DW_DM_030_COMM_AMORTIZATION a, R12_TRANE_ACCOUNTS_PS psa
/*TAY:            WHERE a.gl_account = PSA.ACCOUNT (+) WIP*/
            WHERE a.gl_account = PSA.PS_ACCOUNT (+)
              AND PSA.TRANE_ACCOUNT_IND='X'
              and a.country_indicator  = UPPER(:COUNTRY)
              AND a.RUN_PERIOD >= TO_DATE('1-'||UPPER(:RunDate),'dd-mon-yy')
              and  a.RUN_PERIOD<add_months(to_date('1-'||:RunDate,'dd-mon-yy'),1)
/*TAY:               AND a.gl_account like '5%' WIP*/
              AND a.gl_account like '5%'
              AND A.SHIP_PERIOD >= case when to_date('1-'||:RunDate,'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  then  trunc(trunc(to_date('1-'||:RunDate,'dd-mon-yy'),'YEAR') -1 )-30 else   TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  end
              AND A.SHIP_PERIOD <  (to_date('1-'||:RunDate,'dd-mon-yy') )
            GROUP BY a.country_indicator, a.gl_account,A.GL_ACCOUNT_DESCR, A.forecast_period) B
      GROUP BY B.country_indicator, gL_ACCOUNT, B.GL_ACCOUNT_DESCR  
     ) B
WHERE a.GL_ACCOUNT  (+)  = B.ACCOUNT
  AND a.COUNTRY_INDICATOR   (+) = B.COUNTRY_INDICATOR
union
/* Qry to fetch accounts wich does not exist in dbo.otr_trnco_cm_dist_psb dist table */
SELECT  /*+ NO_CPU_COSTING */
 ADD_MONTHS(((LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')))), -1)  as gl_BeginDate,
 LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy')) gl_End_Date,
 ''AS COUNTRY_INDICATOR,
/*TAY: PSA.ACCOUNT AS GL_ACCOUNT,*/
 PSA.PS_ACCOUNT AS GL_ACCOUNT,
--DIST.JOURNAL_DATE AS JOURNAL_DATE ,
 0 AS DOLLAR_AMOUNT,
 PSA.DESCR as GL_ACC_DESCR,
 0 AS Amort_Comm_and_prepaid_comm,
 0 AS SHORT_TERM_COMM,
 0  AS LONG_TERM_COMM
/*TAY:FROM dbo.otr_TRANE_ACCOUNTS_ps psa*/
FROM dbo.R12_TRANE_ACCOUNTS_PS psa
WHERE  PSA.TRANE_ACCOUNT_IND='X'
/*TAY:  AND PSA.ACCOUNT LIKE '5%' WIP*/
  AND PSA.PS_ACCOUNT LIKE '5%'
  and not exists(select 'X'
/*TAY:                  FROM dbo.otr_trnco_cm_dist_psb dist, dbo.ACTUATE_SEC_XREF ASX*/
                  FROM dbo.R12_TRNCO_CM_DIST_PSB dist --, dbo.ACTUATE_SEC_XREF ASX
/*TAY:                  WHERE DIST.ACCOUNT = PSA.ACCOUNT WIP*/
                  WHERE DIST.R12_ACCOUNT = PSA.R12_ACCOUNT
/*TAY:                    AND DIST.BUSINESS_UNIT_GL= ASX.PSGL*/
                    --AND DIST.BUSINESS_UNIT_GL= ASX.PSGL
                   AND DIST.JOURNAL_DATE BETWEEN TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  AND LAST_DAY(to_date('1-'||:RunDate,'dd-mon-yy'))
/*TAY:                    AND DIST.ACCOUNT LIKE '5%' WIP*/
                    AND DIST.PS_ACCOUNT LIKE '5%'
/*TAY                    and CASE WHEN ASX.NATION_CURR ='USD' THEN 'USA' ELSE 'CAN' END = UPPER(:COUNTRY))*/
                    and CASE WHEN DIST.r12_entity IN (5773, 5588) THEN 'CAN' ELSE 'USA' END = UPPER(:COUNTRY))
  and not exists(select 'x' 
/*TAY                 from DM_030_COMM_AMORTIZATION@DW_INTFC_DR.LAX.TRANE.COM a*/
                 from DW_DM_030_COMM_AMORTIZATION a
                 WHERE a.RUN_PERIOD >= TO_DATE('1-'||UPPER(:RunDate),'dd-mon-yy')
                   and a.RUN_PERIOD<add_months(to_date('1-'||:RunDate,'dd-mon-yy'),1)
/*TAY:             AND  a.gl_account= PSA.ACCOUNT WIP*/
                   AND  a.gl_account= PSA.PS_ACCOUNT
                   AND A.SHIP_PERIOD >= case when to_date('1-'||:RunDate,'dd-mon-yy') = TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  then  trunc(trunc(to_date('1-'||:RunDate,'dd-mon-yy'),'YEAR') -1 )-30 else   TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')  end
                   AND A.SHIP_PERIOD <  (to_date('1-'||:RunDate,'dd-mon-yy') )
                   and a.country_indicator  = UPPER(:COUNTRY)
/*TAY:             AND  a.gl_account like '5%' WIP*/
                   AND  a.gl_account like '5%'
                )