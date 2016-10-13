select * from BH.R12_GL_CODE_COMBINATIONS where r12_account = '9999';
select distinct ps_segment2 from BH.R12_GL_CODE_COMBINATIONS where r12_account = '9999';

select distinct R12_ACCOUNT 
from BH.R12_GL_CODE_COMBINATIONS 
where (ps_segment2 like '52%' or ps_segment2 like '53%' or ps_segment2 like '54%') and ps_segment2 not like '5268%' order by R12_ACCOUNT; -- 96 rows including 9999

select distinct PS_SEGMENT2 from BH.R12_GL_CODE_COMBINATIONS where R12_ACCOUNT in (
'210198', '223011', '223051', '225011', '225021', '225051', '225061', '260111', '260311', '260351', '260551', '260811', '260812', '260813', '260814', '260815', 
'260816', '260817', '275211', '275311', '275312', '275511', '275512', '275513', '275552', '275562', '275854', '275856', '280111', '280112', '280113', '280114', 
'280551', '280691', '281713', '281715', '281716', '281717', '281719', '281911', '281912', '281915', '281919', '281951', '281952', '281955', '281956', '281959', 
'282102', '282103', '282105', '282106', '282107', '282110', '282111', '282112', '282113', '282114', '282115', '282116', '282117', '282118', '282119', '282120', 
'282121', '282122', '282123', '282124', '282125', '282126', '282127', '282128', '282129', '282130', '282131', '282132', '282133', '282134', '282135', '282136', 
'282137', '282138', '282139', '282140', '282141', '282142', '282143', '282144', '282145', '282146', '282147', '282148', '282149', '282150', '282151', '282211', 
'282711', '282712', '282714', '284212', '284213', '284216', '284611', '290111', '290121', '290131', '290711', '295711', '296511', '296519', '296521', '296551', 
'296559'
) order by PS_SEGMENT2; -- 171 rows

select distinct R12_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS where ps_segment2 like '5268%' order by R12_ACCOUNT; -- 20 rows including 9999

select distinct PS_SEGMENT2 from BH.R12_GL_CODE_COMBINATIONS where R12_ACCOUNT in (
'281911', '281912', '281915', '281919', '282114', '282115', '282116', '282117', '282118', '282119', '282120', '282121', '282122', '282123', '282124', '282125', 
'282126', '282127', '282128'
) order by PS_SEGMENT2; -- 32 rows

select distinct R12_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS where ps_segment2 like '5%' order by R12_ACCOUNT; -- 136 rows including 9999


select distinct r12_location from BH.R12_GL_CODE_COMBINATIONS where ps_segment3 = 'SL00' order by r12_location;
-- 113602, 115615, 119001, 119007, 129001, 129003, 129004, 9999

select distinct r12_location from BH.R12_GL_CODE_COMBINATIONS where ps_segment3 = 'TCA0' order by r12_location;
-- 119001, 129001, 129004, 9999

select distinct r12_location from BH.R12_GL_CODE_COMBINATIONS where ps_segment3 in ('SL00','TCA0') order by r12_location;
-- 113602, 115615, 119001, 119007, 129001, 129003, 129004, 9999

select distinct R12_ACCOUNT from R12_TRNCO_CM_DIST_PSB where (PS_ACCOUNT like '52%' or PS_ACCOUNT like '53%' or PS_ACCOUNT like '54%') order by R12_ACCOUNT; -- 42 rows, including 9999
-- 281713, 281716, 281717, 281718, 282103, 282104, 282105, 282107, 282108, 282109, 282110, 282111, 282112, 282113, 282115, 282116, 282117, 282118, 282119, 282120, 282121, 282122, 282123, 282124, 282125, 282126, 282127, 282128, 282129, 282130, 282133, 282134, 282135, 282136, 282137, 282138, 282140, 282141, 282149, 282150, 282152, 9999

select distinct R12_ACCOUNT from R12_TRNCO_CM_DIST_PSB where (PS_ACCOUNT like '52%' or PS_ACCOUNT like '53%' or PS_ACCOUNT like '54%') and PS_ACCOUNT not like '5268%' order by R12_ACCOUNT; -- 42 rows, including 9999

