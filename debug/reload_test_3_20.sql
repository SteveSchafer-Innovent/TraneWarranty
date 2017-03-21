select a.* from tav_stg a order by 1,2, cost_category_sv;
select claim_number, r12_invoice, Accepted_Amt_Labor, Accepted_Amt_Material from tav_temp where claim_number = 'C-20000402' order by 1,2;
select a.claim_number, a.r12_invoice, A.Expense_Amount, A.Cost_Category_Sv from tav_stg a where claim_number = 'C-20000402' order by 1,2, cost_category_sv;

select distinct claim_number from Map_Warranty_Expense_Data;
select count(*) from Map_Warranty_Expense_Data where claim_number < 0;
select count(*) from Map_Warranty_Expense_Data where claim_number > 0;
select count(*) from Map_Concession_Expense_Data where claim_number < 0;
select count(*) from Map_Concession_Expense_Data where claim_number > 0;

select cost_category_sv, count(*)from tav_stg group by cost_category_sv;

-- compare to R12 acct data
select ts.claim_number, ts.r12_invoice, r12.claim_number, r12.invoice
from tav_stg ts
left outer join DBO.R12_Bi_Acct_Entry_Stg_t@DR_ENT_RPT_DW.LAX.TRANE.COM r12 on 
	substr(r12.claim_number,1,instr(r12.claim_number, '_', 1) - 1 ) = ts.claim_number 
	and r12.invoice = ts.r12_invoice
order by 1
;

select * from Map_Concession_Expense_Data where claim_number < 0;
select * from Map_warranty_Expense_Data where claim_number < 0;