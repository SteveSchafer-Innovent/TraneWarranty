BEGIN
  P_LOAD_TAV_STG();
--rollback; 
END;

BEGIN
  P_LOAD_MAP_WARRANTY_EXP_TAV();
--rollback; zz
END;

BEGIN
  P_Load_Map_Concessions_Exp_Tav();
--rollback; 
END;

select * from tav_stg order by claim_number, r12_invoice;
select count(distinct claim_number) from tav_stg;
