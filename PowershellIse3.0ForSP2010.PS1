Register-PSSessionConfiguration -Name PS2 -PSVersion 2.0 –ShowSecurityDescriptorUI

set-item wsman:localhost\client\trustedhosts -value localhost
Enable-WSManCredSSP -Role Client –DelegateComputer localhost

Enable-WSManCredSSP -Role Server

$cred = Get-Credential
$session = New-PSSession -ComputerName localhost -authentication credssp -ConfigurationName PS2 -Credential $cred
Enter-PSSession $session

Add-PSSnapin microsoft.sharepoint.powershell
$web = get-spweb http://SPSite/
$web.Url

Exit-PSSession

Unregister-PSSessionConfiguration -Name PS2

Disable-WSManCredSSP -Role Client
Disable-WSManCredSSP -Role Server
