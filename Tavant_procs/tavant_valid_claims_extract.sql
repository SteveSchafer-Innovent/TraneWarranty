select claim_number, work_order_number, type, state, count(*) cnt, count(distinct ca.payment) cnt_Payment
from claim 
		INNER JOIN (
			SELECT DISTINCT CA.FOR_CLAIM, ca.PAYMENT
			FROM CLAIM_AUDIT CA 
			INNER JOIN PAYMENT P ON P.ID = CA.PAYMENT
			WHERE P.ACTIVE_CREDIT_MEMO IS NOT NULL
		) CA ON CA.FOR_CLAIM = CLAIM.ID
where 0 = 0
AND CLAIM.BUSINESS_UNIT_INFO = 'HVAC TCP'
AND (
            CLAIM.WORK_ORDER_NUMBER LIKE 'WR%' 
            OR 
            CLAIM.WORK_ORDER_NUMBER LIKE 'SW%'
            OR
            CLAIM.CLAIM_NUMBER IN ('C-10765684', 'C-10765685', 'C-10765687', 'C-10765689', 'C-10765703', 'C-10765694')
) 
group by claim_number, work_order_number, type, state
order by count(*) desc
;

select claim_number, state, type from claim where claim_number in ('C-10765823','C-10765809');

