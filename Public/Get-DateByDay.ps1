function Get-DateByDay {
    Param
    (
      [parameter(Mandatory=$false)]
      [ValidateSet("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")]
      [String]
      $DayOfWeek=$((Get-Date).DayOfWeek),
      [parameter(Mandatory=$false)]
      [Int]
      $AddWeeks=0,
      [parameter(Mandatory=$false)]
      [String]
      $Format
    )
$DateParams = @{}
$Week = (Get-Date).AddDays($($AddWeeks * 7))
if ($Format){$DateParams.Add("Format",$Format)}
$dayHash = @{
    Sunday=1
    Monday=2
    Tuesday=3
    Wednesday=4
    Thursday=5
    Friday=6
    Saturday=7
    }
return Get-Date $([datetime]$Week.AddDays($dayHash.Item("$DayOfWeek") - $dayHash.Item("$($Week.DayOfWeek)"))) @DateParams
}