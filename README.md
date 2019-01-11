# ToolsDB
Tools Monitoring Database 

Introduction 

The Tools database can be used for maintaining, monitoring, health checking and baselining your SQL Server and databases. It is a free tool and uses renowned industry standard scripts and stored procedures from Brent Ozar, Ola Hallengreen, Paul Randall and the Tiger Team as well scripts written by myself. 

This document will provide details on the pre-requisites and installation instructions as well as detailed information on how to use the database and its tools to monitor and improve your server and database health as well as providing detailed information to be used for performance baselines and business intelligence. 

 

Pre-Requisites 

This database has been tested on SQL Server 2008R2/2012/2014/2016. I strongly advise that you run the latest version of SQL Server and install the latest available Service Packs and Cumulative Updates. 

The monitoring database will not work properly and the installation will fail if the following pre-requisites are not met.  

These pre-requisites should already exist as part of the standard SQL Build best practices. But this should be checked beforehand. 

The following script (normally run as part of all the standard SQL Server Builds) can be used here to set the pre-requisites: 

The following pre-requisites must be applied before installing the database. 

Database Mail must be enabled and must use the server name as its profile name 

A UNC path for your log files must be set up as follows which your service and agent accounts must have read/write access to: 

 

\\ServerName\DBA\LOGS\   

This will be used for your output of your database maintenance scripts.  

An Agent Operator must be set up with a valid email. 

The Failsafe operator must  use the  name ‘Database Administrators’ 

A Valid Backup Location must be specified. This will be used automatically by the backup jobs. If you are not using native backups, these jobs can be disabled. 

Full backups are configured to take place once a week with Differentials taking place every other night. Transaction log backups are taken every 30 minutes. You will need to amend these if this doesn’t suit your requirements.   If still using Veeam and  DPM then these backup jobs should be disabled upon creation. 

All maintenance jobs are scheduled to take place BEFORE the differential and Full Backups as per best practice. 

Although this database can be used to monitor all servers in an AlwaysOn Availability group, it cannot yet live in an availability group as it is monitoring and storing information on each server’s health. By using linked servers, it is possible for it to live in an availability group and write back information from the secondary’s to the Primary Node but it currently doesn’t do this automatically. I hope to add this enhancement in a future release. 

XP_CMDShell must be enabled 

Installation Instructions 

 

PowerShell 

The Latest version of the tools database is kept here or here (GitHub) 

To install the database, you extract the Tools Directory from the zip file and place this either locally or accessible from a UNC path, or on the server you wish to install it on.  

Once the folder is extracted you run the PowerShell script ‘Create-ToolsDB.ps1’ from the ‘ps’ directory from the PowerShell ISE. You must use an account that is sysadmin on the SQL Server.  

To run the PowerShell script you must complete the following. 

Open a PowerShell window as an administrator and navigate to the folder where the PowerShell script is located: 

 

Next type ‘.\Create-ToolsDB.ps1’ so that the functions within the script can be run from the command line. 

 

You must - run the PowerShell command ‘Create-ToolsDB’ as follows: 

Create-toolsDB  -ComputerName ‘EnterComputerName’ –Database ‘Tools’ –Source ‘Tools Folder location’ –SA ‘SA account’ 

Create-ToolsDB -ComputerName 'DV-SQLCLN-01' -Database 'Tools' -Source 'C:\Users\pepperg\Documents\SQL Server Management Studio\Tools' -sa 'C4rb0n'  

 

-ComputerName - the name of the server instance you wish to install the Tools database on. 

-Database - the name you wish to call the database. By default, this Tools but you can call it something different if you so wish. If you are calling the database Tools then there is no reason to enter this parameter 

-Source - The location of the Tools folder you extracted 

-sa - The name of the sa account you wish to be owner of the database and associated agent jobs. By default this is ‘C4rb0n’ but if you have a different SA account you wish to use then this can be entered here. If your account is ‘C4rb0n’ then there  is no reason to enter this parameter as it is not mandatory. 

