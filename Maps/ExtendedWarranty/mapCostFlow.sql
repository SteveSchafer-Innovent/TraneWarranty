SELECT
		ROWNUM AS RN,
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY REPORT_TYPE, COUNTRY_INDICATOR ORDER BY REPORT_TYPE, COUNTRY_INDICATOR) = 1
			THEN REPORT_TYPE
			ELSE NULL
		END AS REPORT_TYPE,
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY GL_ACCOUNT, GL_ACCOUNT_DESCRIPTION ORDER BY GL_ACCOUNT, GL_ACCOUNT_DESCRIPTION) = 1
			THEN GL_ACCOUNT
			ELSE NULL
		END AS GL_ACCOUNT,
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY GL_ACCOUNT, GL_ACCOUNT_DESCRIPTION ORDER BY GL_ACCOUNT, GL_ACCOUNT_DESCRIPTION) = 1
			THEN GL_ACCOUNT_DESCRIPTION
			ELSE NULL
		END AS GL_ACCOUNT_DESCRIPTION,
		CASE WHEN ROW_NUMBER() OVER(PARTITION BY COUNTRY_INDICATOR ORDER BY COUNTRY_INDICATOR) = 1
			THEN COUNTRY_INDICATOR
			ELSE NULL
		END AS COUNTRY_INDICATOR,
		SHIP_YEAR,
		LAG_PERIOD_EXP_1 AS "1",
		LAG_PERIOD_EXP_2 AS "2",
		LAG_PERIOD_EXP_3 AS "3",
		LAG_PERIOD_EXP_4 AS "4",
		LAG_PERIOD_EXP_5 AS "5",
		LAG_PERIOD_EXP_6 AS "6",
		LAG_PERIOD_EXP_7 AS "7",
		LAG_PERIOD_EXP_8 AS "8",
		LAG_PERIOD_EXP_9 AS "9",
		LAG_PERIOD_EXP_10 AS "10",
		LAG_PERIOD_EXP_11 AS "11",
		LAG_PERIOD_EXP_12 AS "12",
		LAG_PERIOD_EXP_13 AS "13",
		LAG_PERIOD_EXP_14 AS "14",
		LAG_PERIOD_EXP_15 AS "15",
		LAG_PERIOD_EXP_16 AS "16",
		LAG_PERIOD_EXP_17 AS "17",
		LAG_PERIOD_EXP_18 AS "18",
		LAG_PERIOD_EXP_19 AS "19",
		LAG_PERIOD_EXP_20 AS "20",
		LAG_PERIOD_EXP_21 AS "21",
		LAG_PERIOD_EXP_22 AS "22",
		LAG_PERIOD_EXP_23 AS "23",
		LAG_PERIOD_EXP_24 AS "24",
		LAG_PERIOD_EXP_25 AS "25",
		LAG_PERIOD_EXP_26 AS "26",
		LAG_PERIOD_EXP_27 AS "27",
		LAG_PERIOD_EXP_28 AS "28",
		LAG_PERIOD_EXP_29 AS "29",
		LAG_PERIOD_EXP_30 AS "30",
		LAG_PERIOD_EXP_31 AS "31",
		LAG_PERIOD_EXP_32 AS "32",
		LAG_PERIOD_EXP_33 AS "33",
		LAG_PERIOD_EXP_34 AS "34",
		LAG_PERIOD_EXP_35 AS "35",
		LAG_PERIOD_EXP_36 AS "36",
		LAG_PERIOD_EXP_37 AS "37",
		LAG_PERIOD_EXP_38 AS "38",
		LAG_PERIOD_EXP_39 AS "39",
		LAG_PERIOD_EXP_40 AS "40",
		LAG_PERIOD_EXP_41 AS "41",
		LAG_PERIOD_EXP_42 AS "42",
		LAG_PERIOD_EXP_43 AS "43",
		LAG_PERIOD_EXP_44 AS "44",
		LAG_PERIOD_EXP_45 AS "45",
		LAG_PERIOD_EXP_46 AS "46",
		LAG_PERIOD_EXP_47 AS "47",
		LAG_PERIOD_EXP_48 AS "48",
		LAG_PERIOD_EXP_49 AS "49",
		LAG_PERIOD_EXP_50 AS "50",
		LAG_PERIOD_EXP_51 AS "51",
		LAG_PERIOD_EXP_52 AS "52",
		LAG_PERIOD_EXP_53 AS "53",
		LAG_PERIOD_EXP_54 AS "54",
		LAG_PERIOD_EXP_55 AS "55",
		LAG_PERIOD_EXP_56 AS "56",
		LAG_PERIOD_EXP_57 AS "57",
		LAG_PERIOD_EXP_58 AS "58",
		LAG_PERIOD_EXP_59 AS "59",
		LAG_PERIOD_EXP_60 AS "60",
		LAG_PERIOD_EXP_61 AS "61",
		LAG_PERIOD_EXP_62 AS "62",
		LAG_PERIOD_EXP_63 AS "63",
		LAG_PERIOD_EXP_64 AS "64",
		LAG_PERIOD_EXP_65 AS "65",
		LAG_PERIOD_EXP_66 AS "66",
		LAG_PERIOD_EXP_67 AS "67",
		LAG_PERIOD_EXP_68 AS "68",
		LAG_PERIOD_EXP_69 AS "69",
		LAG_PERIOD_EXP_70 AS "70",
		LAG_PERIOD_EXP_71 AS "71",
		LAG_PERIOD_EXP_72 AS "72",
		LAG_PERIOD_EXP_73 AS "73",
		LAG_PERIOD_EXP_74 AS "74",
		LAG_PERIOD_EXP_75 AS "75",
		LAG_PERIOD_EXP_76 AS "76",
		LAG_PERIOD_EXP_77 AS "77",
		LAG_PERIOD_EXP_78 AS "78",
		LAG_PERIOD_EXP_79 AS "79",
		LAG_PERIOD_EXP_80 AS "80",
		LAG_PERIOD_EXP_81 AS "81",
		LAG_PERIOD_EXP_82 AS "82",
		LAG_PERIOD_EXP_83 AS "83",
		LAG_PERIOD_EXP_84 AS "84",
		LAG_PERIOD_EXP_85 AS "85",
		LAG_PERIOD_EXP_86 AS "86",
		LAG_PERIOD_EXP_87 AS "87",
		LAG_PERIOD_EXP_88 AS "88",
		LAG_PERIOD_EXP_89 AS "89",
		LAG_PERIOD_EXP_90 AS "90",
		LAG_PERIOD_EXP_91 AS "91",
		LAG_PERIOD_EXP_92 AS "92",
		LAG_PERIOD_EXP_93 AS "93",
		LAG_PERIOD_EXP_94 AS "94",
		LAG_PERIOD_EXP_95 AS "95",
		LAG_PERIOD_EXP_96 AS "96",
		LAG_PERIOD_EXP_97 AS "97",
		LAG_PERIOD_EXP_98 AS "98",
		LAG_PERIOD_EXP_99 AS "99",
		LAG_PERIOD_EXP_100 AS "100",
		LAG_PERIOD_EXP_101 AS "101",
		LAG_PERIOD_EXP_102 AS "102",
		LAG_PERIOD_EXP_103 AS "103",
		LAG_PERIOD_EXP_104 AS "104",
		LAG_PERIOD_EXP_105 AS "105",
		LAG_PERIOD_EXP_106 AS "106",
		LAG_PERIOD_EXP_107 AS "107",
		LAG_PERIOD_EXP_108 AS "108",
		LAG_PERIOD_EXP_109 AS "109",
		LAG_PERIOD_EXP_110 AS "110",
		LAG_PERIOD_EXP_111 AS "111",
		LAG_PERIOD_EXP_112 AS "112",
		LAG_PERIOD_EXP_113 AS "113",
		LAG_PERIOD_EXP_114 AS "114",
		LAG_PERIOD_EXP_115 AS "115",
		LAG_PERIOD_EXP_116 AS "116",
		LAG_PERIOD_EXP_117 AS "117",
		LAG_PERIOD_EXP_118 AS "118",
		LAG_PERIOD_EXP_119 AS "119",
		LAG_PERIOD_EXP_120 AS "120",
		LAG_PERIOD_EXP_121 AS "121",
		LAG_PERIOD_EXP_122 AS "122",
		LAG_PERIOD_EXP_123 AS "123",
		LAG_PERIOD_EXP_124 AS "124",
		LAG_PERIOD_EXP_125 AS "125",
		LAG_PERIOD_EXP_126 AS "126",
		LAG_PERIOD_EXP_127 AS "127",
		LAG_PERIOD_EXP_128 AS "128",
		LAG_PERIOD_EXP_129 AS "129",
		LAG_PERIOD_EXP_130 AS "130",
		LAG_PERIOD_EXP_131 AS "131",
		LAG_PERIOD_EXP_132 AS "132"
	FROM
		DBO.DM_030_COST_FLOW_PIVOT
	WHERE
		SHIP_YEAR >= 2000
		--AND report_type ='2-16'
		--AND country_indicator= 'USA'
	ORDER BY
		ROWNUM,
		REPORT_TYPE,
		COUNTRY_INDICATOR,
		GL_ACCOUNT 