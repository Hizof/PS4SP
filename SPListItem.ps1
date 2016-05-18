$web = Get-SPWeb http://web
$list = $web.GetList("/sites/site/Lists/MyList")
$i = $list.GetItemById(9000)

#Print all item visible fields
$i.Fields | 
    ?{ $_.Hidden -eq $false -and $_.ReadOnlyField -eq $false -and $_.Title -ne "Attachments" } | 
    %{@{($_.Title + " (" + $_.InternalName + ")") = $i[$_.InternalName]}} #| Out-GridView

#Copy SPListItem to new SPList
function Copy-SPListItem($sourceItem, $destinationList)
{
    $destinationItem = $destinationList.AddItem()
    
    $destinationItem["Title"] = $sourceItem["Title"]

    $sourceItem.Fields |?{$_.SourceId -ne "http://schemas.microsoft.com/sharepoint/v3"}| %{
        $destinationItem[$_.InternalName] = $sourceItem[$_.InternalName]
    }

    $destinationItem.Update()

    return $destinationItem
}

#Query
$spQuery = New-Object Microsoft.SharePoint.SPQuery
$spQuery.ViewAttributes = "Scope='Recursive'";
$spQuery.RowLimit = 2000
$caml = '<Query><Where><IsNull><FieldRef Name="Title" /></IsNull></Where></Query>' 
$spQuery.Query = $caml 

do
{
    $listItems = $list.GetItems($spQuery)
    $spQuery.ListItemCollectionPosition = $listItems.ListItemCollectionPosition
    foreach($item in $listItems)
    {
        Write-Host $item.Title
    }
}
while ($spQuery.ListItemCollectionPosition -ne $null)

    
$web.Dispose()
