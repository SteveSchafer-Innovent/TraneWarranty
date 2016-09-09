SELECT
  /*+ NO_CPU_COSTING */
  'RCPO' AS query_source,
  NVL(ps.gl_bu_id,(
  CASE
    WHEN ps.currency_code = 'USD'
    THEN 'GS303'
    WHEN ps.currency_code = 'CAD'
    THEN 'GS315'
    ELSE 'INVALID CURRENCY-'||ps.currency_code
  END)) AS bu,
  SUM(ps.order_amount) AS revenue_amount,
  SUM(100 *(ps.order_amount - TRUNC(ps.order_amount))) AS revenue_amount_dec
  -- PER PAT'S REQUEST 5/24/07
  --,PS.PLNT_GL_ACCT AS GL_ACCOUNT
  --,(CASE WHEN PS.PLNT_GL_ACCT2 = '750000' THEN PS.PLNT_GL_ACCT2 ELSE PS.PLNT_GL_ACCT END) AS GL_ACCOUNT
  -- PER PAT'S REQUEST 5/30/07
  ,
  ps.r12_account AS gl_account, --  -SS- PLNT_GL_ACCT2
  NVL(ps.gl_dpt_id,(
  CASE
    WHEN ps.currency_code = 'USD'
    THEN 97001
    WHEN ps.currency_code = 'CAD'
    THEN 97011
    ELSE - 10
  END)) AS dept_id,
  NVL(aol.office_name,(
  CASE
    WHEN ps.currency_code = 'USD'
    THEN 'OTHER EQUIPMENT GROUP'
    WHEN ps.currency_code = 'CAD'
    THEN 'CAN OTHER EQUIPMENT GROUP'
    ELSE 'INVALID CURRENCY-'||ps.currency_code
  END)) AS dept_descr,
  ps.plnt_gl_prod AS manf_prod_id,
  px.manf_prod_code_descr AS manf_prod_descr
  /* CHANGING MSUN 5/18/2007 */
  --,(CASE WHEN PS.PLNT_GL_ACCT= '750000' THEN '804900' ELSE  PS.GL_PROD END ) AS DIST_GL_PRODUCT
  -- PER PAT'S REQUEST 5/24/07
  -- ,(CASE WHEN PS.PLNT_GL_ACCT= '750000' OR PS.PLNT_GL_ACCT2 = '750000' THEN '804900' ELSE  PS.GL_PROD END ) AS DIST_GL_PRODUCT
  -- PER PAT'S REQUEST 5/30/07
  ,
  (
  CASE
    WHEN ps.part_type = 'Y'
    AND ps.parts_prod_code_ind = 'PCR'
    THEN '804900'
    ELSE ps.r12_product -- -SS- GL_PROD
  END) AS dist_gl_product
  /* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
  ,
  NVL(px.product_category,(
  CASE
    WHEN ps.plnt_gl_prod = 'ELIM'
    OR ps.plnt_gl_prod = 'TNA0'
    THEN 'LARGE'
    ELSE 'INVALID PROD CODE - '|| ps.plnt_gl_prod
  END)) AS reserve_group,
  ps.jrnl_date AS jrnl_date,
  CAST(TO_CHAR(jrnl_date, 'YYYY') AS INTEGER) AS jrnl_year,
  CAST(TO_CHAR(jrnl_date, 'MM') AS   INTEGER) AS jrnl_month,
  CAST(TO_CHAR(jrnl_date, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(jrnl_date, 'MM') AS INTEGER) AS jrnl_year_month,
  ps.orgn_jrnl_id AS jrnl_id,
  ps.currency_code AS currency,
  NVL(aol.nation_curr, ps.currency_code) AS country_indicator
FROM r12_oracle_ps_rev_rcpo ps -- -SS- OTR
LEFT OUTER JOIN otr_prod_code_xref_rcpo px
ON ps.plnt_gl_bu = px.gl_ledger
AND ps.plnt_gl_prod = px.manf_prod_code
LEFT OUTER JOIN actuate_office_location aol
ON
  /* -SS- FIXME */
  /* -SS- DEPT_ID */
  ps.gl_dpt_id = aol.ora_location
  /* -SS- FIXME */
  /* -SS- BU_UNIT */
