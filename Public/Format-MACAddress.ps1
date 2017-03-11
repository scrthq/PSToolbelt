function Format-MACAddress {
    Param
    (
      [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
      [ValidateScript({if(($_ -replace '[^a-fA-F0-9]','').length -eq 12){$true}else{throw "Input string $_ ($($_ -replace '[^a-fA-F0-9]','')) is not a valid MAC after non-alphanumeric characters were removed. This will not format a string correctly unless it is a valid MAC address."}})]
      [String[]]
      $String,
      [parameter(Mandatory=$false,Position=1)]
      [String]
      $Delimiter = ":",
      [parameter(Mandatory=$false,Position=2)]
      [ValidateSet("Upper","Lower")]
      [String]
      $Case = "Upper"
    )
Process
    {
    foreach ($S in $String)
        {
        if (![string]::IsNullOrEmpty($Delimiter))
            {
            Write-Output ((((($S -replace '[^a-fA-F0-9]','')."To$($Case)"().insert(2,$Delimiter)).insert(5,$Delimiter)).insert(8,$Delimiter)).insert(11,$Delimiter)).insert(14,$Delimiter)
            }
        else
            {
            Write-Output ($S -replace '[^a-fA-F0-9]','')."To$($Case)"()
            }
        }
    }
}