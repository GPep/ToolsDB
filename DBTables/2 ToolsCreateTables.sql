-- Create Tables

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
PRINT  'Creating  Tables....'

IF OBJECT_ID('AgentJobsToCopy','u') IS NOT NULL
BEGIN 
DROP TABLE AgentJobsToCopy
END

CREATE TABLE [dbo].[AgentJobsToCopy]
(
[ID] INT NOT NULL,
[Name] NVarchar(128) NOT NULL
)


IF OBJECT_ID('AGFailoverDates','u') IS NOT NULL
BEGIN 
DROP TABLE AGFailoverDates
END

CREATE TABLE [dbo].[AGFailoverDates](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[PrimaryNode] [sql_variant] NOT NULL,
	[CurrentDate] [datetime] NULL
	CONSTRAINT df_AGFailoverDate DEFAULT GETDATE(),
	) ON [PRIMARY]

IF Object_ID('ClusterNode','u') IS NOT NULL
BEGIN
DROP TABLE clusternode
END

CREATE TABLE [dbo].[clusternode](
	[node] [sql_variant] NULL
) ON [PRIMARY]



IF OBJECT_ID('ClusterNodeNotification','u') IS NOT NULL
BEGIN 
DROP TABLE clusternodeNotification
END

CREATE TABLE [dbo].[Clusternodenotification](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Node] [sql_variant] NOT NULL,
	[CurrentDate] [datetime] NULL,
	) ON [PRIMARY]


IF OBJECT_ID('CommandLog','u') IS NOT NULL
BEGIN
DROP TABLE CommandLog
END

