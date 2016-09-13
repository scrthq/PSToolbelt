function Set-SecretData {
    <#
    .SYNOPSIS
        Sets PSGoogle module configuration. 
        
        Based off of the PSSlack Configuration functions found in that module:

                https://github.com/RamblingCookieMonster/PSSlack

    .DESCRIPTION
        Set PSGoogle module configuration, and $PSGoogle module variable.

    .PARAMETER Key
        Specify the path to your service account's P12 Key

    .PARAMETER HashedData
        Specify the default scopes to use

    .PARAMETER Path
        The service account's email address
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]
        $Key,
        [parameter(Mandatory=$true)]
        [hashtable]
        $Contents,
        [parameter(Mandatory=$false)]
        [string]
        $Path = "$ModuleRoot\$env:USERNAME-$env:COMPUTERNAME-SecretData.xml"
    )
function Encrypt {
    param([string]$string)
    if($String -notlike '')
        {
        ConvertTo-SecureString -String $string -AsPlainText -Force
        }
    }
$Script:SecretData = [pscustomobject]@{$Key=$(Encrypt $($Contents | ConvertTo-Json | Out-String))}
#Write the global variable and the xml
$Script:SecretData | Export-Clixml -Path $Path -Force
}