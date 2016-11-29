CREATE OR REPLACE PACKAGE DBO.Pkg_Cl_Warranty_Xref AS
/***********************************************************************************
    * Author: Venu Hemadri
    *
    * Description: Populates the Claims Warranty Xref table. Seperate procedures were
    * implementad for Initial and Incremental Loading.
    *
    * Revisions:
    *
    *   Change Date         Change Description
    *   -----------         ------------------
    *   16-FEB-2007         Venu Hemadri -- TTP#9290
    *                       Creation.
    *
    *  26-FEB-2007         Venu Hemadri  -- TTP#9290
    *                       Changed the claims end date to 31-JAN-2007 from 31-DEC-2006
    *
    *  07-MAR-2007         Venu Hemadri  -- TTP#9290
    *                       Replaced the condition
    *                     and (g.GL_ACCOUNT LIKE 'CSD.8062%' OR g.GL_ACCOUNT LIKE 'CAN.8062%')
    *                     with
    *                     a((gl.Company IN ('CSD','CAN') and (gl.ACCOUNT IN
    *                     ('710000','428000','806300') OR (gl.ACCOUNT LIKE '8062%')) or
    *                     (gl.Company LIKE 'GS%' and gl.ACCOUNT IN ('710000','428000','806300'))))
    *    05/29/07        Michael Sun
    *                    (1) removing incremental update portion
    *                     (2) changing date range from 1/1/2001~last month to >1/1/2001 for
    *   07/18/07        Michael Sun
    *                    Applying new biz logic -- Is fail date less than or equal to warranty end date (Jackie email 07/18/07)
    *
    *   03/18/2010      Prasanth Viswanathan, Cognizant TTP 9297
    *                    Replaced the synonyms in cursor with new 430 ODS tables
    *                    Modified the query to select only if EFF_WARR is "EFFECTIVE"
    ***********************************************************************************/

