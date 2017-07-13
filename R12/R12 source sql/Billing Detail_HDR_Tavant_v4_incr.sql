/* Formatted on 2016/10/24 16:00 (Formatter Plus v4.8.8) */
-- Billing Detail HDR Report Query 
SELECT rctl.customer_trx_line_id, rct.customer_trx_id,
       rct.trx_number tran_nbr, rct.invoice_currency_code currency,
       rct.purchase_order po_nbr, rct.trx_date ship_date,
       rct.trx_date inv_date, hca_billto.account_number bill_cust_acct,
       hcsu_billto.LOCATION bill_to_location,
       DECODE (rbs.NAME,
               'P21', rct.interface_header_attribute2,
               NVL (rctl.sales_order, rctl.interface_line_attribute1)
              ) sales_ord_nbr,
       NVL (aps.amount_due_original,
            (SELECT SUM (NVL (rctl1.extended_amount, 0))
               FROM ra_customer_trx_lines_all rctl1
              WHERE rctl1.customer_trx_id = rctl.customer_trx_id)
           ) header_total,
       hca_shipto.account_number ship_cust_acct,
       hcsu_shipto.LOCATION ship_to_location,
       hca_billto.account_name bill_cust_name,
       loc_billto.address1 bill_cust_address1,
       loc_billto.address2 bill_cust_address2,
       loc_billto.address3 bill_cust_address3,
       loc_billto.address4 bill_cust_address4, loc_billto.city bill_city,
       loc_billto.state bill_state, loc_billto.county bill_county,
       loc_billto.postal_code bill_postal, rct.attribute8 crd_job_nbr,
       rct.internal_notes crd_job_name
                                      --,Decode(rbs.NAME ,'ORDER ENTRY',interface_line_attribute3 , null) planned_shipment
       , NULL planned_shipment, rct.attribute9 proj_type
                                                        --,(SELECT NAME  FROM hr_organization_units_v houv  WHERE houv.organization_id = rctl.warehouse_id and rownum=1) business_unit -- for p21 it will be sale office name
       , NULL business_unit
