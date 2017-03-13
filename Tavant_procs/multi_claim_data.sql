SELECT * FROM CLAIM WHERE CLAIM_NUMBER = 'C-10764227';
SELECT
	c.claim_number, c.state, count(*), min(work_order_number), max(work_order_number)
	/*
		P.ID AS PAYMENT_ID,
		P.ACTIVE_CREDIT_MEMO,
		CM.CREDIT_MEMO_NUMBER
	*/
	FROM
		CLAIM C
		inner join CLAIM_AUDIT CA on C.ID = CA.FOR_CLAIM
		inner join PAYMENT P on P.ID = CA.PAYMENT
		inner join CREDIT_MEMO CM on P.ACTIVE_CREDIT_MEMO = CM.ID
	WHERE 0=0
		AND P.ACTIVE_CREDIT_MEMO IS NOT NULL
	and	C.CLAIM_NUMBER NOT LIKE '%FALCON'
	AND C.BUSINESS_UNIT_INFO = 'HVAC TCP' 
	AND ( C.WORK_ORDER_NUMBER LIKE 'WR%'
		or
			C.CLAIM_NUMBER IN( 'C-10763992', 'C-10764004', 'C-10764005', 'C-10764006', 'C-10764013', 'C-10764014', 'C-10764015', 'C-10764019', 'C-10764022', 'C-10764023', 'C-10764024', 'C-10764025', 'C-10764028', 'C-10764038', 'C-10764041', 'C-10764048', 'C-10764066', 'C-10764067', 'C-10764073', 'C-10764079', 'C-10764106', 'C-10764106', 'C-10764198', 'C-10764218', 'C-10764224', 'C-10764227', 'C-10764275', 'C-10764284', 'C-10764285', 'C-10764288', 'C-10764292', 'C-10764323', 'C-10764338', 'C-10764534')
			) 
	group by c.claim_number, c.state
	order by 1 desc
;
SELECT
		P.ID,
		P.ACTIVE_CREDIT_MEMO,
		LIG.NAME,
		LIG.GL_CODE_WNTY_EXPENSE_REV,
		LIG.TOTAL_CREDIT_AMT,
		LIG.*
	FROM
		LINE_ITEM_GROUPS LIGS,
		PAYMENT P,
		LINE_ITEM_GROUP LIG
	WHERE
		P.ID = LIGS.FOR_PAYMENT
		AND P.ID IN(110000214582795, 110000214579965)
		AND LIGS.LINE_ITEM_GROUPS = LIG.ID
		AND LIG.GL_CODE_WNTY_EXPENSE_REV IS NOT NULL;
		
select distinct name from line_item_group;		

select * from payment;
select * from credit_memo;
select * from claim_audit;
select c.claim_number, updated_time, ca.Previous_state, P.Claimed_Amount_Amt, P.Total_Amount_Amt, cm.CREDIT_MEMO_NUMBER, cm.CREDIT_MEMO_DATE, p.id, p2.id,-- LIG.NAME,
case when C.CLAIM_NUMBER IN( 'C-10763992', 'C-10764004', 'C-10764005', 'C-10764006', 'C-10764013', 'C-10764014', 'C-10764015', 'C-10764019', 'C-10764022', 'C-10764023', 'C-10764024', 'C-10764025', 'C-10764028', 'C-10764038', 'C-10764041', 'C-10764048', 'C-10764066', 'C-10764067', 'C-10764073', 'C-10764079', 'C-10764106', 'C-10764106', 'C-10764198', 'C-10764218', 'C-10764224', 'C-10764227', 'C-10764275', 'C-10764284', 'C-10764285', 'C-10764288', 'C-10764292', 'C-10764323', 'C-10764338', 'C-10764534') then 1 else 0 end as FIT_DATA
from claim_audit ca
inner join claim c on C.ID = CA.FOR_CLAIM
inner join payment p on P.ID = CA.PAYMENT
left outer join payment p2 on p.id = c.payment
inner join CREDIT_MEMO CM on P.ACTIVE_CREDIT_MEMO = CM.ID
-- INNER JOIN LINE_ITEM_GROUPS LIGS ON P.ID = LIGS.FOR_PAYMENT
-- INNER JOIN LINE_ITEM_GROUP LIG   ON LIGS.LINE_ITEM_GROUPS = LIG.ID
where 0=0
 and c.claim_number = 'C-10764004' -- denied and closed
-- and c.claim_number = 'C-10764041' -- same credit memo, twice
-- and c.claim_number = 'C-10764106' -- two credit memos
and P.ACTIVE_CREDIT_MEMO IS NOT NULL
	and	C.CLAIM_NUMBER NOT LIKE '%FALCON'
	AND C.BUSINESS_UNIT_INFO = 'HVAC TCP' 
	AND ( C.WORK_ORDER_NUMBER LIKE 'WR%'
		or
			C.CLAIM_NUMBER IN( 'C-10763992', 'C-10764004', 'C-10764005', 'C-10764006', 'C-10764013', 'C-10764014', 'C-10764015', 'C-10764019', 'C-10764022', 'C-10764023', 'C-10764024', 'C-10764025', 'C-10764028', 'C-10764038', 'C-10764041', 'C-10764048', 'C-10764066', 'C-10764067', 'C-10764073', 'C-10764079', 'C-10764106', 'C-10764106', 'C-10764198', 'C-10764218', 'C-10764224', 'C-10764227', 'C-10764275', 'C-10764284', 'C-10764285', 'C-10764288', 'C-10764292', 'C-10764323', 'C-10764338', 'C-10764534')
			)

order by 1, 2 desc;

110000249053898
110000214583483
--Get Payment and corresponding Active credit memos
select p.id as payment_id, c.payment gl_detail_payment_id, P.D_Created_On payment_date, p.ACTIVE_CREDIT_MEMO, cm.CREDIT_MEMO_NUMBER, c.id claim_id, c.claim_number
from claim c, claim_audit ca, payment p, credit_memo cm
where c.id = ca.for_claim
and p.id = ca.payment
and p.ACTIVE_CREDIT_MEMO is not null
and p.ACTIVE_CREDIT_MEMO = cm.id
 and c.claim_number in ('C-10764004','C-10764041','C-10764106', 'C-10764285')
-- and c.claim_number = 'C-10764004';
order by claim_number, payment_date
;
110001080697100
C-10764004

--Get GL strings and amount paid for “other” categories based on payment.
select p.id, p.ACTIVE_CREDIT_MEMO, lig.NAME, lig.GL_CODE_WNTY_EXPENSE_REV, lig.total_credit_amt
from line_item_groups ligs, payment p, line_item_group lig
where p.id = ligs.for_payment 
-- and p.id in (110000214582795, 110000214579965) -- C-10764106   110000214579607
 and p.id in (110000249053898, 110000214583483) -- C-10764041  110000214578292
-- and p.id in (110000214583492,110000249064679) -- C-10764004  110000214577514
and ligs.line_item_groups = lig.id
and lig.GL_CODE_WNTY_EXPENSE_REV is not null;

