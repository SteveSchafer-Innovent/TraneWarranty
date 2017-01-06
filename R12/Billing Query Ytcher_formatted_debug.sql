SELECT
RCT.TRX_NUMBER AS INVOICE,
count(distinct RCTL.LINE_NUMBER) AS LINE_SEQ_NUM_count

FROM
ra_customer_trx_all rct

left outer join
ar_payment_schedules_all aps
on 1=1
and aps.customer_trx_id = rct.customer_trx_id

inner join
ra_customer_trx_lines_all rctl
on 1=1
AND rctl.customer_trx_id = rct.customer_trx_id

inner join
ra_batch_sources_all rbs
on 1=1
AND rbs.batch_source_id = rct.batch_source_id
AND rbs.org_id = rct.org_id

inner join
ra_cust_trx_line_gl_dist_all rctgd
on 1=1
AND rctgd.customer_trx_id = rct.customer_trx_id
AND NVL (rctgd.customer_trx_line_id, rctl.customer_trx_line_id) = rctl.customer_trx_line_id

inner join
ra_cust_trx_line_gl_dist_all rctgd_rec
on 1=1
AND rctgd_rec.customer_trx_id = rct.customer_trx_id

inner join
hz_cust_accounts hca_billto
on 1=1
AND rct.bill_to_customer_id = hca_billto.cust_account_id

inner join
hz_cust_site_uses_all hcsu
on 1=1
AND rct.bill_to_site_use_id = hcsu.site_use_id

inner join
hz_cust_acct_sites_all hcas
on 1=1
AND hcsu.cust_acct_site_id = hcas.cust_acct_site_id

inner join
hz_party_sites hps
on 1=1
AND hcas.party_site_id = hps.party_site_id

inner join
ra_cust_trx_types_all rctt
on 1=1
AND rct.cust_trx_type_id = rctt.cust_trx_type_id
AND rctt.org_id = rct.org_id

inner join
hz_parties hp_billto
on 1=1
AND hca_billto.party_id = hp_billto.party_id

/*
left outer join
jtf_rs_salesreps jrs
on 1=1
AND jrs.salesrep_id /- (+) -/ = rct.primary_salesrep_id
AND jrs.org_id /- (+) -/ = rct.org_id

left outer join
jtf_rs_resource_extns jrre
on 1=1
AND jrs.resource_id = jrre.resource_id -- (+)
*/

inner join
hr_operating_units hou
on 1=1
AND hou.organization_id = rct.org_id

inner join
xla_distribution_links xdl
on 1=1
AND rctgd.cust_trx_line_gl_dist_id = xdl.source_distribution_id_num_1
AND rctgd.event_id = xdl.event_id

inner join
xla_ae_headers aeh
on 1=1
AND xdl.ae_header_id = aeh.ae_header_id

inner join
xla_ae_lines ael
on 1=1
AND xdl.ae_header_id = ael.ae_header_id
AND xdl.ae_line_num = ael.ae_line_num

inner join
gl_code_combinations_kfv gcc
on 1=1
AND ael.code_combination_id = gcc.code_combination_id

inner join
xla_distribution_links xdl_rec
on 1=1
AND rctgd_rec.cust_trx_line_gl_dist_id = xdl_rec.source_distribution_id_num_1
AND rctgd.event_id = xdl_rec.event_id

inner join
xla_ae_headers aeh_rec
on 1=1
AND xdl_rec.ae_header_id = aeh_rec.ae_header_id

inner join
xla_ae_lines ael_rec
on 1=1
AND xdl_rec.ae_header_id = ael_rec.ae_header_id
AND xdl_rec.ae_line_num = ael_rec.ae_line_num

inner join
gl_code_combinations_kfv gcc_rec
on 1=1
AND ael_rec.code_combination_id = gcc_rec.code_combination_id

/*
left outer join
mtl_system_items msi
on 1=1
AND msi.inventory_item_id /- (+) -/ = rctl.inventory_item_id
AND msi.organization_id /- (+) -/ = NVL (rctl.warehouse_id, 99)
*/

left outer join
gl_import_references gir
on 1=1
AND gir.gl_sl_link_table /* (+) */ = ael.gl_sl_link_table
AND gir.gl_sl_link_id /* (+) */ = ael.gl_sl_link_id

left outer join
gl_je_lines gjl
on 1=1
AND gjl.je_header_id /* (+) */ = gir.je_header_id
AND gjl.je_line_num /* (+) */ = gir.je_line_num

-- inner join to outer joined field
left outer join
gl_je_headers gjh
on 1=1
AND gjh.je_header_id = gjl.je_header_id

-- inner join to outer joined field
left outer join
gl_je_batches gjb
on 1=1
AND gjb.je_batch_id = gjh.je_batch_id

WHERE 1=1
AND rct.complete_flag = 'Y' -- *
AND rct.org_id IN (456, 457) -- US TCS and CA TCS  Only *
-- AND rct.org_id IN (456, 457) -- redundant
AND rbs.NAME IN ('P21', 'ORDER ENTRY', 'TCS MANUAL') -- *
-- batch source P21 and Order Entry only
--- Rev XLA Accounting
AND rctgd.account_class <> 'REC'
AND xdl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
AND xdl.application_id = 222
-- Rec XLA Accounting
AND rctgd_rec.account_class = 'REC'
AND NVL (rctgd_rec.latest_rec_flag, 'Y') = 'Y'
AND gjh.je_source = 'Receivables'
and gcc.segment4 in ( '411101' /* '210105', '511150' */)
and rctgd.gl_date >= '01-NOV-2016'
and rctgd.gl_date < '01-DEC-2016'
and gjb.posted_date > '30-NOV-2016'

AND xdl_rec.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL' ----
AND xdl_rec.application_id = 222 ----

and GCC.SEGMENT2 = '129008'

group by RCT.TRX_NUMBER
order by 2 desc
;

-- invoice = 50000610, line count = 3

-- 345 seconds
-- 503 seconds
-- 347 seconds
-- 358 seconds, 50029586	152