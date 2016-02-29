# Get log from past two hours and specific correlation token
$date = (Get-Date).addhours(-2)
Get-SPLogEvent -StartTime $date | ?{$_.Correlation -eq "e2d97de8-75ed-4697-b421-131f4fad3464" }

# This example merges the log data for events in a particular time range, which is culture-specific to the United States.
# https://technet.microsoft.com/en-us/library/ff607721.aspx
Merge-SPLogFile -Path "C:\Logs\FarmMergedLog.log" -Overwrite -StartTime "06/09/2008 16:00" - EndTime "06/09/2008 16:15"
