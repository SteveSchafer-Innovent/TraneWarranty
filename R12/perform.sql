/* Formatted on 2016/06/14 16:37 (Formatter Plus v4.8.8) */
-- Billing Detail Line Report Query 
SELECT rctl.CUSTOMER_TRX_LINE_ID
        ,rctgd.CUST_TRX_LINE_GL_DIST_ID
        ,rct.trx_number tran_nbr
       ,rct.invoice_currency_code currency
       ,rct.purchase_order po_nbr
       ,rct.trx_date SHIP_DATE
       ,rct.trx_date inv_date
       ,hca_billto.account_number  bill_cust_acct
       ,hcsu_billto.location Bill_TO_LOCATION
       ,Decode(rbs.NAME ,'P21' ,rct.interface_header_attribute2,NVL(rctl.sales_order,rctl.interface_line_attribute1) ) sales_ord_nbr
       ,nvl(aps.amount_due_original,(select sum(nvl(rctl1.EXTENDED_AMOUNT,0)) FROM ra_customer_trx_lines_all rctl1 WHERE rctl1.customer_trx_id = rctl.customer_trx_id)) header_total
       ,hca_shipto.account_number ship_cust_acct
       ,hcsu_shipto.location SHIP_TO_LOCATION
       ,hca_billto.account_name bill_cust_name
       ,loc_billto.address1 bill_cust_address1
       ,loc_billto.address2 bill_cust_address2
       ,loc_billto.address3 bill_cust_address3
       ,loc_billto.address4 bill_cust_address4
       ,loc_billto.city bill_city
       ,nvl(loc_billto.state,loc_billto.province) bill_state
       ,loc_billto.county bill_county 
       ,loc_billto.postal_code bill_postal
       ,rct.attribute8 crd_job_nbr
       ,rct.internal_notes crd_job_name
       --,Decode(rbs.NAME ,'ORDER ENTRY',interface_line_attribute3 , null) planned_shipment
       ,null planned_shipment
       ,rct.attribute9 proj_type
      -- ,(SELECT NAME  FROM hr_organization_units_v houv  WHERE houv.organization_id = rctl.warehouse_id and rownum=1) business_unit -- for p21 it will be sale office name
        ,null business_unit
