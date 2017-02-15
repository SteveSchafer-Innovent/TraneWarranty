select p.id as payment_id, p.ACTIVE_CREDIT_MEMO, cm.CREDIT_MEMO_NUMBER
from claim c, claim_audit ca, payment p, credit_memo cm
where c.id = ca.for_claim
and p.id = ca.payment
and p.ACTIVE_CREDIT_MEMO is not null
and p.ACTIVE_CREDIT_MEMO = cm.id
and c.claim_number = 'C-10764106';


--Get GL strings and amount paid for “other” categories based on payment.
select p.id, p.ACTIVE_CREDIT_MEMO, lig.NAME, lig.GL_CODE_WNTY_EXPENSE_REV, lig.total_credit_amt
from line_item_groups ligs, payment p, line_item_group lig
where p.id = ligs.for_payment 
and p.id in (110000214582795, 110000214579965)
and ligs.line_item_groups = lig.id
and lig.GL_CODE_WNTY_EXPENSE_REV is not null;
