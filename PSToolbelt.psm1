Param
(
  [parameter(Position=0)]
  $ForceDotSource = $false
)
#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$ModuleRoot = $PSScriptRoot

$_JobStartTime = Get-Date

#Execute a scriptblock to load each function instead of dot sourcing (Issue #5)
    foreach ($file in @($Public + $Private)) {
        if ($ForceDotSource) {
            . $file.FullName
        }
        else {
            $ExecutionContext.InvokeCommand.InvokeScript(
                $false, 
                (
                    [scriptblock]::Create(
                        [io.file]::ReadAllText(
                            $file.FullName,
                            [Text.Encoding]::UTF8
                        )
                    )
                ), 
                $null, 
                $null
            )
        }
    }
$_AddToLogContent = @()
$_LogArray = @()
$_ObjectArray = @()
$_AddToLogContent +=  "Job Started @ $($_JobStartTime.ToString())"
Export-ModuleMember -Function $Public.Basename -Variable _AddToLogContent,_LogArray,_ObjectArray,_JobStartTime