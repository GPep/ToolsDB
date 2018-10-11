USE [msdb]
GO


BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Database Maintenance]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Database Maintenance]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

IF EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name = 'DBA: Differential Backup')
BEGIN
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA: Differential Backup', @delete_unused_schedule=1
END

DECLARE @outputfile NVARCHAR(200)
SET @outputfile = N'\\' + cast(SERVERPROPERTY('MachineName') as nvarchar) + N'\DBA\LOGS\DiffBackup.txt' --This can be changed but is where by default I save all my output files.


DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA: Differential Backup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Differential Backup taken every night except Friday Source: http://ola.hallengren.com', 
		@category_name=N'[Database Maintenance]', 
		@owner_login_name=N'C4rb0n', 
		@notify_email_operator_name=N'Database Administrators', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Diff Backup]    Script Date: 24/09/2018 07:41:02 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Diff Backup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE dbo.DatabaseBackup
@Databases = ''ALL_DATABASES'',
@Directory = ''\\BHF-Storage02\BackupShare\POC_Listener'',
@BackupType = ''DIFF'',
@Verify = ''Y'',
@LogToTable = ''Y'',
@CleanUPTime = 24', 
		@database_name=N'Tools', 
		@output_file_name=@outputfile, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'each night except saturday 0400', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=63, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180316, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


