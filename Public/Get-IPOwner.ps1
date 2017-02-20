function Get-IPOwner {
    Param
    (
      [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
      [String]
      $IP,
      [parameter(Mandatory=$false)]
      [ValidateSet("XML","JSON","Text","HTML")]
      [String]
      $Format = "JSON"
    )
$fmtHash = @{
    XML = "application/xml"
    JSON = "application/json"
    Text = "text/plain"
    HTML = "text/html"
    }
$headers = @{
    Accept = $fmtHash[$Format]
    }
$URI = "http://whois.arin.net/rest/ip/$IP"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $headers
if ($Format -eq "Text")
    {
    $result = $result -split "`n" | Where-Object {$_ -notlike "#*" -and ![string]::IsNullOrWhiteSpace($_)}
    }
elseif ($Format -eq "JSON")
    {
    $result = $result.net
    }
return $result
}