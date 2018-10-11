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

IF EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name = 'DBA: WhoIsActive')
BEGIN
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA: WhoIsActive', @delete_unused_schedule=1
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA: WhoIsActive', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Lightweight Trace logging activity on database server', 
		@category_name=N'Database Maintenance',  
		@notify_email_operator_name=N'Database Administrators', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SP_WhoIsActive]    Script Date: 24/09/2018 08:01:22 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SP_WhoIsActive', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @retention int = 1, @destination_table varchar(500) = ''WhoIsActive'', @destination_database sysname = ''Tools'', 
      @schema varchar(max), @SQL nvarchar(4000), @parameters nvarchar(500), @exists bit;

SET @destination_table = @destination_database + ''.dbo.'' + @destination_table;

--create the logging table
IF OBJECT_ID(@destination_table) IS NULL
BEGIN;
  EXEC sp_WhoIsActive  @get_transaction_info = 1,  @get_outer_command = 1,  @get_plans = 1,  @return_schema = 1,  @schema = @schema OUTPUT;
  SET @schema = REPLACE(@schema, ''<table_name>;'', @destination_table);  
  EXEC(@schema);
END;

--create index on collection_time
SET @SQL = ''USE '' + QUOTENAME(@destination_database) + ''; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''''cx_collection_time'''') SET @exists = 0'';
SET @parameters = N''@destination_table varchar(500), @exists bit OUTPUT'';
EXEC sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;

IF @exists = 0
BEGIN;
  SET @SQL = ''CREATE CLUSTERED INDEX cx_collection_time ON '' + @destination_table + ''(collection_time ASC)'';
  EXEC (@SQL);
END;

--collect activity into logging table
EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,  @get_outer_command = 1,  @get_plans = 1,  @destination_table = @destination_table;  

--purge older data
SET @SQL = ''DELETE FROM '' + @destination_table + '' WHERE collection_time < DATEADD(day, -'' + CAST(@retention AS varchar(10)) + '', GETDATE());'';
EXEC (@SQL);', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'WhoIsActive', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20171020, 
		@active_end_date=99991231, 
		@active_start_time=0, 
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


