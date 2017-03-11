function Get-Uptime {
    Param
    (
      [parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
      [ValidateNotNullOrEmpty()]
      [Alias("Server","Host","Computer","CN")]
      [String[]]
      $ComputerName = $env:COMPUTERNAME,
      [parameter(Mandatory=$false)]
      [ValidateSet("String","Timespan","DateTime")]
      [String]
      $Format = "String",
      [Parameter(Position=1,Mandatory=$false)]
      [Alias("RunAs")]
      [System.Management.Automation.PSCredential]
      $Credential = [System.Management.Automation.PSCredential]::Empty
    )
Begin
    {
    $Final = @()
    }
Process
    {
    foreach ($Computer in $ComputerName)
        {
        try
            {
            $OS = Get-WmiObject win32_operatingsystem -ComputerName $Computer -Credential $Credential -ErrorAction Stop
            $Current = ($OS.ConvertToDateTime($OS.LocalDateTime))
            $LastBoot = ($OS.ConvertToDateTime($OS.LastBootUpTime))
            if ($Format -eq "DateTime")
                {
                $LastBoot | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer
                $Final += $LastBoot
                }
            else
                {
                $Uptime = $Current - $LastBoot
                if ($Format -eq "String")
                    {
                    $Final += "[$Computer] Uptime: " + $Uptime.Days + " days, " + $Uptime.Hours + " hours, " + $Uptime.Minutes + " minutes" 
                    }
                else
                    {
                    $Uptime | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer
                    $Final += $Uptime
                    }
                }
            }
        catch
            {
            Write-Error $_
            }
        }
    }
End
    {
    return $Final
    }
}