AND ps.gl_bu_id = aol.ora_entity
WHERE ps.jrnl_date BETWEEN to_date('01/01/2005', 'MM/DD/YYYY') AND last_day(add_months(sysdate, - 1))
  --PS.JRNL_DATE BETWEEN CAST('2005-01-01 00:00:00.000' AS TIMESTAMP) AND CAST(LAST_DAY(ADD_MONTHS(SYSDATE,-1)) AS TIMESTAMP)
  --AND PS.PRODUCT_CODE = '0331'
  /* 2-5 year Warranty Project Rule */
AND px.two_five = 'Y'
  /* 2-5 year Warranty Project Rule */
GROUP BY ps.gl_bu_id
  -- PER PAT'S REQUEST, 5/30/07
  --,(CASE WHEN PS.PLNT_GL_ACCT2 = '750000' THEN PS.PLNT_GL_ACCT2 ELSE PS.PLNT_GL_ACCT END)
  ,
  ps.r12_account
  /* -SS- PLNT_GL_ACCT2 */
  ,
  ps.gl_dpt_id,
  aol.office_name,
  ps.plnt_gl_prod,
  px.manf_prod_code_descr
  -- PER PAT'S REQUEST, 5/30/07
  --,(CASE WHEN PS.PLNT_GL_ACCT= '750000' OR PS.PLNT_GL_ACCT2 = '750000' THEN '804900' ELSE  PS.GL_PROD END )
  ,
  (
  CASE
    WHEN ps.part_type = 'Y'
    AND ps.parts_prod_code_ind = 'PCR'
    THEN '804900'
    ELSE ps.r12_product
      /* -SS- GL_PROD */
  END),
  ps.r12_product
  /* -SS- GL_PROD */
  ,
  px.product_category,
  ps.jrnl_date,
  CAST(TO_CHAR(ps.jrnl_date, 'YYYY') AS INTEGER),
  CAST(TO_CHAR(ps.jrnl_date, 'MM') AS   INTEGER),
  CAST(TO_CHAR(ps.jrnl_date, 'YYYY') AS INTEGER) * 100 + CAST(TO_CHAR(ps.jrnl_date, 'MM') AS INTEGER),
  ps.orgn_jrnl_id,
  ps.currency_code,
  aol.nation_curr
UNION ALL

/* 2ND*/
SELECT
  /*+ NO_CPU_COSTING */
  'P/S GL' AS query_source,
  ga.business_unit AS bu,
  SUM(l.monetary_amount) AS revenue_amount,
  SUM(100 *(l.monetary_amount - TRUNC(l.monetary_amount))) AS revenue_amount_dec,
  l.r12_account AS gl_account, -- -SS- ACCOUNT
  l.r12_location AS dept_id,   --  -SS- DEPTID
  dp.descr AS dept_descr,
  l.r12_product AS manf_prod_id, -- -SS- PRODUCT
  pr.descr AS manf_prod_descr
  -- PER PAT'S REQUEST 5/24/07
  --, NULL AS DIST_GL_PRODUCT
  ,
  l.r12_product AS dist_gl_product, --  -SS- PRODUCT
  /* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
  NVL(px.product_category,(
  CASE
    WHEN l.r12_product
      /* -SS- PRODUCT */
      = 'ELIM'
    OR l.r12_product
      /* -SS- PRODUCT */
      = 'TNA0'
    THEN 'LARGE'
    ELSE 'INVALID PROD CODE - '|| l.r12_product
      /* -SS- PRODUCT */
  END)) AS reserve_group,
  --, PX.PRODUCT_CATEGORY AS RESERVE_GROUP
  ga.journal_date AS jrnl_date,
  to_number(TO_CHAR(ga.journal_date, 'YYYY')) AS jrnl_year,
  to_number(TO_CHAR(ga.journal_date, 'MM')) AS jrnl_month,
  to_number(TO_CHAR(ga.journal_date, 'YYYY')) * 100 + to_number(TO_CHAR(ga.journal_date, 'MM')) AS jrnl_year_month,
  ga.journal_id AS jrnl_id,
  l.currency_cd AS currency,
  asx.nation_curr AS country_indicator
FROM r12_jrnl_ln_ps
  /* -SS- OTR */
  l,
  r12_jrnl_header_ps
  /* -SS- OTR */
  ga,
  r12_trane_products_ps
  /* -SS- OTR */
  pr,
  otr_trane_depts_ps dp,
  otr_prod_code_xref_rcpo px,
  actuate_sec_xref asx
