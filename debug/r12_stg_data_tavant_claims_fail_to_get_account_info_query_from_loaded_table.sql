select * from DBO.R12_Bi_Acct_Entry_Stg where invoice in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828','2159882');
select * from DBO.R12_Bi_Hdr_Stg where invoice in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828','2159882');
select * from DBO.R12_Bi_Line_Stg  where invoice in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828','2159882');
select * from DBO.R12_Trnbi_Bi_Hdr_Stg where invoice in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828','2159882');

select distinct manf_prod_id from DBO.R12_Bi_Line_Stg  where invoice in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828','2159882');

select a.* from R12_BILLING_ACCTG_RPT a
where tran_nbr in ('2158601','2158738','2158810','2158886','2159113','2159484','2159788','2159828','2159882')
order by 1;