When you run the script, you will be given several options before performing the install. If the database already exists, you will be asked if you wish to recreate the database. If you answer yes, then it will overwrite you database. If you answer no, it will ask you if you want to update to the latest versions of the Stored Procedures/Alerts/Jobs.  If this is a fresh install then the database will simply be created once you have confirmed this is what you want to do and providing the server name and SA account is valid.  

If the database already exists then please take a backup before installing/re-installing 

Once the database is installed you may need to amend the agent jobs to the times and configurations you require if you do not wish to use the defaults (the defaults will be explained in the Agent Jobs section of this document). 

Silent Install 

There is also the option to run a silent install. This option is designed to be used with unattended installations as part of a new SQL build. The silent install has no user interaction in the script. The database will be created automatically. This means if the database already exists, it will automatically be overwritten.  

The file is called ‘create-toolsdb-silent.ps1’.  You run it using exactly the same parameters as the other PowerShell script described above. 

LogFile 

During the install, a log file is created in the Tools folder called ‘log’. This can be used for troubleshooting in case the install process fails or confirmation that the install succeeded. 

 

Database Schema and Design 

Tables associated with third-party functionality (Perf Mon counters, WhoIsActive and Ola Halengren’s backup and maintenance scripts) are created as guided by each resource.  All other tables follow basic design principle. 

  

 

Tables 

Below is the list of tables within the Tools Database. By default there are no non-clustered indexes but these may be added to your tables to speed up data retrieval over time. However, the idea is that the data from these tables should be regularly exported to separate BI reporting database housing information on your whole SQL estate. However, if you only have a small estate or you do not wish to use reporting services, you can report direct from this database. 

AGFailoverDates – This lists the times and dates and Availability Group failover occurred. This is populated by the Agent Job ‘AGFailover’ which runs every time a failover event occurs. This table is only in use if your server is part of a AlwaysOn Availability Group. 

ClusterNode – The current ClusterNode for your WSFC is recorded here. This table is only in use if your server is part of a Windows Server Failover Cluster configuration using shared storage. 

ClusterNodeNotification – This lists the time and date a cluster failover occurred. This is populated by the Agent Job ‘Cluster Change Notification’.  

CommandLog – This holds historical information for all your backup and maintenance commands (backup commands, deletion of old backups, statistics updates, index rebuilds/reorganisations). This table is installed as part of the Ola Halengren backup and maintenance jobs which this database uses extensively.  

CRJobs – This is a holding table for any Agent Jobs that have run for longer than 2 hours (configurable). It is re-populated every time the corresponding Agent Job is run.  

DBLogGrowthRate – this records historical information on your transaction log growth. It will populate a row every time the corresponding agent job is run or if an alert for log growth is triggered. 

DBGrowthRate - this records historical information on your database file growth. It will populate a row every time the corresponding agent job is run or if an alert for log growth is triggered. 

DiskSize – This records historical information on all your disk drives on your database server. A line is created every time the corresponding Stored Procedure or Agent job is run. 

PerformanceCounter – This holds historical information on your Performance Counters depending on how often you run the corresponding collection job and how long you wish to retain the data. By default the data is kept for 180 days and is run every 5 minutes. The idea is that this data would be exported to another BI database used for reporting purposes.  

PerformanceCounterList – This table holds a list of the performance counters it is possible to capture and  has an indicator to confirm whether it is captured or not. 

SessionStatus – This table holds historical information regarding all sessions running on the database when the data was collected. By default this job runs every minute and  keeps data for 180 days. This can be configured via the corresponding Agent Job. 

ServerRoles – This holds a list of all current servers and members of the server. This data can be used in the event of a server migration or a DR event which requires the data to be migrated to another server. 

SQLLogins – This holds a list of all current SQL Logins and their corresponding database users and roles. Again, this can be used for server migrations or a DR Event which requires the data to be migrated to another server. 

