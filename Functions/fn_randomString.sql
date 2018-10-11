USE [Tools]
GO


--First Create View
IF OBJECT_ID('dbo.vwRandomString') IS NOT NULL
BEGIN
DROP VIEW dbo.vwRandomString
END
GO

IF OBJECT_ID('dbo.fn_randomString') IS NOT NULL
DROP FUNCTION dbo.fn_randomString;
GO
 
CREATE VIEW dbo.vwRandomString 
AS 

SELECT RIGHT(CONVERT(VARCHAR(255), NEWID()), 12) AS rand_str;
GO
 
CREATE FUNCTION dbo.fn_RandomString()
RETURNS VARCHAR(12)
AS
BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2016-06-12
-- Version 1.0
-- Description:	This function creates a random string which 
-- can used for obfuscation purposes
-- =============================================

DECLARE @randomString VARCHAR(12);
 
SET @randomString = (SELECT rand_str FROM dbo.vwRandomString);
 
RETURN @randomString;
END