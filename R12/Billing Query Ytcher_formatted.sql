SELECT
rctl.customer_trx_line_id,
rctgd.cust_trx_line_gl_dist_id,
NULL zero_or_non_zero, NVL (rctgd.amount, 0) line_gl_amt,
NVL (rctgd.acctd_amount, 0) line_gl_fun_amt, NULL business_unit_gl,
rbs.NAME bill_source_id, rctgd.gl_date gl_date,
rct.trx_number tran_nbr,
NULL line_seq_num,
rctt.TYPE trx_class,
rctt.NAME trx_type,
hca_billto.account_number bill_cust_acct,
hca_billto.account_name bill_cust_name,
rct.attribute8 crd_job_nbr,
 NVL (DECODE (rbs.NAME,
              'P21', rct.interface_header_attribute2,
              NVL (rctl.sales_order, rctl.interface_line_attribute1)
             ),
      0
     ) sales_ord_nbr,
NULL business_unit,
NULL plant_loc,
NULL planned_shipment,
rct.invoice_currency_code trx_currency_cd,
rct.attribute9 project_type,
rct.reason_code claim_type,
rct.purchase_order po_ref,
jrre.attribute1 sales_office_code,
jrs.NAME sales_branch_name,
(
    SELECT fll.description
          FROM fnd_flex_values_vl fll
         WHERE fll.flex_value_set_id = 1014929      -- location
           AND fll.flex_value = gcc_rec.segment2
) location_desc,
gcc_rec.segment1 rec_gl_acct_entity,
gcc_rec.segment2 rec_gl_acct_location,
gcc_rec.segment3 rec_gl_acct_cost_center,
gcc_rec.segment4 rec_gl_acct_account,
gcc_rec.segment5 rec_gl_acct_product,
gcc_rec.segment6 rec_gl_acct_intercompany,
gcc_rec.segment7 rec_gl_acct_future1,
gcc_rec.segment8 rec_gl_acct_future2,
gcc.segment1 rev_gl_acct_entity,
gcc.segment2 rev_gl_acct_location,
gcc.segment3 rev_gl_acct_cost_center,
gcc.segment4 rev_gl_acct_account,
gcc.segment5 rev_gl_acct_product,
gcc.segment6 rev_gl_acct_intercompany,
gcc.segment7 rev_gl_acct_future1,
gcc.segment8 rev_gl_acct_future2,
rctgd.comments reg_gl_type,
rctgd.account_class account_class,
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
(
  select mic.SEGMENT1||'.'|| mic.SEGMENT2 ||'.'|| mic.SEGMENT3 ||'.'|| mic.SEGMENT4 ||'.'|| mic.SEGMENT5 ||'.'|| mic.SEGMENT6 
  FROM
  mtl_item_categories_v mic ,
  mtl_system_items msi1
  where
  mic.INVENTORY_ITEM_ID = msi1.INVENTORY_ITEM_ID
  AND msi1.segment1 = Decode(rbs.NAME ,'P21', substr(rctl.description,1,instr(rctl.description,'~',1,1)-1) , msi.segment1) 
  AND mic.category_set_name = 'IRPLN SIOP CATEGORY'
  and mic.organization_id = msi1.organization_id
  AND msi1.organization_id = nvl(rctl.warehouse_id,99)
  AND rownum=1
) SIOP_NUMBER,
hou.NAME ou_name,
rct.exchange_rate,
gjh.NAME journal_name,
NULL journal_id,
gjb.NAME gl_batch_name,
gjb.posted_date,
Decode(rbs.NAME ,'P21' ,rct.interface_header_attribute10,rct.interface_header_attribute2) BILLING_TYPE,
nvl(hou.name,0) OU_Name,
rctl.LINE_NUMBER    INVOICE_LINE_NUMBER,
nvl(rctl.translated_description , rctl.description) INVOIE_LINE_DESCRIPTION,
NVL(rctl.QUANTITY_INVOICED , rctl.QUANTITY_CREDITED)  INVOICE_LINE_QUANTITY,
rctl.UNIT_SELLING_PRICE INVOICE_LINE_UNIT_PRICE,
rctl.EXTENDED_AMOUNT INVOICE_LINE_AMOUNT,
rctl.LINE_TYPE INVOICE_LINE_TYPE,
rctl.ATTRIBUTE6 LINE_ATTRIBUTE6,
(
  select sum(nvl(rctl1.EXTENDED_AMOUNT,0))
  FROM ra_customer_trx_lines_all rctl1
  WHERE rctl1.customer_trx_id = rctl.customer_trx_id
  AND nvl(rctl1.attribute6, 'X') not in ('FREIGHT','TAX','MTAX')
  AND rctl1.LINE_TYPE not in ('FREIGHT','TAX')
)    "Subtotal"    ,
(
  select sum(nvl(rctl1.EXTENDED_AMOUNT,0))
  FROM ra_customer_trx_lines_all rctl1
  WHERE rctl1.customer_trx_id = rctl.customer_trx_id
  AND (nvl(rctl1.attribute6, 'X') = 'FREIGHT' OR rctl1.LINE_TYPE ='FREIGHT' )
)    "Subtotal Freight"    ,
(
  select sum(nvl(rctl1.EXTENDED_AMOUNT,0))
  FROM ra_customer_trx_lines_all rctl1
  WHERE rctl1.customer_trx_id = rctl.customer_trx_id
  AND (nvl(rctl1.attribute6, 'X') in ('MTAX','TAX') OR rctl1.LINE_TYPE ='TAX' )
) "Subtotal Tax"    ,
nvl(
  aps.amount_due_original,(
    select sum(nvl(rctl1.EXTENDED_AMOUNT,0))
    FROM ra_customer_trx_lines_all rctl1
    WHERE rctl1.customer_trx_id = rctl.customer_trx_id)
  ) "Total of Totals",
