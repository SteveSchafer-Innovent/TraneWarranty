alter table bh.r12_gl_code_combinations rename column SEGMENT1 to PS_SEGMENT1;
alter table bh.r12_gl_code_combinations rename column SEGMENT2 to PS_SEGMENT2;
alter table bh.r12_gl_code_combinations rename column SEGMENT3 to PS_SEGMENT3;
alter table bh.r12_gl_code_combinations rename column SEGMENT4 to PS_SEGMENT4;

alter table R12_GL_ACCOUNT_SCD rename column COMPANY to PS_COMPANY;
alter table R12_GL_ACCOUNT_SCD rename column ACCOUNT to PS_ACCOUNT;
alter table R12_GL_ACCOUNT_SCD rename column COST_CENTER to PS_COST_CENTER;
alter table R12_GL_ACCOUNT_SCD rename column PROD_CODE to PS_PROD_CODE;