/* $Workfile: TRNBI_BI_HDR_PSB.sql $
*  $Revision: 14 $
*  $Archive: /DRTRNT_or_P/PeopleSoft/Tables/OTR_TRNBI_BI_HDR_PSB/TRNBI_BI_HDR_PSB.sql $
*  $Author: Iidid $
*  $Date: 2/22/11 7:03p $
*
* Description: This table is loaded from Peoplesoft databases FSTRNx into DRTRNx with Truncate/Insert.
* Destination table = DRTRNx.DBO.OTR_TRNBI_BI_HDR_PSB
* Source table = FSTRNx.SYSADM.PS_TRNBI_BI_HDR
* 
* Revisions: 
* 
*   change Date    Description 
*   -----------------    -------------------- 
*   06/22/2009     Neeraja V,Cognizant - Self running script. TTP #7922.
*   03/29/2010     Chinnathambi S,Cognizant - ED to DR migration TTP 7578
*   07/14/2010     Neeraja V,Cognizant - To add the unusable/reusable index code. TTP#7922
*   02/16/2011     Nithin Raj,Cognizant - Modified the code to handle long data type  column 
*						trnbi_hdr_note from source table. TTP#11013
*****************************************************************************************/ 

set timing on
set pause off
set feedback on
set echo on

spool trnbi_bi_hdr_psb.log  
whenever sqlerror exit failure;

prompt User and Database Connected To:
select user, name from v$database;

prompt Truncating OTR_TRNBI_BI_HDR_PSB
exec p_truncate_listed_table('dbo','OTR_TRNBI_BI_HDR_PSB');

prompt Making Indexes unusable on dbo.OTR_TRNBI_BI_HDR_PSB
EXEC dbo.Pkg_Mass_Load_Index_Manip.p_make_tbl_inds_unusable('DBO', 'OTR_TRNBI_BI_HDR_PSB', TRUE);

prompt Altering Session SORT_AREA_SIZE
ALTER SESSION SET SORT_AREA_SIZE = 20971520;


