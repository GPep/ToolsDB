USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('ServerLogin') IS NULL
  EXEC ('CREATE PROCEDURE ServerLogin AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[ServerLogin]

AS 

BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This Stored Procedure copies all login and server role information to a table
-- To be used for DR and migration purposes
-- =============================================


SET NOCOUNT ON

TRUNCATE TABLE tools.dbo.ServerRoles

DECLARE @SQLCmd nvarchar(1000)
DECLARE @RoleName sysname
DECLARE @Login sysname
DECLARE @Count int

IF OBJECT_ID('tempdb.dbo.#ServerRoles','u') IS NOT NULL
BEGIN
DROP TABLE #ServerRoles
END

CREATE TABLE #ServerRoles (
ServerRole sysname,
MemberName sysname,
MemberSID varbinary(85))

INSERT INTO #ServerRoles
exec sp_helpsrvrolemember 

DECLARE ServerRoleCursor Cursor 
FOR SELECT ServerRole,MemberName 
FROM #ServerRoles 
WHERE MemberName not like 'NT SERVICE%' AND 
MemberName <> 'sa' AND
MemberName not like 'NT AUTHORITY%'

OPEN ServerRoleCursor

FETCH NEXT FROM ServerRoleCursor
INTO @RoleName, @Login


SET @Count = 0

WHILE @@FETCH_STATUS = 0
BEGIN
SET @SQLCmd = 'exec sp_addsrvrolemember ''' + @Login + ''' , ''' + @RoleName + ''''
PRINT @SQLCmd

SET @Count = @Count + 1 

FETCH NEXT FROM ServerRoleCursor
INTO @RoleName, @Login
END

IF @Count=0
PRINT 'No logins with serverroles, besides SA'


CLOSE ServerRoleCursor
DEALLOCATE ServerRoleCursor



-- =========================================
-- Adding temp data into tools so it can be replicated for DR for each production server
-- =========================================
DECLARE @roles1 varchar(2000)
DECLARE @data varchar(2000)
DECLARE @data2 varchar(2000)

SET @roles1 = 'select * from #ServerRoles'
SET @data = 'select ServerRole,MemberName, MemberSID from tools.dbo.ServerRoles'
SET @data2 = 'select ServerRole,MemberName, MemberSID from #ServerRoles' 

-- insert data into table from temp table

INSERT INTO tools.dbo.ServerRoles 
SELECT ServerRole,MemberName, MemberSID FROM #ServerRoles

DROP TABLE #ServerRoles

END	
GO