CREATE TABLE [dbo].[CommandLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] NULL,
	[SchemaName] [sysname] NULL,
	[ObjectName] [sysname] NULL,
	[ObjectType] [char](2) NULL,
	[IndexName] [sysname] NULL,
	[IndexType] [tinyint] NULL,
	[StatisticsName] [sysname] NULL,
	[PartitionNumber] [int] NULL,
	[ExtendedInfo] [xml] NULL,
	[Command] [nvarchar](max) NOT NULL,
	[CommandType] [nvarchar](60) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorMessage] [nvarchar](max) NULL,
 CONSTRAINT [PK_CommandLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


IF OBJECT_ID('CRJobs','U') IS NOT NULL
BEGIN
DROP TABLE CRJobs
END


CREATE TABLE [dbo].[CRjobs](
	[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[jobid] [varchar](max) NOT NULL,
	[Startdate] [datetime] NOT NULL,
	[Sessionid] [int] NOT NULL,
	[runrequestdate] [varchar](max) NOT NULL,
	[status] [int] NOT NULL
) ON [PRIMARY]


IF OBJECT_ID('DBGrowthRate','u') IS NOT NULL
BEGIN
DROP TABLE DBGrowthRate
END

CREATE TABLE [dbo].[DBGrowthRate](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[DBName] [varchar](100) NULL,
	[DBID] [int] NULL,
	[NumPages] [int] NULL,
	[DBSizeMB] [decimal](10, 2) NULL,
	[CheckDate] [datetime] NULL
	CONSTRAINT dfDBGrowthRate DEFAULT GETDATE()
) ON [PRIMARY]

IF OBJECT_ID('DBLogGrowthRate','u') IS NOT NULL
BEGIN
DROP TABLE DBLogGrowthRate
END

CREATE TABLE [dbo].[DBLogGrowthRate](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[DBName] [varchar](100) NOT NULL,
	[LogSizeMB] [decimal](10, 2) NOT NULL,
	[LogSpaceUsedPercent] [decimal](10, 2) NOT NULL,
	[Status] [int] NOT NULL,
	[CheckDate] [datetime] NOT NULL
	CONSTRAINT dfLogCheckDate DEFAULT GETDATE()
	) ON [PRIMARY]

IF OBJECT_ID('DiskSize','u') IS NOT NULL
BEGIN
DROP TABLE DiskSize 
END

CREATE TABLE DiskSize(
[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
[ServerName] NVARCHAR(30) NULL,
[DBName] NVARCHAR(100) NULL,
[Logical_File] NVARCHAR(20) NULL,
[DRIVE] NVarchar(5) NULL,
[Size_in_MB] INT,
[FreeSpace_In_MB] INT NULL, 
[FreePercentage] INT NULL,
CheckDate datetime NULL) ON [PRIMARY]

IF OBJECT_ID('ServerRoles','u') IS NOT NULL
BEGIN
DROP TABLE ServerRoles
END

CREATE TABLE [dbo].[ServerRoles](
	[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[ServerRole] [sysname] NOT NULL,
	[MemberName] [sysname] NOT NULL,
	[MemberSID] [varbinary](85) NULL
) ON [PRIMARY]

IF OBJECT_ID('SQLLogins','u') IS NOT NULL
BEGIN
DROP TABLE SQLLogins
END

CREATE TABLE [dbo].[SQLlogins](
	[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[RoleID] [int] NULL,
	[DBName] [varchar](500) NULL,
	[DbRole] [varchar](500) NULL,
	[MemberName] [varchar](500) NULL,
	[MemberSID] [uniqueidentifier] NULL
) ON [PRIMARY]

IF OBJECT_ID('WhoIsActive') IS  NOT  NULL
BEGIN
DROP TABLE WhoIsActive
END

CREATE TABLE [dbo].[WhoIsActive](
	[dd hh:mm:ss.mss] [varchar](8000) NULL,
	[session_id] [smallint] NOT NULL,
	[sql_text] [xml] NULL,
	[sql_command] [xml] NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[wait_info] [nvarchar](4000) NULL,
	[tran_log_writes] [nvarchar](4000) NULL,
	[CPU] [varchar](30) NULL,
	[tempdb_allocations] [varchar](30) NULL,
	[tempdb_current] [varchar](30) NULL,
	[blocking_session_id] [smallint] NULL,
	[reads] [varchar](30) NULL,
	[writes] [varchar](30) NULL,
	[physical_reads] [varchar](30) NULL,
	[query_plan] [xml] NULL,
	[used_memory] [varchar](30) NULL,
	[status] [varchar](30) NOT NULL,
	[tran_start_time] [datetime] NULL,
	[open_tran_count] [varchar](30) NULL,
	[percent_complete] [varchar](30) NULL,
	[host_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[start_time] [datetime] NOT NULL,
	[login_time] [datetime] NULL,
	[request_id] [int] NULL,
	[collection_time] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]



--Create Perfmon tables (based on TigerToolbox https://github.com/Microsoft/tigertoolbox/tree/master/SQL-Performance-Baseline)

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Sessionstatus]') AND type in (N'U'))
              BEGIN
                     DROP TABLE dbo.[Sessionstatus]
                     PRINT 'Table Sessionstatus exists on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100)) + ' dropping table'
              END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[Sessionstatus]') AND TYPE IN (N'U'))
BEGIN
CREATE TABLE [dbo].[Sessionstatus](
       [DateCaptured] [datetime] NULL,
       [dbname] [nvarchar](100) NULL,
       [status] [nvarchar](50) NULL,
       [waittype] [nvarchar](100) NULL,
       [waittime] [bigint] NULL,
       [sessioncnt] [int] NULL,
       [opentran] [int] NULL
) ON [PRIMARY]
PRINT 'Table Sessionstatus created on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100))
END



DECLARE @is2012 bit
       IF((SELECT CAST(REPLACE(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),2),'.','') AS int)) >= 11) --Check if version is higher that 2012
              SET @is2012 = 1
       ELSE 
              SET @is2012 = 0

       IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PerformanceCounterList]') AND type in (N'U'))
              BEGIN
                     DROP TABLE [PerformanceCounterList]
                     PRINT 'Table PerformanceCounterList exists on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100)) + ' dropping table'
              END

       IF NOT EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[PerformanceCounterList]') AND TYPE IN (N'U'))
              BEGIN
                     CREATE TABLE [PerformanceCounterList](
                           [counter_name] [VARCHAR](500) NOT NULL,
                           [is_captured_ind] [BIT] NOT NULL,
                     CONSTRAINT [PK_PerformanceCounterList] PRIMARY KEY CLUSTERED 
                     (
                           [counter_name] ASC
                     )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
                     ) ON [PRIMARY]
                     
                     ALTER TABLE [PerformanceCounterList] ADD  CONSTRAINT [DF_PerformanceCounterList_is_captured_ind]  DEFAULT ((1)) FOR [is_captured_ind]
                     
                     PRINT 'Table PerformanceCounterList created on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100))
              END

       IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PerformanceCounter]') AND type in (N'U'))
              BEGIN
                     DROP TABLE [PerformanceCounter]
                     PRINT 'Table PerformanceCounter exists on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100)) + ' dropping table'
              END

       IF NOT EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[PerformanceCounter]') AND TYPE IN (N'U'))
              BEGIN
                     CREATE TABLE [PerformanceCounter](
                           [CounterName] [VARCHAR](250) NOT NULL,
                           [CounterValue] [VARCHAR](250) NOT NULL,
                           [DateSampled] [DATETIME] NOT NULL,
                     CONSTRAINT [PK_PerformanceCounter] PRIMARY KEY CLUSTERED 
                     (
                           [CounterName] ASC,
                           [DateSampled] ASC
                     )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
                     ) ON [PRIMARY]
                     
                     PRINT 'Table PerformanceCounter created on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100))
              END

       IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[vPerformanceCounter]'))
              BEGIN
                     DROP VIEW [vPerformanceCounter]
                     PRINT 'View vPerformanceCounter exists on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100)) + ' dropping view'
              END

       IF (@is2012 = 0)
              BEGIN
                     IF NOT EXISTS (SELECT * FROM sys.views WHERE OBJECT_ID = OBJECT_ID(N'[vPerformanceCounter]'))
                           BEGIN
                                  EXEC dbo.sp_executesql @statement = N'
                                  CREATE VIEW [vPerformanceCounter]
                                  AS
                                  SELECT * FROM
                                  (SELECT CounterName, CounterValue, DateSampled
                                  FROM PerformanceCounter) AS T1
                                  PIVOT
                                  (
                                  MAX(CounterValue)
                                  FOR CounterName IN ([logicaldisk(_total)\avg. disk queue length],
                                                                     [logicaldisk(_total)\avg. disk sec/read],
                                                                     [logicaldisk(_total)\avg. disk sec/transfer],
                                                                     [logicaldisk(_total)\avg. disk sec/write],
                                                                     [logicaldisk(_total)\current disk queue length],
                                                                     [memory\available mbytes],
                                                                     [paging file(_total)\% usage],
                                                                     [paging file(_total)\% usage peak],
                                                                     [processor(_total)\% privileged time],
                                                                     [processor(_total)\% processor time],
                                                                     [process(sqlservr)\% privileged time],
                                                                     [process(sqlservr)\% processor time],
                                                                     [sql statistics\batch requests/sec],
                                                                     [sql statistics\sql compilations/sec],
                                                                     [sql statistics\sql re-compilations/sec],
                                                                     [general statistics\user connections],
                                                                     [buffer manager\page life expectancy],
                                                                     [buffer manager\buffer cache hit ratio],
                                                                     [memory manager\target server memory (kb)],
                                                                     [memory manager\total server memory (kb)],
                                                                     [buffer manager\checkpoint pages/sec],
                                                                     [buffer manager\free pages],
                                                                     [buffer manager\lazy writes/sec],
                                                                     [transactions\free space in tempdb (kb)])
                                  ) AS PT;
                                  '
                                  PRINT 'View vPerformanceCounter created on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100))
                           END 
                     ELSE PRINT 'View vPerformanceCounter already exists on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100))
              END
       ELSE
              BEGIN
                     IF NOT EXISTS (SELECT * FROM sys.views WHERE OBJECT_ID = OBJECT_ID(N'[vPerformanceCounter]'))
                           BEGIN
                                  EXEC dbo.sp_executesql @statement = N'
                                  CREATE VIEW [vPerformanceCounter]
                                  AS
                                  SELECT * FROM
                                  (SELECT CounterName, CounterValue, DateSampled
                                  FROM PerformanceCounter) AS T1
                                  PIVOT
                                  (
                                  MAX(CounterValue)
                                  FOR CounterName IN ([logicaldisk(_total)\avg. disk queue length],
                                                                     [logicaldisk(_total)\avg. disk sec/read],
                                                                    [logicaldisk(_total)\avg. disk sec/transfer],
                                                                     [logicaldisk(_total)\avg. disk sec/write],
                                                                     [logicaldisk(_total)\current disk queue length],
                                                                     [memory\available mbytes],
                                                                     [paging file(_total)\% usage],
                                                                     [paging file(_total)\% usage peak],
                                                                     [processor(_total)\% privileged time],
                                                                     [processor(_total)\% processor time],
                                                                     [process(sqlservr)\% privileged time],
                                                                     [process(sqlservr)\% processor time],
                                                                     [sql statistics\batch requests/sec],
                                                                     [sql statistics\sql compilations/sec],
                                                                     [sql statistics\sql re-compilations/sec],
                                                                     [general statistics\user connections],
                                                                     [buffer manager\page life expectancy],
                                                                     [buffer manager\buffer cache hit ratio],
                                                                     [memory manager\target server memory (kb)],
                                                                     [memory manager\total server memory (kb)],
                                                                     [buffer manager\checkpoint pages/sec],
                                                                     [buffer manager\lazy writes/sec],
                                                                     [transactions\free space in tempdb (kb)])
                                  ) AS PT;
                                  '
                                  PRINT 'View vPerformanceCounter created on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100))
                           END 
                     ELSE PRINT 'View vPerformanceCounter already exists on server ' + CAST(SERVERPROPERTY('ServerName') AS VARCHAR(100))
              END

       SET NOCOUNT ON

       DECLARE @perfStr VARCHAR(100)
       DECLARE @instStr VARCHAR(100)

       SELECT @instStr = @@SERVICENAME
       --SET @instStr = 'NI1'

       IF(@instStr = 'MSSQLSERVER')
              SET @perfStr = '\SQLServer'
       ELSE 
              SET @perfStr = '\MSSQL$' + @instStr

       TRUNCATE TABLE PerformanceCounterList
       PRINT 'Truncated table PerformanceCounterList'

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Memory\Pages/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Memory\Pages Input/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Memory\Available MBytes',1)
              
       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Processor(_Total)\% Processor Time',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Processor(_Total)\% Privileged Time',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Process(sqlservr)\% Privileged Time',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Process(sqlservr)\% Processor Time',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Paging File(_Total)\% Usage',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Paging File(_Total)\% Usage Peak',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\PhysicalDisk(_Total)\Avg. Disk sec/Read',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\PhysicalDisk(_Total)\Avg. Disk sec/Write',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\PhysicalDisk(_Total)\Disk Reads/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\PhysicalDisk(_Total)\Disk Writes/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\System\Processor Queue Length',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\System\Context Switches/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Page life expectancy',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Buffer cache hit ratio',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Checkpoint Pages/Sec',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Lazy Writes/Sec',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Page Reads/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Page Writes/Sec',0)

       IF (@is2012 = 0)
              INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
              VALUES        (@perfStr + ':Buffer Manager\Free Pages',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Page Lookups/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Free List Stalls/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Readahead pages/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Database Pages',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Target Pages',0)
                     
       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Total Pages',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        (@perfStr + ':Buffer Manager\Stolen Pages',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':General Statistics\User Connections',1)
                     
       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':General Statistics\Processes blocked',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':General Statistics\Logins/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':General Statistics\Logouts/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Memory Manager\Memory Grants Pending',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Memory Manager\Total Server Memory (KB)',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Memory Manager\Target Server Memory (KB)',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Memory Manager\Granted Workspace Memory (KB)',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Memory Manager\Maximum Workspace Memory (KB)',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Memory Manager\Memory Grants Outstanding',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':SQL Statistics\Batch Requests/sec',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':SQL Statistics\SQL Compilations/sec',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':SQL Statistics\SQL Re-Compilations/sec',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':SQL Statistics\Auto-Param Attempts/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Locks(_Total)\Lock Waits/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Locks(_Total)\Lock Requests/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Locks(_Total)\Lock Timeouts/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Locks(_Total)\Number of Deadlocks/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Locks(_Total)\Lock Wait Time (ms)',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Locks(_Total)\Average Wait Time (ms)',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Latches\Total Latch Wait Time (ms)',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Latches\Latch Waits/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Latches\Average Latch Wait Time (ms)',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Access Methods\Forwarded Records/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Access Methods\Full Scans/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Access Methods\Page Splits/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Access Methods\Index Searches/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Access Methods\Workfiles Created/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Access Methods\Worktables Created/Sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Access Methods\Table Lock Escalations/sec',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Cursor Manager by Type(_Total)\Active cursors',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Transactions\Longest Transaction Running Time',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Transactions\Free Space in tempdb (KB)',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES (@perfStr + ':Transactions\Version Store Size (KB)',0)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\LogicalDisk(*)\Avg. Disk Queue Length',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\LogicalDisk(*)\Avg. Disk sec/Read',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\LogicalDisk(*)\Avg. Disk sec/Transfer',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\LogicalDisk(*)\Avg. Disk sec/Write',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\LogicalDisk(*)\Current Disk Queue Length',1)

       INSERT INTO PerformanceCounterList(counter_name,is_captured_ind)
       VALUES        ('\Paging File(*)\*',1)

       PRINT 'Inserts to table PerformanceCounterList completed'



COMMIT TRANSACTION
PRINT 'Database Tables Created Successfully'
END TRY

BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
RAISERROR('Table Creation Failed : %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH

