USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_currentLocks') IS NULL
  EXEC ('CREATE PROCEDURE sp_currentlocks AS RETURN 0;')
GO

ALTER PROCEDURE sp_currentLocks
AS
BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This Stored Procedure views locking in 
-- particular user databases for only active sessions - this list should be constantly changing
-- If it is not constantly changing we need to identify why some locks are being held and causing blocking
-- =============================================

SELECT   tl.resource_type
 ,req.blocking_session_id
 ,tl.resource_associated_entity_id
 ,tl.request_status
 ,tl.request_mode
 ,tl.request_session_id
 ,tl.resource_description
 ,db.name AS 'Database Name'
 ,ex_ses.status
FROM sys.dm_tran_locks tl
INNER JOIN sys.databases AS db
on tl.resource_database_id = db.database_id
INNER JOIN sys.dm_exec_requests as req
ON tl.request_session_id= req.session_id
INNER JOIN sys.dm_exec_sessions ex_ses
ON tl.request_session_id = ex_ses.session_id
--WHERE db.name = ''
WHERE tl.resource_database_id > 4 -- view user databases only

END
