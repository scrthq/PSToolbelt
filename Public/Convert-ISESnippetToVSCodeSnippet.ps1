function Convert-ISESnippetToVSCodeSnippet {
    Param
    (
      [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
      [String[]]
      $Path
    )
Begin
    {
    $vsCodeSnippets = @{}
    if ((Get-Item $Path).Attributes -eq "Directory")
        {
        $SaveTo = $Path
        $Path = Get-ChildItem $Path -Filter "*.ps1xml" | Select-Object -ExpandProperty FullName
        }
    else
        {
        $SaveTo = (Get-Item $Path).Directory.FullName
        }
    }
Process
    {
    foreach ($p in $Path) {
        $snip = Get-Item $p
        $name = "$($snip.BaseName -replace ".snippets",'')"
        $prefix = "ISE_$($name -replace ' ','')"
        [xml]$xml = Get-Content $snip.FullName
        [int]$CaretOffset = [int]$xml.Snippets.Snippet.Code.Script.CaretOffset - 1
        $description = $xml.Snippets.Snippet.Header.Description
        $snipHash = @{
            prefix = $prefix
            body = @()
            description = $description
            }
        $code = $xml.Snippets.Snippet.Code.Script.'#cdata-section'
        $code = $code.Insert($CaretOffset,'$0')
        $code = $code.Replace('    ','\t')
        $code = $code.Replace('$','\$')
        $code -split "`n" | ForEach-Object {
            $snipHash["body"] += "$_"
            }

        $vsCodeSnippets.Add("$name",$snipHash)
        }
    }
End
    {
    $vsCodeSnippets | ConvertTo-Json | Set-Content "$SaveTo\powershell.json" -Force
    (Get-Content "$SaveTo\powershell.json").replace('\\t','\t').replace('\\$','$$').Replace('$$0','$0') | Set-Content "$SaveTo\powershell.json" -Force
    }
}