WHERE ga.jrnl_hdr_status IN('P', 'U')
AND ga.fiscal_year IN('2003', '2004')
AND l.ledger = 'ACTUALS'
AND l.r12_account
  /* -SS- ACCOUNT */
  = '700000'
  /* -SS- ???? */
AND ga.business_unit IN('CAN', 'CSD')
  /* 2-5 year Warranty Project Rule */
AND px.two_five = 'Y'
  /* 2-5 year Warranty Project Rule */
AND ga.business_unit = l.business_unit
AND ga.journal_id = l.journal_id
AND ga.journal_date = l.journal_date
AND ga.unpost_seq = l.unpost_seq
AND l.r12_product
  /* -SS- PRODUCT */
  = pr.r12_product(+)
  /* -SS- PRODUCT */
AND l.r12_location
  /* -SS- DEPTID */
  = dp.deptid(+)
AND l.business_unit = px.gl_ledger(+)
AND l.r12_product
  /* -SS- PRODUCT */
  = px.manf_prod_code(+)
AND ga.business_unit = asx.psgl(+)
GROUP BY ga.business_unit,
  l.r12_account
  /* -SS- ACCOUNT */
  ,
  l.r12_location
  /* -SS- DEPTID */
  ,
  dp.descr,
  l.r12_product
  /* -SS- PRODUCT */
  ,
  pr.descr,
  px.product_category,
  ga.journal_date,
  to_number(TO_CHAR(ga.journal_date, 'YYYY')),
  to_number(TO_CHAR(ga.journal_date, 'MM')),
  to_number(TO_CHAR(ga.journal_date, 'YYYY')) * 100 + to_number(TO_CHAR(ga.journal_date, 'MM')),
  ga.journal_id,
  l.currency_cd,
  asx.nation_curr
UNION

/* 3RD */
SELECT
  /*+ NO_CPU_COSTING */
  'P/S LEDGER' AS query_source,
  ps.business_unit AS bu,
  SUM(ps.posted_total_amt) AS revenue_amount,
  SUM(100 *(ps.posted_total_amt - TRUNC(ps.posted_total_amt))) AS revenue_amount_dec,
  ps.r12_account
  /* -SS- ACCOUNT */
  AS gl_account,
  ps.r12_location
  /* -SS- DEPTID */
  AS dept_id,
  dp.descr AS dept_descr,
  ps.r12_product
  /* -SS- PRODUCT */
  AS manf_prod_id,
  pr.descr AS manf_prod_descr
  -- PER PAT'S REQUEST 5/24/07
  --,NULL AS DIST_GL_PRODUCT
  ,
  ps.r12_product
  /* -SS- PRODUCT */
  AS dist_gl_product
  /* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
  ,
  NVL(px.product_category,(
  CASE
    WHEN ps.r12_product
      /* -SS- PRODUCT */
      = 'ELIM'
    OR ps.r12_product
      /* -SS- PRODUCT */
      = 'TNA0'
    THEN 'LARGE'
    ELSE 'INVALID PROD CODE - '|| ps.r12_product
      /* -SS- PRODUCT */
  END)) AS reserve_group
  --,PX.PRODUCT_CATEGORY AS RESERVE_GROUP
  ,
  to_date('15-' || ps.accounting_period || '-' || ps.fiscal_year, 'DD-MM-YYYY') AS jrnl_date,
  ps.fiscal_year AS jrnl_year,
  ps.accounting_period AS jrnl_month,
  ps.fiscal_year * 100 + ps.accounting_period AS jrnl_year_month,
  'ZZZZZZ' AS jrnl_id,
  ps.currency_cd AS currency,
  asx.nation_curr AS country_indicator
FROM r12_ledger2_ps
  /* -SS- OTR */
  ps,
  r12_trane_products_ps
  /* -SS- OTR */
  pr,
  otr_trane_depts_ps dp,
  otr_prod_code_xref_rcpo px,
  actuate_sec_xref asx
WHERE ps.fiscal_year IN('2000', '2001', '2002')
AND ps.accounting_period <= '12'
AND ps.r12_account
  /* -SS- ACCOUNT */
  = '700000'
  --ADD BY ALEX
