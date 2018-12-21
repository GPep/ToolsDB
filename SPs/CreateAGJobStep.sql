USE [Tools]
GO
/****** Object:  StoredProcedure [dbo].[CreateAGJobStep]    Script Date: 09/11/2018 14:08:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('CreateAGJobStep') IS NULL
  EXEC ('CREATE PROCEDURE CreateAGJobStep AS RETURN 0;')
GO


ALTER PROCEDURE [dbo].[CreateAGJobStep]
AS
BEGIN
SET NOCOUNT ON
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This stored Procedure updates all Non DBA jobs to be AG Aware by creating an extra step that checks whether the 
-- current Node is Primary and if so, it will run. If not, the job will stop. 
-- =============================================


SET NOCOUNT ON; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

TRUNCATE TABLE tools.dbo.AgentJobsToCopy


IF OBJECT_ID(N'tempdb.dbo.#data', N'U') IS NOT NULL 
BEGIN
DROP TABLE dbo.#data;
END

CREATE TABLE dbo.#data 
(id int IDENTITY PRIMARY KEY, 
name sysname);


-- Get all job names exclude jobs that already have a step named 'get_availability_group_role'
INSERT INTO #data (name)
SELECT DISTINCT j.name--, s.step_name 
FROM msdb.dbo.sysjobs j
    EXCEPT
SELECT DISTINCT j.name
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
WHERE s.step_name = N'get_availability_group_role';

-- Remove jobs that need to run on any replica (This will be mainly maintenance jobs that are already AG Aware)
DELETE FROM #data WHERE name LIKE 'DBA:%';



--Insert data and create table in Tools to use with PowerShell Script later
INSERT INTO Tools.dbo.AgentJobsToCopy (ID, Name)
SELECT ID, Name
FROM #data

DECLARE @command varchar(max), @min_id int, @max_id int, @job_name sysname, @availability_group sysname;
SELECT  @min_id = 1, @max_id = (SELECT MAX(d.id) FROM #data AS d);

SELECT @availability_group = (SELECT ag.name FROM sys.availability_groups ag);

-- If this is instance does not belong to HA exit here
IF @availability_group IS NULL 
BEGIN;
    PRINT 'This instance does not belong to AG. Terminating.';
    RETURN;
END;


DECLARE @debug bit = 0; --<------ print only 

-- Loop through the table and execute/print the command per each job
WHILE @min_id <= @max_id
BEGIN;
        SELECT @job_name = name FROM #data AS d WHERE d.id = @min_id;

        SELECT @command = 
        'BEGIN TRAN;
        DECLARE @ReturnCode INT;
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_name=''' + @job_name + ''', @step_name=N''get_availability_group_role'', 
                @step_id=1, 
                @cmdexec_success_code=0, 
                @on_success_action=3, 
                @on_success_step_id=0, 
                @on_fail_action=2, 
                @on_fail_step_id=0, 
                @retry_attempts=0, 
                @retry_interval=0, 
                @os_run_priority=0, @subsystem=N''TSQL'', 
                @command=
        N''-- Detect if this instance''''s role is a Primary Replica.
-- If this instance''''s role is NOT a Primary Replica stop the job so that it does not go on to the next job step
DECLARE @rc int; 
DECLARE @jobid uniqueidentifier
SET @jobid = $(ESCAPE_NONE(JOBID))
EXEC @rc = master.dbo.fn_hadr_group_is_primary N''''' + @availability_group + ''''';

IF @rc = 0
BEGIN;
    DECLARE @name sysname;
    SELECT  @name = (SELECT name FROM msdb.dbo.sysjobs WHERE job_id = @jobid);
    
    EXEC msdb.dbo.sp_stop_job @job_name = @name;
    PRINT ''''Stopped the job since this is not a Primary Replica'''';
END;'', 
        @database_name=N''Tools'',
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
BEGIN; 
    PRINT ''-- Rollback: ''''' + @job_name + ''''''' ROLLBACK TRAN; 
END;
ELSE COMMIT TRAN;' + CHAR(10);

        PRINT @command;
        IF @debug = 0 EXEC (@command);

    SELECT @min_id += 1;
END;

END