select distinct PS_ACCOUNT from R12_TRNCO_CM_DIST_PSB where R12_ACCOUNT in (
'281713', '281716', '281717', '281718', '282103', '282104', '282105', '282107', '282108', '282109', '282110', '282111', '282112', '282113', '282115', '282116', 
'282117', '282118', '282119', '282120', '282121', '282122', '282123', '282124', '282125', '282126', '282127', '282128', '282129', '282130', '282133', '282134', 
'282135', '282136', '282137', '282138', '282140', '282141', '282149', '282150', '282152') order by PS_ACCOUNT;

select distinct R12_ACCOUNT from R12_TRNCO_CM_DIST_PSB where PS_ACCOUNT like '5268%' order by R12_ACCOUNT; -- 14 rows

select distinct PS_ACCOUNT from R12_TRNCO_CM_DIST_PSB where R12_ACCOUNT in (
'282115', '282116', '282117', '282118', '282119', '282120', '282121', '282122', '282123', '282124', '282125', '282126', '282127', '282128') order by PS_ACCOUNT; -- 14 rows

select r12_location, count(*) from BH.R12_GL_CODE_COMBINATIONS where ps_segment3 = 'SL00' group by r12_location order by r12_location;
-- 113602, 115615, 119001, 119007, 129001, 129003, 129004, 9999

select ps_segment3, count(*) from BH.R12_GL_CODE_COMBINATIONS where r12_location in (
'129004',
'119001',
'113602',
'129003',
'115615',
'119007',
'129001'
) group by ps_segment3 order by ps_segment3; -- 233 rows

select distinct r12_location from R12_TRNCO_CM_DIST_PSB where ps_deptid = 'SL00' order by r12_location;
-- 113602, 119001, 129001, 129003

select distinct r12_location from R12_TRNCO_CM_DIST_PSB where ps_deptid = 'TCA0' order by r12_location;
-- 129001, 129004

select distinct r12_location from R12_TRNCO_CM_DIST_PSB where ps_deptid IN ('SL00', 'TCA0') order by r12_location;
-- 113602, 119001, 129001, 129003, 129004

select distinct r12_location, ps_business_unit_gl, ps_account, ps_deptid, ps_product from R12_TRNCO_CM_DIST_PSB where ps_deptid = 'SL00' order by r12_location;

select distinct ps_deptid from R12_TRNCO_CM_DIST_PSB where r12_location in (select distinct r12_location from R12_TRNCO_CM_DIST_PSB where ps_deptid = 'SL00') order by ps_deptid; -- 22 rows

describe R12_TRNCO_CM_DIST_PSB;
select r12_location, count(*) from R12_TRNCO_CM_DIST_PSB where ps_deptid = 'SL00' group by r12_location;

select ps_deptid, count(*) from R12_TRNCO_CM_DIST_PSB where r12_location in (
'119001',
'113602',
'129003',
'129001'
) group by ps_deptid;

select * from R12_COM_SALES_RS_LEDGER where ps_product_id = 'TNA0';

select r12_product, count(*) from R12_BI_ACCT_ENTRY_PSB where ps_product = '0064' group by r12_product;

select ps_product, count(*) from R12_BI_ACCT_ENTRY_PSB where r12_product in ('41198', '41204') group by ps_product; -- 328 results

select r12_product, count(*) from R12_BI_ACCT_ENTRY_PSB where ps_product = '804155' group by r12_product; -- 41204

select r12_account, count(*) from R12_GL_ACCOUNT_SCD where ps_account = '523500' group by r12_account; -- 282106
select ps_account, count(*) from R12_GL_ACCOUNT_SCD where r12_account = '282106' group by ps_account;
select r12_account, count(*) from R12_GL_ACCOUNT_SCD where ps_account = '526892' group by r12_account; -- 282126
select ps_account, count(*) from R12_GL_ACCOUNT_SCD where r12_account = '282126' group by ps_account;
select r12_account, count(*) from R12_GL_ACCOUNT_SCD where ps_account = '526893' group by r12_account; -- 282127
select ps_account, count(*) from R12_GL_ACCOUNT_SCD where r12_account = '282127' group by ps_account;
select r12_account, count(*) from R12_GL_ACCOUNT_SCD where ps_account = '528200' group by r12_account; -- 282131
select ps_account, count(*) from R12_GL_ACCOUNT_SCD where r12_account = '282131' group by ps_account;
select r12_account, count(*) from R12_GL_ACCOUNT_SCD where ps_account = '528300' group by r12_account; -- 282132
select ps_account, count(*) from R12_GL_ACCOUNT_SCD where r12_account = '282132' group by ps_account;
select r12_account, count(*) from R12_GL_ACCOUNT_SCD where ps_account = '532100' group by r12_account; -- 282142
select ps_account, count(*) from R12_GL_ACCOUNT_SCD where r12_account = '282142' group by ps_account;