/*****************************************************************************************
 This Cursor selects data for Initial Load of dm_fal_claims_warranty_xrf table
*****************************************************************************************/
CURSOR C_CLAIMS_WARR_XREF_LOAD IS
SELECT   claim, detail, step, cl_fail_date, cl_ship_date, cl_start_date,
    /* selecting the max of ranks if # of ranks>1 msun 051807 per meeting with Kelly*/
 --        SUM (DISTINCT CASE
             MAX (DISTINCT CASE
                 WHEN warr_type = '01'
                    THEN '8'
                 WHEN warr_type = '00'
                    THEN '4'
                 WHEN warr_type = '04'
                    THEN '2'
                 WHEN warr_type = '03'
                    THEN '1'
                 ELSE '0'
              END
             ) AS warranty_rank
    FROM (
/*Claims are selected 4 ways.  Category 1 is by order number and serial number
 If no warranty is found for this category, type '01' ia assumed with dummy dates */
          SELECT          /*+ INDEX(w XIE1WC_MAT_LBR_ROLLUP) */
                 DISTINCT w.claim_nbr AS claim, w.detail_nbr AS detail,
                          w.step_nbr AS step,
                          CASE
                             WHEN wp.wa_policy_type IS NULL
                                THEN '01'
                             ELSE wp.wa_policy_type
                          END AS warr_type,
                          'EFFECTIVE' AS eff_warr,
                          CASE
                             WHEN wp.wa_policy_type IS NULL
                                THEN TO_DATE ('1-JAN-1900')
                             ELSE ew.start_date
                          END AS warr_start,
                          CASE
                             WHEN wp.wa_policy_type IS NULL
                                THEN TO_DATE ('31-DEC-2059')
                             ELSE ew.end_date
                          END AS warr_end,
                          t.claim_type_code AS claim_type,
                          tf.full_date AS cl_fail_date,
                          ts.full_date AS cl_ship_date,
                          tr.full_date AS cl_start_date, g.ACCOUNT,
                          w.sales_order_prime, w.parent_serial_nbr,
                          '1' AS warr_category
                     FROM WC_MAT_LBR_ROLLUP w,
                          TIME_DAY tt,
                          TIME_DAY tf,
                          TIME_DAY ts,
                          TIME_DAY tr,
                          CLAIM_TYPE_SCD t,
                          GL_ACCOUNT_SCD g,
                          CLAIM_TASK_SCD tk,
                          AP_430_effective_warranty ew,
                          AP_430_warr_policy wp
                    WHERE w.ccn_trx_date_key = tt.time_key
                      AND w.fail_date_key = tf.time_key
                      AND w.start_date_key = tr.time_key
                      AND w.original_ship_date_key = ts.time_key
                      AND tt.full_date >= '1-JAN-2001'
                      AND w.claim_type_scd_key = t.claim_type_scd_key
                      AND w.gl_account_scd_key = g.gl_account_scd_key
                      AND w.claim_task_scd_key = tk.claim_task_scd_key(+)
                      AND w.sales_order_prime IS NOT NULL
                      AND w.parent_serial_nbr <> '?'
                      AND w.sales_order_prime = ew.sales_order_prime(+)
                      AND w.parent_serial_nbr = ew.serial_number(+)
                      AND ew.wa_policy_code = wp.wa_policy_code(+)
                      AND (g.ACCOUNT LIKE '%8062%' or  g.ACCOUNT LIKE '%0620%')
                      AND NOT t.claim_type_descr IN
                                      ('RETROFIT MATERIAL', 'RETROFIT LABOR')
                      AND NOT (    t.claim_type_descr IN
                                      ('MATERIAL',
                                       'SPD',
                                       'CONCESSION',
                                       'EXTENDED PURCHASED LABOR'
                                      )
                               AND SUBSTR (tk.task_code, 1, 1) = 'Z'
                              )
                      AND (wp.wa_policy_type IS NULL
                              OR (    (tf.full_date <= ew.end_date
                                      )
                                  AND wp.wa_policy_type IN
                                                     ('00', '01', '03', '04')
                                 ))
          UNION ALL
/* Category 2 claim selection is by order number and serial number = '?' */
          SELECT          /*+ INDEX(w XIE1WC_MAT_LBR_ROLLUP) */
                 DISTINCT w.claim_nbr AS claim, w.detail_nbr AS detail,
                          w.step_nbr AS step, wp.wa_policy_type AS warr_type,
                          'EFFECTIVE' AS eff_warr, NULL AS warr_start,
                          NULL AS warr_end, t.claim_type_code AS claim_type,
                          tf.full_date AS cl_fail_date,
                          ts.full_date AS cl_ship_date,
                          tr.full_date AS cl_start_date, g.ACCOUNT,
                          w.sales_order_prime, w.parent_serial_nbr,
                          '2' AS warr_category
                     FROM WC_MAT_LBR_ROLLUP w,
                          TIME_DAY tt,
                          TIME_DAY tf,
                          TIME_DAY tr,
                          TIME_DAY ts,
                          GL_ACCOUNT_SCD g,
                          CLAIM_TYPE_SCD t,
                          CLAIM_TASK_SCD tk,
                          AP_430_effective_warranty ew,
                          AP_430_warr_policy wp
                    WHERE w.ccn_trx_date_key = tt.time_key
                    AND tt.full_date >= '1-JAN-2001'
                      AND w.fail_date_key = tf.time_key
                      AND w.original_ship_date_key = ts.time_key
                      AND w.start_date_key = tr.time_key
                      AND w.claim_type_scd_key = t.claim_type_scd_key
                      AND w.gl_account_scd_key = g.gl_account_scd_key
                      AND w.claim_task_scd_key = tk.claim_task_scd_key(+)
                      AND w.sales_order_prime IS NOT NULL
                      AND w.parent_serial_nbr = '?'
                      AND w.sales_order_prime = ew.sales_order_prime(+)
                      AND ew.serial_number IS NULL
                      AND ew.wa_policy_code = wp.wa_policy_code(+)
                      AND (g.ACCOUNT LIKE '%8062%' or  g.ACCOUNT LIKE '%0620%')
                      AND NOT t.claim_type_descr IN
                                      ('RETROFIT MATERIAL', 'RETROFIT LABOR')
                      AND NOT (    t.claim_type_descr IN
                                      ('MATERIAL',
                                       'SPD',
                                       'CONCESSION',
                                       'EXTENDED PURCHASED LABOR'
                                      )
                               AND SUBSTR (tk.task_code, 1, 1) = 'Z'
                              )
          UNION ALL
/* Category 3 claim selection is by serial number and NULL order number */
          SELECT          /*+ INDEX(w XIE1WC_MAT_LBR_ROLLUP) */
                 DISTINCT w.claim_nbr AS claim, w.detail_nbr AS detail,
                          w.step_nbr AS step, wp.wa_policy_type AS warr_type,
                          'EFFECTIVE' AS eff_warr,
                          ew.start_date AS warr_start,
                          ew.end_date AS warr_end,
                          t.claim_type_code AS claim_type,
                          tf.full_date AS cl_fail_date,
                          ts.full_date AS cl_ship_date,
                          tr.full_date AS cl_start_date, g.ACCOUNT,
                          w.sales_order_prime, w.parent_serial_nbr,
                          '3' AS warr_category
                     FROM WC_MAT_LBR_ROLLUP w,
                          TIME_DAY tt,
                          TIME_DAY tf,
                          TIME_DAY ts,
                          TIME_DAY tr,
                          CLAIM_TYPE_SCD t,
                          GL_ACCOUNT_SCD g,
                          CLAIM_TASK_SCD tk,
                          AP_430_effective_warranty ew,
                          AP_430_warr_policy wp
                    WHERE w.ccn_trx_date_key = tt.time_key
                    AND tt.full_date >= '1-JAN-2001'
                      AND w.fail_date_key = tf.time_key
                      AND w.start_date_key = tr.time_key
                      AND w.original_ship_date_key = ts.time_key
                      AND w.claim_type_scd_key = t.claim_type_scd_key
                      AND w.gl_account_scd_key = g.gl_account_scd_key
                      AND w.claim_task_scd_key = tk.claim_task_scd_key(+)
                      AND w.parent_serial_nbr <> '?'
                      AND w.parent_serial_nbr = ew.serial_number(+)
                      AND w.sales_order_prime IS NULL
                      AND ew.serial_number IS NOT NULL
                      AND ew.wa_policy_code = wp.wa_policy_code(+)
                      AND (g.ACCOUNT LIKE '%8062%' or  g.ACCOUNT LIKE '%0620%')
                      AND NOT t.claim_type_descr IN
                                      ('RETROFIT MATERIAL', 'RETROFIT LABOR')
                      AND NOT (    t.claim_type_descr IN
                                      ('MATERIAL',
                                       'SPD',
                                       'CONCESSION',
                                       'EXTENDED PURCHASED LABOR'
                                      )
                               AND SUBSTR (tk.task_code, 1, 1) = 'Z'
                              )
                      AND ((tf.full_date <= ew.end_date
                                  )
                             AND wp.wa_policy_type IN
                                                     ('00', '01', '03', '04'))
          UNION ALL
/* Category 4 claim selection is by NULL order number and serial number = '?' */
          SELECT          /*+ INDEX(w XIE1WC_MAT_LBR_ROLLUP) */
                 DISTINCT w.claim_nbr AS claim, w.detail_nbr AS detail,
                          w.step_nbr AS step, '01' AS warr_type,
                          'EFFECTIVE' AS eff_warr, NULL AS warr_start,
                          NULL AS warr_end, t.claim_type_code AS claim_type,
                          tf.full_date AS cl_fail_date,
                          /* new logic msun 05152007 */
                          --ts.full_date AS cl_ship_date,
                          (case when ts.full_date='1-JAN-1900' then tr.full_date else ts.full_date end)  AS cl_ship_date,
                          tr.full_date AS cl_start_date, g.ACCOUNT,
                          w.sales_order_prime, w.parent_serial_nbr,
                          '4' AS warr_category
                     FROM WC_MAT_LBR_ROLLUP w,
                          TIME_DAY tt,
                          TIME_DAY tf,
                          TIME_DAY ts,
                          TIME_DAY tr,
                          CLAIM_TYPE_SCD t,
                          GL_ACCOUNT_SCD g,
                          CLAIM_TASK_SCD tk
                    WHERE w.ccn_trx_date_key = tt.time_key
                    AND tt.full_date >= '1-JAN-2001'
                      AND w.fail_date_key = tf.time_key
                      AND w.start_date_key = tr.time_key
                      AND w.original_ship_date_key = ts.time_key
                      AND w.claim_type_scd_key = t.claim_type_scd_key
                      AND w.gl_account_scd_key = g.gl_account_scd_key
                      AND w.claim_task_scd_key = tk.claim_task_scd_key(+)
                      AND w.parent_serial_nbr = '?'
                      AND w.sales_order_prime IS NULL
                      AND (g.ACCOUNT LIKE '%8062%' or  g.ACCOUNT LIKE '%0620%')
                      AND NOT t.claim_type_descr IN
                                      ('RETROFIT MATERIAL', 'RETROFIT LABOR')
                      AND NOT (    t.claim_type_descr IN
                                      ('MATERIAL',
                                       'SPD',
                                       'CONCESSION',
                                       'EXTENDED PURCHASED LABOR'
                                      )
                               AND SUBSTR (tk.task_code, 1, 1) = 'Z'
                              ))
GROUP BY claim, detail, step, cl_fail_date, cl_ship_date, cl_start_date;

/*****************************************************************************************
 This Cursor selects data for Incremental Load of dm_fal_claims_warranty_xrf table
 following portion has been removed for monthly reload
*****************************************************************************************/
/* Initial Load procedrure */

PROCEDURE P_CLAIMS_WARR_XREF_LOAD;

/* Incremental Load procedrure */

/*PROCEDURE P_CLAIMS_WARR_XREF_INC_LOAD;*/

END Pkg_Cl_Warranty_Xref;
/

CREATE OR REPLACE PACKAGE BODY DBO.Pkg_Cl_Warranty_Xref AS

    SUBTYPE t_identifier IS VARCHAR2(30);

    G_PKG_NAME CONSTANT t_identifier := 'PKG_CL_WARRANTY_XREF';

    /***********************************************************************************
    * Procedure P_PROCESS_ERRORS
    *
    * Description: Inserts a record into the SY_LOG_ERROR table when problems occur
    *   anywhere in the package.
    *
    * Author: Prasanth V, Cognizant
    *
    * Create Date: 03/05/2010
    *
    * Change Reference (TTP 9297)
    *
    * Revisions:
    *
    *    Change Date   Developer    Change Description (including TTP)
    *   ------------   ---------    ----------------------------------
    *
    ***********************************************************************************/

    PROCEDURE p_process_errors(
            p_package_name_in           IN sy_log_error.package_name%TYPE,
            p_procedure_name_in         IN sy_log_error.procedure_name%TYPE,
            p_source_code_marker_in     IN sy_log_error.source_code_marker%TYPE,
            p_oracle_error_message_in   IN sy_log_error.oracle_error_message%TYPE,
            p_error_notes_in            IN sy_log_error.error_notes%TYPE)
    IS

        l_proc_name         t_identifier := 'P_PROCESS_ERRORS';

    BEGIN
    -- perform insert into error table
        INSERT INTO sy_log_error(
            sy_log_error_key,
            package_name,
            procedure_name,
            source_code_marker,
            oracle_error_message,
            error_notes,
            error_timestamp)
        VALUES(
            sy_log_error_seq.NEXTVAL,
            p_package_name_in,
            p_procedure_name_in,
            p_source_code_marker_in,
            p_oracle_error_message_in,
            p_error_notes_in,
            SYSDATE);

        COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
        /*If an error occurred while trying to log the error, call the error
        process procedure again and log a message indicating the error */
        p_process_errors(
            G_PKG_NAME,
            l_proc_name,
            NULL,
            SUBSTR(SQLERRM,1,255),
            'An error occurred when attempting to insert into error table.');
    END p_process_errors;

   /********************************************************************************************
    *
    * Description: Performs an Initial load of Claims Warranty Xref table with data from
    * Jan 2001 to Feb 2007
    *
    * Revisions:
    *
    *   Change Date    Change Description
    *   -----------    ------------------
    *   8-FEB-2007    Venu Hemadri, TTP#9290
    *                  Creation.
    *   27-FEB-2007      Venu Hemadri, TTP#9290
    *                  Added functionality to return completion code to AppWorx
    *   07-MAR-2007      Venu Hemadri, TTP#9290
    *                  Added functionality for Truncating dm_fal_claims_warranty_xrf table
    *                  before Initial Load.
    *   03/18/2010    Prasanth Viswanathan, Cognizant TTP 9297
    *                    Replaced the QMS error logging by standard including standard error process procedure
    *			 which logs errors into the error table SY_LOG_ERROR
    *********************************************************************************************/
   PROCEDURE p_claims_warr_xref_load
   IS
      l_level                   BINARY_INTEGER     := 0;
      l_claim_nbr               NUMBER (8);
      l_detail_nbr              NUMBER (9);
      l_step_nbr                NUMBER (9);
      l_wa_policy_type          VARCHAR2 (3);
      l_wa_range                VARCHAR2 (2);
      l_proc_name               VARCHAR2 (30)      := 'P_CLAIMS_WARR_XREF_LOAD';
      l_fetch_count             INTEGER            := 0;
      l_ins_count               INTEGER            := 0;
      l_total_ins_count         INTEGER            := 0;
      l_warranty_rank           VARCHAR2 (3);
      l_cl_fail_date            DATE;
      l_cl_ship_date            DATE;
      l_cl_start_date           DATE;
      l_fetch_limit    CONSTANT INTEGER            := 3000;
      l_commit_limit   CONSTANT INTEGER            := 10000;

      TYPE t_cl_warranty_xref IS TABLE OF c_claims_warr_xref_load%ROWTYPE
         INDEX BY BINARY_INTEGER;

      l_cl_warranty_xref_t      t_cl_warranty_xref;
   BEGIN
      l_level := 1;

      OPEN c_claims_warr_xref_load;

      /* Truncate DM_FAL_CLAIMS_WARRANTY_XRF table before making an Initial load */
      IF c_claims_warr_xref_load%ISOPEN
         THEN
              P_Truncate_Listed_Table('DBO','DM_FAL_CLAIMS_WARRANTY_XRF');
         END IF;

      l_level := 2;

      LOOP
         l_fetch_count := c_claims_warr_xref_load%ROWCOUNT;
         l_level := 3;

         FETCH c_claims_warr_xref_load
         BULK COLLECT INTO l_cl_warranty_xref_t LIMIT l_fetch_limit;

         l_level := 4;
         EXIT WHEN (l_fetch_count = c_claims_warr_xref_load%ROWCOUNT);
         l_level := 5;

         FOR l_index IN
            l_cl_warranty_xref_t.FIRST .. l_cl_warranty_xref_t.LAST
         LOOP
            l_level := 6;
            l_claim_nbr := l_cl_warranty_xref_t (l_index).claim;
            l_detail_nbr := l_cl_warranty_xref_t (l_index).detail;
            l_step_nbr := l_cl_warranty_xref_t (l_index).step;
            l_warranty_rank := l_cl_warranty_xref_t (l_index).warranty_rank;
            l_cl_fail_date := l_cl_warranty_xref_t (l_index).cl_fail_date;
            l_cl_ship_date := l_cl_warranty_xref_t (l_index).cl_ship_date;
            l_cl_start_date := l_cl_warranty_xref_t (l_index).cl_start_date;
            l_level := 5;

            CASE
               WHEN l_warranty_rank >= '8'
               THEN
                  l_wa_policy_type := '01';
               WHEN l_warranty_rank >= '4'
               THEN
                  l_wa_policy_type := '00';
               WHEN l_warranty_rank >= '2'
               THEN
                  l_wa_policy_type := '04';
               WHEN l_warranty_rank = '1'
               THEN
                  l_wa_policy_type := '03';
               ELSE
                  l_wa_policy_type := 'NO';
            END CASE;

            l_level := 7;

            CASE
               WHEN l_warranty_rank >= '8'
               AND ADD_MONTHS (l_cl_ship_date, 18) >= l_cl_fail_date
                   /* msun 05/29/07 */
                       AND ADD_MONTHS (l_cl_start_date, 12) >= l_cl_fail_date
               THEN
                  l_wa_range := '1';
               WHEN l_warranty_rank >= '8'
               AND ADD_MONTHS (l_cl_ship_date, 66) >= l_cl_fail_date
                   /* msun 05/29/07 */
                       AND ADD_MONTHS (l_cl_start_date, 60) >= l_cl_fail_date
               THEN
                  l_wa_range := '2';
               WHEN l_warranty_rank >= '8'
               THEN
                  l_wa_range := '5';
               WHEN l_warranty_rank >= '4'
               AND ADD_MONTHS (l_cl_start_date, 12) >= l_cl_fail_date
               THEN
                  l_wa_range := '1';
               WHEN l_warranty_rank >= '4'
               AND ADD_MONTHS (l_cl_start_date, 60) >= l_cl_fail_date
               THEN
                  l_wa_range := '2';
               WHEN l_warranty_rank >= '4'
               THEN
                  l_wa_range := '5';
               WHEN l_warranty_rank >= '2'
               AND ADD_MONTHS (l_cl_start_date, 12) >= l_cl_fail_date
               THEN
                  l_wa_range := '1';
               WHEN l_warranty_rank >= '2'
               AND ADD_MONTHS (l_cl_start_date, 60) >= l_cl_fail_date
               THEN
                  l_wa_range := '2';
               WHEN l_warranty_rank >= '2'
               THEN
                  l_wa_range := '5';
               WHEN l_warranty_rank = '1'
               AND ADD_MONTHS (l_cl_start_date, 12) >= l_cl_fail_date
               THEN
                  l_wa_range := '1';
               WHEN l_warranty_rank = '1'
               AND ADD_MONTHS (l_cl_start_date, 60) >= l_cl_fail_date
               THEN
                  l_wa_range := '2';
               WHEN l_warranty_rank = '1'
               THEN
                  l_wa_range := '5';
               ELSE
                  l_wa_range := 'NO';
            END CASE;

            l_level := 8;

            /* msun 05/29/07 */
          --  TRUNCATE table DM_FAL_CLAIMS_WARRANTY_XRF DROP STORAGE;

            INSERT      /*+ APPEND */INTO DM_FAL_CLAIMS_WARRANTY_XRF
                        (claim_nbr, detail_nbr, step_nbr,
                         wa_policy_type, wa_range, dw_create_date,
                         dw_create_id, dw_last_update_date, dw_last_update_id
                        )
                 VALUES (l_claim_nbr, l_detail_nbr, l_step_nbr,
                         l_wa_policy_type, l_wa_range, SYSDATE,
                         l_proc_name, SYSDATE, l_proc_name
                        );

            l_level := 9;
            l_ins_count := l_ins_count + SQL%ROWCOUNT;
            l_total_ins_count := l_total_ins_count + l_ins_count;
            l_level := 10;

            IF (l_ins_count >= l_commit_limit)
            THEN
               COMMIT;
               l_ins_count := 0;
            END IF;

            l_level := 11;
         END LOOP;

         l_level := 12;
      END LOOP;

      CLOSE c_claims_warr_xref_load;

      DBMS_OUTPUT.PUT_LINE ('DWBS_SUCCESS');
   EXCEPTION
      WHEN OTHERS
      THEN
         IF c_claims_warr_xref_load%ISOPEN
         THEN
            CLOSE c_claims_warr_xref_load;
         END IF;

           p_process_errors(
                G_PKG_NAME,
                L_PROC_NAME,
                l_level,
                SUBSTR(SQLERRM, 1, 255),
                'DM_FAL_CLAIMS_WARRANTY_XRF was not loaded due to error');

      DBMS_OUTPUT.put_line ('DWBS_FAILURE');

    RAISE;

   END p_claims_warr_xref_load;

END Pkg_Cl_Warranty_Xref;
/

