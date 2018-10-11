--Drop old tables

USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @ErrorNumber AS INT, 
@ErrorMessage AS NVarchar(1000), 
@error_severity AS INT



BEGIN TRY;
BEGIN TRANSACTION;
PRINT  'Dropping Old Tables....'


IF OBJECT_ID('ClusterNodeOld','u') IS NOT NULL
BEGIN
DROP TABLE ClusterNodeOld
END

IF OBJECT_ID('ClusterNodeNotificationOld','u') IS NOT NULL
BEGIN
DROP TABLE ClusternodenotificationOld
END

IF OBJECT_ID('CRJobsOld','u') IS NOT NULL
BEGIN
DROP TABLE CRJobsOld
END

IF OBJECT_ID('DBGrowthRateOld','u') IS NOT NULL
BEGIN
DROP TABLE DBGrowthRateOld
END

IF OBJECT_ID('Disk_SizeOld','u') IS NOT NULL
BEGIN
DROP TABLE Disk_SizeOld
END

IF OBJECT_ID('ServerRolesOld','u') IS NOT NULL
BEGIN
DROP TABLE ServerRolesOld
END

IF OBJECT_ID('SQLLoginsOld','u') IS NOT NULL
BEGIN
DROP TABLE SQLLoginsOld
END

IF OBJECT_ID('tblWhoIsActiveOld','u') IS NOT NULL
BEGIN
DROP TABLE tblWhoIsActiveOld
END


COMMIT TRANSACTION
PRINT 'Old Tables Dropped Successfully'
END TRY

BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
RAISERROR('Table Drop Failed : %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH