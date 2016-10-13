-- GCC.SEGMENT2 = FFVC.FLEX_VALUE
SELECT
		FFVC.FLEX_VALUE, FFVC1.DESCRIPTION
	FROM
		FND_FLEX_VALUES_VL FFVC
		INNER JOIN FND_FLEX_VALUES_VL FFVC1 on FFVC1.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
		INNER JOIN FND_FLEX_VALUES_VL FFVC2 on FFVC2.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID
		INNER JOIN FND_FLEX_VALUE_NORM_HIERARCHY FFVCP1 on FFVCP1.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID and FFVC1.FLEX_VALUE = FFVCP1.PARENT_FLEX_VALUE
		INNER JOIN FND_FLEX_VALUE_NORM_HIERARCHY FFVCP2 on FFVCP2.FLEX_VALUE_SET_ID = FFVC.FLEX_VALUE_SET_ID and FFVC2.FLEX_VALUE = FFVCP2.PARENT_FLEX_VALUE
	WHERE 0=0
		AND FFVC.FLEX_VALUE_SET_ID = 1014929
		AND FFVC.ENABLED_FLAG = 'Y'
		AND FFVC.FLEX_VALUE BETWEEN FFVCP1.CHILD_FLEX_VALUE_LOW AND FFVCP1.CHILD_FLEX_VALUE_HIGH
		AND FFVCP1.PARENT_FLEX_VALUE LIKE 'P%'
		AND SYSDATE BETWEEN NVL(FFVCP1.START_DATE_ACTIVE, SYSDATE) AND NVL(FFVCP1.END_DATE_ACTIVE, SYSDATE)
		AND FFVCP2.PARENT_FLEX_VALUE LIKE 'P%'
		AND SYSDATE BETWEEN NVL(FFVCP2.START_DATE_ACTIVE, SYSDATE) AND NVL(FFVCP2.END_DATE_ACTIVE, SYSDATE)
		AND FFVCP1.PARENT_FLEX_VALUE BETWEEN FFVCP2.CHILD_FLEX_VALUE_LOW AND FFVCP2.CHILD_FLEX_VALUE_HIGH
		AND FFVC1.ENABLED_FLAG = 'Y'
		AND FFVC2.ENABLED_FLAG = 'Y'
		AND ROWNUM = 1