AND ps.ledger = 'ACTUALS'
  --ADD BY ALEX
  --AND PR.PRODUCT = '0331'
  /* 2-5 year Warranty Project Rule */
AND px.two_five = 'Y'
  /* 2-5 year Warranty Project Rule */
AND ps.r12_product
  /* -SS- PRODUCT */
  = pr.r12_product
  /* -SS- PRODUCT */
  (+)
AND ps.r12_location
  /* -SS- DEPTID */
  = dp.deptid(+)
AND ps.r12_product
  /* -SS- PRODUCT */
  = px.manf_prod_code(+)
AND ps.business_unit = px.gl_ledger(+)
AND ps.business_unit = asx.psgl(+)
GROUP BY ps.business_unit,
  ps.r12_account
  /* -SS- ACCOUNT */
  ,
  ps.r12_location
  /* -SS- DEPTID */
  ,
  dp.descr,
  ps.r12_product
  /* -SS- PRODUCT */
  ,
  pr.descr,
  px.product_category,
  to_date('15-' || ps.accounting_period || '-' || ps.fiscal_year, 'DD-MM-YYYY'),
  ps.fiscal_year,
  ps.accounting_period,
  ps.fiscal_year * 100 + ps.accounting_period,
  ps.currency_cd,
  asx.nation_curr
UNION ALL

/* 4th -New Query to get the Residential data for Year 2000 and 2001, on 10/01/07  */
SELECT
  /*+ NO_CPU_COSTING */
  DISTINCT 'CS_LD' AS query_source,
  rs_ledger.business_unit AS bu,
  SUM(rs_ledger.sales_total) AS revenue_amount,
  SUM(100 *(rs_ledger.sales_total - TRUNC(rs_ledger.sales_total))) AS revenue_amount_dec,
  rs_ledger.r12_account
  /* -SS- ACCOUNT */
  AS gl_account,
  rs_ledger.r12_location
  /* -SS- DEPT_ID */
  AS dept_id,
  dp.descr AS dept_descr,
  rs_ledger.r12_product
  /* -SS- PRODUCT_ID */
  AS manf_prod_id,
  pr.descr AS manf_prod_descr,
  rs_ledger.r12_product
  /* -SS- PRODUCT_ID */
  AS dist_gl_product
  /* PER JACKIE'S EMAIL 5/9, FOLLOWING LOGIC IS NEEDED*/
  ,
  NVL(px.product_category,(
  CASE
    WHEN rs_ledger.r12_product
      /* -SS- PRODUCT_ID */
      = 'ELIM'
      /* -SS- ???? */
    OR rs_ledger.r12_product
      /* -SS- PRODUCT_ID */
      = 'TNA0'
      /* -SS- ???? */
    THEN 'LARGE'
    ELSE 'INVALID PROD CODE - ' || rs_ledger.r12_product
      /* -SS- PRODUCT_ID */
  END)) AS reserve_group
  --,PX.PRODUCT_CATEGORY AS RESERVE_GROUP
  ,
  to_date('15-' || rs_ledger.accounting_period || '-' || rs_ledger.accounting_year, 'DD-MM-YYYY') AS jrnl_date,
  rs_ledger.accounting_year AS jrnl_year,
  rs_ledger.accounting_period AS jrnl_month,
  rs_ledger.accounting_year * 100 + rs_ledger.accounting_period AS jrnl_year_month,
  'ZZZZZZ' AS jrnl_id,
  SUBSTR('', 3) AS currency,
  asx.nation_curr AS country_indicator
FROM r12_com_sales_rs_ledger
  /* -SS- OTR */
  rs_ledger,
  r12_trane_products_ps
  /* -SS- OTR */
  pr,
  otr_trane_depts_ps dp,
  otr_prod_code_xref_rcpo px,
  actuate_sec_xref asx
WHERE rs_ledger.r12_product
  /* -SS- PRODUCT_ID */
  = pr.r12_product
  /* -SS- PRODUCT */
  (+)
AND rs_ledger.r12_location
  /* -SS- DEPT_ID */
  = dp.deptid(+)
AND rs_ledger.r12_product
  /* -SS- PRODUCT_ID */
  = px.manf_prod_code(+)