select r12_account, count(*) from R12_GL_ACCOUNT_SCD where ps_account like '523500%' group by r12_account; -- 282106

select * from BH.R12_GL_CODE_COMBINATIONS;

select distinct ps_business_unit_gl from R12_BI_ACCT_ENTRY_PSB;

select distinct R12_PRODUCT, PS_PRODUCT from R12_JRNL_LN_PS where PS_PRODUCT in ('ELIM', 'TNA0');
-- elim = 41198, 9999
-- tna0 = 41198, 41901
select distinct R12_PRODUCT, PS_PRODUCT from R12_JRNL_LN_PS where R12_PRODUCT = '9999'; -- 225 rows
select distinct R12_PRODUCT, PS_PRODUCT from R12_JRNL_LN_PS where R12_PRODUCT = '41198'; -- 458 rows
select distinct R12_PRODUCT, PS_PRODUCT from R12_JRNL_LN_PS where R12_PRODUCT = '41901'; -- 235 rows

select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS where PS_ACCOUNT = '700000'; -- 411101
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS where R12_ACCOUNT = '411101'; -- 700000, 700998, 902200, 700402, 700999, 902000, 700020, 720000
select count(*) from R12_JRNL_LN_PS where PS_ACCOUNT = '700000'; -- 6974511
select count(*) from R12_JRNL_LN_PS where R12_ACCOUNT = '411101'; -- 7074009
-- no fix, use r12 as-is, (ps = x or ps = blank) and r12 = x

select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS L where L.R12_ACCOUNT = '411101' AND (L.PS_ACCOUNT = '700000' OR L.PS_ACCOUNT = '');

select distinct R12_ACCOUNT from R12_PROJ_RESOURCE_PS where PS_ACCOUNT = '700000'; -- 411101
select distinct PS_ACCOUNT from R12_PROJ_RESOURCE_PS where R12_ACCOUNT = '411101'; -- 700000, 720000, 700020, 902000, 902200

select distinct R12_ACCOUNT from R12_PROJ_RESOURCE_PS where PS_ACCOUNT = '700020'; -- 411101, 411301
select distinct PS_ACCOUNT from R12_PROJ_RESOURCE_PS where R12_ACCOUNT in ('411101', '411301'); -- 700000, 720000, 700020, 902000, 902200

select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804180'; -- 41206
select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41206'; -- 15 rows (give to kelly)
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804180'; -- 4899076
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41206'; -- 9519853

select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804120'; -- 41201
select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41201'; -- 1129, 804120 (give to kelly)
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804120'; -- 59260
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41201'; -- 82248

select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804190'; -- 41299
select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41299'; -- 14 rows (give to kelly)
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804190'; -- 3296
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41299'; -- 26020018

select distinct R12_PRODUCT, PS_PRODUCT FROM R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '805100'; -- 41208
select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41208'; -- 805100
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '805100'; -- 544944
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41208'; -- 544944

select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '802921'; -- 41399
select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41399'; -- 11 rows (give to kelly)
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '802921'; -- 354
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41399'; -- 1990432

select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '801270'; -- 41132
select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41132'; -- 801270, 801100 (give to kelly)
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '801270'; -- 18913
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41132'; -- 20191

select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '803270'; -- 41499
select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41499'; -- '', 902240, 901103, 902120, 803270, 901123 (give to kelly)
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '803270'; -- 5641
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41499'; -- 785712

select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804140'; -- 41205, 41299
select distinct PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT in ('41205', '41299'); -- 16 rows (give to kelly)
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804140'; -- 291474
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT in '41205'; -- 291239

select distinct R12_PRODUCT, PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '0064'; -- 41204, 41198
select distinct PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT in ('41204', '41198') order by PS_PRODUCT; -- 363 rows (give to kelly)
select count(*) from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804140'; -- 291474
select count(*) from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT in '41205'; -- 291239

select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT like '0620%'; -- 9999

select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT like '8062%'; -- 511701, 511702, 511703, 511705, 511706, 9999
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT in (select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT like '8062%' and R12_ACCOUNT <> '9999') order by PS_ACCOUNT; -- 336 rows

