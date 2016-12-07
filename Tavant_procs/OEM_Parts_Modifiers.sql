--Expense Query For OEM Parts Modifiers:
SELECT c.claim_number,
       i.ITEM_NUMBER as PART_NBR,
       mi.MODIFIER_NAME as GL_NAME,
       ppi.GL_CODE_WNTY_EXPENSE_REV,
       mi.GL_AMT,
       mi.GL_CURR
  FROM claim c,
       payment p,
       line_item_groups ligs,
       line_item_group lig,
       CURRENT_PART_INFO cpi,
       PART_PAYMENT_INFO ppi, --NOTE: If modifier is not picked, PART_PAYMENT_INFO_MODIFIER table will be empty.
       PART_PAYMENT_INFO_MODIFIER ppim,
       MODIFIER_INFO mi,
       item i
 WHERE     c.payment = p.id
       AND p.id = ligs.FOR_PAYMENT
       AND ligs.LINE_ITEM_GROUPS = lig.id
       AND lig.id = cpi.LINE_ITEM_GROUP
       AND cpi.CURRENT_PART_PAYMENT_INFO = ppi.id
       AND ppi.id = ppim.PART_PAYMENT_INFO (+)
       AND  mi.id =  ppim.MODIFIER_INFO 
       AND  i.id = ppi.ITEM 
    --   AND c.claim_number = 'C-10765552'