AND rs_ledger.business_unit = px.gl_ledger(+)
AND rs_ledger.business_unit = asx.psgl(+)
AND px.two_five = 'Y'
AND rs_ledger.r12_account
  /* -SS- ACCOUNT */
  = '700000'
  /* -SS- ???? */
AND rs_ledger.ledger = 'ACTUALS'
AND rs_ledger.accounting_period <= '12'
AND rs_ledger.accounting_year IN('2000', '2001')
  --AND  RS_LEDGER.BUSINESS_UNIT = 'GLUPG'
GROUP BY rs_ledger.business_unit,
  rs_ledger.r12_account
  /* -SS- ACCOUNT */
  ,
  rs_ledger.r12_location
  /* -SS- DEPT_ID */
  ,
  dp.descr,
  rs_ledger.r12_product
  /* -SS- PRODUCT_ID */
  ,
  pr.descr,
  rs_ledger.r12_product
  /* -SS- PRODUCT_ID */
  ,
  px.product_category,
  to_date('15-' || rs_ledger.accounting_period || '-' || rs_ledger.accounting_year, 'DD-MM-YYYY'),
  rs_ledger.accounting_year,
  rs_ledger.accounting_period,
  rs_ledger.accounting_year * 100 + rs_ledger.accounting_period,
  asx.nation_curr
UNION ALL

/*- 5TH QUERY 5/1
AND .BUSINESS_UNIT= ASX.PSGL
ADDING AOL.NAITON_CURR
CHANGING ALIAS NAME FOR MULTIPLE FIELDS
*/
--SELECT CASE WHEN BUSINESS_UNIT IN ('CAN','CSD') THEN BUSINESS_UNIT
--WHEN CURRENCY = 'CAN' THEN 'CAN' ELSE 'CSD' END AS BU
SELECT
  /*+ NO_CPU_COSTING */
  'PBS' AS query_source,
  business_unit AS bu,
  SUM(p7_total) AS revenue_amount,
  SUM(100 *(p7_total - TRUNC(p7_total))) AS revenue_amount_dec,
  gl_account AS gl_account,
  deptid AS dept_id,
  dept_descr AS dept_descr,
  prodcode AS manf_prod_id,
  prod_descr AS manf_prod_descr
  /* CHANGING 5/18/2007 MSUN*/
  ,
  gl_prodcode AS dist_gl_product,
  NVL(reserve_group, 'LARGE') AS reserve_group,
  jrnl_date AS jrnl_date,
  to_number(TO_CHAR(to_date(jrnl_date), 'YYYY')) AS jrnl_year,
  to_number(TO_CHAR(to_date(jrnl_date), 'MM')) AS jrnl_month,
  to_number(TO_CHAR(to_date(jrnl_date), 'YYYY')) * 100 + to_number(TO_CHAR(to_date(jrnl_date), 'MM')) AS jrnl_year_month,
  jrnl_id AS jrnl_id,
  currency AS currency,
  nation_curr AS country_indicator
