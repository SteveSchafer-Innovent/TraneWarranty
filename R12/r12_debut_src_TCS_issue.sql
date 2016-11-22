
CREATE INDEX TEMP1_R12_BI_HDR_STG ON R12_BI_HDR_STG (CUSTOMER_TRX_ID, INVOICE);
CREATE INDEX TEMP1_R12_BI_line_STG ON R12_BI_line_STG (CUSTOMER_TRX_ID, INVOICE);
CREATE INDEX TEMP1_R12_BI_ACCT_ENTRY_STG ON R12_BI_ACCT_ENTRY_STG (CUSTOMER_TRX_ID, INVOICE);
CREATE INDEX TEMP2_R12_BI_ACCT_ENTRY_STG ON R12_BI_ACCT_ENTRY_STG (R12_ACCOUNT);
CREATE INDEX TEMP3_R12_BI_ACCT_ENTRY_STG ON R12_BI_ACCT_ENTRY_STG (R12_PRODUCT);
CREATE INDEX TEMP4_R12_BI_ACCT_ENTRY_STG ON R12_BI_ACCT_ENTRY_STG (R12_LOCATION);
CREATE INDEX TEMP1_R12_TRNBI_BI_HDR_STG on R12_TRNBI_BI_HDR_STG (CUSTOMER_TRX_ID, INVOICE);


			SELECT
					/*+ NO_CPU_COSTING */
					distinct a.manf_prod_id
				FROM
					R12_BI_LINE_STG A
				INNER JOIN R12_BI_ACCT_ENTRY_STG D       ON D.LINE_SEQ_NUM = A.LINE_SEQ_NUM AND D.INVOICE = A.INVOICE AND D.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
				INNER JOIN R12_BI_HDR_STG B              ON D.INVOICE = B.INVOICE AND D.CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
--				INNER JOIN R12_TRNBI_BI_HDR_STG C        ON D.INVOICE = C.INVOICE AND D.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
--				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU    ON AFU.R12_ACCOUNT = D.R12_ACCOUNT
--				INNER JOIN OTR_PROD_CODE_XREF_RCPO X     ON A.MANF_PROD_ID = X.MANF_PROD_CODE
--				LEFT OUTER JOIN R12_TRANE_PRODUCTS_PS PR ON D.R12_PRODUCT = PR.R12_PRODUCT
--				LEFT OUTER JOIN R12_TRANE_LOCATIONS DP   ON DP.R12_LOCATION = D.R12_LOCATION
				WHERE 0=0
					--AND D.JOURNAL_DATE BETWEEN '01-oct-16' AND '31-oct-16'
					--AND B.BILL_SOURCE_ID = 'P21'
					--AND B.BILL_SOURCE_ID = 'ORDER ENTRY'
					AND B.BILL_SOURCE_ID = 'TCS MANUAL'
					--AND C.TRNBI_PROJECT_TYPE = '7'
					--AND D.LEDGER = 'ACTUALS'
					--AND X.TWO_FIVE = 'Y'
					/*
					AND X.GL_LEDGER = 'CSD'
					AND AFU.EQUAL_700000 = 'Y'
					AND D.R12_PRODUCT <> '41208'
					AND D.R12_PRODUCT <> '41399'
					AND D.R12_PRODUCT <> '41132'
					AND D.R12_PRODUCT <> '41499'
					AND D.R12_PRODUCT <> '41205'
					*/
		;
