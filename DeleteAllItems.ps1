function Clear-SPList($list)
{
    #variant A
    $items = $list.items
    foreach ($item in $items)
    {
        $list.GetItemById($Item.id).Delete()
    }
}

function Clear-SPList($list)
{
    #variant B
    $items = $list.items
    $count = $items.Count -1;
    for($intIndex = $count; $intIndex -ge 0; $intIndex--)
    {
       $items[$intIndex].Delete();
    }
}

function Clear-SPListBatch($list, $rowLimit = 500, $camlQuery = "")
{
    $query = new-object Microsoft.Sharepoint.SPQuery   
    $query.Query = $camlQuery
    $query.RowLimit = $rowLimit
	
    do
    {
        $items = $list.GetItems($query)
        $query.ListItemCollectionPosition = $Items.ListItemCollectionPosition
        Write-Host $query.ListItemCollectionPosition
        $count = $items.Count -1;
        Write-Host $count

        # http://www.theodells.org/theodells/blog/2012/10/powershell-function-to-delete-all-sharepoint-list-items/
        [System.Text.StringBuilder]$batchXml = New-Object "System.Text.StringBuilder"; 
        $batchXml.Append("<?xml version=`"1.0`" encoding=`"UTF-8`"?><Batch>")|Out-Null
        $cmd = "<Method><SetList Scope=`"Request`">" + $list.ID + "</SetList><SetVar Name=`"ID`">{0}</SetVar><SetVar Name=`"Cmd`">Delete</SetVar></Method>"
        
        for($intIndex = $count; $intIndex -ge 0; $intIndex--)
        {
            if($items[$intIndex] -ne $null)
            {
                $batchString = [System.String]::Format($cmd, $items[$intIndex].ID.ToString())
                $batchXml.Append($batchString)|Out-Null
            }
        }
        
        $batchXml.Append("</Batch>")|Out-Null
        $web.ProcessBatchData($batchXml.ToString())|Out-Null
    }
    while($query.ListItemCollectionPosition -ne $null)
}