FROM
  (SELECT
    /*+ NO_CPU_COSTING */
    d.entity
    /* -SS- BUSINESS_UNIT_GL */
    AS business_unit,
    d.invoice AS invoice,
    d.line_seq_num AS seq_num,
    d.acct_entry_type AS entry_type,
    d.journal_id AS jrnl_id,
    d.journal_date AS jrnl_date,
    d.r12_account
    /* -SS- ACCOUNT */
    AS gl_account,
    d.monetary_amount AS p7_total,
    d.r12_location
    /* -SS- DEPTID */
    AS deptid,
    aol.office_name AS dept_descr,
    pr.descr AS prod_descr,
    x.product_category AS reserve_group,
    a.r12_product
    /* -SS- IDENTIFIER */
    AS prodcode,
    CASE
      WHEN d.r12_product
        /* -SS- PRODUCT */
        = '0064'
      THEN '804155'
        /* -SS- ???? */
      ELSE d.r12_product
        /* -SS- PRODUCT */
    END AS gl_prodcode,
    d.currency_cd AS currency,
    aol.nation_curr
  FROM r12_bi_line_psb
    /* -SS- OTR */
    a,
    r12_bi_acct_entry_psb
    /* -SS- OTR */
    d,
    otr_prod_code_xref_rcpo x,
    r12_trane_products_ps
    /* -SS- OTR */
    pr,
    actuate_office_location aol
  WHERE d.journal_date BETWEEN to_date('03/01/2006', 'MM/DD/YYYY') AND last_day(add_months(sysdate, - 1))
  AND '411101'
    /* -SS- '700000' */
    = d.r12_account
    /* -SS- ACCOUNT */
  AND 'ACTUALS' = d.ledger
  AND '41206'
    /* -SS- ???? */
    <> d.r12_product
  AND '41201'
    /* -SS- ???? */
    <> d.r12_product
  AND '41299'
    /* -SS- ???? */
    <> d.r12_product
    /* -SS-
    AND '804180' <> D.PRODUCT
    AND '804120' <> D.PRODUCT
    AND '804190' <> D.PRODUCT
    */
    /* 2-5 year Warranty Project Rule */
  AND x.two_five = 'Y'
  AND d.line_seq_num = a.line_seq_num
  AND d.invoice = a.invoice
  AND d.business_unit = a.business_unit
    /*New Logic Adedd as of Oct27-2010 as  Jackie Req */
    --AND D.BUSINESS_UNIT = X.GL_LEDGER (+)
    -- AND D.PRODUCT = X.MANF_PROD_CODE (+)
  AND a.r12_product
    /* -SS- IDENTIFIER */
    = x.manf_prod_code (+)
  AND x.gl_ledger = 'CSD'
    /* New Logic Adedd as of Oct27-2010 as  Jackie Req  */
  AND d.r12_product
    /* -SS- PRODUCT */
    = pr.r12_product
    /* -SS- PRODUCT */
    (+)
  AND d.r12_location
    /* -SS- DEPTID */
    = aol.ora_location
    /* -SS- DEPT_ID */
    (+)
  AND EXISTS
    (SELECT 'X'
    FROM otr_bi_hdr_psb b
    WHERE b.bill_source_id = 'PBS'
    AND d.invoice = b.invoice
    AND d.business_unit = b.business_unit
    )
  AND EXISTS
    (SELECT 'X'
    FROM otr_trnbi_bi_hdr_psb c
    WHERE '7' = c.trnbi_project_type
    AND d.invoice = c.invoice
    AND d.business_unit = c.business_unit
    )
  )
GROUP BY business_unit,
  gl_account,
  deptid,
  dept_descr,
  prod_descr,
  prodcode
  --ADD BY ALEX
  ,
  gl_prodcode
  --ADD BY ALEX
  ,
  NVL(reserve_group, 'LARGE'),
  jrnl_date,
  to_number(TO_CHAR(to_date(jrnl_date), 'YYYY')),
  to_number(TO_CHAR(to_date(jrnl_date), 'MM')),
  to_number(TO_CHAR(to_date(jrnl_date), 'YYYY')) * 100 + to_number(TO_CHAR(to_date(jrnl_date), 'MM')),
  jrnl_id,
  currency,
  nation_curr
UNION ALL
SELECT
  /*+ NO_CPU_COSTING */
  'P21' AS query_source,
  business_unit AS bu,
  SUM(p7_total) AS revenue_amount,
  SUM(100 *(p7_total - TRUNC(p7_total))) AS revenue_amount_dec,
  gl_account AS gl_account,
  deptid AS dept_id,
  dept_descr AS dept_descr,
  prodcode AS manf_prod_id,
  prod_descr AS manf_prod_descr
  /* CHANGING 5/18/2007 MSUN*/
  ,
  gl_prodcode AS dist_gl_product,
  NVL(reserve_group, 'LARGE') AS reserve_group,
  jrnl_date AS jrnl_date,
  to_number(TO_CHAR(to_date(jrnl_date), 'YYYY')) AS jrnl_year,
  to_number(TO_CHAR(to_date(jrnl_date), 'MM')) AS jrnl_month,
  to_number(TO_CHAR(to_date(jrnl_date), 'YYYY')) * 100 + to_number(TO_CHAR(to_date(jrnl_date), 'MM')) AS jrnl_year_month,
  jrnl_id AS jrnl_id,
  currency AS currency,
  nation_curr AS country_indicator