WhoIsActive – This table holds historical information on the WhoISActive stored procedure which can be run ad-hoc but it is also set to populate a table every 5 minutes. This data is kept for 24 hours but this can modified via the corresponding Agent Job. 

Functionality 

What follows is an explanation for all the stored procedures and functions included in this database. 

Stored Procedures 

AGFailover - This stored Procedure is designed to run when a AG Failover occurs so we can record the dates in the AGFailover table. 

AGHealthCheck – This stored procedure provides a report on the current health of an availability group and an email is sent to the operators. 

CheckClusterNode – This stored procedure checks to see which cluster node is currently active if the server is part of a cluster. 

CheckDiskSpace – This stored procedure provides a report on the current disk space available for each drive on the SQL server. If any drive has less than 10% (this is the default but can be changed) then an email is sent to the database administrators 

CheckLongRunningJobs – This stored procedure checks for long running jobs and emails the database administrators if a job has run over the default time. The default is 2 hours but this can be changed using the @time parameter (default is 120 minutes or 2 hours) 

CheckMirrorStatus – This stored procedure provides a report on the current state of a mirroring session (if any database is participating in a mirroring session). This runs every morning and also when a mirroring alert occurs. 

ClearPerfCtrHistory – This clears all information out of the PerformanceCounter Table if it is older than the configured time (by default this is 180 days). 

CommandExecute – Part of Ola Halengren’s backup and maintenance jobs. This stored procedure records information in the CommandLog table whenever any of the backup or maintenance jobs are run.  More information can be found here 

CopyLogins – This stored procedure copy all current SQL Logins to the corresponding table SQLLogins. 

DatabaseBackup - Part of Ola Halengren’s backup and maintenance jobs.  This is highly configurable and industry standard. More information can be found here 

DatabaseIntegrityCheck - Part of Ola Halengren’s backup and maintenance jobs.  This is highly configurable and industry standard. More information can be found here 

DBGrowth – This stored procedure records information on current database file size in the DBGrowthRate table. 

DBLogGrowth - This stored procedure records information on current database file size in the DBLogGrowthRate table. 

GetPerfCountersFromPowerShell – This was written by Adrian Sullivan. It gathers and records all performance Counter information in the PerformanceCounter table. 

IndexOptimize - Part of Ola Halengren’s backup and maintenance jobs.  This is highly configurable and industry standard. More information can be found here 

LoadSessionStatus – records all current sessions in the SessionStatus table. 

LoginDetails – records all current logins and their database roles in the  SQLLogins table  

ServerLogin – records all current logins and  their server roles in the ServerRoles table. 

SQLAgentBootUpAlert – This produces an email to the operators/database administrators every time the SQL Agent is restarted. 

SSMS_Usage – This provides an email report on anyone currently using SSMS on this specific server. 

Sp_CurrentLocks – Provides a list of all current locks in the database. 

SP_currentQueries – All queries currently running on the server. 

Sp_currentWaits – current waiting tasks 

Sp_DBBufferUsage – Provides a report on all Database Buffer usage (system memory cache) in MB and %. The primary purpose of the SQL buffer pool is to reduce database file I/O and improve the response time for data retrieval. 

Sp_findblockingprocesses – Provides a report on all current blocking processes. 

Sp_IOLatency – Provides a report on all current IO usage and latency per database file 

Sp_memoryUsage – Gives a current report on memory usage and whether there is a potential problem. 

Sp_objBufferUsage – Gives a list of all objects in a databases and their current buffer usage (system memory cache). You must enter a database name as a parameter to run this stored procedure. The primary purpose of the SQL buffer pool is to reduce database file I/O and improve the response time for data retrieval. 

 

Sp_spStats – Provides a list of all statistics for stored procedures, listing the most expensive Stored Procedures first. 

Sp_Top10Queries – Provides the Top 10 most expensive queries on your server. 

Sp_waitStatistics – Provides a list of all your most expensive waits. This stored procedure is based on Paul S Randall’s query. More information is available here. 

