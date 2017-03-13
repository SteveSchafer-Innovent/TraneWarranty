SELECT
rct.interface_header_attribute1 CLAIM_NUMBER,  
gcc_rec.segment1 ENTITY,
gcc_rec.segment2 LOCATION,
gcc_rec.segment3 COST_CENTER,
gcc_rec.segment4 ACCOUNT,
gcc_rec.segment5 PRODUCT_CODE,
gcc_rec.segment6 ICP,
gcc_rec.segment7 FUTURE1,
gcc_rec.segment8 FUTURE2,
(SELECT f.description
    FROM FND_ID_FLEX_STRUCTURES b ,
      FND_ID_FLEX_SEGMENTS c,
      fnd_flex_value_sets d,
      fnd_flex_values e,
      fnd_flex_values_tl f
    WHERE b.application_id ='101'
    AND b.id_flex_code     ='GL#'
    AND b.id_flex_code     =c.id_flex_code
    AND b.id_flex_num      =c.id_flex_num
    AND b.application_id   =c.application_id
    AND c.flex_value_set_id=d.flex_value_set_id
    AND d.flex_value_set_id=e.flex_value_set_id
    AND e.flex_value       =gcc_rec.segment2
    AND c.segment_num      = 2
    AND b.id_flex_num      = gcc_rec.chart_of_accounts_id
    AND e.flex_value_id    =f.flex_value_id
    AND f.language         = 'US'
    )LOCATION_NAME,
gjh.NAME JOURNAL_NAME,    
rct.trx_number INV_NBR,
rct.TRX_DATE   TRX_DATE,
rctl.line_number LINE_NBR,
rctl.DESCRIPTION LINE_DESCRIPTION,
rctl.extended_amount LINE_AMOUNT,
'HVAC TAVANT'        SYS_COURCE ,   
rct.INVOICE_CURRENCY_CODE  INVOICE_CURRENCY_CODE  
    FROM 
ra_customer_trx_all rct,
--hr_operating_units hou,
ra_customer_trx_lines_all rctl,
/*mtl_system_items msi,*/
--Rev
/*ra_cust_trx_line_gl_dist_all rctgd,
xla_distribution_links xdl,
xla_ae_headers aeh,
xla_ae_lines ael,
gl_code_combinations_kfv gcc,*/
--Rec
ra_cust_trx_line_gl_dist_all rctgd_rec,
xla_distribution_links xdl_rec,
xla_ae_headers aeh_rec,
xla_ae_lines ael_rec,
gl_code_combinations_kfv gcc_rec,
gl_je_lines gjl,
gl_je_headers gjh,
gl_import_references gir,
gl_ledgers gll

WHERE  rctl.customer_trx_id = rct.customer_trx_id
--AND rct.trx_number = '1566232'
AND rct.org_id IN ( 456,122,89,457,458,94)
--AND rct.org_id = hou.organization_id 
/*AND  hou.NAME IN ('US OU USD RS'
                             ,'IE OU EUR IRI'
                             ,'CA OU CAD RS'
                             ,'US OU USD TCS'
                             ,'CA OU CAD TCS'
                             ,'US OU USD TEL')*/
/*AND rct.org_id IN (SELECT organization_id FROM hr_operating_units WHERE NAME IN ('US OU USD RS'
                                                                                 ,'IE OU EUR IRI'
                                                                                 ,'CA OU CAD RS'
                                                                                 ,'US OU USD TCS'
                                                                                 ,'CA OU CAD TCS'
                                                                                 ,'US OU USD TEL'))*/ 
/*--- Rev XLA Accounting
 AND rctgd.customer_trx_id = rct.customer_trx_id
 AND rctgd.account_class <> 'REC'
 AND ael.code_combination_id = gcc.code_combination_id
 AND rctgd.cust_trx_line_gl_dist_id = xdl.source_distribution_id_num_1
 AND rctgd.event_id = xdl.event_id
 AND xdl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
 AND xdl.application_id = 222
 AND xdl.ae_header_id = aeh.ae_header_id
 AND xdl.ae_header_id = ael.ae_header_id
 AND xdl.ae_line_num = ael.ae_line_num*/
 -- Rec XLA Accounting
 AND rctgd_rec.customer_trx_id = rct.customer_trx_id
 AND rctgd_rec.account_class = 'REC'
 AND NVL (rctgd_rec.latest_rec_flag, 'Y') = 'Y'
 AND ael_rec.code_combination_id = gcc_rec.code_combination_id
 AND gcc_rec.segment4 = '123502'
 AND rctgd_rec.cust_trx_line_gl_dist_id =xdl_rec.source_distribution_id_num_1
 AND rctgd_rec.event_id = xdl_rec.event_id
 AND xdl_rec.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
 AND xdl_rec.application_id = 222
 AND xdl_rec.ae_header_id = aeh_rec.ae_header_id
 AND xdl_rec.ae_header_id = ael_rec.ae_header_id
 AND xdl_rec.ae_line_num = ael_rec.ae_line_num
 AND gjh.je_header_id = gjl.je_header_id
 AND gjl.je_header_id(+) = gir.je_header_id
 AND gjl.je_line_num(+) = gir.je_line_num
 AND gir.gl_sl_link_table(+) = ael_rec.gl_sl_link_table
 AND gir.gl_sl_link_id(+) = ael_rec.gl_sl_link_id
 AND gjh.je_source = 'Receivables'
 --AND gjb.je_batch_id = gjh.je_batch_id
 AND gjh.ledger_id=gll.ledger_id
 AND gll.ledger_category_code='PRIMARY'