USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_currentWaits') IS NULL
  EXEC ('CREATE PROCEDURE sp_currentWaits AS RETURN 0;')
GO

ALTER PROCEDURE sp_currentWaits
AS
BEGIN

SET NOCOUNT ON;

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	this Stored Procedure
-- reports on current processes and gives you an idea of the kind of waits occuring.
-- this report should be constantly changing
-- =============================================


SELECT   w.session_id
 ,w.wait_duration_ms
 ,w.wait_type
 ,w.blocking_session_id
 ,w.resource_description
 ,s.program_name
 ,t.text
 ,db_name(t.dbid) AS DBName
 ,s.cpu_time
 ,s.memory_usage
FROM sys.dm_os_waiting_tasks w
INNER JOIN sys.dm_exec_sessions s
ON w.session_id = s.session_id
INNER JOIN sys.dm_exec_requests r
ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) t
WHERE s.is_user_process = 1



END

GO