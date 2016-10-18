SELECT
		FFVS.FLEX_VALUE_SET_NAME,
		FFV.FLEX_VALUE R12_LOCATION,
		FFVT.FLEX_VALUE_MEANING,
		FFVT.DESCRIPTION R12_DESCRIPTION
	FROM
		FND_FLEX_VALUE_SETS FFVS,
		FND_FLEX_VALUES FFV,
		FND_FLEX_VALUES_TL FFVT
	WHERE
		FFVS.FLEX_VALUE_SET_NAME LIKE'XXIR_GL_LOCATION'
		AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID
		AND FFV.FLEX_VALUE_ID = FFVT.FLEX_VALUE_ID
		AND FFVT.LANGUAGE = 'US'
		AND FFV.FLEX_VALUE LIKE '1%';