select distinct R12_PRODUCT from R12_BI_ACCT_ENTRY_PSB where PS_PRODUCT = '804155'; -- 41204
select distinct PS_PRODUCT from R12_BI_ACCT_ENTRY_PSB where R12_PRODUCT = '41204' order by PS_PRODUCT; -- 43 rows (give to kelly)

select distinct R12_ACCOUNT from R12_LEDGER2_PS where PS_ACCOUNT between '523000' AND '546900' order by R12_ACCOUNT; -- 113 rows including 9999
select distinct PS_ACCOUNT from R12_LEDGER2_PS where R12_ACCOUNT in (
'210198', '223011', '223021', '223051', '225011', '225021', '225051', '260311', '275211', '275311', '275312', '275511', '275512', '275513', 
'275552', '275562', '275854', '275856', '275862', '280111', '280112', '280113', '280114', '280551', '281713', '281715', '281717', '281719', 
'281911', '281912', '281915', '281916', '281919', '281951', '281955', '281956', '281959', '282102', '282103', '282104', '282105', '282106', 
'282107', '282108', '282109', '282110', '282111', '282112', '282113', '282114', '282115', '282116', '282117', '282118', '282119', '282120', 
'282121', '282122', '282123', '282124', '282125', '282126', '282127', '282128', '282129', '282130', '282131', '282132', '282133', '282134', 
'282135', '282136', '282137', '282138', '282139', '282140', '282141', '282142', '282143', '282144', '282145', '282146', '282147', '282148', 
'282149', '282150', '282151', '282714', '284212', '284213', '284215', '284216', '284611', '285511', '290111', '290121', '290131', '290711', 
'290721', '290731', '291311', '291411', '295211', '295411', '295412', '295413', '295711', '296311', '296511', '296519', '296521', '296559'
) order by PS_ACCOUNT; -- 191 rows

select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '523500' order by R12_ACCOUNT; -- 282106
select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '526892' order by R12_ACCOUNT; -- 282126
select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '526893' order by R12_ACCOUNT; -- 282127
select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '528100' order by R12_ACCOUNT; -- 282130
select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '528200' order by R12_ACCOUNT; -- 282131
select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '528300' order by R12_ACCOUNT; -- 282132
select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '532100' order by R12_ACCOUNT; -- 282142

select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '282106';
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '282126';
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '282127';
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '282130';
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '282131';
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '282132';
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '282142';

select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT like '523500%' order by R12_ACCOUNT; -- 282106
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '282106'; -- 523500

select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '710000' order by R12_ACCOUNT; -- 411501
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '411501';

select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '806300' order by R12_ACCOUNT; -- 511707
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '511707'; -- 806300

select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD where PS_ACCOUNT = '428000' order by R12_ACCOUNT; -- 144201
select distinct PS_ACCOUNT from R12_GL_ACCOUNT_SCD where R12_ACCOUNT = '144201'; -- 424000, 428000, 429000


select distinct R12_ACCOUNT from R12_BI_ACCT_ENTRY_PSB order by R12_ACCOUNT; 

select distinct R12_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS order by R12_ACCOUNT;

select distinct R12_ACCOUNT from R12_JRNL_LN_PS order by R12_ACCOUNT;

select distinct R12_ACCOUNT from R12_TRNCO_CM_DIST_PSB order by R12_ACCOUNT; 

select distinct R12_ACCOUNT from R12_LEDGER2_PS order by R12_ACCOUNT;

select distinct R12_ACCOUNT from R12_PROJ_RESOURCE_PS order by R12_ACCOUNT;

-- DW
select distinct R12_ACCOUNT from R12_GL_ACCOUNT_SCD order by R12_ACCOUNT;

