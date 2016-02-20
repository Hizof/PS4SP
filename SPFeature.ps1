function Reactivate-SPFeature($Identity, $url, $Confirm)
{
	Disable-SPFeature –Identity $Identity –url $url –Confirm:$Confirm
	Enable-SPFeature –Identity $Identity –url $url
}

Reactivate-SPFeature "5a578ec2-a66c-491f-a71f-e61e6a78e413" $web.Url $false
