Function Get-SecretData {
    <#
    .SYNOPSIS
        Gets PSGoogle module configuration.

        Based off of the PSGoogle Configuration functions found in that module:

                https://github.com/RamblingCookieMonster/PSGoogle

    .DESCRIPTION
        Get PSGoogle module configuration

    .PARAMETER Source
        Get the config data from either...
        
            PSGoogle:     the live module variable used for command defaults
            $env:USERNAME-PSGoogle.xml: the serialized PSGoogle.xml that loads when importing the module

        Defaults to PSGoogle

    .PARAMETER Path
        If specified, read config from this XML file.
        
        Defaults to $env:USERNAME-PSGoogle.xml in the module root

    .FUNCTIONALITY
        Google Apps
    #>
    param(
        [parameter(Mandatory=$true)]
        $Key = "SecretData",

        [parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_})]
        $Path = "$ModuleRoot\$env:USERNAME-$env:COMPUTERNAME-SecretData.xml"
    )
function Decrypt {
    param($String)
    if($String -is [System.Security.SecureString])
    {
        [System.Runtime.InteropServices.marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.marshal]::SecureStringToBSTR(
                $string))
    }
}
    
$Script:SecretData = Import-Clixml

    if($PSCmdlet.ParameterSetName -eq 'source' -and $Source -eq "SecretData" -and -not $PSBoundParameters.ContainsKey('Path'))
    {
        $Script:SecretData
    }
    else
    {

        Import-Clixml -Path $Path |
            Select -Property @{N='P12KeyPath';E={Decrypt $_.P12KeyPath}},
                @{N='Scopes';E={(Decrypt $_.Scopes) -split ","}},
                @{N='AppEmail';E={Decrypt $_.AppEmail}},
                @{N='AdminEmail';E={Decrypt $_.AdminEmail}},
                @{N='CustomerID';E={Decrypt $_.CustomerID}},
                @{N='Domain';E={Decrypt $_.Domain}},
                @{N='Preference';E={Decrypt $_.Preference}}
    }

}