Sp_whoisActive – Adam Machanic’s industry renowned stored procedure which provides an in-depth list of all active sessions on a database server. More information is available here. 

Sp_blitz – Brent Ozar’s script used to provide vital information on your server as well as a health check. More information is available here. 

Sp_blitzcache – Brent Ozar’s script which provides a wealth of information on your worst performing queries. More information is available here. 

Sp_blitzFirst – Brent Ozar’s script which helps you troubleshoot slow running SQL Server Servers by automatically checking all blocks, locks, waits, performance counters and SQL agent jobs. More information is available here. 

Sp_blitzindex – Brent Ozar’s script which provides extensive information about all your indexes (unused, recommendations, duplicates etc). More information is available here. 

Functions 

Fn_hadr_group_is_primary – Provides information on your current primary node in an availability group. 

Fn_randomString – this creates a random string which can be used for data scrambling purposes or mock data.  

SQL Agent 

 

Jobs 

All Agent jobs are prefixed with ‘DBA: ‘ so they can be easily identified in your SQL Agent Jobs list. I have provided the default settings and times of the Agent Jobs where appropriate. As mentioned, these are default times and are used as a guide. Depending on the size and the activity on your server, you may need to amend these once they are set up. 

DBA: AGFailover – This job is only created if your server is part of an Availability Group. It basically runs the AGFailover Stored Procedure and records the failover events in the corresponding table for historical information. This job only runs when an SQL Alert ‘AlwaysOn – Role Change’ is triggered. It  

DBA: Availability Group Health Check – This provides an email report of the current status of your availability group. It is only installed if your server is participating in an Availability Group. It runs every day at 7:55am. 

DBA: Check Drive Space for SQL instance – Runs the CheckDiskSpace stored procedure at 07:50 every morning. 

DBA: Check Long Running Jobs – Runs the Stored Procedure ‘CheckLongRunningJobs’ every 2 hours. It reports on any job running for longer than 2 hours or whatever minutes you set with the @time parameter. 

DBA: Check Mirror status – This produces an email report of the current status of any mirroring sessions. It is currently only set to trigger whenever a mirroring alert is triggered but this can be set to run every morning if you prefer. This job is only set up if any of your databases participate in a mirroring session. 

DBA: Cluster Change Notification - This job is triggered by an SQL Services reboot and it checks to see if this cluster node has changed. If it has, it sends the database administrators an email. 

DBA: CommandLog Cleanup - This runs on the first day of every month and cleans up any old commands from the commandLog table that are older than 180 days. 

DBA: Database Growth - This runs every evening at 19:15 and records the current database file sizes in the DBGrowthRate table. It is also run whenever an alert for autogrowth is triggered. 

DBA: DBCC Check – System_Databases – This runs DBCC CheckDBs for all the system databases using Ola Halengren’s script. By default it runs at 01:00am every night.   

DBA: DBCC Check – User_Databases - This runs DBCC CheckDBs for all the user databases using Ola Halengren’s script. By default it runs at 01:30am every night.   

DBA: Delete Backup History – This simply delete all old backup history older than 2 months from the MSDB database.  It occurs every night at 00:10. 

DBA: Differential Backup – By default this runs every night except Saturday at 04:00. You can disable this if you are not using differential backups but you will need to amend the full backup job to run every night if you do. This job is highly configurable. More information is available here. 

DBA: Full Backup – By default this runs on Saturday night at 04:00. If you wish this to run nightly, you can change this. The job is AlwaysON AG aware and is highly configurable. More information is available here. 

DBA: IndexOptimize – System Databases – This runs every night at 20:00. It is highly configurable. More information is available here. 

DBA: IndexOptimize – User Database- This runs every night at 21:00. It is highly configurable. More information is available here. 

DBA: Load Session Status per Minute – This loads session information into the SessionStatus table. It runs every minute but this can be changed. 

