--Expense Query For OEM Parts Modifiers:
SELECT
		C.CLAIM_NUMBER,
		I.ITEM_NUMBER AS PART_NBR,
		MI.MODIFIER_NAME AS GL_NAME,
		PPI.GL_CODE_WNTY_EXPENSE_REV,
		MI.GL_AMT,
		MI.GL_CURR,
		LIG.name,
		LIG.accepted_amt
	FROM
		CLAIM C
	INNER JOIN PAYMENT P                            ON C.PAYMENT = P.ID
	INNER JOIN LINE_ITEM_GROUPS LIGS                ON P.ID = LIGS.FOR_PAYMENT
	INNER JOIN LINE_ITEM_GROUP LIG                  ON LIGS.LINE_ITEM_GROUPS = LIG.ID
	INNER JOIN CURRENT_PART_INFO CPI                ON LIG.ID = CPI.LINE_ITEM_GROUP
	INNER JOIN PART_PAYMENT_INFO PPI                ON CPI.CURRENT_PART_PAYMENT_INFO = PPI.ID --NOTE: If modifier is not picked, PART_PAYMENT_INFO_MODIFIER table will be empty.
	LEFT OUTER JOIN PART_PAYMENT_INFO_MODIFIER PPIM ON PPI.ID = PPIM.PART_PAYMENT_INFO
	INNER JOIN MODIFIER_INFO MI                     ON MI.ID = PPIM.MODIFIER_INFO
	INNER JOIN ITEM I                               ON I.ID = PPI.ITEM
	WHERE
		0 = 0
		and mi.modifier_name like 'Rebate%'
		--AND C.CLAIM_NUMBER = 'C-10764292'
		order by c.claim_number
		;
		
		select distinct mi.modifier_name
			FROM
		CLAIM C
	INNER JOIN PAYMENT P                            ON C.PAYMENT = P.ID
	INNER JOIN LINE_ITEM_GROUPS LIGS                ON P.ID = LIGS.FOR_PAYMENT
	INNER JOIN LINE_ITEM_GROUP LIG                  ON LIGS.LINE_ITEM_GROUPS = LIG.ID
	INNER JOIN CURRENT_PART_INFO CPI                ON LIG.ID = CPI.LINE_ITEM_GROUP
	INNER JOIN PART_PAYMENT_INFO PPI                ON CPI.CURRENT_PART_PAYMENT_INFO = PPI.ID --NOTE: If modifier is not picked, PART_PAYMENT_INFO_MODIFIER table will be empty.
	LEFT OUTER JOIN PART_PAYMENT_INFO_MODIFIER PPIM ON PPI.ID = PPIM.PART_PAYMENT_INFO
	INNER JOIN MODIFIER_INFO MI                     ON MI.ID = PPIM.MODIFIER_INFO
	INNER JOIN ITEM I                               ON I.ID = PPI.ITEM
	WHERE
		0 = 0
		and mi.modifier_name like 'Rebate%'
		--AND C.CLAIM_NUMBER = 'C-10764292'
		;