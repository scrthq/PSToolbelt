function Test-RegEx {
    Param
    (
      [parameter(Mandatory=$true,Position=0)]
      [RegEx]
      $RegEx,
      [parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]
      [String[]]
      $String
    )
    Process {
        foreach ($S in $String) {
            [PSCustomObject][Ordered]@{
                String = $S
                RegEx = $RegEx
                Match = $($S -match $RegEx)
            }
        }
    }
}