DBA: Log Growth - This runs every evening at 19:20 and records the current database transaction log sizes in the DBGrowthRate table. It is also run whenever an alert for log autogrowth is triggered. 

DBA: PerfMon Counter Collection - This records performance counter information in the PerformanceCounter table. By default it runs every 5 minutes. 

DBA: Recycle Server Error log – This recycles the SQL server error logs at midnight every night. 

DBA: Server Login Accounts – Runs the ServerLogin stored procedure every night at 18:30. 

DBA: SQL Service Agent Boot up Alert – This runs every time the Agent is restarted and sends an email to the Database Administrators. 

DBA: SSMS Usage – This runs the SSMS_Usage stored procedure every hour and produces a report to the database administrators  

DBA: sysPolicy_purge_history – this is the default purge history agent job that purges historical information from the MSDB database. As part of my best practices, I rename this job  before setting up a server so this may be irrelevant if you have not pre-configured this job to change name. More information on this job is available here. 

DBA: Transaction Log Backups – by default this runs every 30 minutes. It is highly configurable. More information is available here. 

DBA: Update Statistics – By default this runs every night at 23:00. It is highly configurable. More information is available here. 

DBA: User Login Detail Accounts - This is to run a stored proceedure called LoginDetails in the tools DB location every night at 18:00. This is the DR process for making sure logins are captured and stored.  

DBA: WhoIsActive – This runs every 5 minutes and records historical activity for 24 hours using the sp_whoisactive stored procedure. 

 

SQL Alerts 

AlwaysOn – Data Movement Suspended – This alerts the operators/Database Administrators whenever data movement is suspended between any nodes. 

AlwaysOn – Role Change – This alerts the operators/database administrators whenever the role of a node in an AlwaysOn Availability Group changes. 

DBA: Database Auto Growth Event – This will trigger an alert for any autogrowth event and record the new file size in the DBgrowthRate table. 

DBA: Log Auto Growth Event – As above it will trigger an alert for log autogrowth and record the log sizes in the DBLogGrowthRate table. 

Error Number 823 - The 823 error message usually indicates that there is a problem with underlying storage system or the hardware or a driver that is in the path of the I/O request. You can encounter this error when there are inconsistencies in the file system or if the database file is damaged 

Error Number 824 - The 824 error message usually indicates that there is a problem with underlying storage system or the hardware or a driver that is in the path of the I/O request. You can encounter this error when there are inconsistencies in the file system or if the database file is damaged 

Error Number 825 – Another I/O error alert but unlike 823 and 824, it will still create an alert if the I/O succeeds on once of its 4 retries as this is still an indicator that something has gone wrong and should be investigated as soon as possible.  

Severity 017 – Insufficient Resources - Indicates that the statement caused SQL Server to run out of resources (such as memory, locks, or disk space for the database) or to exceed some limit set by the system administrator. 

Severity 018 – Nonfatal Internal Error - Indicates a problem in the Database Engine software, but the statement completes execution, and the connection to the instance of the Database Engine is maintained. The system administrator should be informed every time a message with a severity level of 18 occurs. 

Severity 019 – Fatal Error in Resource - Indicates that a nonconfigurable Database Engine limit has been exceeded and the current batch process has been terminated. Error messages with a severity level of 19 or higher stop the execution of the current batch. Severity level 19 errors are rare and must be corrected by the system administrator or your primary support provider. Contact your system administrator when a message with a severity level 19 is raised. Error messages with a severity level from 19 through 25 are written to the error log. 

Severity 020 – Fatal error In Current Process - Indicates that a statement has encountered a problem. Because the problem has affected only the current task, it is unlikely that the database itself has been damaged. 

Severity 021 – Fatal Error in Database Process - Indicates that a problem has been encountered that affects all tasks in the current database, but it is unlikely that the database itself has been damaged. 

Severity 022 – Fatal Error: Table Integrity Suspect - Indicates that the table or index specified in the message has been damaged by a software or hardware problem. 
 
