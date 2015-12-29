# Get log from past two hours and specific correlation token
$date = (Get-Date).addhours(-2)
Get-SPLogEvent -StartTime $date | ?{$_.Correlation -eq "e2d97de8-75ed-4697-b421-131f4fad3464" }
