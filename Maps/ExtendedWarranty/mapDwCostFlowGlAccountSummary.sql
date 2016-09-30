SELECT
		REPORT_TYPE AS REPORT_TYPE,
		COUNTRY_INDICATOR AS COUNTRY_INDICATOR,
		GL_ACCOUNT AS GL_ACCOUNT,
		GL_ACCOUNT_DESCRIPTION AS GL_ACCOUNT_DESCRIPTION,
		(SUM(LAG_PERIOD_EXP_1)) AS "1",
		(SUM(LAG_PERIOD_EXP_2)) AS "2",
		(SUM(LAG_PERIOD_EXP_3)) AS "3",
		(SUM(LAG_PERIOD_EXP_4)) AS "4",
		(SUM(LAG_PERIOD_EXP_5)) AS "5",
		(SUM(LAG_PERIOD_EXP_6)) AS "6",
		(SUM(LAG_PERIOD_EXP_7)) AS "7",
		(SUM(LAG_PERIOD_EXP_8)) AS "8",
		(SUM(LAG_PERIOD_EXP_9)) AS "9",
		(SUM(LAG_PERIOD_EXP_10)) AS "10",
		(SUM(LAG_PERIOD_EXP_11)) AS "11",
		(SUM(LAG_PERIOD_EXP_12)) AS "12",
		(SUM(LAG_PERIOD_EXP_13)) AS "13",
		(SUM(LAG_PERIOD_EXP_14)) AS "14",
		(SUM(LAG_PERIOD_EXP_15)) AS "15",
		(SUM(LAG_PERIOD_EXP_16)) AS "16",
		(SUM(LAG_PERIOD_EXP_17)) AS "17",
		(SUM(LAG_PERIOD_EXP_18)) AS "18",
		(SUM(LAG_PERIOD_EXP_19)) AS "19",
		(SUM(LAG_PERIOD_EXP_20)) AS "20",
		(SUM(LAG_PERIOD_EXP_21)) AS "21",
		(SUM(LAG_PERIOD_EXP_22)) AS "22",
		(SUM(LAG_PERIOD_EXP_23)) AS "23",
		(SUM(LAG_PERIOD_EXP_24)) AS "24",
		(SUM(LAG_PERIOD_EXP_25)) AS "25",
		(SUM(LAG_PERIOD_EXP_26)) AS "26",
		(SUM(LAG_PERIOD_EXP_27)) AS "27",
		(SUM(LAG_PERIOD_EXP_28)) AS "28",
		(SUM(LAG_PERIOD_EXP_29)) AS "29",
		(SUM(LAG_PERIOD_EXP_30)) AS "30",
		(SUM(LAG_PERIOD_EXP_31)) AS "31",
		(SUM(LAG_PERIOD_EXP_32)) AS "32",
		(SUM(LAG_PERIOD_EXP_33)) AS "33",
		(SUM(LAG_PERIOD_EXP_34)) AS "34",
		(SUM(LAG_PERIOD_EXP_35)) AS "35",
		(SUM(LAG_PERIOD_EXP_36)) AS "36",
		(SUM(LAG_PERIOD_EXP_37)) AS "37",
		(SUM(LAG_PERIOD_EXP_38)) AS "38",
		(SUM(LAG_PERIOD_EXP_39)) AS "39",
		(SUM(LAG_PERIOD_EXP_40)) AS "40",
		(SUM(LAG_PERIOD_EXP_41)) AS "41",
		(SUM(LAG_PERIOD_EXP_42)) AS "42",
		(SUM(LAG_PERIOD_EXP_43)) AS "43",
		(SUM(LAG_PERIOD_EXP_44)) AS "44",
		(SUM(LAG_PERIOD_EXP_45)) AS "45",
		(SUM(LAG_PERIOD_EXP_46)) AS "46",
		(SUM(LAG_PERIOD_EXP_47)) AS "47",
		(SUM(LAG_PERIOD_EXP_48)) AS "48",
		(SUM(LAG_PERIOD_EXP_49)) AS "49",
		(SUM(LAG_PERIOD_EXP_50)) AS "50",
		(SUM(LAG_PERIOD_EXP_51)) AS "51",
		(SUM(LAG_PERIOD_EXP_52)) AS "52",
		(SUM(LAG_PERIOD_EXP_53)) AS "53",
		(SUM(LAG_PERIOD_EXP_54)) AS "54",
		(SUM(LAG_PERIOD_EXP_55)) AS "55",
		(SUM(LAG_PERIOD_EXP_56)) AS "56",
		(SUM(LAG_PERIOD_EXP_57)) AS "57",
		(SUM(LAG_PERIOD_EXP_58)) AS "58",
		(SUM(LAG_PERIOD_EXP_59)) AS "59",
		(SUM(LAG_PERIOD_EXP_60)) AS "60",
		(SUM(LAG_PERIOD_EXP_61)) AS "61",
		(SUM(LAG_PERIOD_EXP_62)) AS "62",
		(SUM(LAG_PERIOD_EXP_63)) AS "63",
		(SUM(LAG_PERIOD_EXP_64)) AS "64",
		(SUM(LAG_PERIOD_EXP_65)) AS "65",
		(SUM(LAG_PERIOD_EXP_66)) AS "66",
		(SUM(LAG_PERIOD_EXP_67)) AS "67",
		(SUM(LAG_PERIOD_EXP_68)) AS "68",
		(SUM(LAG_PERIOD_EXP_69)) AS "69",
		(SUM(LAG_PERIOD_EXP_70)) AS "70",
		(SUM(LAG_PERIOD_EXP_71)) AS "71",
		(SUM(LAG_PERIOD_EXP_72)) AS "72",
		(SUM(LAG_PERIOD_EXP_73)) AS "73",
		(SUM(LAG_PERIOD_EXP_74)) AS "74",
		(SUM(LAG_PERIOD_EXP_75)) AS "75",
		(SUM(LAG_PERIOD_EXP_76)) AS "76",
		(SUM(LAG_PERIOD_EXP_77)) AS "77",
		(SUM(LAG_PERIOD_EXP_78)) AS "78",
		(SUM(LAG_PERIOD_EXP_79)) AS "79",
		(SUM(LAG_PERIOD_EXP_80)) AS "80",
		(SUM(LAG_PERIOD_EXP_81)) AS "81",
		(SUM(LAG_PERIOD_EXP_82)) AS "82",
		(SUM(LAG_PERIOD_EXP_83)) AS "83",
		(SUM(LAG_PERIOD_EXP_84)) AS "84",
		(SUM(LAG_PERIOD_EXP_85)) AS "85",
		(SUM(LAG_PERIOD_EXP_86)) AS "86",
		(SUM(LAG_PERIOD_EXP_87)) AS "87",
		(SUM(LAG_PERIOD_EXP_88)) AS "88",
		(SUM(LAG_PERIOD_EXP_89)) AS "89",
		(SUM(LAG_PERIOD_EXP_90)) AS "90",
		(SUM(LAG_PERIOD_EXP_91)) AS "91",
		(SUM(LAG_PERIOD_EXP_92)) AS "92",
		(SUM(LAG_PERIOD_EXP_93)) AS "93",
		(SUM(LAG_PERIOD_EXP_94)) AS "94",
		(SUM(LAG_PERIOD_EXP_95)) AS "95",
		(SUM(LAG_PERIOD_EXP_96)) AS "96",
		(SUM(LAG_PERIOD_EXP_97)) AS "97",
		(SUM(LAG_PERIOD_EXP_98)) AS "98",
		(SUM(LAG_PERIOD_EXP_99)) AS "99",
		(SUM(LAG_PERIOD_EXP_100)) AS "100",
		(SUM(LAG_PERIOD_EXP_101)) AS "101",
		(SUM(LAG_PERIOD_EXP_102)) AS "102",
		(SUM(LAG_PERIOD_EXP_103)) AS "103",
		(SUM(LAG_PERIOD_EXP_104)) AS "104",
		(SUM(LAG_PERIOD_EXP_105)) AS "105",
		(SUM(LAG_PERIOD_EXP_106)) AS "106",
		(SUM(LAG_PERIOD_EXP_107)) AS "107",
		(SUM(LAG_PERIOD_EXP_108)) AS "108",
		(SUM(LAG_PERIOD_EXP_109)) AS "109",
		(SUM(LAG_PERIOD_EXP_110)) AS "110",
		(SUM(LAG_PERIOD_EXP_111)) AS "111",
		(SUM(LAG_PERIOD_EXP_112)) AS "112",
		(SUM(LAG_PERIOD_EXP_113)) AS "113",
		(SUM(LAG_PERIOD_EXP_114)) AS "114",
		(SUM(LAG_PERIOD_EXP_115)) AS "115",
		(SUM(LAG_PERIOD_EXP_116)) AS "116",
		(SUM(LAG_PERIOD_EXP_117)) AS "117",
		(SUM(LAG_PERIOD_EXP_118)) AS "118",
		(SUM(LAG_PERIOD_EXP_119)) AS "119",
		(SUM(LAG_PERIOD_EXP_120)) AS "120",
		(SUM(LAG_PERIOD_EXP_121)) AS "121",
		(SUM(LAG_PERIOD_EXP_122)) AS "122",
		(SUM(LAG_PERIOD_EXP_123)) AS "123",
		(SUM(LAG_PERIOD_EXP_124)) AS "124",
		(SUM(LAG_PERIOD_EXP_125)) AS "125",
		(SUM(LAG_PERIOD_EXP_126)) AS "126",
		(SUM(LAG_PERIOD_EXP_127)) AS "127",
		(SUM(LAG_PERIOD_EXP_128)) AS "128",
		(SUM(LAG_PERIOD_EXP_129)) AS "129",
		(SUM(LAG_PERIOD_EXP_130)) AS "130",
		(SUM(LAG_PERIOD_EXP_131)) AS "131",
		(SUM(LAG_PERIOD_EXP_132)) AS "132"
	FROM
		DBO.DM_030_COST_FLOW_PIVOT
	WHERE
		--REPORT_TYPE ='2-16'
		--and GL_ACCOUNT  in ('523500')
		--AND COUNTRY_INDICATOR in ('USA')
		SHIP_YEAR >= 2000
	GROUP BY
		REPORT_TYPE,
		COUNTRY_INDICATOR,
		GL_ACCOUNT,
		GL_ACCOUNT_DESCRIPTION
	ORDER BY
		REPORT_TYPE,
		COUNTRY_INDICATOR,
		GL_ACCOUNT,
		GL_ACCOUNT_DESCRIPTION