--        ,Decode(rbs.NAME ,'P21' ,
--           ( select resource_name from jtf_rs_resource_extns_tl jrt where jrt.resource_id = jrre.resource_id and rownum =1)
--           ,(SELECT mtl.ORGANIZATION_CODE  FROM mtl_parameters mtl  WHERE mtl.organization_id = rctl.warehouse_id and rownum=1)) plant_loc
       , NULL plant_loc, hca_shipto.account_name ship_cust_name,
       loc_shipto.address1 ship_cust_address1,
       loc_shipto.address2 ship_cust_address2,
       loc_shipto.address3 ship_cust_address3,
       loc_shipto.address4 ship_cust_address4, loc_shipto.city ship_city,
       loc_shipto.state ship_state, loc_shipto.county ship_county,
       loc_shipto.postal_code ship_postal, rct.comments hdr_note,
       --jrs.NAME sales_branch
       jrre1.resource_name sales_branch
                            --,NVL( jrre.attribute1,DECODE (rct.org_id, 456, 'D2', 457, 'CH', 'NA')) sales_office_code
       , jrre.attribute1 sales_office_code,
       (SELECT ffvc1.description
          FROM fnd_flex_values_vl ffvc,
               fnd_flex_values_vl ffvc1,
               fnd_flex_values_vl ffvc2,
               fnd_flex_value_norm_hierarchy ffvcp1,
               fnd_flex_value_norm_hierarchy ffvcp2
         WHERE gcc.segment2 = ffvc.flex_value
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
         WHERE gcc.segment2 = ffvc.flex_value
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
       (SELECT fll.description
          FROM fnd_flex_values_vl fll
         WHERE fll.flex_value_set_id = 1014929      -- location
           AND fll.flex_value = gcc.segment2) location_desc,
       gcc.segment1 rec_gl_acct_entity, gcc.segment2 rec_gl_acct_location,
       gcc.segment3 rec_gl_acct_cost_center, gcc.segment4 rec_gl_acct_account,
       gcc.segment5 rec_gl_acct_product,
       gcc.segment6 rec_gl_acct_intercompany,
       gcc.segment7 rec_gl_acct_future1, gcc.segment8 rec_gl_acct_future2,
       NVL (rbs.NAME, 0) batch_source,
       DECODE (rbs.NAME,
               'P21', rct.interface_header_attribute10,
               rct.interface_header_attribute2
              ) billing_type,
       NVL (hou.NAME, 0) ou_name, rct.attribute5 "Related Trx Number",
       rct.exchange_rate, gjh.NAME journal_name, NULL journal_id,
       gjb.NAME gl_batch_name, gjb.posted_date, NULL AS dept_id,
       DECODE (rbs.NAME,
               'P21', DECODE (rct.interface_header_attribute10,
                              'SER', rct.purchase_order,
                              NULL
                             ),
               NULL
              ) trnbi_srv_call_id
       -- added by Anand Pingle for EC customer derivation
       ,hps_billto.party_site_number R12_CUST_SITE_NUMBER 
       ,(SELECT hosr.orig_system_reference 
           FROM hz_orig_sys_references hosr
         WHERE  hosr.owner_table_name = 'HZ_CUST_ACCT_SITES_ALL'
           AND  hosr.orig_system = 'TCS_ENT_CUSTOMER'
           AND  hcas_billto.cust_acct_site_id= hosr.owner_table_id
           AND TRUNC (SYSDATE)  BETWEEN NVL (TRUNC (hosr.start_date_active), TRUNC (SYSDATE))
                AND NVL (TRUNC (hosr.end_date_active),  TRUNC (SYSDATE))
           AND hosr.status = 'A'
           AND ROWNUM=1) EC_CUST_NUMBER,
           hcas_billto.attribute6  DEFAULT_BRANCH	
           ,(select name from hr_organization_units_v houv where houv.organization_id=rctl.warehouse_id and rownum=1) INV_ORG
		   ,' ' AS REV_GL_ACCT_ACCOUNT
              
  FROM ar_payment_schedules_all aps,
       ra_customer_trx_all rct,
       ra_customer_trx_lines_all rctl,
       ra_batch_sources_all rbs,
       jtf_rs_salesreps jrs,
       jtf_rs_resource_extns jrre,
       jtf_rs_resource_extns_tl jrre1,
       hz_parties hp_billto,
       hz_cust_accounts hca_billto,
       hz_cust_acct_sites_all hcas_billto,
       hz_cust_site_uses_all hcsu_billto,
       hz_party_sites hps_billto,
       hz_locations loc_billto,
       hz_parties hp_shipto,
       hz_cust_accounts hca_shipto,
       hz_cust_acct_sites_all hcas_shipto,
       hz_cust_site_uses_all hcsu_shipto,
       hz_party_sites hps_shipto,
       hz_locations loc_shipto,
       ra_cust_trx_line_gl_dist_all rctgd,
       gl_code_combinations_kfv gcc,
       hr_operating_units hou,
       xla_distribution_links xdl,
       xla_ae_headers aeh,
       xla_ae_lines ael,
       gl_je_lines gjl,
       gl_je_headers gjh,
       gl_import_references gir,
       gl_je_batches gjb,
       gl_ledgers gll,
       mtl_system_items msi,
       (select al.externally_visible_flag,hou.organization_id org_id
        FROM
        ar_lookups al,
        hr_operating_units hou
        WHERE al.lookup_type='XXAR_BILLING_RPT_OU_SOURCE'
        AND al.enabled_flag='Y'
        AND TRUNC(SYSDATE) BETWEEN NVL(al.start_date_active,SYSDATE-1) AND NVL(al.end_date_active,SYSDATE+1) 
        AND hou.name=al.description
        AND NVL(al.attribute1,'XX') NOT IN ('INTERNATIONAL')) all_source
 WHERE aps.customer_trx_id(+) = rct.customer_trx_id
   AND rct.org_id=all_source.org_id                   -- US TCS and CA TCS  Only
   AND rbs.name=all_source.externally_visible_flag
   AND rbs.org_id=all_source.org_id
   AND rctl.customer_trx_id = rct.customer_trx_id
   AND rctl.line_type = 'LINE'
   AND rctl.line_number = 1
   AND rbs.batch_source_id = rct.batch_source_id
   AND rbs.org_id = rct.org_id
  -- AND rct.org_id IN (456, 457)                     -- US TCS and CA TCS  Only
   AND rct.complete_flag = 'Y'
   --AND rctgd.posting_control_id <> -3
   AND jrs.salesrep_id(+) = rct.primary_salesrep_id
   AND jrs.resource_id = jrre.resource_id(+)
   AND jrre.resource_id = jrre1.resource_id(+) -- Added for SALES_BRANCH column
   AND jrre1.language(+) = 'US' -- Added for SALES_BRANCH column
   AND jrs.org_id(+) = rct.org_id
   AND rct.bill_to_customer_id = hca_billto.cust_account_id
   AND rct.bill_to_site_use_id = hcsu_billto.site_use_id
   AND hca_billto.party_id = hp_billto.party_id
   AND hcsu_billto.cust_acct_site_id = hcas_billto.cust_acct_site_id
   AND loc_billto.location_id = hps_billto.location_id
   AND hps_billto.party_site_id = hcas_billto.party_site_id
   AND NVL (rct.ship_to_site_use_id, rct.bill_to_site_use_id) =
                                                       hcsu_shipto.site_use_id
   AND NVL (rct.ship_to_customer_id, rct.bill_to_customer_id) =
                                                    hca_shipto.cust_account_id
   AND hca_shipto.party_id = hp_shipto.party_id
   AND hcsu_shipto.cust_acct_site_id = hcas_shipto.cust_acct_site_id
   AND loc_shipto.location_id = hps_shipto.location_id
   AND hps_shipto.party_site_id = hcas_shipto.party_site_id
   AND rctgd.customer_trx_id = rct.customer_trx_id
   AND NVL (rctgd.latest_rec_flag, 'Y') = 'Y'
   AND rctgd.account_class = 'REC'
   AND hou.organization_id = rct.org_id
   AND ael.code_combination_id = gcc.code_combination_id
   AND rctgd.cust_trx_line_gl_dist_id = xdl.source_distribution_id_num_1
   AND rctgd.event_id = xdl.event_id
   AND xdl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   AND xdl.application_id = 222
   AND xdl.ae_header_id = aeh.ae_header_id
   AND xdl.ae_header_id = ael.ae_header_id
   AND xdl.ae_line_num = ael.ae_line_num
   AND gjh.je_header_id = gjl.je_header_id
   AND gjl.je_header_id(+) = gir.je_header_id
   AND gjl.je_line_num(+) = gir.je_line_num
   AND gir.gl_sl_link_table(+) = ael.gl_sl_link_table
   AND gir.gl_sl_link_id(+) = ael.gl_sl_link_id
   AND gjh.je_source = 'Receivables'
   AND gjb.je_batch_id = gjh.je_batch_id
   AND gjh.ledger_id=gll.ledger_id
   AND gll.ledger_category_code='PRIMARY'
   AND msi.inventory_item_id(+) = rctl.inventory_item_id
   AND msi.organization_id(+) = NVL (rctl.warehouse_id, 99)
      	  AND (rct.last_update_date > trunc(sysdate-1)
	  OR rctl.last_update_date > trunc(sysdate-1)
	  OR rctgd.last_update_date > trunc(sysdate-1)
	  OR hca_billto.last_update_date > trunc(sysdate-1)
	  OR hca_shipto.last_update_date > trunc(sysdate-1)
	  OR loc_billto.last_update_date > trunc(sysdate-1)
	  OR loc_shipto.last_update_date > trunc(sysdate-1)
	  --OR jrre.last_update_date > trunc(sysdate-1)
	  )