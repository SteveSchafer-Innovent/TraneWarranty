--Expense Query For Parts:
--r12 GL String Parts: ENTITY.LOCATION.COSTCENTER.ACCOUNT.R12PRODUCTCODE.INTERCOMPANY
SELECT
		C.CLAIM_NUMBER,
		I.ITEM_NUMBER AS PART_NBR,
		LIG.NAME AS COST_CATEGORY, --formerly expense type
		PPI.GL_CODE_COGS_REVERSAL AS GL_COGS_REVERSAL_STRING,
		PPI.GL_CODE_REVENUE_REVERSAL AS GL_REV_REVERSAL_STRING,
		PPI.GL_CODE_WNTY_EXPENSE_REV AS GL_EXPENSE_STRING,
		-- GL_ACCOUNT is Segment4 of the GL_EXPENSE_STRING
		PPI.GL_COGS_AMT,
		PPI.GL_COGS_CURR AS GL_COGS_CURRENCY,
		PPI.GL_REVENUE_AMT,
		PPI.GL_REVENUE_CURR,
		PPI.GL_EXPENSE_AMT,
		PPI.GL_EXPENSE_CURR
	FROM
		CLAIM C
	INNER JOIN PAYMENT P             ON C.PAYMENT = P.ID
	INNER JOIN LINE_ITEM_GROUPS LIGS ON P.ID = LIGS.FOR_PAYMENT
	INNER JOIN LINE_ITEM_GROUP LIG   ON LIGS.LINE_ITEM_GROUPS = LIG.ID
	INNER JOIN CURRENT_PART_INFO CPI ON LIG.ID = CPI.LINE_ITEM_GROUP
	INNER JOIN PART_PAYMENT_INFO PPI ON CPI.CURRENT_PART_PAYMENT_INFO = PPI.ID --NOTE: If modifier is not picked, PART_PAYMENT_INFO_MODIFIER table will be empty.
	INNER JOIN ITEM I                ON I.ID = PPI.ITEM 
-- do we need an outer join here?
	where 0=0
AND C.CLAIM_NUMBER = 'C-10763992'
/*
		AND C.CLAIM_NUMBER IN (
'C-10763992',
'C-10764004',
'C-10764005',
'C-10764006',
'C-10764013',
'C-10764014',
'C-10764015',
'C-10764019',
'C-10764022',
'C-10764023',
'C-10764024',
'C-10764025',
'C-10764028',
'C-10764038',
'C-10764041',
'C-10764048',
'C-10764066',
'C-10764067',
'C-10764073',
'C-10764079',
'C-10764106',
'C-10764106_I',
'C-10764198',
'C-10764218',
'C-10764224',
'C-10764227',
'C-10764275',
'C-10764284',
'C-10764285',
'C-10764288',
'C-10764292',
'C-10764323_D',
'C-10764338',
'C-10764534')
*/
order by 1, 2, 3;