FROM
  (SELECT
    /*+ NO_CPU_COSTING */
    d.business_unit_gl AS business_unit,
    d.invoice AS invoice,
    d.line_seq_num AS seq_num,
    d.acct_entry_type AS entry_type,
    d.journal_id AS jrnl_id,
    d.journal_date AS jrnl_date,
    d.r12_account
    /* -SS- ACCOUNT */
    AS gl_account,
    d.monetary_amount AS p7_total,
    d.r12_location
    /* -SS- DEPTID */
    AS deptid,
    aol.office_name AS dept_descr,
    pr.descr AS prod_descr,
    x.product_category AS reserve_group,
    a.r12_product
    /* -SS- IDENTIFIER */
    AS prodcode,
    CASE
      WHEN d.r12_product
        /* -SS- PRODUCT */
        = '0064'
      THEN '804155'
        /* -SS- ???? */
      ELSE d.r12_product
        /* -SS- PRODUCT */
    END AS gl_prodcode,
    d.currency_cd AS currency,
    aol.nation_curr
  FROM r12_bi_line_psb
    /* -SS- OTR */
    a,
    r12_bi_acct_entry_psb
    /* -SS- OTR */
    d,
    otr_prod_code_xref_rcpo x,
    r12_trane_products_ps
    /* -SS- OTR */
    pr,
    actuate_office_location aol
  WHERE d.journal_date BETWEEN to_date('03/01/2006', 'MM/DD/YYYY') AND last_day(add_months(sysdate, - 1))
  AND '411101'
    /* -SS- '700000' */
    = d.r12_account
    /* -SS- ACCOUNT */
  AND 'ACTUALS' = d.ledger
    /* -SS-
    805100 -> 41208
    802921 -> 41399
    801270 -> 41132
    803270 -> 41499
    804140 -> 41205
    804140 -> 41299
    */
  AND '41208' <> d.r12_product
  AND '41399' <> d.r12_product
  AND '41132' <> d.r12_product
  AND '41499' <> d.r12_product
  AND '41205' <> d.r12_product
  AND '41299' <> d.r12_product
    /* -SS-
    AND '805100' <> D.PRODUCT
    AND '802921' <> D.PRODUCT
    AND '801270' <> D.PRODUCT
    AND '803270' <> D.PRODUCT
    AND '804140' <> D.PRODUCT
    */
    /* 2-5 year Warranty Project Rule */
  AND x.two_five = 'Y'
    /* 2-5 year Warranty Project Rule */
  AND d.line_seq_num = a.line_seq_num
  AND d.invoice = a.invoice
  AND d.business_unit = a.business_unit
    /*New Logic Adedd as of Oct27-2010 as  Jackie Req */
    -- AND D.BUSINESS_UNIT = X.GL_LEDGER (+)
    -- AND D.PRODUCT = X.MANF_PROD_CODE (+)
  AND a.r12_product
    /* -SS- IDENTIFIER */
    = x.manf_prod_code (+)
  AND x.gl_ledger = 'CSD'
    /* New Logic Adedd as of Oct27-2010 as  Jackie Req  */
    /* -SS- PRODUCT */
  AND d.r12_product = pr.r12_product (+)
    /* -SS- PRODUCT */
    /* -SS- DEPTID */
  AND d.r12_location = aol.ora_location(+)
    /* -SS- DEPT_ID */
  AND EXISTS
    (SELECT 'X'
    FROM otr_bi_hdr_psb b
    WHERE b.bill_source_id = 'P21'
    AND d.invoice = b.invoice
    AND d.business_unit = b.business_unit
    )
  AND EXISTS
    (SELECT 'X'
    FROM otr_trnbi_bi_hdr_psb c
    WHERE '7' = c.trnbi_project_type
    AND d.invoice = c.invoice
    AND d.business_unit = c.business_unit
    )
  )
GROUP BY business_unit,
  gl_account,
  deptid,
  dept_descr,
  prod_descr,
  prodcode
  --ADD BY ALEX
  ,
  gl_prodcode
  --ADD BY ALEX
  ,
  NVL(reserve_group, 'LARGE'),
  jrnl_date,
  to_number(TO_CHAR(to_date(jrnl_date), 'YYYY')),
  to_number(TO_CHAR(to_date(jrnl_date), 'MM')),
  to_number(TO_CHAR(to_date(jrnl_date), 'YYYY')) * 100 + to_number(TO_CHAR(to_date(jrnl_date), 'MM')),
  jrnl_id,
  currency,
  nation_curr