-- LIKE_52_53_54
select distinct a.R12_ACCOUNT, A.PS_ACCOUNT
from(
select distinct R12_ACCOUNT,PS_ACCOUNT
from R12_BI_ACCT_ENTRY_PSB aa
inner join otr_trane_accounts_ps b on b.account = aa.ps_account
where b.TRANE_ACCOUNT_IND = 'X'
union 
select distinct R12_ACCOUNT, PS_SEGMENT2 AS PS_ACCOUNT 
from BH.R12_GL_CODE_COMBINATIONS aa
inner join otr_trane_accounts_ps b on b.account = PS_SEGMENT2
where b.TRANE_ACCOUNT_IND = 'X'
union
select distinct R12_ACCOUNT, PS_ACCOUNT 
from R12_JRNL_LN_PS a
inner join otr_trane_accounts_ps b on b.account = a.ps_account
where b.TRANE_ACCOUNT_IND = 'X'
union
select distinct R12_ACCOUNT, PS_ACCOUNT 
from R12_TRNCO_CM_DIST_PSB a
inner join otr_trane_accounts_ps b on b.account = a.ps_account
where b.TRANE_ACCOUNT_IND = 'X'
union
select distinct R12_ACCOUNT, PS_ACCOUNT 
from R12_LEDGER2_PS a
inner join otr_trane_accounts_ps b on b.account = a.ps_account
where b.TRANE_ACCOUNT_IND = 'X'
union
select distinct R12_ACCOUNT, PS_ACCOUNT
from R12_PROJ_RESOURCE_PS a
inner join otr_trane_accounts_ps b on b.account = a.ps_account
where b.TRANE_ACCOUNT_IND = 'X'
) a
order by R12_ACCOUNT; 

select * from r12_trane_accounts_ps where r12_account like '%195462%';

select r12_account, listagg(ps_account || '-' || DESCR || '(' || TRANE_ACCOUNT_IND || ')', ',' ) WITHIN GROUP (ORDER BY ps_account) as "ps_accts"
from r12_trane_accounts_ps 
where r12_account in ('281951','281952','281955','281956','281959','282101','282102','295413','295711','296311','296511','296519','296521','296551','296559')
group by r12_account
;

select r12_account,PS_ACCOUNT
FROM R12_TRANE_ACCOUNTS_PS
WHERE R12_ACCOUNT IN
('282153','282154','281913','281917','281920','281921','281957','281960','282153','282154','282155','282156','296512','296513','296515','296516','296517','296520','296556','296557','296560')
;
-- EQUAL_490650
select distinct R12_ACCOUNT
from(
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_BI_ACCT_ENTRY_PSB 
union 
select distinct R12_ACCOUNT, PS_SEGMENT2 AS PS_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_TRNCO_CM_DIST_PSB 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_LEDGER2_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_PROJ_RESOURCE_PS
) a
where PS_ACCOUNT = '490650'
order by R12_ACCOUNT; -- 

-- LIKE_52
select distinct R12_ACCOUNT
from(
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_BI_ACCT_ENTRY_PSB 
union 
select distinct R12_ACCOUNT, PS_SEGMENT2 AS PS_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_TRNCO_CM_DIST_PSB 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_LEDGER2_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_PROJ_RESOURCE_PS
) a
where PS_ACCOUNT like '52%'
order by R12_ACCOUNT; -- 

-- LIKE_53
select distinct R12_ACCOUNT
from(
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_BI_ACCT_ENTRY_PSB 
union 
select distinct R12_ACCOUNT, PS_SEGMENT2 AS PS_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_TRNCO_CM_DIST_PSB 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_LEDGER2_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_PROJ_RESOURCE_PS
) a
where PS_ACCOUNT like '53%'
order by R12_ACCOUNT; -- 

-- LIKE_54
select distinct R12_ACCOUNT
from(
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_BI_ACCT_ENTRY_PSB 
union 
select distinct R12_ACCOUNT, PS_SEGMENT2 AS PS_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_TRNCO_CM_DIST_PSB 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_LEDGER2_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_PROJ_RESOURCE_PS
) a
where PS_ACCOUNT like '54%'
order by R12_ACCOUNT; -- 

-- LIKE 523500%
select distinct R12_ACCOUNT
from(
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_BI_ACCT_ENTRY_PSB 
union 
select distinct R12_ACCOUNT, PS_SEGMENT2 AS PS_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_TRNCO_CM_DIST_PSB 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_LEDGER2_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_PROJ_RESOURCE_PS
) a
where PS_ACCOUNT like '523500%'
order by R12_ACCOUNT; -- 

