function Add-ToLog {
    [cmdletBinding(DefaultParameterSetName="Message")]
    Param
    (
      [parameter(Mandatory=$true,ParameterSetName="Message",Position=0)]
      [String]
      $Message,
      [parameter(Mandatory=$false,ParameterSetName="Message",Position=1)]
      [object]
      $Object,
      [parameter(Mandatory=$false,ParameterSetName="Message")]
      [ValidateSet("Black","Blue","Cyan","DarkBlue","DarkCyan","DarkGray","DarkGreen","DarkMagenta","DarkRed","DarkYellow","Gray","Green","Magenta","Red","White","Yellow")]
      [String]
      $ForegroundColor,
      [parameter(Mandatory=$false,ParameterSetName="Message")]
      [ValidateSet("Black","Blue","Cyan","DarkBlue","DarkCyan","DarkGray","DarkGreen","DarkMagenta","DarkRed","DarkYellow","Gray","Green","Magenta","Red","White","Yellow")]
      [String]
      $BackgroundColor,
      [parameter(Mandatory=$false,ParameterSetName="Message")]
      [ValidateSet("INFO","WARNING","ERROR")]
      [String]
      $MessageType="INFO",
      [parameter(Mandatory=$false,ParameterSetName="Message")]
      [switch]
      $WriteToEventLog,
      [parameter(Mandatory=$false,ParameterSetName="LogOut")]
      [ValidateScript({if($_ -like "*.txt" -or $_ -like "*.log"){$true}else{throw "Incorrect file type! Only txt or log files can be used here"}})]
      [String]
      $SaveLogToPath,
      [parameter(Mandatory=$false,ParameterSetName="LogOut")]
      [ValidateScript({if($_ -like "*.csv"){$true}else{throw "Incorrect file type! Only CSV files can be used here"}})]
      [String]
      $SaveCSVToPath,
      [parameter(Mandatory=$false,ParameterSetName="RefreshCache")]
      [switch]
      $RefreshLogCache,
      [parameter(Mandatory=$false)]
      [switch]
      $Force
    )
if (!$Script:LogArray -and !$Script:ObjectArray)
    {
    Write-Warning "Initializing LogArray and ObjectArray at the Script scope"
    $Script:LogArray = @()
    $Script:ObjectArray = @()
    }
if (!$Script:EventLogConfirmed -and $WriteToEventLog)
    {
    if (!(Get-EventLog -List | ? {$_.LogDisplayName -eq "Automation"}))
        {
        Write-Warning "Creating 'Automation' EventLog with source set as 'PSScript'"
        try
            {
            New-EventLog -LogName Automation -Source PSScript -ErrorAction SilentlyContinue
            }
        catch
            {
            Write-Warning $("Event log creation failed, skipping event logging for this run!`n"+
            "`t`t Please run the following command from an administrator Powershell console to create the event log manually:")
            Write-Host -ForegroundColor Cyan "`t`t`t"'New-EventLog -LogName Automation -Source PSScript'
            $WriteToEventLog = $false
            }
        }
    else
        {
        $Script:EventLogConfirmed = $true
        }
    }
if ($SaveLogToPath){
    try 
        {
        if(!(Test-Path $SaveLogToPath))
            {New-Item $SaveLogToPath -Type File | Out-Null}
        if ($Force)
            {
            "LOG STARTED: $(Get-Date -Format G)" | Set-Content $SaveLogToPath -Force
            }
        else
            {
            "LOG STARTED: $(Get-Date -Format G)" | Add-Content $SaveLogToPath -Force
            }
        $Script:LogArray | Add-Content $SaveLogToPath -Force
        "" | Add-Content $SaveLogToPath -Force
        $Script:LogArray = $null
        }
    catch {Write-Error $Error[0]}
    return
    }
if ($SaveCSVToPath){
    try 
        {
        $Script:ObjectArray | Export-CSV -Path $SaveCSVToPath -NoTypeInformation -Force
        $Script:ObjectArray = $null
        }
    catch {Write-Error $Error[0]}
    return
    }
if ($RefreshLogCache)
    {
    $Script:LogArray = $null
    $Script:ObjectArray = $null
    return
    }
$Msg = "$($MessageType)`t:`t$($Message)"
$Script:LogArray += $Msg
if ($InputObject)
    {
    $Script:ObjectArray += $InputObject
    }
if ($MessageType -eq "INFO")
    {
    $HostParams = @{}
    if ($ForegroundColor){$HostParams.Add("ForegroundColor",$ForegroundColor)}
    if ($BackgroundColor){$HostParams.Add("BackgroundColor",$BackgroundColor)}
    Write-Host $Message @HostParams
    if ($WriteToEventLog)
        {
        Write-EventLog -LogName Automation -Source PSScript -EntryType Information -Message $Message -EventId 1000
        }
    }
elseif ($MessageType -eq "WARNING")
    {
    Write-Warning $Message
    if ($WriteToEventLog)
        {
        Write-EventLog -LogName Automation -Source PSScript -EntryType Warning -Message $Message -EventId 1001
        }
    }
elseif ($MessageType -eq "ERROR")
    {
    Write-Error $Message
    if ($WriteToEventLog)
        {
        Write-EventLog -LogName Automation -Source PSScript -EntryType Error -Message $Message -EventId 1002
        }
    }
}