function Convert-DateToEpoch {
    Param
    (
      [parameter(Mandatory=$true,Position=0)]
      [DateTime]
      $Date
    )
    [Math]::Floor([decimal](Get-Date($Date).ToUniversalTime()-uformat "%s"))
}