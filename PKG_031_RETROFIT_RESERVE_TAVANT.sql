DROP PACKAGE DBO.PKG_031_RETROFIT_RESERVE;

--
-- PKG_031_RETROFIT_RESERVE  (Package) 
--
CREATE OR REPLACE PACKAGE DBO.pkg_031_retrofit_reserve IS

/**********************************************************************************
* $Workfile: PKG_031_RETROFIT_RESERVE.sql $
*  $Revision: 3 $
*  $Archive: /DRTRNT_or_P/ORACLE R12/Warranty and Reserve/Packages/PKG_031_RETROFIT_RESERVE.sql $
*  $Author: Ccdcau $
*  $Date: 1/11/17 11:11a $
*
* Description: Procedures to load tables for Retrofit Reserve Reporting
*
* Author: Jill Blank
*
* Create Date: 10/1/2008
*
* Revisions (add change revision information here if it applies to entire package)
*
*   Change Date              Developer                Change Description (include TTP if it applies to entire pkg)
*   -----------              ---------                ------------------------------------------
*   10/14/2008           Bashkar Shanmugam      Adding new Procedure for loading data into DBO.SY_031_CLAIM_SUM_STG table.
*   10/22/2008           Jaishankar SP          Added new Procedure (p_load_retrofit_reserve) for loading data into DBO.DM_031_RETROFIT_RSV table
*   10/28/2008           Jaishankar SP          Added Global Parameter (G_RUN) to the procedures
*    2/12/2009           Jill Blank             TTP 7120 Changed p_load_claim_sum_stg to remove date upper limit
*   12/9/2016           Pam Nelson, laiqi, IR - Updated for SMART P4 Warranty Reserve Reports project - TTP 14939
*                           Development done by Innovent Solutions
***********************************************************************************/

	PROCEDURE p_load_retrofit_id;

	PROCEDURE p_load_claim_sum_stg(G_RUN  IN DATE);
	PROCEDURE p_load_retrofit_reserve_main(G_RUN IN DATE);
	PROCEDURE p_del_retro_rsv_older_run(G_RUN IN DATE);

END;
/
DROP PACKAGE BODY DBO.PKG_031_RETROFIT_RESERVE;

--
-- PKG_031_RETROFIT_RESERVE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY DBO.PKG_031_RETROFIT_RESERVE
IS
	SUBTYPE T_IDENTIFIER IS VARCHAR2(30) ;
	G_PKG_NAME              CONSTANT T_IDENTIFIER := 'PKG_031_RETROFIT_RESERVE';
	G_RUN                   DATE := TRUNC(SYSDATE, 'MM') ;
	-- The following exception definitions are for custom exceptions to allow special
	-- logging in certain scenarios.  They may be raised to calling functions depending
	-- on exception suppression argument.
	SUBTYPE T_CUSTOM_EXCEP_DESC
IS
	SY_LOG_ERROR.ORACLE_ERROR_MESSAGE%TYPE;
	/***********************************************************************************
	* Procedure P_PROCESS_ERRORS
	*
	* Description: Inserts a record into the SY_LOG_ERROR table when problems occur
	*   anywhere in the package.
	*
	* Author: Bashkar Shanmugam, Three Rivers Technologies
	*
	* Create Date: 10/1/2008
	*
	* Change Reference (TTP 5465)
	*
	* Revisions:
	*
	*    Change Date   Developer Change Description (including TTP)
	*   ------------   --------- ----------------------------------
	*
	***********************************************************************************/
	PROCEDURE P_PROCESS_ERRORS(
			P_PACKAGE_NAME_IN IN SY_LOG_ERROR.PACKAGE_NAME%TYPE,
			P_PROCEDURE_NAME_IN IN SY_LOG_ERROR.PROCEDURE_NAME%TYPE,
			P_SOURCE_CODE_MARKER_IN IN SY_LOG_ERROR.SOURCE_CODE_MARKER%TYPE,
			P_ORACLE_ERROR_MESSAGE_IN IN SY_LOG_ERROR.ORACLE_ERROR_MESSAGE%TYPE,
			P_ERROR_NOTES_IN IN SY_LOG_ERROR.ERROR_NOTES%TYPE)
	IS
		L_PROC_NAME T_IDENTIFIER := 'P_PROCESS_ERRORS';
	BEGIN
		-- perform insert into error table
		INSERT
			INTO
				SY_LOG_ERROR
				(
					SY_LOG_ERROR_KEY,
					PACKAGE_NAME,
					PROCEDURE_NAME,
					SOURCE_CODE_MARKER,
					ORACLE_ERROR_MESSAGE,
					ERROR_NOTES,
					ERROR_TIMESTAMP
				)
				VALUES
				(
					SY_LOG_ERROR_SEQ.NEXTVAL,
					P_PACKAGE_NAME_IN,
					P_PROCEDURE_NAME_IN,
					P_SOURCE_CODE_MARKER_IN,
					P_ORACLE_ERROR_MESSAGE_IN,
					P_ERROR_NOTES_IN,
					SYSDATE
				) ;
		COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
		/*If an error occurred while trying to log the error, call the error
		process procedure again and log a message indicating the error */
		P_PROCESS_ERRORS(G_PKG_NAME, L_PROC_NAME, NULL, SUBSTR(SQLERRM, 1, 255), 'An error occurred when attempting to insert into error table.') ;
	END P_PROCESS_ERRORS;
