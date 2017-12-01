function Confirm-ScriptIsValid {
    Param
    (
        [parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [Alias("Path")]
        [ValidateScript( {Test-Path $_})]
        [String[]]
        $FullName
    )
    Begin {
        $errorColl = @()
        $analyzed = 0
        $lenAnalyzed = 0
    }
    Process {
        foreach ($p in $FullName) {
            $analyzed++
            $item = Get-Item $p
            $lenAnalyzed += $item.Length
            $contents = Get-Content -Path $item.FullName -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $obj = [PSCustomObject][Ordered]@{
                Name = $item.Name
                FullName = $item.FullName
                Length = $item.Length
                Errors = $errors.count
            }
            $obj
            if ($errors.count) {
                $errorColl += $obj
            }
        }
    }
    End {
        Write-Verbose "Total files analyzed: $analyzed"
        Write-Verbose "Total size of files analyzed: $lenAnalyzed ($([Math]::Round(($lenAnalyzed/1MB),2)) MB)"
        Write-Verbose "Files with errors:`n$($errorColl | Sort-Object FullName | Out-String)"
    }
}