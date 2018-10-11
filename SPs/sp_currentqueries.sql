USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_CurrentQueries') IS NULL
  EXEC ('CREATE PROCEDURE sp_CurrentQueries AS RETURN 0;')
GO

ALTER PROCEDURE sp_CurrentQueries
AS
BEGIN
SET NOCOUNT ON
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This Stored Procedure provides a list of currently executing queries
-- =============================================

SELECT s.session_id, S.login_name, S.host_name, S.program_name,
R.command, T.text,
R.wait_type, R.wait_time, R.blocking_session_id
FROM sys.dm_exec_requests AS R
INNER JOIN sys.dm_exec_sessions AS S
ON R.session_id = S.session_id
OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) AS T
WHERE S.is_user_process = 1;


END

GO