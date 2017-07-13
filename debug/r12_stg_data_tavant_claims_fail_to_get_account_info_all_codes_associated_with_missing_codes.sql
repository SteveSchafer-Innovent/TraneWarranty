/* Formatted on 2016/06/14 16:37 (Formatter Plus v4.8.8) */
-- Billing Detail With Lines Report Query 
SELECT distinct
-- rctl.CUSTOMER_TRX_LINE_ID
--        ,rctgd.CUST_TRX_LINE_GL_DIST_ID
--        ,rct.trx_number tran_nbr
/*				
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
*/				
         (
				 --select mic.SEGMENT1||'.'|| mic.SEGMENT2 ||'.'|| mic.SEGMENT3 ||'.'|| mic.SEGMENT4 ||'.'|| mic.SEGMENT5 ||'.'|| mic.SEGMENT6 
				 select mic.SEGMENT6 				 
         FROM mtl_item_categories_v mic , mtl_system_items msi1 where mic.INVENTORY_ITEM_ID = msi1.INVENTORY_ITEM_ID
         AND msi1.segment1 = Decode(rbs.NAME ,'P21', substr(rctl.description,1,instr(rctl.description,'~',1,1)-1) , msi.segment1) 
         AND mic.category_set_name = 'IRPLN SIOP CATEGORY'
         and mic.organization_id = msi1.organization_id
         AND msi1.organization_id = nvl(rctl.warehouse_id,99)
         AND rownum=1 ) SIOP_NUMBER
/*				 
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
		   --, nvl(msi.description,rctl.description) R12_ITEM_DESCCRIPTION1 -- Added by Rijo 02/27/2017
		   ,  DECODE (rbs.NAME,
                          'P21', SUBSTR (rctl.description,
                                         INSTR (rctl.description, '~', 1, 1)+1,
                                           length (rctl.description)
                                         
                                        ),
                         nvl(msi.description,rctl.description)
                         ) R12_ITEM_DESCCRIPTION -- Added by Rijo 04/19/2017
*/												 
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
--	 and rct.trx_number in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828','2159882')
	 and rct.trx_number in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828','2160775','2161010','2161129','2161137','2161192','2161392',
