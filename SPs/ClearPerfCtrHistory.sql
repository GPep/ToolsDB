USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('ClearPerfCtrHistory') IS NULL
  EXEC ('CREATE PROCEDURE ClearPerfCtrHistory AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[ClearPerfCtrHistory] @old_date INT = 180
AS
BEGIN
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This clears out PerfCounter history. It defaults to 180 days
--SOURCE: https://github.com/Microsoft/tigertoolbox/tree/master/SQL-Performance-Baseline
--
-- =============================================
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PerformanceCounter]') AND type in (N'U'))
BEGIN
DELETE dbo.PerformanceCounter 
WHERE DateSampled < DATEADD(dd,-@old_date, dateadd(dd, datediff(dd,0, GETDATE()),0))
END
END TRY
BEGIN CATCH
IF (XACT_STATE()) != 0
ROLLBACK TRANSACTION;
DECLARE @errMessage varchar(MAX)
SET @errMessage = 'Stored procedure ' + OBJECT_NAME(@@PROCID) + ' failed with error ' + CAST(ERROR_NUMBER() AS VARCHAR(20)) + '. ' + ERROR_MESSAGE() 
RAISERROR (@errMessage, 16, 1)                               
END CATCH

END
                     