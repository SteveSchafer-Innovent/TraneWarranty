--Expense Query including modifiers for other Cost Categories i.e. labor, non oem parts, commission, travel, etc
/* Formatted on 10/3/2016 4:38:18 PM (QP5 v5.163.1008.3004) */
SELECT
		C.CLAIM_NUMBER,
		LIG.NAME AS COST_CATEGORY, --formerly expense type
		LIG.GL_CODE_WNTY_EXPENSE_REV,
		LIG.GL_AMT,
		LIG.GL_CURR,
		M.MODIFIERS,
		LI.NAME MODIFIER_NAME,
		LI.GL_AMT MODIFIER_GL_AMT,
		LI.GL_CURR MODIFIER_GL_CURR
	FROM
		CLAIM C
	INNER JOIN PAYMENT P             ON C.PAYMENT = P.ID
	INNER JOIN LINE_ITEM_GROUPS LIGS ON P.ID = LIGS.FOR_PAYMENT
	INNER JOIN LINE_ITEM_GROUP LIG   ON LIGS.LINE_ITEM_GROUPS = LIG.ID
	LEFT OUTER JOIN MODIFIERS M      ON LIG.ID = M.LINE_ITEM_GROUP --NOTE: IF modifier IS NOT picked, MODIFIERS TABLE will be empty.
	LEFT OUTER JOIN LINE_ITEM LI     ON LI.ID = M.MODIFIERS
	WHERE
		0 = 0
		AND M.MODIFIERS IS NOT NULL
		and c.CLAIM_NUMBER = 'C-10764292'
		--  AND c.filed_on_date > '1-SEP-2016' --filter to restrict data to just that entered recently
		--AND c.claim_number = 'C-10765255'
		
;
-- a rebate
select *
from claim c
where c.CLAIM_NUMBER = 'C-10764292';