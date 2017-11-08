
<#
          .Description
          Used by Convert to cleanly format json for snippets
#>
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String]$json)
{
     $indent = 0
     ($json -Split '\n' |
            ForEach-Object {
               if ($_ -match '[\}\]]')
               {
                    # This line contains  ] or }, decrement the indentation level
                    $indent--
               }
               $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
               if ($_ -match '[\{\[]')
               {
                    # This line contains [ or {, increment the indentation level
                    $indent++
               }
               $line
        }) -Join "`n"
}

<#
          .Description
          Will create a powershell.json file in the same directory that is a merged result of all the snippets in the folder. This doesn't delete the original ISE snippets.

          .Example 1 - Run Against a custom folder containing snippets to convert.
          Convert-ISESnippetToVSCodeSnippet -Path "C:\Users\$ENV:UserName\Documents\vscode\snippets" -Verbose

          .Example 2 - Default snippet path of user\Documents\WindowsPowershell
          Convert-ISESnippetToVSCodeSnippet

          .Example 3 - Default snippets to a copy at Vscode Insiders snippet file, overwriting if already exists, though it will create a backup
          Convert-ISESnippetToVSCodeSnippet -DestinationSnippetDirectory "C:\Users\$ENV:UserName\AppData\Roaming\Code - Insiders\User\snippets" -force -backup

          .Parameter Path
          Location of the snippets to convert (recursively)

          .Parameter DestinationSnippetDirectory
          Location to create the "powershell.json" file that will contain snippets. This should be a directory. By default set to same folder but can override with insiders snippet location for example

          .Parameter Force
          Force set content to overwrite any existing content in the destination file (good for syncing) and bypass the user prompt

          .Parameter Backup
          Backup existing file before overwriting for safety

          .Notes
          added some additional functionality to migrate directly to vscode insiders, and handle paths a little differently, as well as backup when overwriting content, sheldonhull 2017-11-08

#>
function Convert-ISESnippetToVSCodeSnippet
{
     [cmdletbinding()]
     Param
     (
          [parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
          [String[]]$Path = "$($HOME)\Documents\WindowsPowerShell\Snippets"

          , [string]$DestinationSnippetDirectory #optional, will default to same path as snippets if not provided
          , [switch]$Force
          ,[switch]$Backup
     )
     Begin
     {
          if([io.file]::Exists($DestinationSnippetDirectory))
          {
               throw "Provide directory to generate powershell.json, not a full file name path"
               exit
          }
          $vsCodeSnippets = @{}
          $DestinationSnippetDirectory = ($DestinationSnippetDirectory, $Path -ne '')[0]
          $DestinationSnippetFile = [io.path]::Combine($DestinationSnippetDirectory, 'powershell.json')

          if ([io.file]::Exists($DestinationSnippetFile))
          {
               write-verbose "Identified Powershell Snippets $DestinationSnippetDirectory existing"
               if (!$force)
               {
                    $response = read-host "Ok to overwrite target vscode powershell snippets json at $DestinationSnippetDirectory ?"
                    if ($response -ne 'y')
                    {
                         write-warning "You didn't select to continue, exiting script"
                         exit
                    }
               }
               if($backup)
               {
                    write-warning "Going to overrite the $DestinationSnippetFile`nCreating temporary backup just in case you didn't read my warning"
                    $BackupTimeStamp = get-date -format 'yyyyMMdd_hhmmss'
                    Copy-Item -path $DestinationSnippetFile -Destination ([io.path]::Combine((Split-Path $DestinationSnippetFile -Parent), ('BACKUP_{0}_powershell.json' -f $BackupTimeStamp)))
                    write-verbose "Backup created"
               }

          }

          if ((Get-Item $Path).Attributes -eq "Directory")
          {
               $SnippetsToConvert = Get-ChildItem $Path -Filter "*.ps1xml" -Recurse | Select-Object BaseName, FullName  | where {$_.Fullname -notmatch '\.history'}
          }
          else
          {
               $SnippetsToConvert = (Get-Item $Path).FullName | where {$_.Fullname -notmatch '\.history'}
               $SourceDirectory = (Get-Item $Path).Directory.FullName
               $BaseName = (Get-Item $Path).BaseName
          }

          write-verbose ("------- SNIPPETS TO CONVERT --------- {0}" -f ($SnippetsToConvert | Select-Object BaseName, FullName | format-table -autosize | out-string)) -Verbose
          write-verbose "Destination Snippet File: $DestinationSnippetFile"
          write-verbose "Pausing 5 sec"

     }
     Process
     {
          foreach ($p in $SnippetsToConvert.FullName)
          {
               try
               {

                    $snip = Get-Item $p
                    #$name = "$($snip.BaseName -replace ".snippets",'')"
                    Write-Verbose "Converting snippet: $($snip.BaseName)"

                    [xml]$xml = Get-Content $snip.FullName
                    $name = $xml.Snippets.Snippet.Header.Title
                    $prefix = "ISE_$($name -replace ' ','')"

                    write-debug "CaretOffset"
                    write-debug ($xml.Snippets.Snippet.Code.Script.CaretOffset | format-list | out-string) -Verbose
                    [int]$CaretOffset = [int]($xml.Snippets.Snippet.Code.Script.CaretOffset) - [int]1
                    $description = $xml.Snippets.Snippet.Header.Description
                    $snipHash = @{
                         prefix      = $prefix
                         body        = @()
                         description = $description
                    }
                    $code = $xml.Snippets.Snippet.Code.Script.'#cdata-section'
               }
               catch
               {
                    write-warning "Unable to convert this snippet file: $($Snip.Basename). Perhaps you have embedded complex xml or other syntax that is too difficult to parse?"
                    continue
               }
               try
               {
                    $codeIns = $code.Insert($CaretOffset, '$0')
                    $code = $codeIns
               }
               catch
               {
               }
               $code = $code.Replace('    ', '\t')
               $code = $code.Replace('$', '\$')
               $code -split "`n" | ForEach-Object {
                    $snipHash["body"] += "$_"
               }

               $vsCodeSnippets.Add("$name", $snipHash)
          }
     }

     End
     {
          ($vsCodeSnippets | ConvertTo-Json -Depth 10) | Format-Json -ErrorAction SilentlyContinue | Set-Content -Path $DestinationSnippetFile -Force:$Force
          (Get-Content $DestinationSnippetFile).replace('\\t', '\t').Replace('\\$0', '$0') | Set-Content -Path $DestinationSnippetFile -Force:$Force
          return $vsCodeSnippets
     }
}

