SELECT
		SESS.SID,
		SESS.SERIAL#,
		SESS.PROCESS,
		SESS.STATUS,
		SESS.USERNAME,
		SESS.SCHEMANAME,
--		sess.*,
		SQL.SQL_TEXT
	FROM
		V$SESSION SESS
	LEFT OUTER JOIN V$SQL SQL ON SQL.SQL_ID = SESS.SQL_ID
	WHERE
		SESS.TYPE = 'USER'
 		AND SESS.USERNAME IN('CCDCAS','CCDCAT', 'CCDCAU', 'ENT_RPT', 'ACTU_CACHE_ADMIN', 'DBO', 'IR_BI_RPT_CCT') 
;
-- ALTER SYSTEM KILL SESSION 'SID , SERIAL#' IMMEDIATE;
-- ALTER SYSTEM DISCONNECT SESSION 'SID , SERIAL#'' IMMEDIATE;
ALTER SYSTEM KILL SESSION '100, 25578' IMMEDIATE;
ALTER SYSTEM DISCONNECT SESSION '173, 48870' IMMEDIATE;

-- BLOCKING
select 
   blocking_session, 
   sid, 
   serial#, 
   wait_class,
   seconds_in_wait
from 
   v$session
where 
   blocking_session is not NULL
order by 
   blocking_session;

-- TEMP SPACE
SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
 
SELECT 
   A.tablespace_name tablespace, 
   D.mb_total,
   SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
   D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM 
   v$sort_segment A,
(
SELECT 
   B.name, 
   C.block_size, 
   SUM (C.bytes) / 1024 / 1024 mb_total
FROM 
   v$tablespace B, 
   v$tempfile C
WHERE 
   B.ts#= C.ts#
GROUP BY 
   B.name, 
   C.block_size
) D
WHERE 
   A.tablespace_name = D.name
GROUP by 
   A.tablespace_name, 
   D.mb_total
/