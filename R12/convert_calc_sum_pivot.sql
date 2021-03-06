alter table DM_030_CALC_SUM_PIVOT add R12_GL_ACCOUNT VARCHAR2(10);

update DM_030_CALC_SUM_PIVOT CFP set
R12_GL_ACCOUNT=(select R12_ACCOUNT from R12_TRANE_ACCOUNTS_PS PSA where PSA.PS_ACCOUNT = CFP.GL_ACCOUNT)
where exists (select R12_ACCOUNT from R12_TRANE_ACCOUNTS_PS PSA where PSA.PS_ACCOUNT = CFP.GL_ACCOUNT);

alter table DM_030_CALC_SUM_PIVOT drop column GL_ACCOUNT;
alter table DM_030_CALC_SUM_PIVOT rename column R12_GL_ACCOUNT to GL_ACCOUNT;

commit;

-- NOTE: GL_ACCOUNT_DESCRIPTION isn't big enough for R12 descriptions
alter table DM_030_CALC_SUM_PIVOT add R12_GL_ACCOUNT_DESCR varchar2(128);

update DM_030_CALC_SUM_PIVOT CFP
set R12_GL_ACCOUNT_DESCR = (select DESCR from R12_ACCOUNT_FILTER_UPD AFU where AFU.R12_ACCOUNT = CFP.GL_ACCOUNT)
where exists (select DESCR from R12_ACCOUNT_FILTER_UPD AFU where AFU.R12_ACCOUNT = CFP.GL_ACCOUNT);

alter table DM_030_CALC_SUM_PIVOT drop column GL_ACCOUNT_DESCR;
alter table DM_030_CALC_SUM_PIVOT rename column R12_GL_ACCOUNT_DESCR to GL_ACCOUNT_DESCR;

commit;

