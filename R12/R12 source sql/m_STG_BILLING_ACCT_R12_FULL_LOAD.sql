/* Formatted on 2016/10/24 15:45 (Formatter Plus v4.8.8) */
SELECT rctl.customer_trx_line_id, rctgd.cust_trx_line_gl_dist_id,
       NULL zero_or_non_zero, NVL (rctgd.amount, 0) line_gl_amt,
       NVL (rctgd.acctd_amount, 0) line_gl_fun_amt, NULL business_unit_gl,
       rbs.NAME bill_source_id, rctgd.gl_date gl_date,
       rct.trx_number tran_nbr
                              --,rctl.line_number LINE_SEQ_NUM
       , NULL line_seq_num, rctt.TYPE trx_class, rctt.NAME trx_type,
       hca_billto.account_number bill_cust_acct,
       hca_billto.account_name bill_cust_name
                                             -- ,rct.attribute5 linked_inv_nbr
       , rct.attribute8 crd_job_nbr,
       NVL (DECODE (rbs.NAME,
                    'P21', rct.interface_header_attribute2,
                    NVL (rctl.sales_order, rctl.interface_line_attribute1)
                   ),
            0
           ) sales_ord_nbr
                          --,(SELECT NAME  FROM hr_organization_units_v houv  WHERE houv.organization_id = rctl.warehouse_id and rownum=1) business_unit
       ,
       NULL business_unit
