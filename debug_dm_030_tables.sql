select ca.gl_account, caCnt, rrCnt
from (
select 'ca', gl_account, count(*) caCnt from dm_030_comm_amortization group by gl_account
) ca
join (
select 'rr', gl_account, count(*) rrCnt from dm_030_rev_release group by gl_account
) rr on rr.gl_account = ca.gl_account
;

select 'ca', gl_account, count(*) caCnt from dm_030_comm_amortization group by gl_account
union all
select 'rr', gl_account, count(*) rrCnt from dm_030_rev_release group by gl_account
;

select * from dm_030_rev_release where rownum < 10;

-- R12_BI_HDR_PSB
select * from R12_BI_HDR_PSB where rownum < 100;
select listagg(entry_type,', ' ) within group (order by entry_type)  from (select distinct entry_type from R12_bi_hdr_psb); 
select listagg(bill_source_id, ', ') within group (order by bill_source_id)  from (select distinct bill_source_id from R12_bi_hdr_psb);
select distinct bill_source_id, count(*) from R12_bi_hdr_psb where bill_source_id in ('PBS','P21') group by bill_source_id;
select listagg(ps_business_unit, ', ') within group (order by ps_business_unit) from (select distinct ps_business_unit from R12_bi_hdr_psb); 
select count(*), count(distinct invoice) from R12_bi_hdr_psb;

-- BI ACCT
select listagg(LEDGER, ', ') within group (order by LEDGER) from (select distinct LEDGER from R12_BI_ACCT_ENTRY_PSB);
select ledger, count(*) from DBO.R12_BI_ACCT_ENTRY_PSB group by ledger; -- all values = ACTUALS

update DM_030_COMM_AMORTIZATION CA
INNER JOIN R12_TRANE_ACCOUNTS_PS psa on psa.ps_account = ca.gl_account
INNER JOIN R12_ACTUATE_UPDATE_FILTER afu on afu.r12_account = psa.r12_account
set 
	ca.gl_account = psa.r12_account,
	ca.gl_account_descr = afu.descr;
	
select distinct r12_account, gl_account_descr from DM_030_COMM_AMORTIZATION;
select distinct r12_account, descr from DBO.R12_ACCOUNT_FILTER_UPD 
where 
LIKE_52_53_54 = 'Y' 
or 
STANDARD_WARRANTY_EXPENSE = 'Y'
order by 1
;
desc R12_ACCOUNT_FILTER_UPD;
select distinct r12_account, descr from DBO.R12_ACCOUNT_FILTER_UPD 
where lower(descr) like 'legacy%';
