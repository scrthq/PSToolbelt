function Convert-ISESnippetToVSCodeSnippet {
    Param
    (
        [parameter(Mandatory = $false,Position = 0,ValueFromPipeline = $true)]
        [String[]]
        $Path = "$($HOME)\Documents\WindowsPowerShell\Snippets"
    )
    Begin {
        function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String]$json) {
            $indent = 0
            ($json -Split '\n' |
                    ForEach-Object {
                    if ($_ -match '[\}\]]') {
                        # This line contains  ] or }, decrement the indentation level
                        $indent--
                    }
                    $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
                    if ($_ -match '[\{\[]') {
                        # This line contains [ or {, increment the indentation level
                        $indent++
                    }
                    $line
                }) -Join "`n"
        }
        $vsCodeSnippets = @{}
        if ((Get-Item $Path).Attributes -eq "Directory") {
            $SaveTo = $Path
            $Path = Get-ChildItem $Path -Filter "*.ps1xml" | Select-Object -ExpandProperty FullName
        }
        else {
            $SaveTo = (Get-Item $Path).Directory.FullName
        }
    }
    Process {
        foreach ($p in $Path) {
            $snip = Get-Item $p
            $name = "$($snip.BaseName -replace ".snippets",'')"
            Write-Verbose "Converting snippet: $name"
            $prefix = "ISE_$($name -replace ' ','')"
            [xml]$xml = Get-Content $snip.FullName
            [int]$CaretOffset = [int]$xml.Snippets.Snippet.Code.Script.CaretOffset - 1
            $description = $xml.Snippets.Snippet.Header.Description
            $snipHash = @{
                prefix      = $prefix
                body        = @()
                description = $description
            }
            $code = $xml.Snippets.Snippet.Code.Script.'#cdata-section'
            try {
                $codeIns = $code.Insert($CaretOffset,'$0')
                $code = $codeIns
            }
            catch {
            }
            $code = $code.Replace('    ','\t')
            $code = $code.Replace('$','\$')
            $code -split "`n" | ForEach-Object {
                $snipHash["body"] += "$_"
            }

            $vsCodeSnippets.Add("$name",$snipHash)
        }
    }
    End {
        ($vsCodeSnippets | ConvertTo-Json -Depth 10) | Format-Json -ErrorAction SilentlyContinue | Set-Content "$SaveTo\powershell.json" -Force
        (Get-Content "$SaveTo\powershell.json").replace('\\t','\t').Replace('\\$0','$0') | Set-Content "$SaveTo\powershell.json" -Force
    }
}