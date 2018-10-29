USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('AGFailover') IS NULL
  EXEC ('CREATE PROCEDURE AGFailOver AS RETURN 0;')
GO

ALTER PROCEDURE AGFailover
AS
BEGIN
SET NOCOUNT ON
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This stored Procedure is designed to run when a AG Failover occurs so we can record the dates in a table 
--
-- =============================================


IF OBJECT_ID('tempdb.dbo.#PrimaryNode','u') IS NOT NULL
BEGIN
DROP TABLE #PrimaryNode
END

DECLARE @agName varchar(20)

SET @agName = (SELECT top 1 ag.name FROM sys.availability_groups ag)

--Check if this is the Primary Node before running scripts
IF (SELECT dbo.fn_hadr_group_is_primary(@agName) ) = 1
BEGIN

DECLARE @lastFailover [SQL_Variant]
DECLARE @PrimaryNode [SQL_Variant]
 
SET @lastFailover = (SELECT TOP 1 PrimaryNode FROM AGFailoverDates
ORDER BY CurrentDate DESC)


--Confirm current primary node
SELECT hags.primary_replica AS PrimaryNode, ag.name AS AG
  INTO #PrimaryNode
  FROM sys.dm_hadr_availability_group_states hags
  INNER JOIN sys.availability_groups ag ON ag.group_id = hags.group_id


SET @PrimaryNode = (SELECT hags.primary_replica 
  FROM sys.dm_hadr_availability_group_states hags
  INNER JOIN sys.availability_groups ag ON ag.group_id = hags.group_id)


IF @PrimaryNode <> @LastFailover OR @lastFailover IS NULL
BEGIN



INSERT INTO AGFailoverDates(PrimaryNode)
SELECT PrimaryNode
FROM #PrimaryNode
END

DROP TABLE #PrimaryNode

END


END