rct.attribute5 "Related Trx Number",
hps.party_site_number R12_CUST_SITE_NUMBER ,
(
  SELECT hosr.orig_system_reference 
  FROM hz_orig_sys_references hosr
  WHERE  hosr.owner_table_name = 'HZ_CUST_ACCT_SITES_ALL'
  AND  hosr.orig_system = 'TCS_ENT_CUSTOMER'
  AND  hcas.cust_acct_site_id= hosr.owner_table_id
  AND TRUNC (SYSDATE)  BETWEEN NVL (TRUNC (hosr.start_date_active), TRUNC (SYSDATE))
  AND NVL (TRUNC (hosr.end_date_active),  TRUNC (SYSDATE))
  AND hosr.status = 'A'
  AND ROWNUM=1
) EC_CUST_NUMBER

FROM
ra_customer_trx_all rct,
ar_payment_schedules_all aps,
ra_customer_trx_lines_all rctl,
ra_batch_sources_all rbs,
ra_cust_trx_line_gl_dist_all rctgd,
ra_cust_trx_line_gl_dist_all rctgd_rec,
hz_cust_accounts hca_billto,
hz_cust_site_uses_all hcsu,
hz_cust_acct_sites_all hcas,
hz_party_sites hps,
ra_cust_trx_types_all rctt,
hz_parties hp_billto,
jtf_rs_salesreps jrs,
jtf_rs_resource_extns jrre,
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

WHERE aps.customer_trx_id(+) = rct.customer_trx_id
AND rctgd.customer_trx_id = rct.customer_trx_id
AND rctl.customer_trx_id = rct.customer_trx_id
AND rct.cust_trx_type_id = rctt.cust_trx_type_id
AND rct.complete_flag = 'Y'
AND msi.inventory_item_id(+) = rctl.inventory_item_id
AND msi.organization_id(+) = NVL (rctl.warehouse_id, 99)
AND rctt.org_id = rct.org_id
AND rbs.batch_source_id = rct.batch_source_id
AND rct.org_id IN (456, 457)                     -- US TCS and CA TCS  Only
AND rbs.NAME IN ('P21', 'ORDER ENTRY', 'TCS MANUAL')
-- batch source P21 and Order Entry only
AND rbs.org_id = rct.org_id
AND jrs.salesrep_id(+) = rct.primary_salesrep_id
AND jrs.resource_id = jrre.resource_id(+)
AND jrs.org_id(+) = rct.org_id
AND rct.bill_to_customer_id = hca_billto.cust_account_id
AND hca_billto.party_id = hp_billto.party_id
AND NVL (rctgd.customer_trx_line_id, rctl.customer_trx_line_id) = rctl.customer_trx_line_id
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
AND rctgd_rec.cust_trx_line_gl_dist_id = xdl_rec.source_distribution_id_num_1
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
AND rct.bill_to_site_use_id=hcsu.site_use_id
AND hcsu.cust_acct_site_id=hcas.cust_acct_site_id
AND hcas.party_site_id=hps.party_site_id
and gcc.segment4 in ( '210105', '511150')
AND rct.org_id IN ( 456,457)  
and rctgd.gl_date >= '01-NOV-2016'
and rctgd.gl_date < '01-DEC-2016'
and gjb.posted_date > '30-NOV-2016' 