prompt INSERTING into OTR_TRNBI_BI_HDR_PSB
DECLARE
   CURSOR c1
   IS
      SELECT BUSINESS_UNIT,
             INVOICE,
             TRNBI_ORIG_SYS_REF,
             TRNBI_CLAIM_NUMBER,
             TRNBI_TRX_TYPE,
             TRNBI_CR_JOB_NBR,
             TRNBI_CREDIT_JB_ID,
             TRNBI_SALES_ORD_ID,
             TRNBI_DELIV_OPTION,
             TRNBI_MFG_BU,
             TRNBI_MFG_LOC,
             TRNBI_NBR_OF_LEGS,
             TRNBI_LEG_NBR,
             TRNBI_DOC_TYPE,
             TRNBI_TRAN_CUS_NBR,
             TRNBI_TRAN_BIL_ADD,
             TRNBI_SALES_OFFICE,
             TRNBI_INI_CONTRACT,
             TRNBI_TOTAL_STORED,
             TRNBI_PREV_CON_ADD,
             TRNBI_PREV_CON_DED,
             TRNBI_CURR_CON_ADD,
             TRNBI_CURR_CON_DED,
             TRNBI_PCT_CON_COMP,
             TRNBI_RETAINAGE_CM,
             TRNBI_STORE_MT_RET,
             TRNBI_STORE_MAT_CM,
             TRNBI_TOT_RETAINAG,
             TRNBI_CON_BIL_TODT,
             TRNBI_CON_EFF_DATE,
             TRNBI_CUS_PROJ_NBR,
             TRNBI_CONT_COMP_NM,
             TRNBI_CONT_CONTACT,
             TRNBI_CON_APP_DATE,
             TRNBI_VIAARCHITECT,
             TRNBI_ARCHITECT_AD,
             TRNBI_ARCHITECT_CT,
             TRNBI_ARCHITECT_ST,
             TRNBI_ARCHITECT_PC,
             TRNBI_ARC_PREV_AMT,
             TRNBI_ARC_CERT_IND,
             TRNBI_ARC_COMPANY,
             TRNBI_ARC_NAME,
             TRNBI_ARC_CERT_DT,
             TRNBI_ARC_AMT_CERT,
             TRNBI_CUS_PREV_AMT,
             TRNBI_CUS_CERT_IND,
             TRNBI_CUS_CERT_CON,
             TRNBI_CUS_CERT_AMT,
             TRNBI_FIN_INV_IND,
             TRNBI_IN_EMAIL_ADD,
             TRNBI_PLAN_SHPMT,
             TRNBI_CR_JOB_NAME,
             TRNBI_PROJECT_TYPE,
             TRNBI_REL_TRX_NBR,
             TRNBI_SHIP_TO_REF,
             TRNBI_RETAINAGE_PC,
             TRNBI_TOTAL_ADD,
             TRNBI_TOTAL_DED,
             TRNBI_CON_SUM_TODT,
             TRNBI_NET_CHG_BY,
             TRNBI_PROJECT_NAME,
             BI_CURRENCY_CD,
             CREATED_BY_USER,
             TRNBI_ORDER_TYPE,
             TRNBI_PRIM_SALESMN,
             TRNBI_WAYBILLNBR,
             FOB_TERMS,
             REMIT_FROM_CUST_ID,
             TRNBI_BATCH_ID,
             TRNBI_BILL_REVIEW,
             TRNBI_HDR_NOTE,
             TRNBI_SRV_CALL_ID,
             TRNBI_CUS_CERT_DAT,
             TRNBI_AUTH_ID,
             BUSINESS_UNIT_AR,
             TRNBI_ORIG_CUST_ID,
             TRNBI_FS_GRP_CD,
             TRNBI_MSTR_DEL_OPT,
             TRNBI_MSTR_INV_FRM,
             TRNBI_LOGO_KEY,
             SYSDATE AS ED_CREATE_DATE,
             'TRNBI_BI_HDR_PSB.sql' AS ED_CREATE_ID,
             SYSDATE AS ED_UPDATE_DATE,
             'TRNBI_BI_HDR_PSB.sql' AS ED_UPDATE_ID,
             'N' AS ED_SOURCE_ARCHIVE_IND
        FROM PS_TRNBI_BI_HDR;

   TYPE trnbi_bi_hdr IS TABLE OF c1%ROWTYPE
                           INDEX BY PLS_INTEGER;

   trnbi_hdr                trnbi_bi_hdr;

   l_trnbi_hdr_note         VARCHAR2 (4000);

   L_FETCH_LIMIT   CONSTANT INTEGER := 3000;

   l_fetch_count            PLS_INTEGER := 0;