Severity level 22 errors occur rarely. If one occurs, run DBCC CHECKDB to determine whether other objects in the database are also damaged. The problem might be in the buffer cache only and not on the disk itself. If so, restarting the instance of the Database Engine corrects the problem. To continue working, you must reconnect to the instance of the Database Engine; otherwise, use DBCC to repair the problem. In some cases, you may have to restore the database. 
 
If restarting the instance of the Database Engine does not correct the problem, then the problem is on the disk. Sometimes destroying the object specified in the error message can solve the problem. For example, if the message reports that the instance of the Database Engine has found a row with a length of 0 in a nonclustered index, delete the index and rebuild it. 

Severity 023 – Database Integrity Suspect. - Indicates that the integrity of the entire database is in question because of a hardware or software problem. 

Severity level 23 errors occur rarely. If one occurs, run DBCC CHECKDB to determine the extent of the damage. The problem might be in the cache only and not on the disk itself. If so, restarting the instance of the Database Engine corrects the problem. To continue working, you must reconnect to the instance of the Database Engine; otherwise, use DBCC to repair the problem. In some cases, you may have to restore the database. 

Severity 024 – Fatal Error: Hardware Error - Indicates a media failure. The system administrator may have to restore the database. You may also have to call your hardware vendor. 

Severity 025 – Fatal Error – This is a catch-all for miscellaneous fatal errors but has generally been associated with failed upgrades. 

Post-Install Best Practices and Testing 

The database uses the FULL recovery model by default. If you do not wish to have Point in Time recovery then this can be changed to SIMPLE. 

The database owner is set to the SA account that you provided during the setup. 

The owner of the Agent Jobs is also set to the SA account that you provided during the set up. 

If there are any Agent Jobs you are not planning to use (Native Backups, maintenance or performance counter collection) then these jobs should be disabled immediately.  

If you do not require differential backups you should disable the Differential Backup Job. 

If you are planning to use the native backups then a FULL backup should be run immediately to prevent the log and differential backup jobs failing.  

Test ALL SQL Jobs are working correctly and change the default schedules to times that suit you if required. 

If you receive a lot of data/log file growth rate alerts when first installed then your databases may require new autogrowth settings.  I would also recommend changing the model file size and autogrowth settings to a higher setting. 

You may need to amend the notification delays with some of the alerts. 

High Availability 

All stored procedures and jobs are aware of high availability technology in use on the server (mirroring, clusters, AlwaysOn AGs) and are configured at the point of the Tools database installation. If high availability functionality is configured at a later date, you will need to run the tools installation again and perform an upgrade of the database. This will install the DBA jobs required for HA monitoring and reporting. 

Future Releases 

A future release will allow the database to be in an availability group. Currently you could configure it to run in here but any information about secondary nodes would need to be inserted into the Primary Node of the tools database which could be provided using a Linked Server connection to the Primary from each secondary. This is currently not available by default therefore it is advisable not to add this database to an AG.  

Database Mirroring is now deprecated so there will be no future enhancements on database mirroring.  

The functionality of this database is designed so that the historical information can be used in SSRS or be exported to a centralised BI version of the database so you can monitor and report on your whole SQL Estate. A future release would include default functionality and documentation on how to do this. 

 

Resources 

 

Sources 

All third party sources for Stored Procedures are regularly updated. I will regularly update my own central install with the latest versions of each script but it is strongly advised that you check yourself and update the scripts regularly.  

Ola Halengren – Backup and Maintenance Scripts - https://ola.hallengren.com/  

Brent Ozar – First Responder (all blitz scripts)  https://www.brentozar.com/first-aid/  

Paul S Randall – https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/  

Tiger Tool Box – SQL Performance Baselines - https://github.com/Microsoft/tigertoolbox/tree/master/SQL-Performance-Baseline  

GitHub and Issues Log 

The current stable release of the database will be available for download from here 

https://github.com/GPep/ToolsDB 

Please report any issues here: 

https://github.com/GPep/ToolsDB/issues 

 

 
