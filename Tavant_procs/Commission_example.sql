SELECT distinct
       claim.id as claim_id,
       claim.commercial_policy,
       claim.claim_number as claim_number,
       claim.TYPE as claim_type,
       claim.filed_on_date as filed_on_date,
       sales_order.job_number as job_number,
       sales_order.sales_order_number as sales_order_number,
       sales_order.mfg as mfg,
       item.siop_segment6 AS mfg_prod_code,
       credit_memo.credit_memo_number as credit_memo_number,
       credit_memo.credit_memo_date as credit_memo_date,
       payment.id as tavant_payment_id,
       payment.claimed_amount_amt as claim_payment_amt,
       payment.claimed_amount_curr as claim_amount_currency,
       credit_memo.cr_dr_flag as credit_debit_flag,
       commission_gl_wnty_expense AS gl_allocation_string,
   --    commission_amt AS claim_commission_amt_exp, --this is the CURRENT claim commission amount to get the entire claim split amount on a reopened claim you must summarize all comm_split_mat
       cc.commission_code as commission_code,
       commission_split as commission_split,
       split_amount_amt AS comm_split_amt,
       split_amount_curr AS comm_split_currency,
       sysdate as ed_create_date
  FROM claim,
       payment,
       credit_memo,
       claimed_item,
       inventory_item,
       item,
       sales_order,
       service_information si,
       service s,
       service_commission_details scd,
       commission_detail cd,
       commission_code cc
 WHERE     claim.payment = payment.id
       AND payment.active_credit_memo = credit_memo.id (+)
       --AND claim.for_sales_order = sales_order.id -- need to remove this
       AND claim.id = claimed_item.claim
       AND CLAIMED_ITEM.item_ref_inv_item = INVENTORY_ITEM.ID
       AND inventory_item.for_sales_order = sales_order.id
       AND item.id = inventory_item.of_type
       AND claim.service_information = si.id
       AND si.service_detail = s.id
       AND s.id = scd.service
       AND scd.commission_details = cd.id
       AND cc.id = cd.commission_code
			 and  CLAIM.CLAIM_NUMBER = 'C-10764004'
    --   AND claim.claim_number LIKE '%10764900%'
ORDER BY claim.claim_number,
COMMISSION_CODE, COMMISSION_SPLIT;