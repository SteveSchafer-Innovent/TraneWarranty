--  fll.flex_value = gcc.segment2
SELECT
		fll.flex_value location_code, FLL.DESCRIPTION
	FROM
		FND_FLEX_VALUES_VL FLL
	WHERE
		FLL.FLEX_VALUE_SET_ID = 1014929;