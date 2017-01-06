-- Extract
SELECT DISTINCT
		CLAIM.CLAIM_NUMBER,
		CLAIM.TYPE as TAVANT_CLAIM_TYPE, -- used for claim_type
		CLAIM.COMMERCIAL_POLICY, -- used for claim_type
		EXPENSES.QUERY_SOURCE,
		EXPENSES.WARRANTY_TYPE,
		EXPENSES.PRIORITY,
		EXPENSES.PART_NBR,
		EXPENSES.COST_CATEGORY,
		EXPENSES.GL_EXPENSE_STRING,
		-- 9258.115614.00000.511705.41125.0000.00000.00000
		REGEXP_SUBSTR(EXPENSES.GL_EXPENSE_STRING,'[^.]+', 1, 1) AS SEGMENT1,
		REGEXP_SUBSTR(EXPENSES.GL_EXPENSE_STRING,'[^.]+', 1, 2) AS SEGMENT2,
		REGEXP_SUBSTR(EXPENSES.GL_EXPENSE_STRING,'[^.]+', 1, 3) AS SEGMENT3,
		REGEXP_SUBSTR(EXPENSES.GL_EXPENSE_STRING,'[^.]+', 1, 4) AS SEGMENT4,
		REGEXP_SUBSTR(EXPENSES.GL_EXPENSE_STRING,'[^.]+', 1, 5) AS SEGMENT5,
		REGEXP_SUBSTR(EXPENSES.GL_EXPENSE_STRING,'[^.]+', 1, 6) AS SEGMENT6,
		REGEXP_SUBSTR(EXPENSES.GL_EXPENSE_STRING,'[^.]+', 1, 7) AS SEGMENT7,
		REGEXP_SUBSTR(EXPENSES.GL_EXPENSE_STRING,'[^.]+', 1, 8) AS SEGMENT8,
		EXPENSES.GL_EXPENSE_AMT,
		EXPENSES.GL_EXPENSE_CURR,
		REBATES.GL_NAME AS REBATES_GL_NAME,
		REBATES.GL_CODE_WNTY_EXPENSE_REV AS REBATES_GL_CODE_WNTY_EXP_REV,
		REBATES.GL_AMT AS REBATES_GL_AMT,
		REBATES.GL_CURR AS REBATES_GL_CURR,
		CLAIM.FAILURE_DATE,
		CLAIM.FILED_ON_DATE
	FROM
		CLAIM
	INNER JOIN (
		--Expense Query For Parts:
		--r12 GL String Parts: ENTITY.LOCATION.COSTCENTER.ACCOUNT.R12PRODUCTCODE.INTERCOMPANY
		SELECT
				C.CLAIM_NUMBER,
				'OEM' AS QUERY_SOURCE,
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
				PPI.GL_EXPENSE_CURR,
				AP.ID AS AP_ID,
				PD.ID AS PD_ID,
				PD.WARRANTY_TYPE,
				PD.PRIORITY
			FROM
				CLAIM C
			INNER JOIN PAYMENT P             ON C.PAYMENT = P.ID
			INNER JOIN LINE_ITEM_GROUPS LIGS ON P.ID = LIGS.FOR_PAYMENT
			INNER JOIN LINE_ITEM_GROUP LIG   ON LIGS.LINE_ITEM_GROUPS = LIG.ID
			INNER JOIN CURRENT_PART_INFO CPI ON LIG.ID = CPI.LINE_ITEM_GROUP
			INNER JOIN PART_PAYMENT_INFO PPI ON CPI.CURRENT_PART_PAYMENT_INFO = PPI.ID --NOTE: If modifier is not picked, PART_PAYMENT_INFO_MODIFIER table will be empty.
			INNER JOIN ITEM I                ON I.ID = PPI.ITEM 
			LEFT OUTER JOIN APPLICABLE_POLICY AP ON PPI.APPLICABLE_POLICY = AP.ID -- LINE_ITEM_GROUP.APPLICABLE_POLICY can be null
			LEFT OUTER JOIN POLICY_DEFINITION PD ON AP.POLICY_DEFINITION = PD.ID
		
		UNION ALL
		
		--Expense Query  for Cost Categories labor, non oem parts, travel, etc, everything but OEM parts
		SELECT DISTINCT
				C.CLAIM_NUMBER,
				'NON-OEM' AS QUERY_SOURCE,
				NULL AS ITEM_NUMBER,
				LIG.NAME AS COST_CATEGORY, --formerly expense type
				NULL AS GL_COGS_REVERSAL_STRING,
				NULL AS GL_REV_REVERSAL_STRING,
				LIG.GL_CODE_WNTY_EXPENSE_REV AS GL_EXPENSE_STRING,
				-- GL_ACCOUNT is Segment4 of the GL_EXPENSE_STRING
				NULL AS GL_COGS_AMT,
				NULL AS GL_COGS_CURRENCY,
				NULL AS GL_REVENUE_AMT,
				NULL AS GL_REVENUE_CURR,
				LIG.ACCEPTED_AMT AS EXPENSE_AMOUNT,
				LIG.ACCEPTED_CURR AS EXPENSE_CURRENCY,
				AP.ID AS AP_ID,
				PD.ID AS PD_ID,
				PD.WARRANTY_TYPE,
				PD.PRIORITY
			FROM
				CLAIM C
			INNER JOIN PAYMENT P             ON C.PAYMENT = P.ID
			INNER JOIN LINE_ITEM_GROUPS LIGS ON P.ID = LIGS.FOR_PAYMENT
			INNER JOIN LINE_ITEM_GROUP LIG   ON LIGS.LINE_ITEM_GROUPS = LIG.ID
			LEFT OUTER JOIN APPLICABLE_POLICY AP ON LIG.APPLICABLE_POLICY = AP.ID -- LINE_ITEM_GROUP.APPLICABLE_POLICY can be null
			LEFT OUTER JOIN POLICY_DEFINITION PD ON AP.POLICY_DEFINITION = PD.ID
			WHERE
				0 = 0
				AND LIG.NAME NOT IN('Oem Parts', 'Claim Amount')
				AND LIG.GL_CODE_WNTY_EXPENSE_REV IS NOT NULL 

	) EXPENSES
		ON EXPENSES.CLAIM_NUMBER = CLAIM.CLAIM_NUMBER
	LEFT OUTER JOIN (
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
	) REBATES
		ON REBATES.CLAIM_NUMBER = CLAIM.CLAIM_NUMBER AND REBATES.PART_NBR = EXPENSES.PART_NBR
	WHERE
		0 = 0
		-- AND CLAIM.FILED_ON_DATE > '13-NOV-2016'
		--AND claim.business_unit_info = 'HVAC TCP' --Jean Skemp recommends using original source id insteal
		AND STATE = 'ACCEPTED_AND_CLOSED'
		-- AND SALES_ORDER.ORIGINAL_SOURCE_ID IN('CS', 'GP')
		-- and claim.claim_number = 'C-10764292'
		-- and inventory_item.serial_number like '11492KBA3R'
		--ORDER BY claim, serial_number, priority
-- AND CLAIM.CLAIM_NUMBER = 'C-10764292'
/**/
AND CLAIM.CLAIM_NUMBER IN (
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
/**/
order by 1, 2, 3, 4, 5;