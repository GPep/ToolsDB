USE [Tools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('DBLogGrowth') IS NULL
  EXEC ('CREATE PROCEDURE DBLogGrowth AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[DBLogGrowth]
AS

BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	Tracks Transaction Log growth and records data in table DBLogGrowthRate in Tools
-- =============================================

SET NOCOUNT ON


IF OBJECT_ID('tempdb.dbo.#DBLogSpace','u') IS NOT NULL
BEGIN
DROP TABLE #DBLogSpace
END

CREATE TABLE #DBLogSpace(
DBName Varchar(100) NOT NULL,
LogSizeMB Decimal(10,2) NOT NULL,
LogSpaceUsedPercent Decimal(10,2) NOT NULL,
[Status] int NOT NULL)

INSERT INTO #DBLogSpace
EXEC('DBCC SQLPERF(LOGSPACE)')


INSERT INTO DBLogGrowthRate(DBName, LogSizeMB, LogSpaceUsedPercent, [Status])
SELECT DBName, LogSizeMB, LogSpaceUsedPercent, [Status]
FROM #DBLogSpace

END