--        ,Decode(rbs.NAME ,'P21' ,
--           ( select resource_name from jtf_rs_resource_extns_tl jrt where jrt.resource_id = jrre.resource_id and rownum =1)
--           ,(SELECT NAME  FROM hr_organization_units_v houv  WHERE houv.organization_id = rctl.warehouse_id and rownum=1)) plant_loc
       , NULL plant_loc, NULL planned_shipment,
       (SELECT ffvc1.description
          FROM fnd_flex_values_vl ffvc,
               fnd_flex_values_vl ffvc1,
               fnd_flex_values_vl ffvc2,
               fnd_flex_value_norm_hierarchy ffvcp1,
               fnd_flex_value_norm_hierarchy ffvcp2
         WHERE gcc_rec.segment2 = ffvc.flex_value
           AND ffvc.flex_value_set_id = 1014929
           AND ffvc.enabled_flag = 'Y'
           AND ffvc.flex_value BETWEEN ffvcp1.child_flex_value_low
                                   AND ffvcp1.child_flex_value_high
           AND ffvcp1.parent_flex_value LIKE 'P%'
           --AND ffvcp1.RANGE_ATTRIBUTE ='C'
           AND ffvcp1.flex_value_set_id = ffvc.flex_value_set_id
           AND SYSDATE BETWEEN NVL (ffvcp1.start_date_active, SYSDATE)
                           AND NVL (ffvcp1.end_date_active, SYSDATE)
           AND ffvcp2.parent_flex_value LIKE 'P%'
           --AND ffvcp2.RANGE_ATTRIBUTE ='C'
           AND SYSDATE BETWEEN NVL (ffvcp2.start_date_active, SYSDATE)
                           AND NVL (ffvcp2.end_date_active, SYSDATE)
           AND ffvcp2.flex_value_set_id = ffvc.flex_value_set_id
           AND ffvcp1.parent_flex_value BETWEEN ffvcp2.child_flex_value_low
                                            AND ffvcp2.child_flex_value_high
           AND ffvc1.enabled_flag = 'Y'
           AND ffvc2.enabled_flag = 'Y'
           AND ffvc1.flex_value_set_id = ffvc.flex_value_set_id
           AND ffvc2.flex_value_set_id = ffvc.flex_value_set_id
           AND ffvc1.flex_value = ffvcp1.parent_flex_value
           AND ffvc2.flex_value = ffvcp2.parent_flex_value
           AND ROWNUM = 1) sales_district,
       (SELECT ffvc3.description
          FROM fnd_flex_values_vl ffvc,
               fnd_flex_values_vl ffvc1,
               fnd_flex_values_vl ffvc2,
               fnd_flex_values_vl ffvc3,
               fnd_flex_value_norm_hierarchy ffvcp1,
               fnd_flex_value_norm_hierarchy ffvcp2,
               fnd_flex_value_norm_hierarchy ffvcp3
         WHERE gcc_rec.segment2 = ffvc.flex_value
           AND ffvc.flex_value_set_id = 1014929
           AND ffvc.enabled_flag = 'Y'
           AND ffvc.flex_value BETWEEN ffvcp1.child_flex_value_low
                                   AND ffvcp1.child_flex_value_high
           AND ffvcp1.parent_flex_value LIKE 'P%'
           --AND ffvcp1.RANGE_ATTRIBUTE ='C'
           AND ffvcp1.flex_value_set_id = ffvc.flex_value_set_id
           AND SYSDATE BETWEEN NVL (ffvcp1.start_date_active, SYSDATE)
                           AND NVL (ffvcp1.end_date_active, SYSDATE)
           AND ffvcp2.parent_flex_value LIKE 'P%'
           --AND ffvcp2.RANGE_ATTRIBUTE ='C'
           AND SYSDATE BETWEEN NVL (ffvcp2.start_date_active, SYSDATE)
                           AND NVL (ffvcp2.end_date_active, SYSDATE)
           AND ffvcp2.flex_value_set_id = ffvc.flex_value_set_id
           AND ffvcp1.parent_flex_value BETWEEN ffvcp2.child_flex_value_low
                                            AND ffvcp2.child_flex_value_high
           AND ffvcp3.parent_flex_value LIKE 'P%'
           --AND ffvcp2.RANGE_ATTRIBUTE ='C'
           AND SYSDATE BETWEEN NVL (ffvcp3.start_date_active, SYSDATE)
                           AND NVL (ffvcp3.end_date_active, SYSDATE)
           AND ffvcp3.flex_value_set_id = ffvc.flex_value_set_id
           AND ffvcp2.parent_flex_value BETWEEN ffvcp3.child_flex_value_low
                                            AND ffvcp3.child_flex_value_high
           AND ffvc1.enabled_flag = 'Y'
           AND ffvc2.enabled_flag = 'Y'
           AND ffvc3.enabled_flag = 'Y'
           AND ffvc1.flex_value_set_id = ffvc.flex_value_set_id
           AND ffvc2.flex_value_set_id = ffvc.flex_value_set_id
           AND ffvc3.flex_value_set_id = ffvc.flex_value_set_id
           AND ffvc1.flex_value = ffvcp1.parent_flex_value
           AND ffvc2.flex_value = ffvcp2.parent_flex_value
           AND ffvc3.flex_value = ffvcp3.parent_flex_value
           AND ROWNUM = 1) territory,
       rct.invoice_currency_code trx_currency_cd, rct.attribute9 project_type,
       rct.reason_code claim_type, rct.purchase_order po_ref
                                                             -- ,rct.attribute1 BILL_TYPE_ID
                                                              --,rct.PRIMARY_SALESREP_ID Sales_Branch
                                                            --,NVL( jrre.attribute1,DECODE (rct.org_id, 456, 'D2', 457, 'CH', 'NA')) sales_office_code
       ,
       jrre.attribute1 sales_office_code, --jrs.NAME sales_branch_name,
	   jrre1.resource_name sales_branch_name,
       (SELECT fll.description
          FROM fnd_flex_values_vl fll
         WHERE fll.flex_value_set_id = 1014929      -- location
           AND fll.flex_value = gcc_rec.segment2) location_desc,
       gcc_rec.segment1 rec_gl_acct_entity,
       gcc_rec.segment2 rec_gl_acct_location,
       gcc_rec.segment3 rec_gl_acct_cost_center,
       gcc_rec.segment4 rec_gl_acct_account,
       gcc_rec.segment5 rec_gl_acct_product,
       gcc_rec.segment6 rec_gl_acct_intercompany,
       gcc_rec.segment7 rec_gl_acct_future1,
       gcc_rec.segment8 rec_gl_acct_future2, gcc.segment1 rev_gl_acct_entity,
       gcc.segment2 rev_gl_acct_location,
       gcc.segment3 rev_gl_acct_cost_center, gcc.segment4 rev_gl_acct_account,
       gcc.segment5 rev_gl_acct_product,
       gcc.segment6 rev_gl_acct_intercompany,
       gcc.segment7 rev_gl_acct_future1, gcc.segment8 rev_gl_acct_future2,
       rctgd.comments reg_gl_type, rctgd.account_class account_class,
       DECODE (rbs.NAME,
               'P21', SUBSTR (rctl.description,
                              1,
                              INSTR (rctl.description, '~', 1, 1) - 1
                             ),
               msi.segment1
              ) item_number,
       DECODE (rbs.NAME,
               'P21', SUBSTR (rctl.description,
                              INSTR (rctl.description, '~', 1, 1) + 1
                             ),
               NVL (rctl.translated_description, rctl.description)
              ) item_desc,
       hou.NAME ou_name, rct.exchange_rate, gjh.NAME journal_name,
       NULL journal_id, gjb.NAME gl_batch_name, gjb.posted_date,
       (SELECT    mic.segment1
               || '.'
               || mic.segment2
               || '.'
               || mic.segment3
               || '.'
               || mic.segment4
               || '.'
               || mic.segment5
               || '.'
               || mic.segment6
          FROM mtl_item_categories_v mic, mtl_system_items msi1
         WHERE mic.inventory_item_id = msi1.inventory_item_id
           AND msi1.segment1 =
                  DECODE (rbs.NAME,
                          'P21', SUBSTR (rctl.description,
                                         1,
                                           INSTR (rctl.description, '~', 1, 1)
                                         - 1
                                        ),
                          msi.segment1
                         )
           AND mic.category_set_name = 'IRPLN SIOP CATEGORY'
           AND mic.organization_id = msi1.organization_id
           AND msi1.organization_id = NVL (rctl.warehouse_id, 99)
           AND ROWNUM = 1) siop_number,
       NULL AS dept_id
       -- added by Anand Pingle for EC customer derivation
       ,hps.party_site_number R12_CUST_SITE_NUMBER 
       ,(SELECT hosr.orig_system_reference 
           FROM hz_orig_sys_references hosr
         WHERE  hosr.owner_table_name = 'HZ_CUST_ACCT_SITES_ALL'
           AND  hosr.orig_system = 'TCS_ENT_CUSTOMER'
           AND  hcas.cust_acct_site_id= hosr.owner_table_id
           AND TRUNC (SYSDATE)  BETWEEN NVL (TRUNC (hosr.start_date_active), TRUNC (SYSDATE))
                AND NVL (TRUNC (hosr.end_date_active),  TRUNC (SYSDATE))
           AND hosr.status = 'A'
           AND ROWNUM=1) EC_CUST_NUMBER,
           hcas.attribute6  DEFAULT_BRANCH,
           (select name from hr_organization_units_v houv where houv.organization_id=rctl.warehouse_id and rownum=1) INV_ORG
  FROM ra_customer_trx_all rct,
       ra_customer_trx_lines_all rctl,
       ra_batch_sources_all rbs,
       ra_cust_trx_line_gl_dist_all rctgd,
       ra_cust_trx_line_gl_dist_all rctgd_rec,
       hz_cust_accounts hca_billto,
      --START added by Anand Pingle for EC customer derivation
       hz_cust_site_uses_all hcsu,
       hz_cust_acct_sites_all hcas,
       hz_party_sites hps,
      --END added by Anand Pingle for EC customer derivation
       ra_cust_trx_types_all rctt,
       hz_parties hp_billto,
       jtf_rs_salesreps jrs,
       jtf_rs_resource_extns jrre,
	   jtf_rs_resource_extns_tl jrre1,
       gl_code_combinations_kfv gcc,
       gl_code_combinations_kfv gcc_rec,
       hr_operating_units hou,
       xla_distribution_links xdl,
       xla_ae_headers aeh,
       xla_ae_lines ael,
       xla_distribution_links xdl_rec,
       xla_ae_headers aeh_rec,
       xla_ae_lines ael_rec,
       mtl_system_items msi,
       gl_je_lines gjl,
       gl_je_headers gjh,
       gl_import_references gir,
       gl_je_batches gjb
 WHERE rctgd.customer_trx_id = rct.customer_trx_id
   AND rctl.customer_trx_id = rct.customer_trx_id
   AND rct.cust_trx_type_id = rctt.cust_trx_type_id
   AND rct.complete_flag = 'Y'
   -- AND rctgd_rec.posting_control_id <> -3
   AND msi.inventory_item_id(+) = rctl.inventory_item_id
   AND msi.organization_id(+) = NVL (rctl.warehouse_id, 99)
   AND rctt.org_id = rct.org_id
   AND rbs.batch_source_id = rct.batch_source_id
   AND rct.org_id IN (456, 457)                     -- US TCS and CA TCS  Only
   AND rbs.NAME IN
          ('P21', 'ORDER ENTRY', 'TCS MANUAL')
                                      -- batch source P21 and Order Entry only
   AND rbs.org_id = rct.org_id
   AND jrs.salesrep_id(+) = rct.primary_salesrep_id
   AND jrs.resource_id = jrre.resource_id(+)
   AND jrre.resource_id = jrre1.resource_id(+) -- Added for SALES_BRANCH column
   AND jrre1.language(+) = 'US' -- Added for SALES_BRANCH column
   AND jrs.org_id(+) = rct.org_id
   AND rct.bill_to_customer_id = hca_billto.cust_account_id
   AND hca_billto.party_id = hp_billto.party_id
   AND NVL (rctgd.customer_trx_line_id, rctl.customer_trx_line_id) =
                                                     rctl.customer_trx_line_id
   AND hou.organization_id = rct.org_id
   --- Rev XLA Accounting
   AND rctgd.account_class <> 'REC'
   AND ael.code_combination_id = gcc.code_combination_id
   AND rctgd.cust_trx_line_gl_dist_id = xdl.source_distribution_id_num_1
   AND rctgd.event_id = xdl.event_id
   AND xdl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   AND xdl.application_id = 222
   AND xdl.ae_header_id = aeh.ae_header_id
   AND xdl.ae_header_id = ael.ae_header_id
   AND xdl.ae_line_num = ael.ae_line_num
   -- Rec XLA Accounting
   AND rctgd_rec.customer_trx_id = rct.customer_trx_id
   AND rctgd_rec.account_class = 'REC'
   AND NVL (rctgd_rec.latest_rec_flag, 'Y') = 'Y'
   AND ael_rec.code_combination_id = gcc_rec.code_combination_id
   AND rctgd_rec.cust_trx_line_gl_dist_id =
                                          xdl_rec.source_distribution_id_num_1
   AND rctgd.event_id = xdl_rec.event_id
   AND xdl_rec.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   AND xdl_rec.application_id = 222
   AND xdl_rec.ae_header_id = aeh_rec.ae_header_id
   AND xdl_rec.ae_header_id = ael_rec.ae_header_id
   AND xdl_rec.ae_line_num = ael_rec.ae_line_num
   AND gjh.je_header_id = gjl.je_header_id
   AND gjl.je_header_id(+) = gir.je_header_id
   AND gjl.je_line_num(+) = gir.je_line_num
   AND gir.gl_sl_link_table(+) = ael.gl_sl_link_table
   AND gir.gl_sl_link_id(+) = ael.gl_sl_link_id
   AND gjh.je_source = 'Receivables'
   AND gjb.je_batch_id = gjh.je_batch_id
   AND gjh.ledger_id in (2041,2022) -- To avoid Duplication data by restricting only PRIMARY Ledger
   AND rct.bill_to_site_use_id=hcsu.site_use_id
   AND hcsu.cust_acct_site_id=hcas.cust_acct_site_id
   AND hcas.party_site_id=hps.party_site_id
	 and rct.trx_number in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828');