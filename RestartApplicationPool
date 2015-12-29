# Load IIS module:
Import-Module WebAdministration
# Adds registered Microsoft SharePoint PowerShell snap-ins
Add-PSSnapin "Microsoft.SharePoint.PowerShell"
# Get SharePoint Web Application
$app = Get-SPWebApplication http://site/
# Get pool name from web application:
$poolName = Stop-WebAppPool $app.ApplicationPool.Name
# Recycle the application pool:
Restart-WebAppPool $poolName
