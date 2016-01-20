$web = Get-SPWeb http://web
$list = $web.GetList("/sites/site/Lists/MyList")
$i = $list.GetItemById(9000)

#Print all item visible fields
$i.Fields | 
    ?{ $_.Hidden -eq $false -and $_.ReadOnlyField -eq $false -and $_.Title -ne "Attachments" } | 
    %{@{($_.Title + " (" + $_.InternalName + ")") = $i[$_.InternalName]}} #| Out-GridView
    
$web.Dispose()
