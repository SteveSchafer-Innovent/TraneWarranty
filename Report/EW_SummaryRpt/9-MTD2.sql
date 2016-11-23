/* EXTENDED WARRANTY MTD QUERY  MTD2*/
SELECT
  /*+ FIRST_ROWS */
  ADD_MONTHS((LAST_DAY(to_date('1-'
  ||:RunDate,'dd-mon-yy'))), -1) AS gl_BeginDate,
  LAST_DAY(to_date('1-'
  ||:RunDate,'dd-mon-yy')) gl_End_Date,
  begbalances.COUNTRY_INDICATOR AS COUNTRY_INDICATOR,
  CAST(begbalances.ACCOUNT AS NUMBER)ACCOUNT,
  NVL(begbalances.begbal_base,0) AS Begning_Balance,
  NVL(endingbalances.EndBal_base,0) AS END_Blance
FROM
  (
  /* Begning Balance DRTRNP */
  SELECT  /*+ NO_CPU_COSTING */     Cross_Ref.PeopleSoft_ac AS ACCOUNT,
    gl_ledgers.ledger_id         AS ledger,
    gl_balances.period_name      AS fiscal_year,  
    CASE
      WHEN gl_ledgers.ledger_id=2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id =2041
      THEN 'CAN'
    END                                                                       AS COUNTRY_INDICATOR,
    SUM(DECODE (gl_balances.period_name,:RunDate, gl_balances.BEGIN_BALANCE_DR-gl_balances.BEGIN_BALANCE_CR, 0)) AS begbal_base,
    psa.DESCR
    || ' - (R12 A/C : '
    ||gl_code_combinations.segment4
    ||'-'
    ||gl_ledgers.name
    ||')' AS DESCR
  FROM SY_120_GL_LEDGERS_EW gl_ledgers,
    SY_120_GL_BALANCES_EW gl_balances,
    SY_120_GL_CODE_COMBO_EW gl_code_combinations,
    OTR_TRANE_ACCOUNTS_PS psa,
    (SELECT a.BUSINESS_UNIT PS_BU ,
        A.ORACLE_XREF_VALUE Oracle_BU
    FROM dbo.ps_trane_R12_xref   a
    WHERE Recname_xref IN ('ENTITY')
    AND a.BUSINESS_UNIT in ('GS001','GS165')
    AND a.ps_attribute1 = ' '
    AND a.ps_attribute2 = ' '
    AND a.ps_attribute3 = ' '
    AND a.ps_attribute4 = ' '
    AND a.effdt         =
      (SELECT MAX(b.EFFDT)
      FROM dbo.ps_trane_R12_xref   b
      WHERE b.recname_xref = a.recname_xref
      AND b.business_unit  = a.business_unit
      AND b.ps_attribute1  = a.ps_attribute1
      AND b.ps_attribute2  = a.ps_attribute2
      AND b.ps_attribute3  = a.ps_attribute3
      AND b.ps_attribute4  = a.ps_attribute4
      )
    ) Cross_ref_BU,
    (SELECT   A.ORACLE_XREF_VALUE Oracle_Acc,
        a.PS_ATTRIBUTE1 PeopleSoft_ac
    FROM dbo.ps_trane_R12_xref   a
    WHERE Recname_xref IN ('ACCOUNT')
    AND a.ps_attribute1 = '490650'
    AND a.effdt         =
      (SELECT MAX(b.EFFDT)
      FROM dbo.ps_trane_R12_xref   b
      WHERE b.recname_xref = a.recname_xref
      AND b.business_unit  = a.business_unit
      AND b.ps_attribute1  = a.ps_attribute1
      AND b.ps_attribute2  = a.ps_attribute2
      AND b.ps_attribute3  = a.ps_attribute3
      AND b.ps_attribute4  = a.ps_attribute4
      )
    )Cross_Ref ,
    (
SELECT    a.BUSINESS_UNIT  PS_BU    , A.PS_ATTRIBUTE2 PS_DEPT,A.ORACLE_XREF_VALUE  Oracle_DEPT  
from ps_trane_r12_xref a --@DR_INTFC_DR.LAX.TRANE.COM a      
where Recname_xref in ('LOCATION')     
and ps_attribute2 like 'GL00%'
AND a.BUSINESS_UNIT in ('GS001','GS165')
and a.effdt = (SELECT MAX(b.EFFDT)                                
from ps_trane_r12_xref b--@DR_INTFC_DR.LAX.TRANE.COM b                        
where b.recname_xref  = a.recname_xref              
and b.business_unit = a.business_unit 
and b.ps_attribute1 = a.ps_attribute1
and b.ps_attribute2 = a.ps_attribute2
and b.ps_attribute3 = a.ps_attribute3
and b.ps_attribute4 = a.ps_attribute4) --Dept
) DEPT 
  WHERE  gl_balances.period_name=:RunDate
  AND gl_ledgers.ledger_id     IN (2022,2041 )
   AND
    CASE
      WHEN gl_ledgers.ledger_id=2022
      THEN 'USA'
      ELSE 'CAN'
    END                         =UPPER(:COUNTRY)
  AND gl_balances.ACTUAL_FLAG = 'A'
  AND gl_balances.ledger_id             = gl_ledgers.ledger_id
  AND gl_balances.code_combination_id   =gl_code_combinations.code_combination_id
  AND Cross_Ref.Oracle_Acc              = gl_code_combinations.segment4
  AND Cross_ref_BU.ORACLE_BU            = gl_code_combinations.segment1
  and Cross_ref_BU.PS_BU                =  dept.PS_BU
  and dept.Oracle_DEPT                  = gl_code_combinations.segment2
  AND Cross_Ref.PeopleSoft_ac (+)       = PSA.ACCOUNT
  AND PSA.TRANE_ACCOUNT_IND             ='X'
 GROUP BY Cross_Ref.PeopleSoft_ac,
    gl_ledgers.ledger_id,
    gl_balances.period_name,
    CASE
      WHEN gl_ledgers.ledger_id=2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id =2041then 'CAN'
    END ,
    psa.DESCR
    || ' - (R12 A/C : '
    ||gl_code_combinations.segment4
    ||'-'
    ||gl_ledgers.name
    ||')'
  )begbalances,
  
  (
  /* Ending Balance DRTRNP */
  SELECT  /*+ NO_CPU_COSTING */  Cross_Ref.PeopleSoft_ac AS ACCOUNT,
    gl_ledgers.ledger_id               AS ledger,
    gl_balances.period_name            AS fiscal_year,
    CASE
      WHEN gl_ledgers.ledger_id=2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id =2041
      THEN 'CAN'
    END AS COUNTRY_INDICATOR ,
    NVL(SUM(gl_balances.begin_balance_dr + gl_balances.period_net_dr - gl_balances.begin_balance_cr - gl_balances.period_net_cr),0) AS EndBal_base,
    psa.DESCR
    || ' - (R12 A/C : '
    ||gl_code_combinations.segment4
    ||'-'
    ||gl_ledgers.name
    ||')' AS DESCR
  FROM SY_120_GL_LEDGERS_EW gl_ledgers,
    SY_120_GL_BALANCES_EW gl_balances,
    SY_120_GL_CODE_COMBO_EW gl_code_combinations,
    OTR_TRANE_ACCOUNTS_PS psa,
    (SELECT a.BUSINESS_UNIT PS_BU ,
      A.ORACLE_XREF_VALUE Oracle_BU
    FROM dbo.ps_trane_R12_xref   a
    WHERE Recname_xref IN ('ENTITY')
    AND a.BUSINESS_UNIT in ('GS001','GS165')
    AND a.ps_attribute1 = ' '
    AND a.ps_attribute2 = ' '
    AND a.ps_attribute3 = ' '
    AND a.ps_attribute4 = ' '
    AND a.effdt         =
      (SELECT MAX(b.EFFDT)
      FROM dbo.ps_trane_R12_xref   b
      WHERE b.recname_xref = a.recname_xref
      AND b.business_unit  = a.business_unit
      AND b.ps_attribute1  = a.ps_attribute1
      AND b.ps_attribute2  = a.ps_attribute2
      AND b.ps_attribute3  = a.ps_attribute3
      AND b.ps_attribute4  = a.ps_attribute4
      )
    ) Cross_ref_BU,
    (SELECT   A.ORACLE_XREF_VALUE Oracle_Acc,
        a.PS_ATTRIBUTE1 PeopleSoft_ac
    FROM dbo.ps_trane_R12_xref   a
    WHERE Recname_xref IN ('ACCOUNT')
    AND a.ps_attribute1 = '490650'
    AND a.effdt         =
      (SELECT MAX(b.EFFDT)
      FROM dbo.ps_trane_R12_xref   b
      WHERE b.recname_xref = a.recname_xref
      AND b.business_unit  = a.business_unit
      AND b.ps_attribute1  = a.ps_attribute1
      AND b.ps_attribute2  = a.ps_attribute2
      AND b.ps_attribute3  = a.ps_attribute3
      AND b.ps_attribute4  = a.ps_attribute4
      )
    )Cross_Ref ,
    (
SELECT    a.BUSINESS_UNIT  PS_BU    , A.PS_ATTRIBUTE2 PS_DEPT,A.ORACLE_XREF_VALUE  Oracle_DEPT  from ps_trane_r12_xref a--@DR_INTFC_DR.LAX.TRANE.COM a      
where Recname_xref in ('LOCATION')     
and ps_attribute2 like 'GL00%'
AND a.BUSINESS_UNIT in ('GS001','GS165')
and a.effdt = (SELECT MAX(b.EFFDT)                                
from ps_trane_r12_xref b--@DR_INTFC_DR.LAX.TRANE.COM b                        
where b.recname_xref  = a.recname_xref              
and b.business_unit = a.business_unit 
and b.ps_attribute1 = a.ps_attribute1
and b.ps_attribute2 = a.ps_attribute2
and b.ps_attribute3 = a.ps_attribute3
and b.ps_attribute4 = a.ps_attribute4) --Dept
) DEPT 
  WHERE     gl_balances.period_name  = :RunDate
  AND
    CASE
      WHEN gl_ledgers.ledger_id=2022     
      THEN 'USA'
      ELSE 'CAN'
    END                         =UPPER(:COUNTRY)
  AND gl_ledgers.ledger_id     IN (2022,2041 )
  AND gl_balances.ACTUAL_FLAG = 'A'
  AND gl_balances.ledger_id          = gl_ledgers.ledger_id
  AND gl_balances.code_combination_id=gl_code_combinations.code_combination_id
  AND Cross_Ref.Oracle_Acc    = gl_code_combinations.segment4
  AND Cross_ref_BU.ORACLE_BU     = gl_code_combinations.segment1
  and Cross_ref_BU.PS_BU  =  dept.PS_BU
  and dept.Oracle_DEPT = gl_code_combinations.segment2
  AND Cross_Ref.PeopleSoft_ac(+) = PSA.ACCOUNT
  AND PSA.TRANE_ACCOUNT_IND      ='X'
  GROUP BY Cross_Ref.PeopleSoft_ac,
    gl_ledgers.ledger_id ,
    gl_balances.period_name,
    CASE
      WHEN gl_ledgers.ledger_id=2022
      THEN 'USA'
      WHEN gl_ledgers.ledger_id =2041then 'CAN'
    END ,
    psa.DESCR
    || ' - (R12 A/C : '
    ||gl_code_combinations.segment4
    ||'-'
    ||gl_ledgers.name
    ||')'
  )endingbalances
  
WHERE begbalances.ACCOUNT   = endingbalances.ACCOUNT(+)
AND begbalances.fiscal_year = endingbalances.fiscal_year(+)
AND begbalances.ledger      = endingbalances.ledger(+)
GROUP BY CAST(begbalances.ACCOUNT AS NUMBER),
  begbalances.COUNTRY_INDICATOR,
  begbalances.begbal_base,
  endingbalances.EndBal_base