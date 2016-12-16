--Expense Query For Parts:
--r12 GL String Parts: ENTITY.LOCATION.COSTCENTER.ACCOUNT.R12PRODUCTCODE.INTERCOMPANY

SELECT c.claim_number,
       i.ITEM_NUMBER AS PART_NBR,
       lig.name AS cost_category,                      --formerly expense type
       ppi.GL_CODE_COGS_REVERSAL AS GL_COGS_REVERSAL_STRING,
       ppi.GL_CODE_REVENUE_REVERSAL AS GL_REV_REVERSAL_STRING,
       ppi.GL_CODE_WNTY_EXPENSE_REV AS GL_EXPENSE_STRING,
       ppi.GL_COGS_AMT,
       ppi.GL_COGS_CURR AS GL_COGS_CURRENCY,
       ppi.GL_REVENUE_AMT,
       ppi.GL_REVENUE_CURR,
       ppi.GL_EXPENSE_AMT,
       ppi.GL_EXPENSE_CURR
  FROM claim c,
       payment p,
       line_item_groups ligs,
       line_item_group lig,
       CURRENT_PART_INFO cpi,
       PART_PAYMENT_INFO ppi, --NOTE: If modifier is not picked, PART_PAYMENT_INFO_MODIFIER table will be empty.
       item i
 WHERE     c.payment = p.id
       AND p.id = ligs.FOR_PAYMENT
       AND ligs.LINE_ITEM_GROUPS = lig.id
       AND lig.id = cpi.LINE_ITEM_GROUP
       AND cpi.CURRENT_PART_PAYMENT_INFO = ppi.id
       AND i.id = ppi.ITEM -- do we need an outer join here?
       AND (c.claim_number = 'C-10765255'  )
       - --'C-10765552'
--     or c.claim_number = 'C-10764718'
--     or c.claim_number = 'C-10764743'
--   or c.claim_number = 'C-10764732')
 


