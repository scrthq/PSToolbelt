function Edit-FileHex {
    Param
    (
      [parameter(Mandatory=$true,Position=0)]
      [ValidateScript({Test-Path $_})]
      [ValidateNotNullOrEmpty()]
      [Alias("Path","File")]
      [String]
      $FilePath,
      [parameter(Mandatory=$true,Position=1)]
      [ValidateNotNullOrEmpty()]
      [Int]
      $Offset,
      [parameter(Mandatory=$true,Position=2)]
      [ValidateNotNullOrEmpty()]
      [String]
      $Original,
      [parameter(Mandatory=$true,Position=3)]
      [ValidateNotNullOrEmpty()]
      [String]
      $Updated,
      [parameter(Mandatory=$false)]
      [Switch]
      $OverwriteOriginal
    )
if ($OverwriteOriginal)
    {
    $NewFilePath = $FilePath
    }
else
    {
    $fileinfo = Get-Item $FilePath
    $NewFilePath = "$($fileinfo.Directory)\$($fileinfo.BaseName) (Hexed)$($fileinfo.Extension)"
    }
$bytes  = [System.IO.File]::ReadAllBytes($FilePath)
$current = [Convert]::ToString($($bytes[$Offset]),16)
if ($current -eq $Original)
    {
    $newByte = [Convert]::ToByte("$Updated",16)
    $bytes[$Offset] = $newByte
    [System.IO.File]::WriteAllBytes($NewFilePath, $bytes)
    }
}