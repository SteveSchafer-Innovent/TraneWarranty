--Expense Query  for Cost Categories labor, non oem parts, travel, etc, everything but OEM parts

SELECT distinct c.claim_number,
       lig.NAME as cost_category, --formerly expense type
       lig.GL_CODE_WNTY_EXPENSE_REV,
       lig.GL_AMT,
       lig.GL_CURR
  FROM claim c,
       payment p,
       line_item_groups ligs,
       line_item_group lig
 WHERE     c.payment = p.id
       AND p.id = ligs.FOR_PAYMENT
       AND ligs.LINE_ITEM_GROUPS = lig.id
       AND lig.NAME NOT IN ('Oem Parts', 'Claim Amount')
        AND c.claim_number = 'C-10765552' --'C-10765255'
       and gl_code_wnty_expense_rev is not null
       
       
