USE [Tools]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_hadr_group_is_primary]    Script Date: 17/09/2018 06:27:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************
Author: Glenn Pepper
Date: 12/09/2017
Purpose: Will check if this is the Primary node in an Availability Group
************************************/
IF OBJECT_ID('fn_hadr_group_is_primary') IS NOT  NULL
BEGIN
DROP FUNCTION fn_hadr_group_is_primary
END
GO

CREATE FUNCTION [dbo].[fn_hadr_group_is_primary] (@AGName sysname)
RETURNS bit
AS
BEGIN;
  DECLARE @PrimaryReplica sysname; 

  SELECT
    @PrimaryReplica = hags.primary_replica
  FROM sys.dm_hadr_availability_group_states hags
  INNER JOIN sys.availability_groups ag ON ag.group_id = hags.group_id
  WHERE ag.name = @AGName;

  IF UPPER(@PrimaryReplica) =  UPPER(@@SERVERNAME)
    RETURN 1; -- primary

    RETURN 0; -- not primary
END; 

GO


