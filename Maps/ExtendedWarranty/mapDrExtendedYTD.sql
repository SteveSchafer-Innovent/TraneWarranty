/* EXTENDED WARRANTY SCHEDULE-YTD REPORT QUERY */
SELECT
		/*+ FIRST_ROWS */
		SALES.COUNTRY_INDICATOR,
		BEGBALANCES.R12_ACCOUNT AS ACCOUNT,
		SALES.DESCR,
		--begbalances.ledger,
		---begbalances.fiscal_year,
		BEGBALANCES.BEGBAL_BASE AS BEGNING_BALANCE,
		100 *(BEGBALANCES.BEGBAL_BASE - TRUNC(BEGBALANCES.BEGBAL_BASE)) AS BEGNING_BALANCE_DEC,
		BEGBALANCES.BEGBAL_BASE + PERIODDATA.PRDMONETARYAMT_BASE AS END_BLANCE,
		100 *(BEGBALANCES.BEGBAL_BASE + PERIODDATA.PRDMONETARYAMT_BASE - TRUNC(BEGBALANCES.BEGBAL_BASE + PERIODDATA.PRDMONETARYAMT_BASE)) AS END_BLANCE_DEC,
		SALES.REVENUE_AMOUNT,
		100 *(SALES.REVENUE_AMOUNT - TRUNC(SALES.REVENUE_AMOUNT)) AS REVENUE_AMOUNT_DEC,
		REV.DEFERRED_REVENUE AS DEFERRED_REVENUE,
		100 *(REV.DEFERRED_REVENUE - TRUNC(REV.DEFERRED_REVENUE)) AS DEFERRED_REVENUE_DEC,
		REV.SHORT_TERM_BALA AS SHORT_TERM_BALA,
		100 *(REV.SHORT_TERM_BALA - TRUNC(REV.SHORT_TERM_BALA)) AS SHORT_TERM_BALA_DEC,
		REV.LONG_TERM_BALA AS LONG_TERM_BALA,
		100 *(REV.LONG_TERM_BALA - TRUNC(REV.LONG_TERM_BALA)) AS LONG_TERM_BALA_DEC
	FROM
		(
			/* Begning Balance DRTRNP */
			SELECT
					L.R12_ACCOUNT
					-- -SS- ACCOUNT
					,
					L.LEDGER,
					L.FISCAL_YEAR,
					SUM(DECODE(L.ACCOUNTING_PERIOD, 0, L.POSTED_BASE_AMT, 0)) AS BEGBAL_BASE
					--100*(SUM(DECODE (l.accounting_period, 0, l.posted_base_amt, 0))  - TRUNC( SUM(DECODE (l.accounting_period, 0, l.posted_base_amt, 0))) )   AS begbal_base_DEC
				FROM
					R12_LEDGER2_PS L -- /* -SS- OTR */
					-- -SS- NEW
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = L.R12_ACCOUNT
					-- -SS- /NEW
				LEFT OUTER JOIN ACTUATE_SEC_XREF ASX ON L.BUSINESS_UNIT = ASX.PSGL -- -SS- ???? issue 87
				WHERE
					L.FISCAL_YEAR = TO_CHAR(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy'), 'YYYY')
					AND L.LEDGER = 'ACTUALS'
					AND L.BUSINESS_UNIT IN('CAN', 'CSD')
					-- -SS- NEW
					AND((L.PS_ACCOUNT = 'NA'
					AND AFU.BETWEEN_523000_546900 = 'Y')
					OR(L.PS_ACCOUNT BETWEEN '523000' AND '546900'))
					-- -SS- /NEW
					-- -SS- AND L.ACCOUNT BETWEEN '523000' AND '546900'
					-- -SS- NEW
					AND((L.PS_DEPTID = 'NA'
					AND L.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
					OR L.PS_DEPTID LIKE 'SL00%')
					-- -SS- /NEW
					-- -SS- AND L.DEPTID LIKE 'SL00%'
					AND
					CASE WHEN ASX.NATION_CURR = 'USD'
						THEN 'USA'
						ELSE 'CAN'
					END = UPPER(:COUNTRY)
				GROUP BY
					L.R12_ACCOUNT, -- -SS- ACCOUNT
					L.FISCAL_YEAR,
					L.LEDGER
		)
		BEGBALANCES
	LEFT OUTER JOIN
		(
			/* Ending Balance DRTRNP */
			-- perioddata
			SELECT
					/*+ index (ga XPKOTR_JRNL_HEADER_PS) */
					L.R12_ACCOUNT, 
					GA.FISCAL_YEAR, 
					L.LEDGER, 
					SUM(NVL(DECODE(SIGN(TO_CHAR(GA.JOURNAL_DATE, 'MM') - TO_CHAR(TRUNC(TO_DATE(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy')), 'YEAR'), 'mm')), - 1, L.MONETARY_AMOUNT), 0) + DECODE(SIGN(TO_CHAR(GA.JOURNAL_DATE, 'MM') - TO_CHAR(TRUNC(TO_DATE(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy')), 'YEAR'), 'mm')), - 1, 0, DECODE(SIGN(TO_CHAR(GA.JOURNAL_DATE, 'MM') - TO_CHAR(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy'), 'mm')), 1, 0, L.MONETARY_AMOUNT))) AS PRDMONETARYAMT_BASE
					--100*(SUM ( NVL(DECODE  (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),  -1, l.monetary_amount ) ,0)
					-- +
					-- DECODE (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),   -1, 0,
					--DECODE (SIGN (  TO_CHAR (ga.journal_date, 'MM')  - TO_CHAR(TO_DATE('1-'||:RunDate,'dd-mon-yy'),'mm')   ), 1, 0,  l.monetary_amount  ) )) -TRUNC (SUM ( NVL(DECODE  (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),  -1, l.monetary_amount ) ,0)
					-- +
					-- DECODE (SIGN (TO_CHAR (ga.journal_date, 'MM') - to_char(TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR') ,'mm')),   -1, 0,
					--DECODE (SIGN (  TO_CHAR (ga.journal_date, 'MM')  - TO_CHAR(TO_DATE('1-'||:RunDate,'dd-mon-yy'),'mm')   ), 1, 0,  l.monetary_amount  ) )))) AS  prdmonetaryamt_base_Dec
				FROM R12_JRNL_LN_PS L -- /* -SS- OTR */
				INNER JOIN OTR_JRNL_HEADER_PS GA ON GA.BUSINESS_UNIT = L.BUSINESS_UNIT AND GA.JOURNAL_ID = L.JOURNAL_ID AND GA.JOURNAL_DATE = L.JOURNAL_DATE AND GA.UNPOST_SEQ = L.UNPOST_SEQ
					-- -SS- NEW
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = L.R12_ACCOUNT
					-- -SS- /NEW
				-- -SS- LEFT OUTER JOIN ACTUATE_SEC_XREF ASX ON L.BUSINESS_UNIT = ASX.PSGL
				WHERE
					GA.JRNL_HDR_STATUS IN('P', 'U')
					AND GA.FISCAL_YEAR = TO_CHAR(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy'), 'YYYY')
					AND GA.JOURNAL_DATE <= LAST_DAY(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy'))
					AND L.LEDGER = 'ACTUALS'
					AND L.BUSINESS_UNIT IN('CAN', 'CSD')
					AND
					CASE WHEN L.R12_ENTITY IN ('5773', '5588')
						THEN 'CAN'
						ELSE 'USA'
					END = UPPER(:COUNTRY)
					-- -SS- NEW
					AND((L.PS_ACCOUNT = 'NA'
					AND AFU.BETWEEN_523000_546900 = 'Y')
					OR(L.PS_ACCOUNT BETWEEN '523000' AND '546900'))
					-- -SS- /NEW
					-- -SS- AND L.ACCOUNT BETWEEN '523000' AND '546900'
					-- -SS- NEW
					AND((L.PS_DEPTID = 'NA'
					AND L.R12_LOCATION IN('113602', '115615', '119001', '119007', '129001', '129003', '129004'))
					OR L.PS_DEPTID = 'SL00')
					-- -SS- /NEW
					-- -SS- AND L.DEPTID = 'SL00'
				GROUP BY
					L.R12_ACCOUNT,
					GA.FISCAL_YEAR,
					L.LEDGER
		)
		PERIODDATA ON BEGBALANCES.R12_ACCOUNT = PERIODDATA.R12_ACCOUNT -- R12_2_R12 
		AND BEGBALANCES.FISCAL_YEAR = PERIODDATA.FISCAL_YEAR
		AND BEGBALANCES.LEDGER = PERIODDATA.LEDGER
	INNER JOIN
		(
			/* Sales Data DRTRNP */
			SELECT
					/*+ FIRST_ROWS */
					CASE WHEN A.R12_ENTITY NOT IN('5773', '5588')
							-- -SS- ASX.NATION_CURR ='USD'
						THEN 'USA' ELSE 'CAN' END AS COUNTRY_INDICATOR, A.R12_ACCOUNT,
					-- -SS- ACCOUNT
					PSA.DESCR, SUM(A.MONETARY_AMOUNT * - 1) AS REVENUE_AMOUNT
					--SUM (100*(A.MONETARY_AMOUNT*-1 -TRUNC(A.MONETARY_AMOUNT*-1))) AS REVENUE_AMOUNT_DEC
				FROM R12_BI_ACCT_ENTRY_PSB A -- /* -SS- OTR */
				INNER JOIN R12_TRNBI_BI_HDR_PSB B ON A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE
				INNER JOIN R12_BI_HDR_PSB C       ON B.BUSINESS_UNIT = C.PS_BUSINESS_UNIT AND B.INVOICE = C.INVOICE
					-- -SS- NEW
				INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = A.R12_ACCOUNT
					-- -SS- /NEW
				LEFT OUTER JOIN R12_TRANE_ACCOUNTS_PS PSA ON A.R12_ACCOUNT = PSA.R12_ACCOUNT -- R12_2_R12 -- /* -SS- ACCOUNT */  -- /* -SS- OTR was PS_TRANE_ACCOUNTS */
					-- -SS- , ACTUATE_SEC_XREF ASX
				WHERE
					A.JOURNAL_DATE >= TRUNC(TO_DATE(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy')), 'YEAR')
					AND A.JOURNAL_DATE <= LAST_DAY(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy'))
					--BETWEEN TO_DATE('01/01/2003','MM/DD/YYYY') AND TO_DATE('12/31/2050','MM/DD/YYYY')
					AND A.R12_ENTITY IN('5773', '5588')
					-- -SS- AND A.BUSINESS_UNIT_GL IN('CAN', 'CSD')
					AND
					CASE WHEN A.R12_ENTITY NOT IN('5773', '5588')
							-- -SS- ASX.NATION_CURR ='USD'
						THEN 'USA'
						ELSE 'CAN'
					END = UPPER(:COUNTRY)
					-- -SS- AND A.BUSINESS_UNIT_GL= ASX.PSGL(+)
					AND PSA.TRANE_ACCOUNT_IND = 'X'
					AND C.ENTRY_TYPE = 'IN'
					-- -SS- NEW
					AND((A.PS_ACCOUNT = 'NA'
					AND AFU.BETWEEN_523000_546900 = 'Y')
					OR(A.PS_ACCOUNT <> 'NA'
					AND A.PS_ACCOUNT BETWEEN '523000' AND '546900'))
					-- -SS- /NEW
					-- -SS- AND A.ACCOUNT BETWEEN '523000' AND '546900'
				GROUP BY
					CASE WHEN A.R12_ENTITY NOT IN('5773', '5588')
						THEN 'USA'
						ELSE 'CAN'
					END
					-- -SS- ASX.NATION_CURR
					,
					A.R12_ACCOUNT
					-- -SS- ACCOUNT
					,
					PSA.DESCR
		)
		SALES ON BEGBALANCES.R12_ACCOUNT = SALES.R12_ACCOUNT  -- R12_2_R12 
	INNER JOIN
		(
			/* DEFERRED,SHORT_TERM,LONG_TERM DWTRNP */
			SELECT B.GL_ACCOUNT, B.GL_ACCOUNT_DESCR AS DESCRIPTION, SUM(B.DEFERRED_REVENUE) AS DEFERRED_REVENUE, SUM(B.SHORT_TERM_REVENUE) AS SHORT_TERM_BALA, SUM(LONG_TERM_REVENUE) AS LONG_TERM_BALA FROM
					(SELECT A.GL_ACCOUNT, A.GL_ACCOUNT_DESCR, TO_DATE('1-'||:RUNDATE, 'dd-mon-yy'),(MAX(A.REC_REV_MNTHLY) + CASE WHEN A.FORECAST_PERIOD = TO_DATE('1-'||:RUNDATE, 'dd-mon-yy') THEN MAX(A.DEFERRED_REVENUE) ELSE 0 END) AS DEFERRED_REVENUE, MAX(A.SHORT_TERM_DR) AS SHORT_TERM_REVENUE, MAX(A.LONG_TERM_DR) AS LONG_TERM_REVENUE, A.FORECAST_PERIOD
								/* TRUNC(TO_DATE(TO_DATE('1-'||:RunDate,'dd-mon-yy')),'YEAR')   as ship_from
								, (to_date('1-'||:RunDate,'dd-mon-yy') )as ship_to */
							FROM DW_DM_030_REV_RELEASE A -- SR use synonym DM_030_REV_RELEASE@DW_INTFC_DR.LAX.TRANE.COM A
								-- -SS- NEW
							INNER JOIN R12_ACCOUNT_FILTER_UPD AFU ON AFU.R12_ACCOUNT = A.GL_ACCOUNT -- -SS- GL_ACCOUNT is R12
								-- -SS- /NEW
							WHERE
								A.COUNTRY_INDICATOR = UPPER(:COUNTRY)
								AND A.RUN_PERIOD >= TO_DATE('1-'||:RUNDATE, 'dd-mon-yy')
								AND A.RUN_PERIOD < ADD_MONTHS(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy'), 1)
								-- -SS- NEW
								AND AFU.BETWEEN_523000_546900 = 'Y' -- -SS- ???? issue 67
								-- -SS- /NEW
								-- -SS- AND A.GL_ACCOUNT BETWEEN '523000' AND '546900'
								AND A.SHIP_PERIOD >= TRUNC(TO_DATE(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy')), 'YEAR')
								AND A.SHIP_PERIOD <(TO_DATE('1-'||:RUNDATE, 'dd-mon-yy'))
							GROUP BY
								A.GL_ACCOUNT,
								A.GL_ACCOUNT_DESCR,
								A.FORECAST_PERIOD
					)
					B
				GROUP BY
					GL_ACCOUNT,
					B.GL_ACCOUNT_DESCR
		)
		REV ON BEGBALANCES.R12_ACCOUNT = REV.GL_ACCOUNT
	WHERE
		BEGBALANCES.BEGBAL_BASE <> 0;