-- LIKE 5268%
select distinct R12_ACCOUNT, PS_ACCOUNT, b.descr
from(
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_BI_ACCT_ENTRY_PSB 
union 
select distinct R12_ACCOUNT, PS_SEGMENT2 AS PS_ACCOUNT from BH.R12_GL_CODE_COMBINATIONS 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_JRNL_LN_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_TRNCO_CM_DIST_PSB 
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_LEDGER2_PS
union
select distinct R12_ACCOUNT, PS_ACCOUNT from R12_PROJ_RESOURCE_PS
) a
inner join otr_trane_accounts_ps b on b.account = a.ps_account
where PS_ACCOUNT like '5268%'
and b.TRANE_ACCOUNT_IND = 'X'
order by R12_ACCOUNT; -- 

select PS_ACCOUNT, R12_ACCOUNT, DESCR
from r12_trane_accounts_ps 
where ps_account iN('523500', '526892', '526893', '528100', '528200', '528300', '532100');


-- LIKE_SL00
select distinct R12_LOCATION
from(
select distinct R12_LOCATION, PS_DEPTID from R12_TRNCO_CM_DIST_PSB
union
select distinct R12_LOCATION, PS_SEGMENT3 as PS_DEPTID from BH.R12_GL_CODE_COMBINATIONS
)
where PS_DEPTID = 'SL00' 
order by R12_LOCATION;
-- 113602, 115615, 119001, 119007, 129001, 129003, 129004, 9999

-- IN_SL00_TCA0
select distinct R12_LOCATION
from(
select distinct R12_LOCATION, PS_DEPTID from R12_TRNCO_CM_DIST_PSB
union
select distinct R12_LOCATION, PS_SEGMENT3 as PS_DEPTID from BH.R12_GL_CODE_COMBINATIONS
)
where PS_DEPTID in ('TCA0', 'SL00') 
order by R12_LOCATION;
-- 113602, 115615, 119001, 119007, 129001, 129003, 129004, 9999

select 
a.table_name, a.column_name, a.index_name, b.uniqueness
from all_ind_columns a, all_indexes b
where a.index_name=b.index_name 
and a.table_name in ('OTR_BI_ACCT_ENTRY_PSB',
'OTR_BI_HDR_PSB',
'OTR_BI_LINE_PSB',
'OTR_COM_SALES_RS_LEDGER',
'OTR_JRNL_HEADER_PS',
'OTR_JRNL_LN_PS',
'OTR_LEDGER2_PS',
'OTR_ORACLE_PS_REV_RCPO',
'OTR_PROD_CODE_XREF_RCPO',
'otr_TRANE_ACCOUNTS_ps',
'OTR_TRANE_DEPTS_PS',
'OTR_TRANE_PRODUCTS_PS',
'OTR_TRNBI_BI_HDR_PSB',
'otr_trnco_cm_dist_psb',
'PS_TRANE_ACCOUNTS')
order by a.table_name, a.index_name, a.column_position;

--ps_accounts used in prod 
select u.*, otr.*
from otr_trane_accounts_ps otr
left outer join (
select 'used' isUsed, ps_account from r12_trane_accounts_ps otr
where ps_account in ('526100', '528100', '528300', '528600', '544500', '523000', '526883', '526884', '526890', '528200', '528800', '532200', '532600', '523500', '526200', '526881', '528900', 
'529900', '526000', '526300', '526886', '526887', '529213', '532100', '532500', '546950', '526889', '526892', '546900', '526891', '526893', '528700', '532400', '526882', 
'529600', '532300', '523050', '523100', '526010', '526020', '526700', '526885', '526888', '526895', '527900', '529410', '529800', '546400', '526880')
) u on otr.account = u.ps_account
where otr.trane_account_ind = 'X';

select u.*, otr.*
from otr_trane_accounts_ps otr
left outer join (
select 'used' isUsed, ps_account from r12_trane_accounts_ps otr
where ps_account in ('526100', '528100', '528300', '528600', '544500', '523000', '526883', '526884', '526890', '528200', '528800', '532200', '532600', '523500', '526200', '526881', '528900', 
'529900', '526000', '526300', '526886', '526887', '529213', '532100', '532500', '546950', '526889', '526892', '546900', '526891', '526893', '528700', '532400', '526882', 
'529600', '532300', '523050', '523100', '526010', '526020', '526700', '526885', '526888', '526895', '527900', '529410', '529800', '546400', '526880')
) u on otr.account = u.ps_account
where otr.trane_account_ind = 'X';

select distinct OTR_BI_ACCT_ENTRY_PSB.ledger
from OTR_BI_ACCT_ENTRY_PSB;

select * from DBO.R12_TRANE_PRODUCTS_PS where rownum < 100 and r12_product <> 9999;