BEGIN
   OPEN c1;

   LOOP
      FETCH c1
      BULK COLLECT INTO trnbi_hdr
      LIMIT L_FETCH_LIMIT;

      EXIT WHEN c1%ROWCOUNT = l_fetch_count;


      FOR l_index IN trnbi_hdr.FIRST .. trnbi_hdr.LAST
      LOOP
         l_trnbi_hdr_note :=
            SUBSTR (trnbi_hdr (l_index).trnbi_hdr_note, 1, 4000);

                     INSERT                                      /*+ APPEND */
                       INTO OTR_TRNBI_BI_HDR_PSB (BUSINESS_UNIT,
                                                  INVOICE,
                                                  TRNBI_ORIG_SYS_REF,
                                                  TRNBI_CLAIM_NUMBER,
                                                  TRNBI_TRX_TYPE,
                                                  TRNBI_CR_JOB_NBR,
                                                  TRNBI_CREDIT_JB_ID,
                                                  TRNBI_SALES_ORD_ID,
                                                  TRNBI_DELIV_OPTION,
                                                  TRNBI_MFG_BU,
                                                  TRNBI_MFG_LOC,
                                                  TRNBI_NBR_OF_LEGS,
                                                  TRNBI_LEG_NBR,
                                                  TRNBI_DOC_TYPE,
                                                  TRNBI_TRAN_CUS_NBR,
                                                  TRNBI_TRAN_BIL_ADD,
                                                  TRNBI_SALES_OFFICE,
                                                  TRNBI_INI_CONTRACT,
                                                  TRNBI_TOTAL_STORED,
                                                  TRNBI_PREV_CON_ADD,
                                                  TRNBI_PREV_CON_DED,
                                                  TRNBI_CURR_CON_ADD,
                                                  TRNBI_CURR_CON_DED,
                                                  TRNBI_PCT_CON_COMP,
                                                  TRNBI_RETAINAGE_CM,
                                                  TRNBI_STORE_MT_RET,
                                                  TRNBI_STORE_MAT_CM,
                                                  TRNBI_TOT_RETAINAG,
                                                  TRNBI_CON_BIL_TODT,
                                                  TRNBI_CON_EFF_DATE,
                                                  TRNBI_CUS_PROJ_NBR,
                                                  TRNBI_CONT_COMP_NM,
                                                  TRNBI_CONT_CONTACT,
                                                  TRNBI_CON_APP_DATE,
                                                  TRNBI_VIAARCHITECT,
                                                  TRNBI_ARCHITECT_AD,
                                                  TRNBI_ARCHITECT_CT,
                                                  TRNBI_ARCHITECT_ST,
                                                  TRNBI_ARCHITECT_PC,
                                                  TRNBI_ARC_PREV_AMT,
                                                  TRNBI_ARC_CERT_IND,
                                                  TRNBI_ARC_COMPANY,
                                                  TRNBI_ARC_NAME,
                                                  TRNBI_ARC_CERT_DT,
                                                  TRNBI_ARC_AMT_CERT,
                                                  TRNBI_CUS_PREV_AMT,
                                                  TRNBI_CUS_CERT_IND,
                                                  TRNBI_CUS_CERT_CON,
                                                  TRNBI_CUS_CERT_AMT,
                                                  TRNBI_FIN_INV_IND,
                                                  TRNBI_IN_EMAIL_ADD,
                                                  TRNBI_PLAN_SHPMT,
                                                  TRNBI_CR_JOB_NAME,
                                                  TRNBI_PROJECT_TYPE,
                                                  TRNBI_REL_TRX_NBR,
                                                  TRNBI_SHIP_TO_REF,
                                                  TRNBI_RETAINAGE_PC,
                                                  TRNBI_TOTAL_ADD,
                                                  TRNBI_TOTAL_DED,
                                                  TRNBI_CON_SUM_TODT,
                                                  TRNBI_NET_CHG_BY,
                                                  TRNBI_PROJECT_NAME,
                                                  BI_CURRENCY_CD,
                                                  CREATED_BY_USER,
                                                  TRNBI_ORDER_TYPE,
                                                  TRNBI_PRIM_SALESMN,
                                                  TRNBI_WAYBILLNBR,
                                                  FOB_TERMS,
                                                  REMIT_FROM_CUST_ID,
                                                  TRNBI_BATCH_ID,
                                                  TRNBI_BILL_REVIEW,
                                                  TRNBI_HDR_NOTE,
                                                  TRNBI_SRV_CALL_ID,
                                                  TRNBI_CUS_CERT_DAT,
                                                  TRNBI_AUTH_ID,
                                                  BUSINESS_UNIT_AR,
                                                  TRNBI_ORIG_CUST_ID,
                                                  TRNBI_FS_GRP_CD,
                                                  TRNBI_MSTR_DEL_OPT,
                                                  TRNBI_MSTR_INV_FRM,
                                                  TRNBI_LOGO_KEY,
                                                  ED_CREATE_DATE,
                                                  ED_CREATE_ID,
                                                  ED_UPDATE_DATE,
                                                  ED_UPDATE_ID,
                                                  ED_SOURCE_ARCHIVE_IND)
                     VALUES (trnbi_hdr (l_index).BUSINESS_UNIT,
                             trnbi_hdr (l_index).INVOICE,
                             trnbi_hdr (l_index).TRNBI_ORIG_SYS_REF,
                             trnbi_hdr (l_index).TRNBI_CLAIM_NUMBER,
                             trnbi_hdr (l_index).TRNBI_TRX_TYPE,
                             trnbi_hdr (l_index).TRNBI_CR_JOB_NBR,
                             trnbi_hdr (l_index).TRNBI_CREDIT_JB_ID,
                             trnbi_hdr (l_index).TRNBI_SALES_ORD_ID,
                             trnbi_hdr (l_index).TRNBI_DELIV_OPTION,
                             trnbi_hdr (l_index).TRNBI_MFG_BU,
                             trnbi_hdr (l_index).TRNBI_MFG_LOC,
                             trnbi_hdr (l_index).TRNBI_NBR_OF_LEGS,
                             trnbi_hdr (l_index).TRNBI_LEG_NBR,
                             trnbi_hdr (l_index).TRNBI_DOC_TYPE,
                             trnbi_hdr (l_index).TRNBI_TRAN_CUS_NBR,
                             trnbi_hdr (l_index).TRNBI_TRAN_BIL_ADD,
                             trnbi_hdr (l_index).TRNBI_SALES_OFFICE,
                             trnbi_hdr (l_index).TRNBI_INI_CONTRACT,
                             trnbi_hdr (l_index).TRNBI_TOTAL_STORED,
                             trnbi_hdr (l_index).TRNBI_PREV_CON_ADD,
                             trnbi_hdr (l_index).TRNBI_PREV_CON_DED,
                             trnbi_hdr (l_index).TRNBI_CURR_CON_ADD,
                             trnbi_hdr (l_index).TRNBI_CURR_CON_DED,
                             trnbi_hdr (l_index).TRNBI_PCT_CON_COMP,
                             trnbi_hdr (l_index).TRNBI_RETAINAGE_CM,
                             trnbi_hdr (l_index).TRNBI_STORE_MT_RET,
                             trnbi_hdr (l_index).TRNBI_STORE_MAT_CM,
                             trnbi_hdr (l_index).TRNBI_TOT_RETAINAG,
                             trnbi_hdr (l_index).TRNBI_CON_BIL_TODT,
                             trnbi_hdr (l_index).TRNBI_CON_EFF_DATE,
                             trnbi_hdr (l_index).TRNBI_CUS_PROJ_NBR,
                             trnbi_hdr (l_index).TRNBI_CONT_COMP_NM,
                             trnbi_hdr (l_index).TRNBI_CONT_CONTACT,
                             trnbi_hdr (l_index).TRNBI_CON_APP_DATE,
                             trnbi_hdr (l_index).TRNBI_VIAARCHITECT,
                             trnbi_hdr (l_index).TRNBI_ARCHITECT_AD,
                             trnbi_hdr (l_index).TRNBI_ARCHITECT_CT,
                             trnbi_hdr (l_index).TRNBI_ARCHITECT_ST,
                             trnbi_hdr (l_index).TRNBI_ARCHITECT_PC,
                             trnbi_hdr (l_index).TRNBI_ARC_PREV_AMT,
                             trnbi_hdr (l_index).TRNBI_ARC_CERT_IND,
                             trnbi_hdr (l_index).TRNBI_ARC_COMPANY,
                             trnbi_hdr (l_index).TRNBI_ARC_NAME,
                             trnbi_hdr (l_index).TRNBI_ARC_CERT_DT,
                             trnbi_hdr (l_index).TRNBI_ARC_AMT_CERT,
                             trnbi_hdr (l_index).TRNBI_CUS_PREV_AMT,
                             trnbi_hdr (l_index).TRNBI_CUS_CERT_IND,
                             trnbi_hdr (l_index).TRNBI_CUS_CERT_CON,
                             trnbi_hdr (l_index).TRNBI_CUS_CERT_AMT,
                             trnbi_hdr (l_index).TRNBI_FIN_INV_IND,
                             trnbi_hdr (l_index).TRNBI_IN_EMAIL_ADD,
                             trnbi_hdr (l_index).TRNBI_PLAN_SHPMT,
                             trnbi_hdr (l_index).TRNBI_CR_JOB_NAME,
                             trnbi_hdr (l_index).TRNBI_PROJECT_TYPE,
                             trnbi_hdr (l_index).TRNBI_REL_TRX_NBR,
                             trnbi_hdr (l_index).TRNBI_SHIP_TO_REF,
                             trnbi_hdr (l_index).TRNBI_RETAINAGE_PC,
                             trnbi_hdr (l_index).TRNBI_TOTAL_ADD,
                             trnbi_hdr (l_index).TRNBI_TOTAL_DED,
                             trnbi_hdr (l_index).TRNBI_CON_SUM_TODT,
                             trnbi_hdr (l_index).TRNBI_NET_CHG_BY,
                             trnbi_hdr (l_index).TRNBI_PROJECT_NAME,
                             trnbi_hdr (l_index).BI_CURRENCY_CD,
                             trnbi_hdr (l_index).CREATED_BY_USER,
                             trnbi_hdr (l_index).TRNBI_ORDER_TYPE,
                             trnbi_hdr (l_index).TRNBI_PRIM_SALESMN,
                             trnbi_hdr (l_index).TRNBI_WAYBILLNBR,
                             trnbi_hdr (l_index).FOB_TERMS,
                             trnbi_hdr (l_index).REMIT_FROM_CUST_ID,
                             trnbi_hdr (l_index).TRNBI_BATCH_ID,
                             trnbi_hdr (l_index).TRNBI_BILL_REVIEW,
                             l_trnbi_hdr_note,
                             trnbi_hdr (l_index).TRNBI_SRV_CALL_ID,
                             trnbi_hdr (l_index).TRNBI_CUS_CERT_DAT,
                             trnbi_hdr (l_index).TRNBI_AUTH_ID,
                             trnbi_hdr (l_index).BUSINESS_UNIT_AR,
                             trnbi_hdr (l_index).TRNBI_ORIG_CUST_ID,
                             trnbi_hdr (l_index).TRNBI_FS_GRP_CD,
                             trnbi_hdr (l_index).TRNBI_MSTR_DEL_OPT,
                             trnbi_hdr (l_index).TRNBI_MSTR_INV_FRM,
                             trnbi_hdr (l_index).TRNBI_LOGO_KEY,
                             trnbi_hdr (l_index).ED_CREATE_DATE,
                             trnbi_hdr (l_index).ED_CREATE_ID,
                             trnbi_hdr (l_index).ED_UPDATE_DATE,
                             trnbi_hdr (l_index).ED_UPDATE_ID,
                             trnbi_hdr (l_index).ED_SOURCE_ARCHIVE_IND);
      END LOOP;

      COMMIT;

      l_fetch_count := c1%ROWCOUNT;
   END LOOP;


   CLOSE c1;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;

      IF c1%ISOPEN
      THEN
         CLOSE c1;
      END IF;

      DBMS_OUTPUT.put_line (SQLCODE || '-' || SQLERRM);
