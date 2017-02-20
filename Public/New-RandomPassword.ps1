function New-RandomPassword {
    Param
    (
      [parameter(Mandatory=$false)]
      [int]
      $Length = 15
    )
$ascii=$null
for ($a=33;$a –le 126;$a++)
    {
    $ascii+=,[char][byte]$a
    }
for ($loop=1; $loop –le $length; $loop++) 
    {
    $RandomPassword+=($ascii | Get-Random)
    }
return $RandomPassword
}