--        ,Decode(rbs.NAME ,'P21' ,
--           ( select resource_name from jtf_rs_resource_extns_tl jrt where jrt.resource_id = jrre.resource_id and rownum =1)
--           ,(SELECT mtl.ORGANIZATION_CODE  FROM mtl_parameters mtl  WHERE mtl.organization_id = rctl.warehouse_id and rownum=1)) plant_loc
        ,null plant_loc
        ,hca_shipto.account_name ship_cust_name
       ,loc_shipto.address1 ship_cust_address1
       ,loc_shipto.address2 ship_cust_address2
       ,loc_shipto.address3 ship_cust_address3
       ,loc_shipto.address4 ship_cust_address4
       ,loc_shipto.city  ship_city
       ,nvl(loc_shipto.state,loc_shipto.province)  ship_state
       ,loc_shipto.county ship_county
       ,loc_shipto.postal_code ship_postal
       ,rct.comments hdr_note
       --,jrs.name Sales_Branch
       ,jrre1.resource_name sales_branch
      -- ,NVL( jrre.attribute1,DECODE (rct.org_id, 456, 'D2', 457, 'CH', 'NA')) sales_office_code
      ,jrre.attribute1 sales_office_code
       ,(Select ffvc1.description 
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
               AND ffvcp1.PARENT_FLEX_VALUE LIKE 'P%'
               --AND ffvcp1.RANGE_ATTRIBUTE ='C'                    
               AND ffvcp1.flex_value_set_id = ffvc.flex_value_set_id
               AND sysdate between nvl(ffvcp1.START_DATE_ACTIVE,sysdate) and nvl(ffvcp1.END_DATE_ACTIVE,sysdate)
               AND ffvcp2.PARENT_FLEX_VALUE LIKE 'P%'
               --AND ffvcp2.RANGE_ATTRIBUTE ='C'       
               AND sysdate between nvl(ffvcp2.START_DATE_ACTIVE,sysdate) and nvl(ffvcp2.END_DATE_ACTIVE,sysdate)
               AND ffvcp2.flex_value_set_id = ffvc.flex_value_set_id
               AND ffvcp1.PARENT_FLEX_VALUE   BETWEEN ffvcp2.child_flex_value_low
               AND ffvcp2.child_flex_value_high
               AND ffvc1.enabled_flag = 'Y'                         
               AND ffvc2.enabled_flag = 'Y'    
               AND ffvc1.flex_value_set_id = ffvc.flex_value_set_id 
               AND ffvc2.flex_value_set_id  = ffvc.flex_value_set_id
               AND ffvc1.flex_value = ffvcp1.PARENT_FLEX_VALUE 
               AND ffvc2.flex_value  = ffvcp2.PARENT_FLEX_VALUE 
               AND ROWNUM=1     )   Sales_District
          ,(Select ffvc3.description 
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
               AND ffvcp1.PARENT_FLEX_VALUE LIKE 'P%'
               --AND ffvcp1.RANGE_ATTRIBUTE ='C'                    
               AND ffvcp1.flex_value_set_id = ffvc.flex_value_set_id
               AND sysdate between nvl(ffvcp1.START_DATE_ACTIVE,sysdate) and nvl(ffvcp1.END_DATE_ACTIVE,sysdate)
               AND ffvcp2.PARENT_FLEX_VALUE LIKE 'P%'
               --AND ffvcp2.RANGE_ATTRIBUTE ='C'       
               AND sysdate between nvl(ffvcp2.START_DATE_ACTIVE,sysdate) and nvl(ffvcp2.END_DATE_ACTIVE,sysdate)
               AND ffvcp2.flex_value_set_id = ffvc.flex_value_set_id
               AND ffvcp1.PARENT_FLEX_VALUE   BETWEEN ffvcp2.child_flex_value_low
                                       AND ffvcp2.child_flex_value_high
               AND ffvcp3.PARENT_FLEX_VALUE LIKE 'P%'
               --AND ffvcp2.RANGE_ATTRIBUTE ='C'       
               AND sysdate between nvl(ffvcp3.START_DATE_ACTIVE,sysdate) and nvl(ffvcp3.END_DATE_ACTIVE,sysdate)
               AND ffvcp3.flex_value_set_id = ffvc.flex_value_set_id
               AND ffvcp2.PARENT_FLEX_VALUE   BETWEEN ffvcp3.child_flex_value_low
                                       AND ffvcp3.child_flex_value_high                        
               AND ffvc1.enabled_flag = 'Y'                         
               AND ffvc2.enabled_flag = 'Y'  
               AND ffvc3.enabled_flag = 'Y'   
               AND ffvc1.flex_value_set_id = ffvc.flex_value_set_id 
               AND ffvc2.flex_value_set_id  = ffvc.flex_value_set_id
               AND ffvc3.flex_value_set_id  = ffvc.flex_value_set_id
               AND ffvc1.flex_value = ffvcp1.PARENT_FLEX_VALUE 
               AND ffvc2.flex_value  = ffvcp2.PARENT_FLEX_VALUE  
               AND ffvc3.flex_value  = ffvcp3.PARENT_FLEX_VALUE
               AND ROWNUM=1   )   Territory   
   ,(select   fll.description
            from  FND_FLEX_VALUES_VL fll
           where fll.FLEX_VALUE_SET_ID = 1014929  -- location
           and     fll.flex_value = gcc.segment2) location_desc      
 , gcc.segment1 rec_gl_acct_ENTITY
       , gcc.segment2 rec_gl_acct_LOCATION
       , gcc.segment3 rec_gl_acct_COST_CENTER
       , gcc.segment4 rec_gl_acct_ACCOUNT
       , gcc.segment5 rec_gl_acct_PRODUCT
       , gcc.segment6 rec_gl_acct_INTERCOMPANY
       , gcc.segment7 rec_gl_acct_FUTURE1
       , gcc.segment8 rec_gl_acct_FUTURE2
       , nvl(rbs.NAME,0) batch_source
       , Decode(rbs.NAME ,'P21' ,rct.interface_header_attribute10,rct.interface_header_attribute2) BILLING_TYPE
       , nvl(hou.name,0) OU_Name
       , rctl.LINE_NUMBER    INVOICE_LINE_NUMBER
       , nvl(rctl.translated_description , rctl.description) INVOIE_LINE_DESCRIPTION
       , NVL(rctl.QUANTITY_INVOICED , rctl.QUANTITY_CREDITED)  INVOICE_LINE_QUANTITY
       , rctl.UNIT_SELLING_PRICE INVOICE_LINE_UNIT_PRICE
       , rctl.EXTENDED_AMOUNT INVOICE_LINE_AMOUNT
       , rctl.LINE_TYPE INVOICE_LINE_TYPE
       , rctl.ATTRIBUTE6 LINE_ATTRIBUTE6
       , (select sum(nvl(rctl1.EXTENDED_AMOUNT,0)) FROM ra_customer_trx_lines_all rctl1 WHERE rctl1.customer_trx_id = rctl.customer_trx_id
            AND nvl(rctl1.attribute6, 'X') not in ('FREIGHT','TAX','MTAX') AND rctl1.LINE_TYPE not in ('FREIGHT','TAX') )    "Subtotal"    
       , (select sum(nvl(rctl1.EXTENDED_AMOUNT,0)) FROM ra_customer_trx_lines_all rctl1 WHERE rctl1.customer_trx_id = rctl.customer_trx_id
            AND (nvl(rctl1.attribute6, 'X') = 'FREIGHT' OR rctl1.LINE_TYPE ='FREIGHT' ))    "Subtotal Freight"    
       , (select sum(nvl(rctl1.EXTENDED_AMOUNT,0)) FROM ra_customer_trx_lines_all rctl1 WHERE rctl1.customer_trx_id = rctl.customer_trx_id
            AND (nvl(rctl1.attribute6, 'X') in ('MTAX','TAX') OR rctl1.LINE_TYPE ='TAX' )) "Subtotal Tax"    
       , nvl(aps.amount_due_original,(select sum(nvl(rctl1.EXTENDED_AMOUNT,0)) FROM ra_customer_trx_lines_all rctl1 WHERE rctl1.customer_trx_id = rctl.customer_trx_id)) "Total of Totals"
       , rct.attribute5 "Related Trx Number"
       , nvl(aps.gl_date,rctgd.gl_date) GL_DATE
       , rct.exchange_rate
        ,gjh.name journal_name
       ,null journal_id
       ,gjb.name gl_batch_name
        ,gjb.posted_date
        , Decode(rbs.NAME ,'P21', substr(rctl.description,1,instr(rctl.description,'~',1,1)-1) , msi.segment1) Item_number 
        , Decode(rbs.NAME ,'P21', substr(rctl.description,instr(rctl.description,'~',1,1)+1) ,  nvl(rctl.translated_description , rctl.description) ) Item_desc
        ,Decode(rbs.NAME ,'P21' ,decode(rct.interface_header_attribute10,'SER', RCT.PURCHASE_ORDER, null),null) TRNBI_SRV_CALL_ID
         ,(select mic.SEGMENT1||'.'|| mic.SEGMENT2 ||'.'|| mic.SEGMENT3 ||'.'|| mic.SEGMENT4 ||'.'|| mic.SEGMENT5 ||'.'|| mic.SEGMENT6 
         FROM mtl_item_categories_v mic , mtl_system_items msi1 where mic.INVENTORY_ITEM_ID = msi1.INVENTORY_ITEM_ID
         AND msi1.segment1 = Decode(rbs.NAME ,'P21', substr(rctl.description,1,instr(rctl.description,'~',1,1)-1) , msi.segment1) 
         AND mic.category_set_name = 'IRPLN SIOP CATEGORY'
         and mic.organization_id = msi1.organization_id
         AND msi1.organization_id = nvl(rctl.warehouse_id,99)
         AND rownum=1 ) SIOP_NUMBER
		,null ORIG_SYS_NBR
		,null PRIOR_TRX_NBR		
		,null MULTIPLIER
		,null PROD_CODE
		,null INVOICE_AMT_PRETAX
		,null IDENTIFIER
		,null PROJECT_ID
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
           AND ROWNUM=1) EC_CUST_NUMBER ,
           hcas_billto.attribute6  DEFAULT_BRANCH 
           ,(select name from hr_organization_units_v houv where houv.organization_id=rctl.warehouse_id and rownum=1) INV_ORG
		   ,' ' AS REV_GL_ACCT_ACCOUNT
		  -- ,msi.description R12_ITEM_DESCCRIPTION -- Added by Rijo 02/27/2017
		     ,  DECODE (rbs.NAME,
                          'P21', SUBSTR (rctl.description,
                                         INSTR (rctl.description, '~', 1, 1)+1,
                                           length (rctl.description)
                                         
                                        ),
                         nvl(msi.description,rctl.description)
                         ) R12_ITEM_DESCCRIPTION -- Added by Rijo 04/19/2017
  FROM ar_payment_schedules_all aps,
       ra_customer_trx_all RCT,
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
       gl_je_batches gjb  ,
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
 --  AND rbs.NAME in ( 'P21' , 'ORDER ENTRY','TCS MANUAL') -- batch source P21 and Order Entry only
    AND rct.org_id=all_source.org_id                   -- US TCS and CA TCS  Only
   AND rbs.name=all_source.externally_visible_flag
   AND rbs.org_id=all_source.org_id
   AND rctl.customer_trx_id = rct.customer_trx_id
   AND rbs.batch_source_id = rct.batch_source_id
   AND rbs.org_id = rct.org_id
   AND rct.complete_flag='Y'
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
   AND NVL (rct.ship_to_site_use_id, rct.bill_to_site_use_id) =   hcsu_shipto.site_use_id
   AND NVL (rct.ship_to_customer_id, rct.bill_to_customer_id) =   hca_shipto.cust_account_id
   AND hca_shipto.party_id = hp_shipto.party_id
   AND hcsu_shipto.cust_acct_site_id = hcas_shipto.cust_acct_site_id
   AND loc_shipto.location_id = hps_shipto.location_id
   AND hps_shipto.party_site_id = hcas_shipto.party_site_id
   AND rctgd.customer_trx_id = rct.customer_trx_id
   AND NVL (rctgd.latest_rec_flag, 'Y') = 'Y'
   AND rctgd.ACCOUNT_CLASS = 'REC'
   AND hou.organization_id = rct.org_id
   AND ael.code_combination_id = gcc.code_combination_id
   AND rctgd.cust_trx_line_gl_dist_id = xdl.source_distribution_id_num_1
   AND rctgd.event_id = xdl.event_id
   AND xdl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   AND xdl.application_id = 222
   AND xdl.ae_header_id = aeh.ae_header_id
   AND xdl.ae_header_id = ael.ae_header_id
   AND xdl.ae_line_num = ael.ae_line_num
  -- AND RCTL.line_type <> 'TAX'
    AND gjh.je_header_id  = gjl.je_header_id 
   AND gjl.je_header_id (+) = gir.je_header_id
   AND gjl.je_line_num (+)= gir.je_line_num
   AND gir.gl_sl_link_table(+) = ael.gl_sl_link_table
   AND gir.gl_sl_link_id(+) = ael.gl_sl_link_id
   AND gjh.je_source = 'Receivables'
   AND gjb.je_batch_id=gjh.je_batch_id
   AND gjh.ledger_id=gll.ledger_id
   AND gll.ledger_category_code='PRIMARY'
   AND msi.INVENTORY_ITEM_ID(+) = rctl.INVENTORY_ITEM_ID
   AND msi.organization_id(+) = nvl(rctl.warehouse_id,99)
        AND (rct.last_update_date > trunc(sysdate-1)
   OR rctl.last_update_date > trunc(sysdate-1)
   OR rctgd.last_update_date > trunc(sysdate-1)
   OR hca_billto.last_update_date > trunc(sysdate-1)
   OR hca_shipto.last_update_date > trunc(sysdate-1)
   OR loc_billto.last_update_date > trunc(sysdate-1)
   OR loc_shipto.last_update_date > trunc(sysdate-1))
 --  OR jrre.last_update_date > trunc(sysdate-1) -- Commented for Performance improvement
 --  OR gjb.last_update_date > trunc(sysdate-1))
