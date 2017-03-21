select * from tav_payment_raw where claim_number = 'C-20000138';
select * from tav_temp where claim_number = 'C-20000138' order by 2,3;
select * from tav_stg where claim_number = 'C-20000138' order by 2,3;
where claim_number = 'C-20000139'
order by claim_number, r12_invoice, Cost_Category_Sv;
select claim_number
from tav_stg
group by claim_number
having count(distinct r12_invoice) > 1
order by 1
;

C-20000124
C-20000138
C-20000165
C-20000304
C-20000402
C-20000562
C-20000578
