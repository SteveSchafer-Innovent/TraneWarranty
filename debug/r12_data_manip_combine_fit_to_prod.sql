-- clean up r12_bi_acct_entry_stg_t to get only the FIT2 data.
select * from r12_bi_acct_entry_stg_t where ed_create_date > '01-mar-17';
delete from r12_bi_acct_entry_stg_t where journal_date < '03-MAR-17';
commit;
-- roll journal_date back one month
update r12_bi_acct_entry_stg_t
set
	journal_date = add_months(journal_date, -1);
commit;
delete from r12_bi_acct_entry_stg where claim_number like 'C%';

select * from r12_bi_acct_entry_stg_t order by journal_date desc;

-- clean up the other R12 tables with FIT data to only have FIT data
-- NOTE: Need to figure out how to get rid of the 'old' FIT2 data on reload
delete from R12_BI_HDR_STG_T where not exists (select * from r12_bi_acct_entry_stg_t where R12_BI_HDR_STG_T.invoice = r12_bi_acct_entry_stg_t.invoice);
delete from R12_BI_LINE_STG_T where not exists (select * from r12_bi_acct_entry_stg_t where R12_BI_LINE_STG_T.invoice = r12_bi_acct_entry_stg_t.invoice);
delete from R12_TRNBI_BI_HDR_STG_T where not exists (select * from r12_bi_acct_entry_stg_t where R12_TRNBI_BI_HDR_STG_T.invoice = r12_bi_acct_entry_stg_t.invoice);
commit;

select * from r12_bi_acct_entry_stg where claim_number like 'C-%' order by Claim_Number;
delete from r12_bi_acct_entry_stg where claim_number like 'C-%';
commit;

insert into r12_bi_acct_entry_stg select * from r12_bi_acct_entry_stg_t;
commit;
insert into R12_BI_HDR_STG select * from R12_BI_HDR_STG_T;
commit;
insert into R12_BI_LINE_STG select * from R12_BI_LINE_STG_T;
commit;
insert into R12_TRNBI_BI_HDR_STG select * from R12_TRNBI_BI_HDR_STG_T;
commit;

select count(*) from r12_bi_acct_entry_stg_t;
select count(*) from R12_BI_HDR_STG_T;
select count(*) from R12_BI_LINE_STG_T;
select count(*) from R12_TRNBI_BI_HDR_STG_T;

select entry_type, a.claim_number, a.invoice, A.Monetary_Amount
    FROM R12_BI_ACCT_ENTRY_STG_t A
    INNER JOIN R12_TRNBI_BI_HDR_STG_t B
      ON A.INVOICE = B.INVOICE 
      AND A.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
    INNER JOIN R12_BI_HDR_STG_t C
      ON B.INVOICE = C.INVOICE 
      AND B.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
where a.claim_number like 'C%' 
-- and entry_type = 'INV'
-- and claim_number like 'C-20000402%'
;


