function Get-TrueCount{
    Param
    (
      [parameter(Mandatory=$false,Position=0)]
      $Array
    )
if ($array)
   {
   if ($array.Count)
       {
       Write-Verbose "Count is more than 1!"
       $count = $array.Count
       }
   else
       {
       Write-Verbose "Count is 1!"
       $count = 1
       }
   }
else
   {
   Write-Verbose "Input array is empty!"
   $count = 0
   }
return $count
}