/***********************************************************************************
* Procedure P_LOAD_RETROFIT_ID
*
* Description: Update the UD_031_RETROFIT_ID table. Merge statement used to Insert new retro_id record into UD_031_RETROFIT_ID table
*
* Author: Bashkar Shanmugam, Three Rivers Technologies
*
* Create Date: 10/1/2008
*
* Change Reference (TTP 5465)
*
* Revisions:
*
*    Change Date   Developer    Change Description (including TTP)
*   ------------   ---------    ----------------------------------
*
***********************************************************************************/
	PROCEDURE P_LOAD_RETROFIT_ID
	IS
		L_PROC_NAME CONSTANT T_IDENTIFIER := 'P_LOAD_RETROFIT_ID';
		L_LEVEL     NUMBER := 0;
	BEGIN
		L_LEVEL := 1;
		/*below merge statement get the new RETRO_ID from WC_MAT_LBR_ROLLUP table into UD_031_RETROFIT_ID.
		*/
		MERGE INTO UD_031_RETROFIT_ID A USING
		(
			SELECT DISTINCT RETRO_ID FROM WC_MAT_LBR_ROLLUP WHERE RETRO_ID IS NOT NULL
		)
		B ON(TRIM(A.RETROFIT_ID) = TRIM(B.RETRO_ID))
	WHEN NOT MATCHED THEN
		INSERT
				(
					RETROFIT_ID,
					SPECIFIC_RESERVE_IND,
					PCT_100_RECOVERY_IND,
					NEW_RESOLVED_IND,
					ED_CREATE_DATE,
					ED_CREATE_ID,
					ED_UPDATE_DATE,
					ED_UPDATE_ID
				)
				VALUES
				(
					TRIM(B.RETRO_ID),
					NULL,
					NULL,
					'N',
					SYSDATE,
					L_PROC_NAME,
					SYSDATE,
					L_PROC_NAME
				) ;
		DBMS_OUTPUT.PUT_LINE('DWBS_SUCCESS') ;
		COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
		P_PROCESS_ERRORS(G_PKG_NAME, L_PROC_NAME, L_LEVEL, SUBSTR(SQLERRM, 1, 255), 'DBO.UD_031_RETROFIT_ID load terminated due to error') ;
		RAISE;
		DBMS_OUTPUT.PUT_LINE('DWBS_FAILURE') ;
	END P_LOAD_RETROFIT_ID;
