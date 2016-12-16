  SELECT DISTINCT
   claim.claim_number,
         claim.TYPE,
         commercial_policy,
         claimed_item.ITEM_REF_INV_ITEM,
         claim.failure_date,
         inventory_item.shipment_date,
         inventory_item.delivery_date AS start_date,
         sales_order.sales_order_number,
         sales_order.mfg,
         serial_number,
         sales_order.original_source_id,
         siop_segment1,
         siop_segment2,
         siop_segment3,
         siop_segment4,
         siop_segment5,
         siop_segment6,
         policy_definition.code,
         policy_definition.description,
         policy_definition.priority,
      --   policy.till_date, Policy till date is not showing correctly Mohit reviewed sql but needs to investigate further
         warranty_type,
         policy_definition.months_frm_delivery,
         policy_definition.months_frm_shipment,
         true_coverage_months
    FROM claim,
         claimed_item,
         payment,
         line_item_groups,
         line_item_group,
         applicable_policy,
         policy,
         policy_definition,
         warranty,
         inventory_item,
         item,
         sales_order
   WHERE     CLAIM.ID = CLAIMED_ITEM.CLAIM
         AND CLAIMED_ITEM.ITEM_REF_INV_ITEM = INVENTORY_ITEM.ID
         AND inventory_item.for_sales_order = sales_order.id
         AND warranty.id = policy.warranty
         AND warranty.for_item = inventory_item.id
         AND item.id = inventory_item.of_type
         AND claim.filed_on_date > '13-NOV-2016'
        --AND claim.business_unit_info = 'HVAC TCP' --Jean Skemp recommends using original source id insteal
         AND state = 'ACCEPTED_AND_CLOSED'
         AND CLAIM.PAYMENT = PAYMENT.ID
         AND PAYMENT.ID = LINE_ITEM_GROUPS.FOR_PAYMENT
         AND LINE_ITEM_GROUPS.LINE_ITEM_GROUPS = LINE_ITEM_GROUP.ID
         AND LINE_ITEM_GROUP.APPLICABLE_POLICY = APPLICABLE_POLICY.ID -- LINE_ITEM_GROUP.APPLICABLE_POLICY can be null
         AND APPLICABLE_POLICY.POLICY_DEFINITION = POLICY_DEFINITION.ID
         AND original_source_id in ('CS', 'GP')

--and inventory_item.serial_number like '11492KBA3R'
--ORDER BY claim, serial_number, priority