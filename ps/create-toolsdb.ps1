function Create-ToolsDB
{
    [CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName,

    [Parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
	[string]$Database = 'Tools',

    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Source,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [String]$sa = 'C4rb0n'
    )

    #Create-ToolsDB -ComputerName MININT-9F84K7A -Source 'C:\Users\glpepper\Documents\GitHub\ToolsDB'


 process
	{
		try
		{


        IF (!(Get-Module -Name sqlps))
    {
        Write-Host 'Loading SQLPS Module' -ForegroundColor DarkYellow
        Push-Location
        Import-Module sqlps -DisableNameChecking
        Pop-Location
    }

    $Continue = $true
    $logFile = $Source+'\log.txt'
    if (!(Test-Path $logfile))
    {
    New-Item -path $Source -name log.txt -type "file"
    }
    ELSE
    {
    Clear-Content -Path $logFile
    }
    $Time = Get-Date
    "*********Database Creation started at $Time ***********" | out-file $logFile -append


    #Test Connection first

    $Connection = Test-SqlCon -ComputerName $ComputerName -ErrorAction Stop

    IF ($Connection -eq $false)
    {
    Write-Host "Connection to $computerName Could not be established. Install Cancelled"
    "Connection to $computerName Could not be established. Install cancelled at $time" | out-file $logFile -append
    
    }


    #check sa login is valid
    $SAExists = get-SALogin -ComputerName $computerName -SA $sa
    
    IF ($SAExists -eq $false)
    {
    write-Host "SA account $sa could no be verified. Installed Cancelled"
    "SA Account $sa could not be verified. Install Cancelled" | out-file $login -Append

    }


    $dbExists = Check-DBExists $ComputerName $Database -ErrorAction Stop

    If ($dbExists -eq $false)
    {

    $ConfirmStart = Confirm-Start -ErrorAction Stop

    if ($ConfirmStart -eq $true)
    {

    write-host "DB Creation about to start"

    "DB Creation about to start" | out-file $logFile -append

    Create-DB $ComputerName $Source -ErrorAction Stop

    Create-Tables $ComputerName $Source -ErrorAction Stop
    }

    elseif ($ConfirmStart -eq $false)
    {
     write-host "The Answer was no. therefore DB Creation cancelled"
     "DB Creation cancelled by user" | out-file $logFile -append
    
    }

    }
    
    else

    {

    $confirmCreate = Confirm-Create -ErrorAction stop
    if ($Confirmcreate -eq $true)
    {

    $BackUp = Confirm-Backup -ErrorAction Stop

    if ($Backup -eq $true)
    { 

    write-host "Backup of $database has been confirmed. The creation will now start"
    "Backup of $database has been confirmed. The creation will now start...." | out-file $logFile -append
        
    Create-DB $ComputerName $Source -ErrorAction Stop

    Create-Tables $ComputerName $Source -ErrorAction Stop
    }

    else
    {

    write-host "Backup of $database has not been confirmed. Therefore the creation has been cancelled"
    "Backup of $database has not been confirmed. Therefore the creation has been cancelled" | out-file $logFile -append
    
    }

    }

    Elseif ($ConfirmCreate -eq $false)
    {

    write-host "Recreation of $database not confirmed"
    "Recreation of $database not confirmed" | out-file $logFile -append

    $ConfirmUpgrade = Confirm-upgrade -ErrorAction Stop

    If ($ConfirmUpgrade -eq $false)
    {
    write-host "upgrade not confirmed. Install cancelled"
    }

    elseIf ($ConfirmUpgrade -eq $true)
    {

    $BackUp = Confirm-Backup -ErrorAction Stop

    if ($Backup -eq $true)
    { 

    write-host "Backup of $database has been confirmed. The update will now start"
    "Backup of $database has been confirmed. The update will now start...." | out-file $logFile -append
    }

    else
    {

    write-host "Backup of $database has not been confirmed. Therefore the creation has been cancelled"
    "Backup of $database has not been confirmed. Therefore the creation has been cancelled" | out-file $logFile -append
    }


    }

    }


    }

    Create-Sps $ComputerName $Source -ErrorAction Stop

    Create-Fns $ComputerName $Source -ErrorAction Stop

    Create-Jobs $ComputerName $Source -ErrorAction Stop

    Create-Alerts $ComputerName $Source

    set-Owner $ComputerName $Database $sa 
    
    Change-JobOwnersScript -server $ComputerName -newchange $sa 

    }
    catch
		{
            $ErrorMessage = $_.Exception.Message
            Write-Error -Message $ErrorMessage
            "Install failed $time :  $errorMessage " | out-file $logFile -append
			           
		}

    Finally
    {
       

       "*******************completed at $Time ***************" | out-file $logFile -append
    }
   }

}


function Create-DB
{
	[CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName,
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Source

	)
	process
	{
		try
		{
		$DBRoot = $Source + "\DBCreate"
        $Sql = Get-ChildItem $Dbroot |  Where-Object {$_.Name -eq "1 Tools DB Creation.sql"}
        write-host "The Database will now be created" -BackgroundColor DarkGreen -ForegroundColor Yellow
                
        if ($Database -ne 'Tools')
        {

        $query = Replace-String -Script $sql.FullName -Source 'Tools' -Replace $Database
        Write-Host "Running Script : " $sql.Name -BackgroundColor DarkGreen -ForegroundColor White
        Invoke-Sqlcmd -ServerInstance $ComputerName -query $query -QueryTimeout 0
        }
        Else
        {
        Write-Host "Running Script : " $sql.Name -BackgroundColor DarkGreen -ForegroundColor White
        $query = $sql.FullName
        Invoke-Sqlcmd -ServerInstance $ComputerName -InputFile $query -QueryTimeout 0
        Write-Host "Creating Database Object " $sql.Name -BackgroundColor DarkGreen -ForegroundColor White          
              
        }


        write-Host "Database Created Successfully" -BackgroundColor DarkGreen -ForegroundColor Yellow
        "Database Object Created at $Time" | out-file $logFile -append

		}
		catch
		{
            $ErrorMessage = $_.Exception.Message
            Write-Error -Message $ErrorMessage
            $ErrorMessage | outFile $logFile -append
		}
	}
}

function Create-Tables
{
	[CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName,
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Source
	)
	process
	{
		try
		{
		$TablesRoot = $Source + "\DBTables"
        $TableScripts = Get-ChildItem $Tablesroot | Where-Object {$_.Extension -eq ".sql"}  | sort-object -desc  
        write-host "Creating Tables" -BackgroundColor DarkGreen -ForegroundColor Yellow




        foreach ($s in $Tablescripts)
    {

        if ($Database -ne 'Tools')
        {

        $query = Replace-String -Script $s.FullName -Source 'Tools' -Replace $Database 

        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        Invoke-Sqlcmd -ServerInstance $ComputerName -query $query 
        }

                Else
        {
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        $script = $s.FullName
        Invoke-Sqlcmd -ServerInstance $ComputerName -InputFile $script
        }

    }
        write-host "Tables Created Successfully" -BackgroundColor DarkGreen -ForegroundColor Yellow
        "Tables Created at $Time" | out-file $logFile -append
		}
		catch
		{
            $ErrorMessage = $_.Exception.Message
            Write-Error -Message $ErrorMessage
            $ErrorMessage | outfile $logfile -append
		}
	}
}



function Create-SPs
{
	[CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName,
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Source
	)
	process
	{
		try
		{
        $SPRoot = $Source + "\SPs"
        $SPScripts = Get-ChildItem $SPRoot | Where-Object {$_.Extension -eq ".sql"} | sort-object -desc
		write-host "Creating Stored Procedures...." -BackgroundColor DarkGreen -ForegroundColor Yellow
        
        foreach ($s in $SPscripts)
    {

        if ($Database -ne 'Tools')
        {

        $query = Replace-String -Script $s.FullName -Source 'Tools' -Replace $Database
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        Invoke-Sqlcmd -ServerInstance $ComputerName -query $query -DisableVariables
        }    

        Else
        {
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        $script = $s.FullName
        Invoke-Sqlcmd -ServerInstance $ComputerName -InputFile $script
        }        
    }
        write-host "Stored Procedures created successfully" -BackgroundColor DarkGreen -ForegroundColor Yellow
        "Stored Procedures Created at $Time" | out-file $logFile -append

		}
		catch
		{
            $ErrorMessage = $_.Exception.Message
            Write-Error -Message $ErrorMessage
            $ErrorMessage| out-file $logFile -append
		}
	}
}


function Create-Fns
{
	[CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName,
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Source
	)
	process
	{
		try
		{
        $FNRoot = $Source + "\Functions"
        $FNScripts = Get-ChildItem $FNRoot| Where-Object {$_.Extension -eq ".sql"} | sort-object -desc
        write-host "Creating Functions..." -BackgroundColor DarkGreen -ForegroundColor Yellow
        foreach ($s in $FNScripts)
    {

        if ($Database -ne 'Tools')
        {

        $query = Replace-String -Script $s.FullName -Source 'Tools' -Replace $Database 

        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        Invoke-Sqlcmd -ServerInstance $ComputerName -query $query
        }
        Else
        {
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        $script = $s.FullName
        Invoke-Sqlcmd -ServerInstance $ComputerName -InputFile $script
        }

    }
        write-host "Functions created successfully" -BackgroundColor DarkGreen -ForegroundColor Yellow
        "Functions Created at $Time" | out-file $logFile -append

		}
		catch
		{
			$ErrorMessage = $_.Exception.Message
            Write-Error -Message $ErrorMessage
            $ErrorMessage| out-file $logFile -append
		}
	}
}

function Create-Jobs
{
	[CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName,
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Source
	)
	process
	{
		try
		{
        $JobsRoot = $Source + "\Jobs"
        $JobsScripts = Get-ChildItem $JobsRoot | Where-Object {$_.Extension -eq ".sql"} | sort-object -desc
		write-host "Creating Jobs..." -BackgroundColor DarkGreen -ForegroundColor Yellow
        
        foreach ($s in $JobsScripts)
    {

        if ($Database -ne 'Tools')
        {

        $query = Replace-String -Script $s.FullName -Source 'Tools' -Replace $Database
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        Invoke-Sqlcmd -ServerInstance $ComputerName -query $query -DisableVariables
        }
        Else
        {
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        $script = $s.FullName
        Invoke-Sqlcmd -ServerInstance $ComputerName -InputFile $script -DisableVariables
            

        }


    }
        Write-Host "Jobs created successfully" -BackgroundColor DarkGreen -ForegroundColor Yellow
        "Jobs Created at $Time" | out-file $logFile -append
		}
		catch
		{
			$ErrorMessage = $_.Exception.Message
            Write-Error -Message $ErrorMessage
            $ErrorMessage| out-file $logFile -append
		}
	}
}


function Create-Alerts
{
	[CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName,
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Source
	)
	process
	{
		try
		{
         $ATRoot = $Source + "\Alerts"
         $ATScripts = Get-ChildItem $ATRoot| Where-Object {$_.Extension -eq ".sql"} | sort-object -desc
         write-host "Creating SQL Alerts..." -BackgroundColor DarkGreen -ForegroundColor Yellow 
		
         foreach ($s in $ATscripts)
    {

        if ($Database -ne 'Tools')
        {

        $query = Replace-String -Script $s.FullName -Source 'Tools' -Replace $Database
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White

        Invoke-Sqlcmd -ServerInstance $ComputerName -query $query
        }
        Else
        {
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        $script = $s.FullName
        Invoke-Sqlcmd -ServerInstance $ComputerName -InputFile $script
        }

    }
        Write-Host "SQL Alerts Created Successfully" -BackgroundColor DarkGreen -ForegroundColor Yellow
        "Alerts Created at $Time" | out-file $logFile -append
		}
		catch
		{
            $ErrorMessage = $_.Exception.Message
            Write-Error -Message $ErrorMessage
            $ErrorMessage| out-file $logFile -append
		}
	}
}


Function Replace-String {
    [OutputType([String])]
    [CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Script,
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Source,
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Replace
     )

    Process

    {

    Try 
    {
    Get-Content $script | foreach {$_.replace($Source,$Replace)} | Out-String
    
    }

    Catch

    {

    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage
    $ErrorMessage| out-file $logFile -append
    }


    }

    }


 
Function Set-Owner
{

[CmdletBinding()]
	param
	(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName,

    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Database,

    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$sa
     )

    Process

    {

    Try 
    {


    $SQLQRY = "ALTER AUTHORIZATION ON DATABASE:: $database to $sa"
    Invoke-Sqlcmd -ServerInstance $ComputerName -query $SQLQRY

    Write-Host "Database Owner Changed to $sa" -BackgroundColor DarkGreen -ForegroundColor Yellow
    "Owner changed at $Time" | out-file $logFile -append

    }



    Catch
    {
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage
    $ErrorMessage| out-file $logFile -append
    }

    }

}

Function Change-JobOwnersScript {
    Param(
          [ValidateLength(0,100)][string]$server
        , [ValidateLength(0,80)][string]$newchange
    )
    Process
    {
        $nl = [Environment]::NewLine

    
        $srv = New-Object Microsoft.SqlServer.Management.Smo.Server($server)

        try 
        {

        foreach ($job in $srv.JobServer.Jobs)
        {
            if ($job.OwnerLoginName -ne $newchange)
            {
                $sqlquery = $script + "---- Current owner: " + $job.OwnerLoginName + $nl + "EXEC msdb.dbo.sp_update_job @job_id=N'" + $job.JobID + "'" + $nl + ", @owner_login_name=N'$newchange'" | out-string
                Invoke-Sqlcmd -ServerInstance $ComputerName -query $sqlquery

            }


        }
         Write-Host "Job Owners Changed to $sa" -BackgroundColor DarkGreen -ForegroundColor Yellow
        "Job Owners Changed to $sa" | out-file $logFile -append
            

        }
        Catch {

            $ErrorMessage = $_.Exception.Message
            Write-Error -Message $ErrorMessage
            $ErrorMessage| out-file $logFile -append
            "$sa is not a valid login therefore the jobs are owned by $env:UserName "
              }
        finally 
        {

        }

    }

}


Function Check-DBExists

{

Param(
          [ValidateLength(0,100)][string]$ComputerName
        , [ValidateLength(0,80)][string]$Database
    )
    Process
    {
    
    $exists = $null

    Try
    {

    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server($ComputerName)

    ForEach ($db in $srv.Databases) 
    {
    IF ($db.Name -eq $Database)
    {
    $exists = $true
    break
    }
    else {

    $exists = $false

    }
    
    } 


    }

    Catch

    {
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage
    $ErrorMessage| out-file $logFile -append

    }
    return $exists

}

}





Function Confirm-Start

{

Param(
    )

    Process
    {

    $confirmed = $null

    Try
    {


    $create = Read-Host "The database $database is about to be created on $ComputerName. Are you sure this is what you want to do? (Y/N)" 

    if ($create -eq 'Y')
    {
    $confirmed = $true
    }
    else 
    {
    $confirmed = $false

    }
    
    }

    Catch

    {
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage
    $ErrorMessage| out-file $logFile -append
    }
    return $confirmed

}

}


Function Confirm-Create

{

Param(
    )

    Process
    {
    $ConfirmStart = $false


    try
    {
    $input = Read-Host "The database $database already exists on $ComputerName. Do you want to overwrite it? (Y/N)"

    if ($input -eq 'Y')
    {

    $ConfirmStart = $true

    }

    else 
    {

    $ConfirmStart = $false

    }

    }



    catch 
    {
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage
    $ErrorMessage| out-file $logFile -append

    }

    return $ConfirmStart

}

}


Function Confirm-Upgrade

{

Param(
    )

    Process
    {
    $upgrade = $false


    try
    {
    $input = Read-Host "Would you like to update the stored Procedures, Functions, Alerts and Jobs to the current versions? (Y/N)"

    if ($input -eq 'Y')
    {

    $upgrade = $true

    }

    else 
    {

    $Upgrade = $false

    }

    return $upgrade

    }



    catch 
    {
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage
    $ErrorMessage| out-file $logFile -append

    }



}

}



Function get-SALogin

{


Param(
          [ValidateLength(0,100)][string]$ComputerName
        , [ValidateLength(0,80)][string]$SA
)
Process

{
$exists = $false

try 
    {


    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ComputerName
    #This sets the connection to mixed-mode authentication 
    $srv.ConnectionContext.LoginSecure=$true; 
    $dbs=$srv.Logins
    if($dbs.contains($SA))
        {
        Write-Host  "$sa found"
        $Exists = $true
        }

        else
        {
        write-host "$sa Not Found"
        $Exists = $false
        }

        return $exists
    }
    
catch 

    {
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage
    }

}

}

function test-SQLCon

{
Param(
    [Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ComputerName
)
Process

{
$ServerExists = $false

try 
    {

    

    $srv = New-Object System.Data.SqlClient.SqlConnection
    $srv.ConnectionString = "Data Source=$computerName; Database=master;Integrated Security=True;"
    $srv.Open()
    $srv.Close()
    $serverExists = $true
    return $ServerExists
    }

    Catch

    {
    $serverExists = $false     
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage
    Return $ServerExists
    }

}

}

Function Confirm-Backup

{

Param(
    )

    

    Process
    {

    $CheckBackup = $false

    try
    {

    $BU = Read-Host "Have you taken a backup of $database ? (Y/N)"

    If ($BU -eq 'Y') 
    {
    $CheckBackup = $true

    }
    else 
    {
    $CheckBackup = $false
    }
    

    }

    catch 
    {
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message $ErrorMessage

    }

    Return $CheckBackup


    }
}





