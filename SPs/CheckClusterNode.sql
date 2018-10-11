USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('CheckClusterNode') IS NULL
  EXEC ('CREATE PROCEDURE CheckClusterNode AS RETURN 0;')
GO

ALTER PROCEDURE CheckClusterNode 
AS

BEGIN


-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	This Stored Procedure looks to see if the cluster node has changed during a service restart
-- If the cluster node has changed, an email is sent to the DBAs
-- =============================================	
	
	DECLARE @N SQL_VARIANT;
	DECLARE @CD Datetime;
	DECLARE @ID int;
	DECLARE @NC SQL_VARIANT;
	DECLARE @CD1 SQL_VARIANT;
	
	
	SET @CD = Getdate()
	SET @N = (select SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as 'Node')
	SET @ID = (Select top 1 ID from tools.dbo.Clusternodenotification order by id desc)
	;WITH node_CTE (id,Node)  
AS  
(  
    SELECT ID, COUNT(*)  
    FROM tools.dbo.Clusternodenotification  
    WHERE ID IS NOT NULL  
    GROUP BY ID  
)  
Select top 1  @NC = node_CTE.Node
FROM Clusternodenotification as node_cte
LEFT JOIN node_cte prev ON prev.ID = node_cte.ID - 1
LEFT JOIN node_cte nex ON nex.ID = node_cte.ID + 1
order by node_CTE.Node desc


SET @CD1 = (Select top 1 currentdate from tools.dbo.Clusternodenotification order by currentdate desc)
	

	Insert into tools.dbo.Clusternodenotification
	Select @n,@CD

	
	
IF @N = @NC

		BEGIN 

		PRINT 'This matches so no issue'

END

	ELSE 
IF @N != @NC
and @CD > @cd1

BEGIN 


	DECLARE @body2 varchar(800);
	DECLARE @EMAILSUBJECT1 varchar(200);
	DECLARE @SERVERNAME VARCHAR(200);
	DECLARE @EMAILADDRESS VARCHAR(200);
	
	SET @SERVERNAME = @@SERVERNAME

	SET @EMAILSUBJECT1 = N'SQL cluster node changed for server' + ' ' +@SERVERNAME

	SET @EMAILADDRESS = (SELECT Email_Address from msdb.dbo.sysoperators WHERE enabled = 1)
	


	SET @body2='<font face=verdana size=2><B>This Instance is on the new Node on the cluster. Please Investigate as to why the cluster node failed over</b></font><br /><br />
			<style type="text/css">h2, body {font-family: Arial, verdana;} table{font-size:11px; border-collapse:collapse;} td{background-color:#F1F1F1; border:1px solid black; padding:3px;} 
			th{background-color:#99CCFF;border:1px solid black; padding:1px;}</style>
			<table cellpadding=2 cellspacing=2><tr><th><B>Node</B></th><th><B>Current Date</B></th></tr>'
			+ 
			cast((select top 1 td = Node, ''
					   , td = CurrentDate, ''
				from tools.dbo.Clusternodenotification as TD 
				order by CurrentDate desc
			    for xml path('tr'), type
				) as varchar(max) )
			+ '</table><BR>'

EXEC msdb.dbo.sp_send_dbmail
       @profile_name = @SERVERNAME,  -- Use valid database mail profile here
       @subject = @EMAILSUBJECT1,
       @body = @body2,@body_format = 'HTML',
	   @recipients = @EMAILADDRESS ; -- Use valid email address here

END

END