-- Billing Accounting Report Query
SELECT  --NULL zero_or_non_zero
       NVL (rctgd.amount, 0) line_gl_amt
       ,NVL (rctgd.acctd_amount, 0) line_gl_fun_amt 
       ,NULL business_unit_gl
       ,rbs.NAME bill_source_id
       ,rctgd.gl_date gl_date
       , rct.trx_number tran_nbr
       --,rctl.line_number LINE_SEQ_NUM
       ,null line_Seq_num
       ,rctt.type trx_class
       ,rctt.name trx_type
        ,hca_billto.account_number bill_cust_acct
        ,hca_billto.account_name bill_cust_name
       -- ,rct.attribute5 linked_inv_nbr
        ,rct.attribute8 crd_job_nbr
        ,Decode(rbs.NAME ,'P21' ,rct.interface_header_attribute2,NVL(rctl.sales_order,rctl.interface_line_attribute1) ) sales_ord_nbr
        --,(SELECT NAME  FROM hr_organization_units_v houv  WHERE houv.organization_id = rctl.warehouse_id and rownum=1) business_unit 
        ,null business_unit
--        ,Decode(rbs.NAME ,'P21' ,
--           ( select resource_name from jtf_rs_resource_extns_tl jrt where jrt.resource_id = jrre.resource_id and rownum =1)
--           ,(SELECT NAME  FROM hr_organization_units_v houv  WHERE houv.organization_id = rctl.warehouse_id and rownum=1)) plant_loc
  ,null plant_loc       
 ,NULL planned_shipment
        ,(Select ffvc1.description 
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
          WHERE gcc_rec.segment2 = ffvc.flex_value
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
        ,rct.invoice_currency_code trx_CURRENCY_CD
        ,rct.attribute9 PROJECT_TYPE
        ,rct.reason_code CLAIM_TYPE
        ,rct.purchase_order PO_REF
       -- ,rct.attribute1 BILL_TYPE_ID
        --,rct.PRIMARY_SALESREP_ID Sales_Branch 
		--,NVL( jrre.attribute1,DECODE (rct.org_id, 456, 'D2', 457, 'CH', 'NA')) sales_office_code
		,jrre.attribute1 sales_office_code
        ,jrs.name Sales_Branch_name 
           ,(select   fll.description
            from  FND_FLEX_VALUES_VL fll
           where fll.FLEX_VALUE_SET_ID = 1014929  -- location
           and     fll.flex_value = gcc_rec.segment2) location_desc
        , gcc_rec.segment1 rec_gl_acct_ENTITY
        , gcc_rec.segment2 rec_gl_acct_LOCATION
        , gcc_rec.segment3 rec_gl_acct_COST_CENTER
        , gcc_rec.segment4 rec_gl_acct_ACCOUNT
        , gcc_rec.segment5 rec_gl_acct_PRODUCT
        , gcc_rec.segment6 rec_gl_acct_INTERCOMPANY
        , gcc_rec.segment7 rec_gl_acct_FUTURE1
        , gcc_rec.segment8 rec_gl_acct_FUTURE2
        , gcc.segment1 rev_gl_acct_ENTITY
        , gcc.segment2 rev_gl_acct_LOCATION
        , gcc.segment3 rev_gl_acct_COST_CENTER
        , gcc.segment4 rev_gl_acct_ACCOUNT
        , gcc.segment5 rev_gl_acct_PRODUCT
        , gcc.segment6 rev_gl_acct_INTERCOMPANY
        , gcc.segment7 rev_gl_acct_FUTURE1
        , gcc.segment8 rev_gl_acct_FUTURE2
        , rctgd.COMMENTS Reg_GL_type
        , rctgd.ACCOUNT_CLASS ACCOUNT_CLASS
        , Decode(rbs.NAME ,'P21', substr(rctl.description,1,instr(rctl.description,'~',1,1)-1) , msi.segment1) Item_number 
        , Decode(rbs.NAME ,'P21', substr(rctl.description,instr(rctl.description,'~',1,1)+1) ,  nvl(rctl.translated_description , rctl.description) ) Item_desc
	    , hou.name OU_Name
          , rct.exchange_rate
       ,gjh.name journal_name
       ,null journal_id
       ,gjb.name gl_batch_name
       ,gjb.posted_date
	   ,(select mic.SEGMENT1||'.'|| mic.SEGMENT2 ||'.'|| mic.SEGMENT3 ||'.'|| mic.SEGMENT4 ||'.'|| mic.SEGMENT5 ||'.'|| mic.SEGMENT6 
         FROM mtl_item_categories_v mic , mtl_system_items msi1 where mic.INVENTORY_ITEM_ID = msi1.INVENTORY_ITEM_ID
         AND msi1.segment1 = Decode(rbs.NAME ,'P21', substr(rctl.description,1,instr(rctl.description,'~',1,1)-1) , msi.segment1) 
         AND mic.category_set_name = 'IRPLN SIOP CATEGORY'
         and mic.organization_id = msi1.organization_id
         AND msi1.organization_id = nvl(rctl.warehouse_id,99)
         AND rownum=1 ) SIOP_NUMBER
     FROM ra_customer_trx_all rct,
          ra_customer_trx_lines_all rctl,
          ra_batch_sources_all rbs,
          ra_cust_trx_line_gl_dist_all rctgd,
          ra_cust_trx_line_gl_dist_all rctgd_rec,
          hz_cust_accounts hca_billto,
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
     WHERE rctgd.customer_trx_id = rct.customer_trx_id
      AND rctl.customer_trx_id = rct.customer_trx_id
      AND rct.cust_trx_type_id = rctt.cust_trx_type_id
	  AND rct.complete_flag='Y'
	 -- AND rctgd_rec.posting_control_id <> -3
      AND msi.INVENTORY_ITEM_ID(+) = rctl.INVENTORY_ITEM_ID
      AND msi.organization_id(+) = nvl(rctl.warehouse_id,99)
      AND rctt.org_id = rct.org_id
      AND rbs.batch_source_id = rct.batch_source_id
      AND rct.org_id in (456,457) -- US TCS and CA TCS  Only
      AND rbs.NAME in ( 'P21' , 'ORDER ENTRY','TCS MANUAL') -- batch source P21 and Order Entry only
      AND rbs.org_id = rct.org_id
      AND jrs.salesrep_id(+) = rct.primary_salesrep_id
      AND jrs.resource_id = jrre.resource_id(+)
      AND jrs.org_id(+) = rct.org_id
      AND rct.bill_to_customer_id = hca_billto.cust_account_id
      AND hca_billto.party_id = hp_billto.party_id
      AND NVL (rctgd.customer_trx_line_id, rctl.customer_trx_line_id) =  rctl.customer_trx_line_id
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
      AND gjh.je_header_id  = gjl.je_header_id 
      AND gjl.je_header_id (+) = gir.je_header_id
	  AND gjl.je_line_num (+)= gir.je_line_num
	  AND gir.gl_sl_link_table(+) = ael.gl_sl_link_table
	  AND gir.gl_sl_link_id(+) = ael.gl_sl_link_id
	  AND gjh.je_source = 'Receivables'
	  AND gjb.je_batch_id = gjh.je_batch_id
 --    and rct.trx_number = '197143'
