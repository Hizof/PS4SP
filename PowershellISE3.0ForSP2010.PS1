# More inforation http://blogs.technet.com/b/anneste/archive/2014/09/17/how-to-enable-remote-powershell-for-sharepoint-2013-for-non-administrators.aspx
Register-PSSessionConfiguration -Name PS2 -PSVersion 2.0 –ShowSecurityDescriptorUI

# Please consult system admin when your run set-item and Enable-WSManCredSSP
set-item wsman:localhost\client\trustedhosts -value * -Confirm:$false -Force
Enable-WSManCredSSP -Role Client –DelegateComputer * -Force
Enable-WSManCredSSP -Role Server -Force

# For test purpose
# Get-WSManCredSSP
# get-item wsman:localhost\client\trustedhosts

$cred = Get-Credential
$session = New-PSSession -ComputerName $env:COMPUTERNAME -authentication credssp -ConfigurationName PS2 -Credential $cred
Enter-PSSession $session

Add-PSSnapin microsoft.sharepoint.powershell

$web = get-spweb http://SPSite/

$web.Url

Exit-PSSession

Unregister-PSSessionConfiguration -Name PS2

Disable-WSManCredSSP -Role Client
Disable-WSManCredSSP -Role Server
