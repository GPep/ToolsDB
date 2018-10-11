--Transfer Data from old tables to new tables

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
PRINT  'Updating Tables....'



--Insert Data to new tables

INSERT INTO clusterNode(node)
SELECT node
FROM 
ClusterNodeOld

INSERT INTO ClusterNodeNotification(Node, CurrentDate)
SELECT Node, CurrentDate
FROM ClusterNodeNotificationOld

INSERT INTO CRJobs (jobId, StartDate, sessionid, RunRequestDate, Status)
SELECT jobid, startdate, sessionid, runrequestdate, status
FROM CRJobsOld


INSERT INTO DBGrowthRate(DBName, DBID, NumPages, DBSizeMB, CheckDate)
SELECT DBName, DBID, NumPages, DBSizeMB, CheckDate
FROM DBGrowthRateOld

INSERT INTO DiskSize(ServerName, DBName, Logical_file, Drive, Size_in_MB,
FreeSpace_in_MB, FreePercentage, CheckDate)
SELECT Server, DB_Name, Logical_File, Drive, Size_in_mb, FreeSpace_in_MB,
FreePercentage, Date
FROM Disk_SizeOld


INSERT INTO ServerRoles(ServerRole, MemberName, MemberSID)
SELECT ServerRole, MemberName, MemberSID
FROM ServerRolesOld

INSERT INTO SQLLogins(RoleID, DBName, DBRole, MemberName, MemberSID)
SELECT RoleID, DBNAme, DBRole, MemberName, MemberSID
FROM SQLLoginsOld

INSERT INTO WhoIsActive
SELECT * FROM tblWhoIsActiveOld



COMMIT TRANSACTION
PRINT 'Database Tables updated Successfully'
END TRY

BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
RAISERROR('Table Update Failed : %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH



