-- about 1,000 are like this
select count(*) -- gl_product_code, manf_prod_code, ora_product 
from otr_prod_code_xref_rcpo where gl_product_code = manf_prod_code;

-- no plnt_gl_prod = ps_gl_prod (makes sense)
select plnt_gl_prod, ps_gl_prod, r12_product from R12_ORACLE_PS_REV_RCPO where plnt_gl_prod = ps_gl_prod;