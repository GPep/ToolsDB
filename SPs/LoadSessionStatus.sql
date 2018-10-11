USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('LoadSessionStatus') IS NULL
  EXEC ('CREATE PROCEDURE LoadSessionStatus AS RETURN 0;')
GO

ALTER PROCEDURE LoadSessionStatus @Days INT = -5
AS
BEGIN
SET NOCOUNT ON
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This stored Procedure Captures all Session information for the last 5 days by default (but tis can  be changed)
--
-- =============================================


delete from dbo.Sessionstatus where DateCaptured < DATEADD(dd, @Days,getdate()); -- Keep Last 5 Days Data Only
INSERT INTO dbo.Sessionstatus
SELECT Getdate() as "Date Captured", DB_NAME(database_id) as "Database Name" ,status,wait_type,SUM(wait_time) as [Wait in ms],COUNT(r.session_id) as [Session Count],SUM(open_transaction_count) as [Open Transactions]
from  sys.dm_exec_requests r  
where 
r.blocking_session_id = 0 
and r.status NOT IN ('suspended','background') 
group by status,DB_NAME(database_id),wait_type
UNION ALL
SELECT Getdate() as "Date Captured", DB_NAME(database_id) as "Database Name" ,status,wait_type, SUM(wait_time) as [Wait in ms], COUNT(r.session_id) as [Session Count],SUM(open_transaction_count) as [Open Transactions]
from  sys.dm_exec_requests r  
where 
r.blocking_session_id = 0 and r.status = 'suspended'
group by status,DB_NAME(database_id),wait_type
UNION ALL
SELECT Getdate() as "Date Captured", DB_NAME(database_id) as "Database Name",'blocked',wait_type, SUM(wait_time) as [Wait in ms],COUNT(r.session_id) as [Session Count],SUM(open_transaction_count) as [Open Transactions]
from  sys.dm_exec_requests r  
where 
-- r.session_id > 50 and 
r.blocking_session_id <> 0
GROUP BY DB_NAME(database_id),wait_type
UNION ALL
SELECT Getdate() as "Date Captured", DB_NAME(database_id) as "Database Name",s.status,s.lastwaittype , SUM(s.waittime) as [Wait in ms],COUNT(s.spid) as [Session Count],SUM(s.open_tran) as [Open Transactions]
from  sys.sysprocesses s  left join sys.dm_exec_requests r
on s.spid = r.session_id
where 
r.session_id is NULL 
GROUP BY DB_NAME(database_id),s.status,s.lastwaittype


END
