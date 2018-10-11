USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('LoginDetails') IS NULL
  EXEC ('CREATE PROCEDURE LoginDetails AS RETURN 0;')
GO



ALTER PROCEDURE [dbo].[LoginDetails] 

AS
BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This Stored Procedure Copies all server 
-- logins details to table SQL Logins - to be used
-- In DR scenarios or for Migration projects.
-- =============================================

SET NOCOUNT ON;


DECLARE @availability_group sysname;

SELECT @availability_group = (SELECT ag.name FROM sys.availability_groups ag);

-- If this is instance does not belong to HA exit here
IF @availability_group IS NOT NULL

BEGIN
--Check to see if this is the Primary or Secondary node (this should run on the Primary Node Only)
DECLARE @rc int
EXEC @rc = master.dbo.fn_hadr_group_is_primary @availability_group
IF @rc <> 1
BEGIN
PRINT 'THIS IS NOT THE PRIMARY NODE THEREFORE THE PROCEDURE WILL STOP HERE'
RETURN
END
END


IF OBJECT_ID('tempdb..##Roles') IS NOT NULL
BEGIN
   DROP TABLE ##Roles
END

DECLARE @dbname varchar(100), @sqlstring nvarchar(MAX)
SET @sqlstring = ''

DECLARE dbcursor CURSOR FOR
SELECT name FROM master.sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb') AND [State] = 0

OPEN dbcursor
FETCH NEXT FROM dbcursor INTO @dbname

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sqlstring = @sqlstring 
					+ ' USE [' 
					+ @dbname 
					--+ ']; INSERT INTO ##Roles (MemberName, MemberSID) SELECT name, sid FROM sysusers; '
					+ ']; INSERT INTO ##Roles (DbRole, MemberName, MemberSID) exec sp_helprolemember; '
					+ 'UPDATE ##Roles SET DBName = '''
					+ @dbname 
					+ ''' WHERE DBName IS NULL;'

	FETCH NEXT FROM dbcursor INTO @dbname

END

CLOSE dbcursor;
DEALLOCATE dbcursor;

IF OBJECT_ID('tempdb.dbo.##Roles','u') IS NOT NULL
BEGIN
DROP TABLE ##Roles
END

CREATE TABLE ##Roles (
	RoleID int IDENTITY(1,1)
	, DBName varchar(500)
	, DbRole varchar(500)
	, MemberName varchar(500)
	, MemberSID UNIQUEIDENTIFIER
	)

EXEC (@sqlstring)


DECLARE dbcursor2 CURSOR FOR
SELECT RoleID FROM ##Roles

DECLARE @RoleID int
DECLARE @CurrentDB varchar(500)
DECLARE @Statement varchar(2000)

SET @CurrentDB = ''

OPEN dbcursor2
FETCH NEXT FROM dbcursor2 INTO @RoleID

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @CurrentDB != (SELECT DBName FROM ##Roles WHERE RoleID = @RoleID)
	BEGIN
		PRINT ''
		SELECT @Statement = 'USE [' + (SELECT DBName FROM ##Roles WHERE RoleID = @RoleID) + '];'
		PRINT @Statement
	END

	SELECT DISTINCT @Statement = 'CREATE USER ['
		+ MemberName
		+ '] FOR LOGIN ['
		+ + MemberName
		+ '];'
	FROM ##Roles
	WHERE RoleID = @RoleID

	PRINT @Statement

	SELECT @Statement = 'EXEC sp_addrolemember '''
		+ DbRole 
		+ ''', '''
		+ MemberName
		+ ''';'
	FROM ##Roles
	WHERE RoleID = @RoleID

	PRINT @Statement



	SELECT @CurrentDB = DBName FROM ##Roles WHERE RoleID = @RoleID

	FETCH NEXT FROM dbcursor2 INTO @RoleID

END

CLOSE dbcursor2;
DEALLOCATE dbcursor2;

-- =========================================
-- Adding temp data into tools so it can be replicated for DR for each production server
-- =========================================

--create table 


--drop table tools.dbo.SQLlogins

TRUNCATE TABLE tools.dbo.SQLlogins

/*
Create table tools.dbo.SQLlogins
(RoleID int
	, DBName varchar(500)
	, DbRole varchar(500)
	, MemberName varchar(500)
	, MemberSID UNIQUEIDENTIFIER
	)
*/
DECLARE @roles1 varchar(2000)
DECLARE @data varchar(2000)
DECLARE @data2 varchar(2000)

SET @roles1 = 'select * from ##roles'
SET @data = 'select roldid,DBName, DbRole, MemberName, MemberSID from tools.dbo.SQLlogins'
SET @data2 = 'select roldid,DBName, DbRole, MemberName, MemberSID from ##roles' 

-- insert data into table from temp table

INSERT INTO tools.dbo.SQLlogins 
SELECT RoleID, dbname, DbRole,MemberName, MemberSID FROM ##Roles

DROP TABLE ##Roles

END
GO