select * from DBO.R12_TRANE_PRODUCTS_PS where ps_product = '804900';
select distinct ps_gl_prod, r12_product, plnt_gl_prod, part_type, parts_prod_code_ind from R12_ORACLE_PS_REV_RCPO;
desc R12_ORACLE_PS_REV_RCPO;

select * from r12_trane_accounts_ps 
where PS_ACCOUNT LIKE '0620%'
OR PS_ACCOUNT LIKE '8062%';

-- standard warranty existing
select a.r12_account, a.typ, listagg(ps_account || '-' || DESCR, ','||chr(10) ) WITHIN GROUP (ORDER BY ps_account) as "ps_accts"
from (
	-- select '281911' as r12_account, 'S' as typ from dual union all
	-- select '281912', 'S' from dual	union all
	-- select '281915', 'S' from dual	union all
	-- select '281916', 'S' from dual	union all
	-- select '296519' , 'S' from dual	union all
	-- select '296511', 'S' from dual	union all
	-- select '296519', 'S' from dual	union all
	-- select '296521', 'S' from dual	union all
	select '511701' as r12_account, 'SE' as typ from dual	union all
	select '511702' , 'SE' from dual	union all
	select '511703' , 'SE' from dual	union all
	select '511704' , 'SE' from dual	union all
	select '511705' , 'SE' from dual	union all
	select '511706' , 'SE' from dual	union all
	select '511707' , 'SE' from dual	union all
	select '511709' , 'SE' from dual	union all
	-- select '281913', 'S' from dual	union all
	-- select '281917', 'S' from dual	union all
	-- select '281920', 'S' from dual	union all
	-- select '281921', 'S' from dual	union all
	-- select '296512', 'S' r12_account from dual	union all
	select '511707' , 'SE' from dual	union all
	-- select '296513' , 'S' from dual	union all
	-- select '296515' , 'S' from dual	union all
	-- select '296516' , 'S' from dual	union all
	-- select '296517' , 'S' from dual	union all
	-- select '296520' , 'S' from dual	union all
	-- select '281919' , 'S' from dual	union all
	select '411101' , 'R' from dual union all
	select '411301' , 'R' from dual union all
	select '411501' , 'R' from dual
) a
left outer join r12_trane_accounts_ps t on t.r12_account = a.r12_account
group by a.r12_account, a.typ
order by 1 
;
select distinct a.r12_account, ps_account, a.typ
from (
	-- select '281911' as r12_account, 'S' as typ from dual union all
	-- select '281912', 'S' from dual	union all
	-- select '281915', 'S' from dual	union all
	-- select '281916', 'S' from dual	union all
	-- select '296519' , 'S' from dual	union all
	-- select '296511', 'S' from dual	union all
	-- select '296519', 'S' from dual	union all
	-- select '296521', 'S' from dual	union all
	select '511701' as r12_account, 'SE' as typ from dual	union all
	select '511702' , 'SE' from dual	union all
	select '511703' , 'SE' from dual	union all
	select '511704' , 'SE' from dual	union all
	select '511705' , 'SE' from dual	union all
	select '511706' , 'SE' from dual	union all
	select '511707' , 'SE' from dual	union all
	select '511709' , 'SE' from dual	union all
	-- select '281913', 'S' from dual	union all
	-- select '281917', 'S' from dual	union all
	-- select '281920', 'S' from dual	union all
	-- select '281921', 'S' from dual	union all
	-- select '296512', 'S' r12_account from dual	union all
	select '511707' , 'SE' from dual	union all
	-- select '296513' , 'S' from dual	union all
	-- select '296515' , 'S' from dual	union all
	-- select '296516' , 'S' from dual	union all
	-- select '296517' , 'S' from dual	union all
	-- select '296520' , 'S' from dual	union all
	-- select '281919' , 'S' from dual	union all
	select '411101' , 'R' from dual union all
	select '411301' , 'R' from dual union all
	select '411501' , 'R' from dual
) a
inner join r12_trane_accounts_ps t on t.r12_account = a.r12_account
order by 1 
;
;

select distinct length(plnt_gl_prod), length(gl_prod) from otr_oracle_ps_rev_rcpo;

-- 1638
SELECT COUNT(*) 
FROM OTR_ORACLE_PS_REV_RCPO;
WHERE GL_PROD IS NULL;
