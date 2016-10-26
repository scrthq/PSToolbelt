function Convert-WebSafeBase64ToNormal {
    Param
    (
      [parameter(Mandatory=$true,Position=0)]
      [String]
      $WebSafeBase64String,
      [parameter(Mandatory=$false)]
      [String]
      $OutFile
    )
$WebSafeBase64String = $WebSafeBase64String.Replace('_', '/').Replace('-', '+')
switch ($WebSafeBase64String.Length % 4)
    {
    2 {$WebSafeBase64String += "=="}
    3 {$WebSafeBase64String += "="}
    }
if ($OutFile)
    {
    $WebSafeBase64String | Out-File $OutFile
    }
else
    {
    return $WebSafeBase64String
    }
}