--Expense Query including modifiers for other Cost Categories i.e. labor, non oem parts, commission, travel, etc
/* Formatted on 10/3/2016 4:38:18 PM (QP5 v5.163.1008.3004) */
SELECT c.claim_number,
       lig.NAME as cost_category, --formerly expense type
       lig.GL_CODE_WNTY_EXPENSE_REV,
       lig.GL_AMT,
       lig.GL_CURR,
       m.modifiers,
       li.NAME modifier_name,
       li.GL_AMT modifier_GL_AMT,
       li.GL_CURR modifier_GL_curr
  FROM claim c,
       payment p,
       line_item_groups ligs,
       line_item_group lig,
       MODIFIERS m, --NOTE: IF modifier IS NOT picked, MODIFIERS TABLE will be empty.
        line_item li
 WHERE     c.payment = p.id
       AND p.id = ligs.FOR_PAYMENT
       AND ligs.LINE_ITEM_GROUPS = lig.id
       AND lig.id = m.LINE_ITEM_GROUP (+)
       AND  li.id (+) = m.MODIFIERS
       and m.modifiers is not null
     --  AND c.filed_on_date > '1-SEP-2016' --filter to restrict data to just that entered recently
       --AND c.claim_number = 'C-10765255'