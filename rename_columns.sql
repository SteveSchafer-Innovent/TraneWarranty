alter table dbo.r12_ap_030_arc_bill rename column COMPANY to PS_COMPANY;
alter table dbo.r12_ap_030_arc_bill rename column ACCOUNT to PS_ACCOUNT;
alter table dbo.r12_bi_acct_entry_psb rename column ACCOUNT to PS_ACCOUNT;
alter table dbo.r12_bi_acct_entry_psb rename column PRODUCT to PS_PRODUCT;
alter table dbo.r12_bi_acct_entry_psb rename column BUSINESS_UNIT_GL to PS_BUSINESS_UNIT_GL;
alter table dbo.r12_bi_acct_entry_psb rename column DEPTID to PS_DEPTID;
alter table dbo.r12_bi_hdr_psb rename column BUSINESS_UNIT to PS_BUSINESS_UNIT;
alter table dbo.r12_bi_line_psb rename column IDENTIFIER to PS_IDENTIFIER;
alter table dbo.r12_trane_products_ps rename column PRODUCT to PS_PRODUCT;
alter table dbo.r12_trnco_cm_dist_psb rename column ACCOUNT to PS_ACCOUNT;
alter table dbo.r12_trnco_cm_dist_psb rename column PRODUCT to PS_PRODUCT;
alter table dbo.r12_trnco_cm_dist_psb rename column BUSINESS_UNIT_GL to PS_BUSINESS_UNIT_GL;
alter table dbo.r12_trnco_cm_dist_psb rename column DEPTID to PS_DEPTID;
