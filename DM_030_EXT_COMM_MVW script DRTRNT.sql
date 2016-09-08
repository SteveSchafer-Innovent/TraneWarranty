DROP PUBLIC SYNONYM DM_030_EXT_COMM_MVW;

CREATE OR REPLACE PUBLIC SYNONYM DM_030_EXT_COMM_MVW FOR DBO.DM_030_EXT_COMM_MVW;


DROP MATERIALIZED VIEW DBO.DM_030_EXT_COMM_MVW;
CREATE MATERIALIZED VIEW DBO.DM_030_EXT_COMM_MVW (COUNTRY_INDICATOR,JRNL_YEAR_MONTH,GL_ACCOUNT,JOURNAL_DATE,COMMISSION_AMOUNT)
TABLESPACE D1_AA
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 8/9/2016 5:45:19 PM (QP5 v5.163.1008.3004) */
  SELECT country_indicator,
         jrnl_year_month,
         gl_account,
         journal_date,
         NVL (SUM (commission_amount), 0) AS commission_amount
    FROM (SELECT CASE WHEN dist.R12_ENTITY IN ('5773', '5588') THEN 'CAN' ELSE 'USA' END 
                /* -SS- CASE UPPER (TRIM (asx.nation_curr))
                    WHEN 'CAD' THEN 'CAN'
                    WHEN 'USD' THEN 'USA'
                    ELSE NULL
                 END
                    */ AS country_indicator,
                 TO_CHAR (dist.journal_date, 'YYYYMM') AS jrnl_year_month,
                 dist.R12_ACCOUNT /* -SS- ACCOUNT */ AS gl_account,
                 TRUNC (dist.journal_date, 'MM') AS journal_date,
                 CASE
                    WHEN    dist.debit_amt = 0
                         OR dist.debit_amt IS NULL
                         OR dist.credit_amount <> ''
                    THEN
                       dist.credit_amount * -1
                    ELSE
                       dist.debit_amt
                 END
                    AS commission_amount
            FROM DBO.R12_TRNCO_CM_DIST_PSB /* -SS- OTR */ dist,
                 R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA /* -SS- ,
                 dbo.actuate_sec_xref asx */
           WHERE     dist.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */
                 AND dist.R12_ENTITY NOT IN ('5773', '5588') /* -SS- asx.nation_curr = 'USD' */
                 AND PSA.trane_account_ind = 'X'
                 /* -SS- AND dist.business_unit_gl = asx.psgl */
                 AND (dist.R12_LOCATION /* -SS- deptid */ IS NULL OR dist.deptid = 'SL00' /* -SS- ???? */ )
                 AND dist.journal_date BETWEEN '1-NOV-2004'
                                           AND LAST_DAY (
                                                  ADD_MONTHS (SYSDATE, -1))
                 AND (   dist.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '52%' /* -SS- ???? */
                      OR dist.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '53%' /* -SS- ???? */
                      OR dist.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '54%' /* -SS- ???? */ )
          UNION ALL
          SELECT CASE WHEN dist.R12_ENTITY IN ('5773', '5588') THEN 'CAN' ELSE 'USA' END 
                /* -SS- CASE UPPER (TRIM (asx.nation_curr))
                    WHEN 'CAD' THEN 'CAN'
                    WHEN 'USD' THEN 'USA'
                    ELSE NULL
                 END */
                    AS country_indicator,
                 TO_CHAR (dist.journal_date, 'YYYYMM') AS jrnl_year_month,
                 dist.R12_ACCOUNT /* -SS- ACCOUNT */ AS gl_account,
                 TRUNC (dist.journal_date, 'MM') AS journal_date,
                 CASE
                    WHEN    dist.debit_amt = 0
                         OR dist.debit_amt IS NULL
                         OR dist.credit_amount <> ''
                    THEN
                       dist.credit_amount * -1
                    ELSE
                       dist.debit_amt
                 END
                    AS commission_amount
            FROM DBO.R12_TRNCO_CM_DIST_PSB /* -SS- OTR */ dist,
                 R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA /* -SS- ,
                 dbo.actuate_sec_xref asx */
           WHERE     dist.R12_ACCOUNT /* -SS- ACCOUNT */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */
                 AND dist.R12_ENTITY IN ('5773', '5588') /* -SS- asx.nation_curr = 'CAD' */
                 AND PSA.trane_account_ind = 'X'
                 /* -SS- AND dist.business_unit_gl = asx.psgl */
                 AND (dist.R12_LOCATOIN /* -SS- deptid */ IS NULL OR dist.R12_LOCATION /* -SS- deptid */ IN ('TCA0', 'SL00') /* -SS- ???? */ )
                 AND dist.journal_date BETWEEN '1-NOV-2004'
                                           AND LAST_DAY (
                                                  ADD_MONTHS (SYSDATE, -1))
                 AND (   dist.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '52%' /* -SS- ???? */
                      OR dist.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '53%' /* -SS- ???? */
                      OR dist.R12_ACCOUNT /* -SS- ACCOUNT */ LIKE '54%' /* -SS- ???? */ )
          UNION ALL
          SELECT CASE WHEN dist.R12_ENTITY IN ('5773', '5588') THEN 'CAN' ELSE 'USA' END
                /* -SS- CASE UPPER (TRIM (asx.nation_curr))
                    WHEN 'CAD' THEN 'CAN'
                    WHEN 'USD' THEN 'USA'
                    ELSE NULL
                 END */
                    AS country_indicator,
                 TO_CHAR (comm.gl_posted_date, 'YYYYMM') AS jrnl_year_month,
                 GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ AS gl_account,
                 TRUNC (comm.gl_posted_date, 'MM') AS journal_date,
                 CASE
                    WHEN    comm.debit_amount = 0
                         OR comm.debit_amount IS NULL
                         OR comm.credit_amount <> ''
                    THEN
                       comm.credit_amount * -1
                    ELSE
                       comm.debit_amount
                 END
                    AS commission_amount
            FROM bh.cms_commission_distributions comm,
                 BH.R12_GL_CODE_COMBINATIONS /* -SS- OTR */ GL_CODE,
                 R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA /* -SS- ,
                 actuate_sec_xref asx */
           WHERE     comm.code_combination_id = gl_code.code_combination_id
                 AND dist.R12_ENTITY NOT IN ('5773', '5588') /* -SS- asx.nation_curr = 'USD' */
                 AND GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */(+)
                 AND PSA.trane_account_ind = 'X'
                 /* -SS- AND gl_code.segment1 = asx.psgl(+) */
                 AND (GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IS NULL OR 
                  GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ = 'SL00' /* -SS- ???? */)
                 AND comm.gl_posted_date BETWEEN '1-JAN-2000' AND '31-OCT-2004'
                 AND (   GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '52%'
                      OR GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '53%'
                      OR GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '54%')
          UNION ALL
          SELECT CASE WHEN dist.R12_ENTITY IN ('5773', '5588') THEN 'CAN' ELSE 'USA' END
                /* -SS- CASE UPPER (TRIM (asx.nation_curr))
                    WHEN 'CAD' THEN 'CAN'
                    WHEN 'USD' THEN 'USA'
                    ELSE NULL
                 END */
                    AS country_indicator,
                 TO_CHAR (comm.gl_posted_date, 'YYYYMM') AS jrnl_year_month,
                 GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ AS gl_account,
                 TRUNC (comm.gl_posted_date, 'MM') AS journal_date,
                 CASE
                    WHEN    comm.debit_amount = 0
                         OR comm.debit_amount IS NULL
                         OR comm.credit_amount <> ''
                    THEN
                       comm.credit_amount * -1
                    ELSE
                       comm.debit_amount
                 END
                    AS commission_amount
            FROM bh.cms_commission_distributions comm,
                 BH.R12_GL_CODE_COMBINATIONS /* -SS- OTR */ GL_CODE,
                 R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA /* -SS- ,
                 actuate_sec_xref asx */
           WHERE     comm.code_combination_id = gl_code.code_combination_id
                 AND GL_CODE.R12_ENTITY /* -SS- SEGMENT3 */ IN ('5773', '5588') /* -SS- asx.nation_curr = 'CAD' */
                 AND GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */(+)
                 AND PSA.trane_account_ind = 'X'
                 /* -SS- AND gl_code.segment1 = asx.psgl(+) */
                 AND (GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IS NULL
                      OR GL_CODE.R12_LOCATION /* -SS- SEGMENT3 */ IN ('TCA0' /* -SS- ???? */, 'SL00' /* -SS- ???? */))
                 AND comm.gl_posted_date BETWEEN '1-JAN-2000' AND '31-OCT-2004'
                 AND (   GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '52%'
                      OR GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '53%'
                      OR GL_CODE.R12_ACCOUNT /* -SS- SEGMENT2 */ LIKE '54%')
          UNION ALL
          SELECT upd.country_indicator AS country_indicator,
                 TO_CHAR (upd.jrnl_date, 'YYYYMM') AS jrnl_year_month,
                 upd.R12_ACCOUNT /* -SS- gl_account */ AS gl_account,
                 TRUNC (upd.jrnl_date, 'MM') AS journal_date,
                 upd.revenue_amount AS commission_amount
            FROM MD_030_COMMISSION_DTL_UPD UPD, R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
           WHERE     upd.R12_ACCOUNT /* -SS- gl_account */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */(+)
                 AND PSA.trane_account_ind = 'X'
                 AND upd.jrnl_date BETWEEN '1-JAN-1998' AND '31-DEC-1999'
          UNION ALL
          SELECT DISTINCT
                 upd.country_indicator AS country_indicator,
                 TO_CHAR (upd.jrnl_date, 'YYYYMM') AS jrnl_year_month,
                 upd.R12_ACCOUNT /* -SS- gl_account */ AS gl_account,
                 TRUNC (ADD_MONTHS (upd.jrnl_date, -24), 'MM') AS journal_date,
                 0 AS commission_amount
            FROM MD_030_COMMISSION_DTL_UPD UPD, R12_TRANE_ACCOUNTS_PS /* -SS- OTR */ PSA
           WHERE     upd.R12_ACCOUNT /* -SS- gl_account */ = PSA.R12_ACCOUNT /* -SS- ACCOUNT */(+)
                 AND PSA.trane_account_ind = 'X'
                 AND upd.jrnl_date BETWEEN '1-JAN-1998' AND '31-DEC-1999')
   WHERE journal_date BETWEEN TRUNC (ADD_MONTHS (SYSDATE, -144), 'MM')
                          AND LAST_DAY (ADD_MONTHS (SYSDATE, -1))
GROUP BY country_indicator,
         jrnl_year_month,
         gl_account,
         journal_date;

COMMENT ON MATERIALIZED VIEW DBO.DM_030_EXT_COMM_MVW IS 'snapshot table for snapshot DBO.DM_030_EXT_COMM_MVW';

CREATE INDEX DBO.XIE1DM_030_EXT_COMM_MVW ON DBO.DM_030_EXT_COMM_MVW
(COUNTRY_INDICATOR, GL_ACCOUNT)
LOGGING
TABLESPACE I1_AA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          80K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

GRANT SELECT ON DBO.DM_030_EXT_COMM_MVW TO ACTUATE_SECURITY;

GRANT SELECT ON DBO.DM_030_EXT_COMM_MVW TO READ_DBO;
