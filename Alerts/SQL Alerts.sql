-- ** Add and configure all SQL alerts ** 
--All emails are sent to the failsafe operator email address
USE [msdb]
GO

DECLARE @Operator NVarchar(200)
SET @Operator = (SELECT name from msdb.dbo.sysoperators where enabled = 1)

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'DBA: DATABASE Auto Growth Event')
BEGIN
EXEC msdb.dbo.sp_add_alert @name=N'DBA: DATABASE Auto Growth Event', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=15, 
		@include_event_description_in=1, 
		@notification_message=N'DBA: DATABASE Auto Growth Event', 
		@category_name=N'[Uncategorized]', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'select * from DATA_FILE_AUTO_GROW', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=N'DBA: DATABASE AUTO GROWTH Event', @operator_name=@Operator, @notification_method = 7;
EXECUTE msdb.dbo.sp_update_alert @name = 'DBA: DATABASE Auto Growth Event', @job_Name = 'DBA: Autogrowth Email Alert'
END



IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'DBA: LOG Auto Growth Event')
BEGIN
EXEC msdb.dbo.sp_add_alert @name=N'DBA: LOG Auto Growth Event', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@notification_message=N'DBA: LOG Auto Growth Event', 
		@category_name=N'[Uncategorized]', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'SELECT * FROM LOG_FILE_AUTO_GROW', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=N'DBA: LOG Auto Growth Event', @operator_name=@Operator, @notification_method = 7;
EXECUTE msdb.dbo.sp_update_alert @name = 'DBA: Log Auto Growth Event', @job_Name = 'DBA: Autogrowth Email Alert'
END


IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 017 - Insufficient Resources')
BEGIN
                EXEC msdb.dbo.sp_add_alert @name=N'Severity 017 - Insufficient Resources', 
                                                @message_id=0, 
                                                @severity=17, 
                                                @enabled=1, 
                                                @delay_between_responses=300, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 017 - Insufficient Resources', @operator_name=@Operator, @notification_method = 1
END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 018 - Nonfatal Internal Error')
BEGIN
                EXEC msdb.dbo.sp_add_alert @name=N'Severity 018 - Nonfatal Internal Error', 
                                                @message_id=0, 
                                                @severity=18, 
                                                @enabled=1, 
                                                @delay_between_responses=0, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 018 - Nonfatal Internal Error', @operator_name=@Operator, @notification_method = 1

END


IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 019 - Fatal Error in Resource')
BEGIN
                EXEC msdb.dbo.sp_add_alert @name=N'Severity 019 - Fatal Error in Resource', 
                                                @message_id=0, 
                                                @severity=19, 
                                                @enabled=1, 
                                                @delay_between_responses=300, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 019 - Fatal Error in Resource', @operator_name=@Operator, @notification_method = 1

END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 020 - Fatal Error in Current Process')
BEGIN
                EXEC msdb.dbo.sp_add_alert @name=N'Severity 020 - Fatal Error in Current Process', 
                                                @message_id=0, 
                                                @severity=20, 
                                                @enabled=1, 
                                                @delay_between_responses=300, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 020 - Fatal Error in Current Process', @operator_name=@Operator, @notification_method = 1
                
END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 021 - Fatal Error in Database Process')
BEGIN
                EXEC msdb.dbo.sp_add_alert @name=N'Severity 021 - Fatal Error in Database Process', 
                                                @message_id=0, 
                                                @severity=21, 
                                                @enabled=1, 
                                                @delay_between_responses=300, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 021 - Fatal Error in Database Process', @operator_name=@Operator, @notification_method = 1


END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 022 - Fatal Error: Table Integrity Suspect')
BEGIN
                EXEC msdb.dbo.sp_add_alert @name=N'Severity 022 - Fatal Error: Table Integrity Suspect', 
                                                @message_id=0, 
                                                @severity=22, 
                                                @enabled=1, 
                                                @delay_between_responses=300, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 022 - Fatal Error: Table Integrity Suspect', @operator_name=@Operator, @notification_method = 1

END


IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 023 - Database Integrity Suspect')
BEGIN
                EXEC msdb.dbo.sp_add_alert @name=N'Severity 023 - Database Integrity Suspect', 
                                                @message_id=0, 
                                                @severity=23, 
                                                @enabled=1, 
                                                @delay_between_responses=300, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 023 - Database Integrity Suspect', @operator_name=@Operator, @notification_method = 1
