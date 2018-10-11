USE [Tools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('DBGrowth') IS NULL
  EXEC ('CREATE PROCEDURE DBGrowth AS RETURN 0;')
GO


ALTER PROCEDURE [dbo].[DBGrowth]

AS
BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	Tracks Database growth and stores it in table DBGrowthRate
-- =============================================


SET NOCOUNT ON


	INSERT INTO [dbo].[DBGrowthRate]
			   ([DBName]
			   ,[DBID]
			   ,[NumPages]
			   ,[DBSizeMB]
			   ,[CheckDate])
		SELECT sd.name AS DBName
			, sd.database_ID AS [DBID]
			,  SUM(mf.size) as NumPages
			, (SUM(CONVERT(decimal(10,2), mf.size))) *8 / 1024 AS 'DBSizeMB'
			, GETDATE() AS CheckDate
		FROM sys.databases sd
		JOIN sys.master_files mf
		ON sd.database_ID = mf.database_ID
		GROUP BY sd.name, sd.database_ID
		ORDER BY sd.name


END