/***********************************************************************************
* Procedure P_LOAD_CLAIM_SUM_STG
*
* Description: Update the SY_031_CLAIM_SUM_STG table. Truncate the existing record from the table and insert
*              previous 24 months of claims summery data from the sysdate or the date we passing through parameter.
*
* Author: Bashkar Shanmugam, Three Rivers Technologies
*
* Create Date: 10/14/2008
*
* Change Reference (TTP 6144)
*
* Revisions:
*
*    Change Date   Developer    Change Description (including TTP)
*   ------------   ---------    ----------------------------------
*   10/27/2008    Jaishankar SP, Cognizant    Updated the parameter as 'G_RUN'. Earlier it was 'P_TRANS_DATE'
*    2/12/2009    Jill Blank    Removed the upper limit of 12/31/2008 which is incorrect - TTP 7120
*   05/16/2012   Bhavani  Cognizant     Included DM_WAR_CSN_RSV_PCT_REF and UD_031_STDWTY_RSV_CLM_ADJ  tables for claims TTP#12544
*   12/142012    Jill Blank        Removed product code 0061 TTP 12995
***********************************************************************************/
	PROCEDURE P_LOAD_CLAIM_SUM_STG
		(
			G_RUN IN DATE
		)
	IS
		L_PROC_NAME CONSTANT T_IDENTIFIER := 'P_LOAD_CLAIM_SUM_STG';
		L_LEVEL     NUMBER := 0;
	BEGIN
		L_LEVEL := 1;
		-- Clearing all the records exist in installed base table
		DBO.P_TRUNCATE_LISTED_TABLE('DBO', 'SY_031_CLAIM_SUM_STG') ;
		L_LEVEL := 2;
		INSERT /*+ APPEND */
			INTO DBO.SY_031_CLAIM_SUM_STG
		SELECT
				COUNTRY_INDICATOR,
				GL_ACCOUNT,
				TRXYEARMONTH AS TRX_PERIOD,
				SUM(EXPENSE_AMOUNT * IN_RESERVE_PERCENT / 10000) AS EXPENSE_AMT_IN_RES,
				SYSDATE,
				L_PROC_NAME,
				SYSDATE,
				L_PROC_NAME
			FROM
				(
					-- Retrofit Material - Falcon
					SELECT
							'FM' AS QUERY_SOURCE,
							MLR.CLAIM_NBR AS CLAIM_NUMBER,
							MLR.STEP_NBR AS STEP_NUMBER,
							GLA.R12_ENTITY AS BUSINESS_UNIT,
							PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
							CTYPES.CLAIM_TYPE_DESCR AS CLAIM_TYPE,
							SUM(MLR.EXP_TYPE_AMOUNT * - 1) AS EXPENSE_AMOUNT,
							RES_PCT.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
							GLA.R12_ACCOUNT AS GL_ACCOUNT,
							ETS.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
							SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
							CASE
								WHEN GLA.R12_PRODUCT IS NULL OR GLA.R12_PRODUCT = '' THEN PCS.PROD_CODE
								ELSE GLA.R12_PRODUCT
								END AS GL_PROD_CODE,
							PCS.PROD_CODE AS MANF_PROD_CODE,
							SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
							CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
							CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
							CASE
								WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1' THEN 'Y'
								ELSE 'N'
								END AS INTERNAL_EXTERNAL,
							TD3.FULL_DATE AS TRX_DATE,
							TO_CHAR(TD3.YEAR) AS TRX_YEAR,
							TO_CHAR(TD3.MONTH) AS TRX_MONTH,
							CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_TRX_TO_BASE,
							CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_SHIP_TO_BASE,
							TD2.FULL_DATE AS SHIP_DATE,
							TD2.YEAR * 100 + TD2.MONTH AS SHIP_YEAR_MONTH,
							CEIL(((TD3.TIME_KEY - TD2.TIME_KEY) / 30.42)) + 1 AS INTMONTHS_SHIP_TO_TRX,
							TD.FULL_DATE AS START_DATE,
							(TD3.TIME_KEY - TD.TIME_KEY) / 30.42 AS INTMONTHS_START_TO_TRX,
							TD1.FULL_DATE AS FAIL_DATE,
							(TD3.TIME_KEY - TD1.TIME_KEY) / 30.42 AS INTMONTHS_FAIL_TO_TRX,
							CASE
								WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY') OR TD1.FULL_DATE IS NULL THEN 'NO'
								ELSE FCW.WA_POLICY_TYPE
								END AS WARRANTY_TYPE,
							CASE
								WHEN FCW.WA_RANGE = '1' THEN '1st Year Standard Warranty'
								WHEN FCW.WA_RANGE = '2' THEN '2nd-5th Year Standard Warranty'
								WHEN FCW.WA_RANGE = '5' THEN '> 5th Year Standard Warranty'
								ELSE 'Out of Standard Warranty'
								END AS WARRANTY_DURATION,
							MLR.TRX_CURRENCY AS CURRENCY,
							CASE
								WHEN GLA.R12_ENTITY NOT IN('5773', '5588') THEN 'USA'
								ELSE 'CAN'
								END AS COUNTRY_INDICATOR,
							MLR.RETRO_ID AS RETROFIT_ID,
							GLA.R12_COST_CENTER AS GL_DEPT,
							CASE
								WHEN A.CLAIM_NUMBER IS NULL THEN 10000 *( CASE
									WHEN (PCS.PROD_CODE IN('0054', '0197')) OR (RD.NEW_RESOLVED_IND = 'R' AND RD.SPECIFIC_RESERVE_IND = 'Y' OR RD.PCT_100_RECOVERY_IND = 'Y') THEN 0
									ELSE RES_PCT.RESERVE_PCT
									END)
								ELSE RS_RES_PCT.RESERVE_PCT
								END AS IN_RESERVE_PERCENT,
							RD.NEW_RESOLVED_IND,
							ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
							100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH,
							0 AS EXPENSE_AMT_IN_RES,
							0 AS EXPENSE_AMT_NOT_IN_RES
						FROM
							WC_MAT_LBR_ROLLUP MLR
						INNER JOIN EXPENSE_TYPE_SCD ET            ON MLR.EXPENSE_TYPE_SCD_KEY = ET.EXPENSE_TYPE_SCD_KEY
						LEFT OUTER JOIN DM_FAL_CLAIMS_WARRANTY_XRF FCW ON MLR.CLAIM_NBR = FCW.CLAIM_NBR AND MLR.DETAIL_NBR = FCW.DETAIL_NBR AND MLR.STEP_NBR = FCW.STEP_NBR
						INNER JOIN TIME_DAY TD3                   ON MLR.CCN_TRX_DATE_KEY = TD3.TIME_KEY
						INNER JOIN TIME_DAY TD2                   ON MLR.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY
						INNER JOIN TIME_DAY TD1                   ON MLR.FAIL_DATE_KEY = TD1.TIME_KEY
						INNER JOIN TIME_DAY TD                    ON MLR.START_DATE_KEY = TD.TIME_KEY
						INNER JOIN CLAIM_TASK_SCD CTASKS          ON MLR.CLAIM_TASK_SCD_KEY = CTASKS.CLAIM_TASK_SCD_KEY
						INNER JOIN CLAIM_TYPE_SCD CTYPES          ON MLR.CLAIM_TYPE_SCD_KEY = CTYPES.CLAIM_TYPE_SCD_KEY
						INNER JOIN R12_GL_ACCOUNT_SCD GLA 				ON MLR.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY
						INNER JOIN EXPENSE_TYPE_SCD ETS           ON MLR.EXPENSE_TYPE_SCD_KEY = ETS.EXPENSE_TYPE_SCD_KEY
						INNER JOIN PROD_CODE_SCD PCS              ON MLR.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY
						INNER JOIN CUST_ACCOUNT_SCD CACCT         ON MLR.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY
						INNER JOIN SUBMIT_OFFICE_SCD SOS          ON MLR.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY
						INNER JOIN PROD_CODE_XREF_RCPO_DR PRODGRP ON 'CSD' = PRODGRP.GL_LEDGER
							AND PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE                                   
							AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL
						INNER JOIN UD_031_RETROFIT_RULES RES_PCT ON CTYPES.CLAIM_TYPE_DESCR = RES_PCT.CLAIM_TYPE AND ETS.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
						INNER JOIN UD_031_RETROFIT_ID RD ON MLR.RETRO_ID = RD.RETROFIT_ID
						LEFT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
						LEFT OUTER JOIN UD_031_STDWTY_RSV_CLM_ADJ A ON MLR.CLAIM_NBR = A.CLAIM_NUMBER
						LEFT OUTER JOIN DM_WAR_CSN_RSV_PCT_REF RS_RES_PCT ON A.CLAIM_TYPE = RS_RES_PCT.CLAIM_TYPE
						WHERE
							MLR.CLAIM_TYPE_SCD_KEY = 3
							AND CASE
								WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1' THEN 'Y'
								ELSE 'N'
								END = RES_PCT.CUST_CREDIT_CATG_CODE
							AND ((GLA.PS_ACCOUNT = 'NA' AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y')
								OR GLA.PS_ACCOUNT LIKE '0620%'
								OR GLA.PS_ACCOUNT LIKE '8062%')
							AND GLA.PS_COMPANY IN ('CSD', 'CAN')
						GROUP BY
							MLR.CLAIM_NBR,
							MLR.STEP_NBR,
							GLA.R12_ENTITY,
							PRODGRP.PRODUCT_CATEGORY,
							CTYPES.CLAIM_TYPE_DESCR,
							RES_PCT.EXPENSE_TYPE_CATG,
							GLA.R12_ACCOUNT,
							ETS.EXPENSE_TYPE_DESCR,
							SOS.SUBMIT_OFFICE_NAME,
							GLA.R12_PRODUCT,
							PCS.PROD_CODE,
							SOS.COMPANY_OWNED_IND,
							CACCT.ACCOUNT_NUMBER,
							CACCT.CUST_ACCT_NAME,
							CASE
								WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1' THEN 'Y'
								ELSE 'N'
								END,
							TD3.FULL_DATE,
							TO_CHAR(TD3.YEAR),
							TO_CHAR(TD3.MONTH),
							CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1,
							CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1,
							TD2.FULL_DATE,
							TD2.YEAR * 100 + TD2.MONTH,
							CEIL(((TD3.TIME_KEY - TD2.TIME_KEY) / 30.42)) + 1,
							TD.FULL_DATE,
							(TD3.TIME_KEY - TD.TIME_KEY) / 30.42,
							TD1.FULL_DATE,
							(TD3.TIME_KEY - TD1.TIME_KEY) / 30.42,
							CASE
								WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY') OR TD1.FULL_DATE IS NULL THEN 'NO'
								ELSE FCW.WA_POLICY_TYPE
								END,
							CASE
								WHEN FCW.WA_RANGE = '1' THEN '1st Year Standard Warranty'
								WHEN FCW.WA_RANGE = '2' THEN '2nd-5th Year Standard Warranty'
								WHEN FCW.WA_RANGE = '5' THEN '> 5th Year Standard Warranty'
								ELSE 'Out of Standard Warranty'
								END,
							MLR.TRX_CURRENCY,
							CASE
								WHEN GLA.R12_ENTITY NOT IN('5773', '5588') THEN 'USA'
								ELSE 'CAN'
								END,
							MLR.RETRO_ID,
							GLA.R12_COST_CENTER,
							CASE
								WHEN A.CLAIM_NUMBER IS NULL THEN 10000 *( CASE
									WHEN (PCS.PROD_CODE IN('0054', '0197')) OR(RD.NEW_RESOLVED_IND = 'R' AND RD.SPECIFIC_RESERVE_IND = 'Y' OR RD.PCT_100_RECOVERY_IND = 'Y') THEN 0
									ELSE RES_PCT.RESERVE_PCT
									END)
								ELSE RS_RES_PCT.RESERVE_PCT
								END,
							RD.NEW_RESOLVED_IND,
							ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42),
							100 * TD3.YEAR + TD3.MONTH
					UNION ALL
					-- Retrofit Material - Tavant
					SELECT
							'TM' AS QUERY_SOURCE,
							SUBSTR(STG.CLAIM_NUMBER, 3) * -1,
							0 AS STEP_NUMBER,
							STG.BUSINESS_UNIT,
							STG.RESERVE_GROUP,
							STG.CLAIM_TYPE,
							STG.EXPENSE_AMOUNT,
							STG.MATERIAL_LABOR,
							STG.GL_ACCOUNT,
							STG.EXPENSE_TYPE_DESCR,
							STG.OFFICE_NAME,
							STG.GL_PROD_CODE,
							STG.MANF_PROD_CODE,
							STG.COMPANY_OWNED,
							STG.CUSTOMER_NUMBER,
							STG.CUSTOMER_NAME,
							STG.INTERNAL_EXTERNAL,
							STG.TRX_DATE,
							STG.TRX_YEAR,
							STG.TRX_MONTH,
							STG.INTMONTHS_TRX_TO_BASE,
							STG.INTMONTHS_SHIP_TO_BASE,
							STG.SHIP_DATE,
							STG.SHIP_YEAR_MONTH,
							STG.INTMONTHS_SHIP_TO_TRX,
							STG.START_DATE,
							STG.INTMONTHS_START_TO_TRX,
							STG.FAIL_DATE,
							STG.INTMONTHS_FAIL_TO_TRX,
							STG.WARRANTY_TYPE,
							STG.WARRANTY_DURATION,
							STG.CURRENCY,
							STG.COUNTRY_INDICATOR,
							STG.RETROFIT_ID,
							'NA' AS GL_DEPT,
							STG.IN_RESERVE_PERCENT,
							'wut?' AS NEW_RESOLVED_IND,
							STG.TRX_LAG,
							STG.TRXYEARMONTH,
							STG.EXPENSE_AMT_IN_RES,
							STG.EXPENSE_AMT_NOT_IN_RES
						FROM TAV_STG STG
						INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
							ON STG.GL_ACCOUNT = AFU.R12_ACCOUNT
						WHERE 0 = 0
							AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y'
							AND CLAIM_TYPE = 'RETROFIT Material'
					UNION ALL
					--Retrofit Labor - Falcon
					SELECT
							'FL' AS QUERY_SOURCE,
							CCN_DATA.CLAIM_NBR AS CLAIM_NUMBER,
							CCN_DATA.STEP_NBR AS STEP_NUMBER,
							GLA.R12_ENTITY AS BUSINESS_UNIT,
							PRODGRP.PRODUCT_CATEGORY AS RESERVE_GROUP,
							CCN_DATA.CLAIM_TYPE AS CLAIM_TYPE,
							CCN_DATA.DOLLAR_AMOUNT AS EXPENSE_AMOUNT,
							CCN_DATA.EXPENSE_TYPE_CATG AS MATERIAL_LABOR,
							GLA.R12_ACCOUNT AS GL_ACCOUNT,
							CCN_DATA.EXPENSE_TYPE_DESCR AS EXPENSE_TYPE_DESCR,
							SOS.SUBMIT_OFFICE_NAME AS OFFICE_NAME,
							CASE
								WHEN GLA.R12_PRODUCT IS NULL OR GLA.R12_PRODUCT = '' THEN PCS.PROD_CODE
								ELSE GLA.R12_PRODUCT
								END AS GL_PROD_CODE,
							PCS.PROD_CODE AS MANF_PROD_CODE,
							SOS.COMPANY_OWNED_IND AS COMPANY_OWNED,
							CACCT.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
							CACCT.CUST_ACCT_NAME AS CUSTOMER_NAME,
							CASE
								WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1' THEN 'Y'
								ELSE 'N'
								END AS INTERNAL_EXTERNAL,
							TD3.FULL_DATE AS TRX_DATE,
							TO_CHAR(TD3.YEAR) AS TRX_YEAR,
							TO_CHAR(TD3.MONTH) AS TRX_MONTH,
							CEIL(ABS(MONTHS_BETWEEN(TD3.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_TRX_TO_BASE,
							CEIL(ABS(MONTHS_BETWEEN(TD2.FULL_DATE, ADD_MONTHS(TRUNC(SYSDATE, 'MM'), - 1)))) + 1 AS INTMONTHS_SHIP_TO_BASE,
							TD2.FULL_DATE AS SHIP_DATE,
							TD2.YEAR * 100 + TD2.MONTH AS SHIP_YEAR_MONTH,
							CEIL(((TD3.TIME_KEY - TD2.TIME_KEY) / 30.42)) + 1 AS INTMONTHS_SHIP_TO_TRX,
							TD.FULL_DATE AS START_DATE,
							(TD3.TIME_KEY - TD.TIME_KEY) / 30.42 AS INTMONTHS_START_TO_TRX,
							TD1.FULL_DATE AS FAIL_DATE,
							(TD3.TIME_KEY - TD1.TIME_KEY) / 30.42 AS INTMONTHS_FAIL_TO_TRX,
							CASE
								WHEN TD1.FULL_DATE = TO_DATE('1/1/1900', 'MM/DD/YYYY') OR TD1.FULL_DATE IS NULL THEN 'NO'
								ELSE FCW.WA_POLICY_TYPE
								END AS WARRANTY_TYPE,
							CASE
								WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR' THEN 'Out of Standard Warranty'
								ELSE CASE
									WHEN FCW.WA_RANGE = '1' THEN '1st Year Standard Warranty'
									WHEN FCW.WA_RANGE = '2' THEN '2nd-5th Year Standard Warranty'
									WHEN FCW.WA_RANGE = '5' THEN '> 5th Year Standard Warranty'
									ELSE 'Out of Standard Warranty'
									END
								END AS WARRANTY_DURATION,
							CCN_DATA.TRX_CURRENCY AS CURRENCY,
							CASE
								WHEN GLA.R12_ENTITY NOT IN('5773', '5588') THEN 'USA'
								ELSE 'CAN'
								END AS COUNTRY_INDICATOR,
							CCN_DATA.RETRO_ID AS RETROFIT_ID,
							GLA.R12_COST_CENTER
							AS GL_DEPT,
							CASE
								WHEN A.CLAIM_NUMBER IS NULL THEN 10000 *( CASE
									WHEN (PCS.PROD_CODE IN('0054', '0197')) OR(RD.NEW_RESOLVED_IND = 'R' AND RD.SPECIFIC_RESERVE_IND = 'Y' OR RD.PCT_100_RECOVERY_IND = 'Y') THEN 0
									ELSE RES_PCT.RESERVE_PCT
									END)
								ELSE RS_RES_PCT.RESERVE_PCT
								END AS IN_RESERVE_PERCENT,
							RD.NEW_RESOLVED_IND,
							ROUND((TD3.FULL_DATE - TD2.FULL_DATE) / 30.42) AS TRX_LAG,
							100 * TD3.YEAR + TD3.MONTH AS TRXYEARMONTH,
							0 AS EXPENSE_AMT_IN_RES,
							0 AS EXPENSE_AMT_NOT_IN_RES
						FROM
							(
								-- THIS IS THE CORE PORTION FOR  CLAIM TYPE TO RETRIEVE EXPENSE RELATED INFORMATION
								SELECT
										'SPD/Retrofit Labor/Extended Purchased Labor' AS TYPE,
										LR.CLAIM_NBR,
										LR.RETRO_ID,
										CT.CLAIM_TYPE_CODE AS CLAIM_TYPE,
										CASE
											WHEN EXPENSE_TYPE_SCD_KEY IN(58, 60, 61) THEN 'MATERIAL'
											ELSE 'LABOR'
											END AS EXPENSE_TYPE_DESCR,
										CASE
											WHEN EXPENSE_TYPE_SCD_KEY IN(58, 60, 61) THEN 'MATERIAL'
											ELSE 'LABOR'
											END AS EXPENSE_TYPE_CATG,
										LR.CHARGE_COMM_PCT,
										LR.CHARGE_COMPANY_PCT,
										LR.ALLOCATED_EXP_TYPE_AMOUNT * - 1 AS DOLLAR_AMOUNT,
										LR.STEP_NBR,
										LR.CCN_TRX_DATE_KEY,
										LR.ORIGINAL_SHIP_DATE_KEY,
										LR.FAIL_DATE_KEY,
										LR.START_DATE_KEY,
										LR.GL_ACCOUNT_SCD_KEY,
										LR.PROD_CODE_SCD_KEY,
										LR.CUST_ACCOUNT_SCD_KEY,
										LR.SUBMIT_OFFICE_SCD_KEY,
										LR.TRX_CURRENCY
									FROM
										WC_LABOR_ROLLUP LR
									INNER JOIN TIME_DAY TD       ON TD.TIME_KEY = LR.CCN_TRX_DATE_KEY
									INNER JOIN CLAIM_TYPE_SCD CT ON LR.CLAIM_TYPE_SCD_KEY = CT.CLAIM_TYPE_SCD_KEY
									INNER JOIN R12_GL_ACCOUNT_SCD GLA ON GLA.GL_ACCOUNT_SCD_KEY = LR.GL_ACCOUNT_SCD_KEY
									LEFT OUTER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = GLA.R12_ACCOUNT
									WHERE
										1 = 1
										-- for 'RETROFIT LABOR'
										AND LR.CLAIM_TYPE_SCD_KEY = 2
										AND TD.FULL_DATE >= TO_DATE('1/1/2001', 'MM/DD/YYYY')
										AND((GLA.PS_ACCOUNT = 'NA' AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y')
										OR GLA.PS_ACCOUNT LIKE '0620%'
										OR GLA.PS_ACCOUNT LIKE '8062%')
							) CCN_DATA

							LEFT OUTER JOIN
							(
								SELECT DISTINCT
								CLAIM_NBR, STEP_NBR, WA_POLICY_TYPE, WA_RANGE
								FROM DM_FAL_CLAIMS_WARRANTY_XRF
							) FCW
							ON 1=1
							AND CCN_DATA.CLAIM_NBR = FCW.CLAIM_NBR -- (+)
							AND CCN_DATA.STEP_NBR = FCW.STEP_NBR -- (+)

							INNER JOIN
							TIME_DAY TD3
							ON 1=1
							AND CCN_DATA.CCN_TRX_DATE_KEY = TD3.TIME_KEY

							INNER JOIN
							TIME_DAY TD2
							ON 1=1
							AND CCN_DATA.ORIGINAL_SHIP_DATE_KEY = TD2.TIME_KEY

							INNER JOIN
							TIME_DAY TD1
							ON 1=1
							AND CCN_DATA.FAIL_DATE_KEY = TD1.TIME_KEY

							INNER JOIN
							TIME_DAY TD
							ON 1=1
							AND CCN_DATA.START_DATE_KEY = TD.TIME_KEY

							INNER JOIN
							R12_GL_ACCOUNT_SCD GLA
							ON 1=1
							AND CCN_DATA.GL_ACCOUNT_SCD_KEY = GLA.GL_ACCOUNT_SCD_KEY

							INNER JOIN
							PROD_CODE_SCD PCS
							ON 1=1
							AND CCN_DATA.PROD_CODE_SCD_KEY = PCS.PROD_CODE_SCD_KEY

							INNER JOIN
							CUST_ACCOUNT_SCD CACCT
							ON 1=1
							AND CCN_DATA.CUST_ACCOUNT_SCD_KEY = CACCT.CUST_ACCOUNT_SCD_KEY

							INNER JOIN
							SUBMIT_OFFICE_SCD SOS
							ON 1=1
							AND CCN_DATA.SUBMIT_OFFICE_SCD_KEY = SOS.SUBMIT_OFFICE_SCD_KEY

							INNER JOIN
							PROD_CODE_XREF_RCPO_DR PRODGRP
							ON 1=1
							AND PCS.PROD_CODE = PRODGRP.MANF_PROD_CODE
							AND PRODGRP.PRODUCT_CATEGORY IS NOT NULL

							INNER JOIN
							UD_031_RETROFIT_RULES RES_PCT
							ON 1=1
							AND CASE
								WHEN CCN_DATA.CLAIM_TYPE = 'EXTD PURCHASED LABOR' THEN 'EXTENDED PURCHASED LABOR'
								ELSE CCN_DATA.CLAIM_TYPE
								END = RES_PCT.CLAIM_TYPE
							AND CCN_DATA.EXPENSE_TYPE_DESCR = RES_PCT.EXPENSE_TYPE_DESCR
							AND CCN_DATA.EXPENSE_TYPE_CATG = UPPER(RES_PCT.EXPENSE_TYPE_CATG)
							AND SOS.COMPANY_OWNED_IND = RES_PCT.COMPANY_OWNED_IND
							AND CASE
								WHEN CACCT.CUST_CREDIT_CATG_CODE = 'Z1' THEN 'Y'
								ELSE 'N'
								END = RES_PCT.CUST_CREDIT_CATG_CODE

							INNER JOIN
							UD_031_RETROFIT_ID RD
							ON 1=1
							AND CCN_DATA.RETRO_ID = RD.RETROFIT_ID

							LEFT OUTER JOIN
							UD_031_STDWTY_RSV_CLM_ADJ A
							ON 1=1
							AND CCN_DATA.CLAIM_NBR = A.CLAIM_NUMBER -- (+) 

							LEFT OUTER JOIN
							DM_WAR_CSN_RSV_PCT_REF RS_RES_PCT
							ON 1=1
							AND A.CLAIM_TYPE = RS_RES_PCT.CLAIM_TYPE -- (+) 

						WHERE
							1 = 1
							AND 'CSD' = PRODGRP.GL_LEDGER
							AND GLA.PS_COMPANY IN ('CSD', 'CAN')
					UNION ALL
					-- Retrofit Labor - Tavant
					SELECT
							'TL' AS QUERY_SOURCE,
							SUBSTR(STG.CLAIM_NUMBER, 3) * -1,
							0 AS STEP_NUMBER,
							STG.BUSINESS_UNIT,
							STG.RESERVE_GROUP,
							STG.CLAIM_TYPE,
							STG.EXPENSE_AMOUNT,
							STG.MATERIAL_LABOR,
							STG.GL_ACCOUNT,
							STG.EXPENSE_TYPE_DESCR,
							STG.OFFICE_NAME,
							STG.GL_PROD_CODE,
							STG.MANF_PROD_CODE,
							STG.COMPANY_OWNED,
							STG.CUSTOMER_NUMBER,
							STG.CUSTOMER_NAME,
							STG.INTERNAL_EXTERNAL,
							STG.TRX_DATE,
							STG.TRX_YEAR,
							STG.TRX_MONTH,
							STG.INTMONTHS_TRX_TO_BASE,
							STG.INTMONTHS_SHIP_TO_BASE,
							STG.SHIP_DATE,
							STG.SHIP_YEAR_MONTH,
							STG.INTMONTHS_SHIP_TO_TRX,
							STG.START_DATE,
							STG.INTMONTHS_START_TO_TRX,
							STG.FAIL_DATE,
							STG.INTMONTHS_FAIL_TO_TRX,
							STG.WARRANTY_TYPE,
							STG.WARRANTY_DURATION,
							STG.CURRENCY,
							STG.COUNTRY_INDICATOR,
							STG.RETROFIT_ID,
							'NA' AS GL_DEPT,
							STG.IN_RESERVE_PERCENT,
							'wut?' AS NEW_RESOLVED_IND,
							STG.TRX_LAG,
							STG.TRXYEARMONTH,
							STG.EXPENSE_AMT_IN_RES,
							STG.EXPENSE_AMT_NOT_IN_RES
						FROM TAV_STG STG
						INNER JOIN R12_ACCOUNT_FILTER_UPD AFU
							ON STG.GL_ACCOUNT = AFU.R12_ACCOUNT
						WHERE 0 = 0
							AND AFU.STANDARD_WARRANTY_EXPENSE = 'Y'
							AND CLAIM_TYPE = 'RETROFIT Labor'
				)
			WHERE
				TRX_DATE BETWEEN TRUNC(ADD_MONTHS(
				CASE WHEN G_RUN IS NULL
					THEN TRUNC(SYSDATE, 'MM')
					ELSE G_RUN
				END, - 24), 'MM')
				AND LAST_DAY(TRUNC(ADD_MONTHS(
				CASE WHEN G_RUN IS NULL
					THEN TRUNC(SYSDATE, 'MM')
					ELSE G_RUN
				END, - 1), 'MM'))
			GROUP BY
				COUNTRY_INDICATOR,
				GL_ACCOUNT,
				TRXYEARMONTH,
				EXPENSE_AMT_IN_RES;
		DBMS_OUTPUT.PUT_LINE('DWBS_SUCCESS') ;
		COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
		P_PROCESS_ERRORS(G_PKG_NAME, L_PROC_NAME, L_LEVEL, SUBSTR(SQLERRM, 1, 255), 'DBO.SY_031_CLAIM_SUM_STG load terminated due to error') ;
		RAISE;
		DBMS_OUTPUT.PUT_LINE('DWBS_FAILURE') ;
	END P_LOAD_CLAIM_SUM_STG;
/***********************************************************************************
* Procedure P_LOAD_RETROFIT_RESERVE
*
* Description: insert previous 24 months of Claims amount, Sales amount, Calculated Rate, Remaining Periods and
* Retrofit reserve calculation amount for any run period or the date we passing through parameter.
*
* Author: Jaishankar SP, Cognizant
*
* Create Date: 10/22/2008
*
* Change Reference (TTP 6143)
*
* Revisions:
*
*    Change Date   Developer    Change Description (including TTP)
*   ------------   ---------    ----------------------------------
*   10/27/2008    Jaishankar SP, Cognizant    Updated the parameter as 'G_RUN'. Earlier it was 'RUN_PERIOD'
*   12/14/2012    Jill Blank        TTP 13076 changed outer join so that a row is included even when there are no claim records
***********************************************************************************/
	PROCEDURE P_LOAD_RETROFIT_RESERVE(
			G_RUN IN DATE)
	IS
		L_PROC_NAME CONSTANT T_IDENTIFIER := 'P_LOAD_RETROFIT_RESERVE';
		L_LEVEL     NUMBER := 0;
	BEGIN
		L_LEVEL := 1;
		INSERT /*+ APPEND */
			INTO DBO.DM_031_RETROFIT_RSV
		SELECT
				DM_031_RETROFIT_RSV_SEQ.NEXTVAL AS DM_031_RETROFIT_RSV_KEY,
				RUN_PERIOD,
				SHIP_PERIOD,
				COUNTRY_INDICATOR,
				CLAIM_AMT,
				SALES_AMT,
				CALCULATED_RATE,
				WEIGHTED_AVG_RATE,
				REMAINING_PDS,
				REMAINING_PDS_FACTOR,
				RESERVE_CALC_AMT,
				SYSDATE AS ED_CREATE_DATE,
				L_PROC_NAME AS ED_CREATE_ID,
				SYSDATE AS ED_UPDATE_DATE,
				L_PROC_NAME AS ED_UPDATE_ID
			FROM
				(
					SELECT
							TO_NUMBER(TO_CHAR(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'YYYYMM')) AS RUN_PERIOD,
							SSS.SHIP_PERIOD,
							SSS.COUNTRY_INDICATOR,
							NVL(CSS.IN_RSV_EXPENSE_AMT, 0) AS CLAIM_AMT,
							NVL(SSS.REVENUE_AMT / 1000000, 0) AS SALES_AMT,
							NVL((CSS.IN_RSV_EXPENSE_AMT) /(SSS.REVENUE_AMT / 1000000), 0) AS CALCULATED_RATE,
							NVL(SUM(CSS.IN_RSV_EXPENSE_AMT) OVER(PARTITION BY TO_NUMBER(TO_CHAR(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'YYYYMM')), SSS.COUNTRY_INDICATOR) / SUM(SSS. REVENUE_AMT / 1000000) OVER(PARTITION BY TO_NUMBER(TO_CHAR(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'YYYYMM')), SSS.COUNTRY_INDICATOR), 0) AS WEIGHTED_AVG_RATE,
							NVL(24 -(MONTHS_BETWEEN(TRUNC(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'MM'), TO_DATE(SHIP_PERIOD, 'YYYYMM'))), 0) AS REMAINING_PDS,
							NVL((24 - ROUND(MONTHS_BETWEEN(TRUNC(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'MM'), TO_DATE(SHIP_PERIOD, 'YYYYMM')), 0)) / 24, 0) AS REMAINING_PDS_FACTOR,
							NVL(SSS.REVENUE_AMT / 1000000 * SUM(CSS.IN_RSV_EXPENSE_AMT) OVER(PARTITION BY TO_NUMBER(TO_CHAR(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'YYYYMM')), SSS.COUNTRY_INDICATOR) / SUM(SSS. REVENUE_AMT / 1000000) OVER(PARTITION BY TO_NUMBER(TO_CHAR(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'YYYYMM')), SSS.COUNTRY_INDICATOR) *(24 - ROUND(MONTHS_BETWEEN(TRUNC(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'MM'), TO_DATE(SHIP_PERIOD, 'YYYYMM')), 0)) / 24, 0) AS RESERVE_CALC_AMT
						FROM
							DR_SY_031_SALES_SUM_STG SSS,
							(
								SELECT
										CASE        WHEN COUNTRY_INDICATOR = 'USA'
											THEN 'USD' WHEN COUNTRY_INDICATOR = 'CAN'
											THEN 'CAD'
										END COUNTRY_INDICATOR,
										TRX_PERIOD,
										NVL(SUM(IN_RSV_EXPENSE_AMT), 0) AS IN_RSV_EXPENSE_AMT
									FROM
										DBO.SY_031_CLAIM_SUM_STG
									GROUP BY
										CASE        WHEN COUNTRY_INDICATOR = 'USA'
											THEN 'USD' WHEN COUNTRY_INDICATOR = 'CAN'
											THEN 'CAD'
										END,
										TRX_PERIOD
							)
							CSS
						WHERE
							SSS.SHIP_PERIOD = CSS.TRX_PERIOD (+)
							AND SSS.COUNTRY_INDICATOR = CSS.COUNTRY_INDICATOR (+)
						GROUP BY
							TO_NUMBER(TO_CHAR(
							CASE WHEN G_RUN IS NULL
								THEN TRUNC(SYSDATE, 'MM')
								ELSE G_RUN
							END, 'YYYYMM')),
							SSS.SHIP_PERIOD,
							SSS.COUNTRY_INDICATOR,
							CSS.IN_RSV_EXPENSE_AMT,
							SSS.REVENUE_AMT
						ORDER BY
							3,
							2
				)
			WHERE
				TO_DATE(SHIP_PERIOD, 'YYYYMM') BETWEEN ADD_MONTHS(TO_DATE(RUN_PERIOD, 'YYYYMM'), - 24) AND ADD_MONTHS(TO_DATE(RUN_PERIOD, 'YYYYMM'), - 1) ;
		DBMS_OUTPUT.PUT_LINE('DWBS_SUCCESS') ;
		COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
		P_PROCESS_ERRORS(G_PKG_NAME, L_PROC_NAME, L_LEVEL, SUBSTR(SQLERRM, 1, 255), 'DBO.DM_031_RETROFIT_RSV load terminated due to error') ;
		RAISE;
		DBMS_OUTPUT.PUT_LINE('DWBS_FAILURE') ;
	END P_LOAD_RETROFIT_RESERVE;
/***********************************************************************************
*
* Author: Bashkar Shanmugam, Three Rivers Technologies
*
* Description: Delete the retrofit reserve data for only the run period (in case
* process needs to be re-executed for the same run period)
*
* Parameters: None
*
* Revisions:
*
*   Change Date    Change Description
*   -----------    ------------------
*   11/05/2008    Jaishankar SP, Cognizant    Updated the code with'SUCCESS/FAILURE' outputs
***********************************************************************************/
	PROCEDURE P_DEL_RETRO_RSV_SAME_RUN(
			G_RUN IN DATE)
	IS
		L_PROC_NAME CONSTANT T_IDENTIFIER := 'P_DEL_RETRO_RSV_SAME_RUN';
		L_LEVEL     INTEGER := 0;
	BEGIN
		L_LEVEL := 1;
		DELETE
			FROM
				DBO.DM_031_RETROFIT_RSV
			WHERE
				TO_DATE((SUBSTR(RUN_PERIOD, 5, 6) ||'/01/'||SUBSTR(RUN_PERIOD, 1, 4)), 'MM/DD/YYYY') = TRUNC(
				CASE WHEN G_RUN IS NULL
					THEN TRUNC(SYSDATE, 'MM')
					ELSE G_RUN
				END) ;
		DBMS_OUTPUT.PUT_LINE('DWBS_SUCCESS') ;
		COMMIT;
		L_LEVEL := 2;
	EXCEPTION
	WHEN OTHERS THEN
		P_PROCESS_ERRORS(G_PKG_NAME, L_PROC_NAME, L_LEVEL, SUBSTR(SQLERRM, 1, 255), 'Error occurred while deleting a period in Retrofit Reserve tables') ;
		RAISE;
		DBMS_OUTPUT.PUT_LINE('DWBS_FAILURE') ;
	END P_DEL_RETRO_RSV_SAME_RUN;
/***********************************************************************************
*
* Author: Bashkar Shanmugam, Three Rivers Technologies
*
* Description: Delete the Retrofit reserve  data for run period older than 13 months
*
* Parameters: None
*
* Revisions:
*
*   Change Date    Change Description
*   -----------    ------------------
*   11/05/2008    Jaishankar SP, Cognizant    Updated the code with'SUCCESS/FAILURE' outputs
***********************************************************************************/
	PROCEDURE P_DEL_RETRO_RSV_OLDER_RUN(
			G_RUN IN DATE)
	IS
		L_PROC_NAME CONSTANT T_IDENTIFIER := 'P_DEL_RETRO_RSV_OLDER_RUN';
		L_LEVEL     INTEGER := 0;
	BEGIN
		L_LEVEL := 1;
		DELETE
			FROM
				DBO.DM_031_RETROFIT_RSV
			WHERE
				TO_DATE((SUBSTR(RUN_PERIOD, 5, 6) ||'/01/'||SUBSTR(RUN_PERIOD, 1, 4)), 'MM/DD/YYYY') < ADD_MONTHS(
				CASE WHEN G_RUN IS NULL
					THEN TRUNC(SYSDATE, 'MM')
					ELSE G_RUN
				END, - 13) ;
		DBMS_OUTPUT.PUT_LINE('DWBS_SUCCESS') ;
		COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
		P_PROCESS_ERRORS(G_PKG_NAME, L_PROC_NAME, L_LEVEL, SUBSTR(SQLERRM, 1, 255), 'Error occurred while deleting older run periods of Retrofit Reserve tables') ;
		RAISE;
		DBMS_OUTPUT.PUT_LINE('DWBS_FAILURE') ;
	END P_DEL_RETRO_RSV_OLDER_RUN;
/***********************************************************************************
*
* Author: Jaishankar SP, Cognizant
* Description: Main Procedure to call sub procedures to load data for retrofit schedule for 24 months
*
*  Create Date: 27/10/2008
*
*    Parameters: None
*
* Revisions:
*
*   Change Date    Change Description
*   -----------    ------------------
***********************************************************************************/
	PROCEDURE P_LOAD_RETROFIT_RESERVE_MAIN(
			G_RUN IN DATE)
	IS
		L_PROC_NAME CONSTANT T_IDENTIFIER := 'P_LOAD_RETROFIT_RESERVE_MAIN';
		L_LEVEL     INTEGER := 0;
	BEGIN
		L_LEVEL := 1;
		P_DEL_RETRO_RSV_SAME_RUN(G_RUN) ;
		L_LEVEL := 2;
		P_LOAD_RETROFIT_RESERVE(G_RUN) ;
		L_LEVEL := 3;
		DBMS_OUTPUT.PUT_LINE('DWBS_SUCCESS') ;
	EXCEPTION
	WHEN OTHERS THEN
		P_PROCESS_ERRORS(G_PKG_NAME, L_PROC_NAME, L_LEVEL, SUBSTR(SQLERRM, 1, 255), NULL) ;
		RAISE;
		DBMS_OUTPUT.PUT_LINE('DWBS_FAILURE') ;
	END P_LOAD_RETROFIT_RESERVE_MAIN;
END;
/