'2161456','2161556','2161663','2161667','2161735','2161779','2161912','2162076','2162150','2162330','2162565','2162702','2162956','2163172',
'2163228','2163471','2164402','2165239','2165698','2165759','2165838','2166149','2166220','2166313','2166325','2166340','2166553','2166677',
'2166705','2167064','2167720','2168123','2168224','2168303','2168339','2168380','2168479','2168562','2168660','2168897','2168955','2169418',
'2169604','2169947','2170037','2170480','2170548','2170737','2170767','2170798','2170965','2171375','2171598','2171747','2171758','2171898',
'2172222','2172305','2172361','2172383','2172708','2172797','2172966','2172979','2173017','2173089','2173526','2174152','2174157','2174172',
'2174210','2174413','2174438','2174968','2175082','2175359','2175398','2175403','2175703','2175909','2177242','2178733','2179933','2179988',
'2180122','2180472','2180496','2180861','2180957','2180967','2181132','2181149','2181218','2181399','2181521','2181539','2181967','2182470',
'2182748','2182878','2183665','2183692','2183780','2183988','2184024','2184079','2184486','2184495','2184820','2185248','2185459','2185812',
'2185867','2185868','2185870','2186048','2186312','2186391','2186617','2187568','2187842','2187953','2188148','2188200','2188222','2188944',
'2189111','2189244','2189690','2190063','2190210','2190222','2190424','2190587','2190906','2191116','2191235','2191537','2191726','2191776',
'2191932','2191991','2192048','2192404','2192521','2192803','2192819','2192926','2192936','2193137','2193257','2193269','2193417','2193543',
'2193625','2193648','2193708','2193779','2193806','2193844','2194129','2194461','2194596','2194611','2194950','2195285','2195318','2195367',
'2195391','2195614','2195705','2195865','2196054','2196311','2196826','2196856','2196917','2197043','2197260','2197878','2198011','2198023',
'2198225','2198255','2198635','2198686','2198996','2199043','2199411','2199627','2199640','2199777','2199826','2199929','2200157','2200211',
'2200406','2200510','2200554','2200591','2200803','2201146','2202350','2202375','2202554','2202697','2203065','2203291','2203333','2203408',
'2204065','2204419','2204610','2204961','2205079','2205152','2205170','2205395','2205603','2205613','2205653','2206149','2206320','2207105',
'2207461','2207693','2208404','2208634','2208942','2209226','2209227','2209387','2209415','2209840','2210357','2210385','2210738','2210780',
'2210786','2211123','2211147','2211185','2211327','2211361','2211463','2211507','2211632','2212460','2212741','2212774','2212855','2212984',
'2213218','2213363','2213567','2213597','2213750','2214289','2214290','2214595','2214596','2214641','2214971','2215208','2215465','2215564',
'2216068','2216411','2216430','2216706','2216905','2217051','50086081','50086153','50086249','50086415','50086523','50086619','50086960','50086974'
,'50087022','50087032','50087309','50087354','50087355','50087423','50087463','50087547','50087568','50087592','50087596','50087651','50087719',
'50088046','50088198','50088286','50088381','50088384','50088477','50088619','50088622','50088635','50088775','50088776','50088917','50089112',
'50089148','50089170','50089212','50089252','50089461','50089462','50089817','50089895','50089921','50090051','50090120','50090309','50090465',
'50090483','50090646','50090647','50090686','50090697','50090700','50090790','50090853','50090898','50090907','50091112','50091138','50091276',
'50091295','50091304','50091306','50091705','50091733','50091882','50092522','50092534','50092859','50093051','50093054','50093407','50093455',
'50093650','50093717','50093744','2158835','2159266','2159852','2161142','2161795','2161864','2161951','2162253','2162338','2163260','2163344',
'2164223','2164447','2165787','2165822','2166354','2166615','2166676','2166696','2166777','2167085','2168153','2168909','2169599','2169613',
'2170005','2170985','2171524','2172090','2172325','2172425','2172858','2173002','2173272','2173856','2173870','2174169','2174214','2175097',
'2175460','2177256','2178468','2180526','2180530','2180545','2183299','2183445','2183515','2184496','2184634','2184880','2184901','2185890',
'2187145','2189164','2189733','2189898','2189911','2190093','2190297','2191457','2193284','2193379','2193652','2193670','2193727','2193811',
'2193838','2194401','2195355','2196065','2197655','2197686','2198887','2199077','2200516','2200613','2200918','2201158','2201293','2202385',
'2203075','2203132','2203277','2203467','2204478','2204621','2205937','2207372','2207531','2207716','2208489','2209885','2209892','2210351',
'2210370','2210916','2211706','2212168','2212522','2212554','2212881','2213429','2213456','2214339','2215481','2215929','2217061','2217740',
'2217771','2218413','2218612','2219343','2219449','2219786','2220048','2220405','2220975','2221152','2221301','2221543','2221575','2221824',
'2221943','2222117','2222426','2222562','2222653','2222937','2223373','2223725','2223944','2224060','2224457','2224513','2224909','2225095',
'2225345','2226067','2226111','2226523','2226551','2226552','2227602','2227875','2228002','2228554','2228880','2229346','2229488','2229558',
'2229929','2229971','2230117','2230166','2230209','2230252','2230567','2230609','2230973','2231061','2231069','2231128','2231391','2231994',
'2232140','2232480','2232633','2232917','2233212','2233314','2233539','2233590','2234117','2234526','2234552','2234748','2234896','2235189',
'2235324','2235472','2235644','2235947','2236252','2236527','2236631','2237282','2237318','2237449','2237539','2237585','2237672','2237795',
'2237817','2237827','2238402','2238437','2238459','2238934','2238964','2239565','2239580','2239591','2239627','2239782','2239870','2240316',
'2240343','2240433','2240697','2240864','2240934','2241134','2241223','2241347','2241462','2241709','2241722','2241933','2242042','2242188',
'2242391','2242856','2242940','2242998','2243598','2243799','2244022','2244221','50093833','50093862','50093873','50093879','50093886','50093889',
'50093986','50094007','50094093','50094143','50094405','50094491','50094563','50095321','50095327','50095386','50095449','50095546','50095625',
'50095626','50095633','50096014','50096049','50096073','50096107','50096113','50096114','50096147','50096206','50096214','50096219','50096240',
'50096480','50096485','50096486','50096488','50096532','50096607','50096772','50096799','50096802','50096804','50096839','50096851','50096966',
'50097247','50097248','50097275','2217416','2217649','2217828','2218802','2219409','2219599','2220062','2220084','2220619','2221887','2221983',
'2222003','2222122','2222146','2222172','2222609','2223991','2227392','2227605','2230327','2230513','2231275','2231480','2231484','2232177',
'2232581','2232820','2233392','2233463','2233592','2233946','2234070','2234276','2235024','2237314','2238318','2238355','2239568','2239600',
'2239890','2240334','2240372','2241746','2242163','2242887','2243011','2244467','2244780','2222616')
	 ;