END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 024 - Fatal Error: Hardware Error')
BEGIN
EXEC msdb.dbo.sp_add_alert @name=N'Severity 024 - Fatal Error: Hardware Error', 
                                                @message_id=0, 
                                                @severity=24, 
                                                @enabled=1, 
                                                @delay_between_responses=300, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 024 - Fatal Error: Hardware Error', @operator_name=@Operator, @notification_method = 1

END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Severity 025 - Fatal Error')
BEGIN
                EXEC msdb.dbo.sp_add_alert @name=N'Severity 025 - Fatal Error', 
                                                @message_id=0, 
                                                @severity=25, 
                                                @enabled=1, 
                                                @delay_between_responses=300, 
                                                @include_event_description_in=1, 
                                                @category_name=N'[Uncategorized]', 
                                                @job_id=N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 025 - Fatal Error', @operator_name=@Operator, @notification_method = 1

END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Error Number 823')
BEGIN
				EXEC msdb.dbo.sp_add_alert @name=N'Error Number 823', 
												@message_id=823, 
												@severity=0, 
												@enabled=1, 
												@delay_between_responses=60, 
												@include_event_description_in=1, 
												@category_name=N'[Uncategorized]', 
												@job_id=N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 823', @operator_name=@Operator, @notification_method = 1;

END


IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Error Number 824')
BEGIN
				EXEC msdb.dbo.sp_add_alert @name=N'Error Number 824', 
												@message_id=824, 
												@severity=0, 
												@enabled=1, 
												@delay_between_responses=60, 
												@include_event_description_in=1, 
												@category_name=N'[Uncategorized]', 
												@job_id=N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 824', @operator_name=@Operator, @notification_method = 7;

END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'Error Number 825')
BEGIN
				EXEC msdb.dbo.sp_add_alert @name=N'Error Number 825', 
												@message_id=825, 
												@severity=0, 
												@enabled=1, 
												@delay_between_responses=60, 
												@include_event_description_in=1, 
												@category_name=N'[Uncategorized]', 
												@job_id=N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 825', @operator_name=@Operator, @notification_method = 7;

END

--Availability Group Specific Alerts
IF (SELECT SERVERPROPERTY('ISHadrEnabled')) = 1

BEGIN

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'AlwaysOn - Role Change')
BEGIN
EXEC msdb.dbo.sp_add_alert @name=N'AlwaysOn - Role Change', 
		@message_id=1480, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=915, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_notification @alert_name=N'AlwaysOn - Role Change', @operator_name=@Operator, @notification_method = 7;
EXECUTE msdb.dbo.sp_update_alert @name = 'AlwaysOn - Role Change', @job_Name = 'DBA: AGFailover'
END

/****** Object:  Alert [AlwaysOn - Data Movement Suspended]    Script Date: 18/09/2018 06:29:01 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'AlwaysOn - Data Movement Suspended')
BEGIN
EXEC msdb.dbo.sp_add_alert @name=N'AlwaysOn - Data Movement Suspended', 
		@message_id=35264, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=915, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=N'AlwaysOn - Data Movement Suspended', @operator_name=@Operator, @notification_method = 7;
EXECUTE msdb.dbo.sp_update_alert @name = 'AlwaysOn - Data Movement Suspended', @job_Name = 'DBA: Availability Group Health Check'
END





END

--Add mirroring alert if any databases are part of a mirroring session

IF (SELECT COUNT(database_id) FROM sys.database_mirroring WHERE mirroring_state IS NOT NULL) > 0
BEGIN

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'DBA: Mirroring State Change') 
BEGIN
EXEC msdb.dbo.sp_add_alert @name=N'DBA: Mirroring State Change', 
		@message_id=0,  
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=915, 
		@include_event_description_in=1,  
		@notification_message=N'DBA: Mirroring State Change',   
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'SELECT * FROM DATABASE_MIRRORING_STATE_CHANGE WHERE State = 6 ', 
		@job_id=N'00000000-0000-0000-0000-000000000000'

EXECUTE msdb.dbo.sp_update_alert @name = 'DBA: Mirroring State Change', @job_Name = 'DBA: Check Mirror Status'
END

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = 'DBA: Mirroring Unsent Log Warning') 
BEGIN
EXEC msdb.dbo.sp_add_alert @name=N'DBA: Mirroring Unsent Log Warning', 
		@message_id=32044, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=915, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'

EXECUTE msdb.dbo.sp_update_alert @name = 'DBA: Mirroring Unsent Log Warning', @job_Name = 'DBA: Check Mirror Status'

END


END