END;
/

prompt Rebuilding Indexes on dbo.OTR_TRNBI_BI_HDR_PSB
EXEC dbo.Pkg_Mass_Load_Index_Manip.p_rebuild_tbl_inds('DBO', 'OTR_TRNBI_BI_HDR_PSB', FALSE);




prompt Updating OTR_LOAD_CONTROL
Declare
    count1 number :=0;
    tablename varchar2(30) := 'OTR_TRNBI_BI_HDR_PSB';
    comment_prod varchar2(400) := 'BEFORE6;';
    comment_test varchar2(400) := 'BEFORE6; Not in production yet.';

BEGIN
    SELECT count(*) into count1
    FROM OTR_LOAD_CONTROL olc
    WHERE olc.TABLE_NAME=tablename;

    If count1=0 then
    INSERT into OTR_LOAD_CONTROL
      VALUES(tablename, sysdate, comment_test);
    end if;
    
  IF '&production_variable' = 'Y' then
    UPDATE OTR_LOAD_CONTROL olc 
    SET LOAD_COMMENT=comment_prod,
        LAST_LOAD_DATE=sysdate 
    WHERE olc.TABLE_NAME=tablename;
  ELSIF '&production_variable' = 'N' THEN
    UPDATE OTR_LOAD_CONTROL olc 
    SET LOAD_COMMENT=comment_test,
        LAST_LOAD_DATE=sysdate 
    WHERE olc.TABLE_NAME=tablename;
  ELSE /* Do not change load_comment */
    UPDATE OTR_LOAD_CONTROL olc 
    SET LAST_LOAD_DATE=sysdate
    WHERE olc.TABLE_NAME=tablename;
  END if;

    COMMIT;
    
END;
/

 
