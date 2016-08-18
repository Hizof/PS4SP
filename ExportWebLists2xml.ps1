function AddWebNode($web)
{
    Write-Host "Добавление SPSite" -BackgroundColor Cyan
    [System.XML.XMLElement]$webNode=$websNode.appendChild($oXMLDocument.CreateElement("web"))
    $webNode.SetAttribute("Title", $web.Title)
    $webNode.SetAttribute("ServerRelativeUrl", $web.ServerRelativeUrl)
    return $webNode
}

function AddListsNode($webNode)
{
    Write-Host "Добавление Lists" -BackgroundColor Cyan
    [System.XML.XMLElement]$listsNode=$webNode.appendChild($oXMLDocument.CreateElement("lists"))
    return $listsNode
}

function AddListNode($list, $listsNode)
{
    Write-Host "Добавление List" -BackgroundColor Cyan
    [System.XML.XMLElement]$listNode=$listsNode.appendChild($oXMLDocument.CreateElement("list"))
    $listNode.SetAttribute("Title", $list.Title)
    return $listNode
}

function AddListItemsNode($listNode)
{
    Write-Host "Добавление ListItems" -BackgroundColor Cyan
    [System.XML.XMLElement]$listItemsNode=$listNode.appendChild($oXMLDocument.CreateElement("listItems"))
    return $listItemsNode
}

function AddListItemNode($listItem, $listItemsNode)
{
    Write-Host "Добавление ListItem" -BackgroundColor Cyan
    [System.XML.XMLElement]$listItemNode=$listItemsNode.appendChild($oXMLDocument.CreateElement("listItem"))

    $listItem.Fields  | 
    #?{ $_.Hidden -eq $false -and $_.ReadOnlyField -eq $false -and $_.Title -ne "Attachments" } | 
    %{
        $listItemNode.SetAttribute($_.InternalName, $listItem[$_.InternalName])
     }
    
    return $listItemNode
}

function AddListItemPropertiesNode($listItemNode)
{
    Write-Host "Добавление ListItem Properties" -BackgroundColor Cyan
    [System.XML.XMLElement]$ListItemPropertiesNode=$listItemNode.appendChild($oXMLDocument.CreateElement("ListItemProperties"))
    return $ListItemPropertiesNode
}

function AddListItemPropertyNode($listItemPropertyName, $listItemPropertyValue, $ListItemPropertiesNode)
{
    Write-Host "Добавление listItemProperty" -BackgroundColor Cyan
    [System.XML.XMLElement]$listItemPropertyNode=$ListItemPropertiesNode.appendChild($oXMLDocument.CreateElement("ListItemProperty"))

    $listItemPropertyNode.SetAttribute("Name", $listItemPropertyName)
    $listItemPropertyNode.SetAttribute("Value", $listItemPropertyValue)
}

function ExportSPListItem($listItem, $listItemsNode)
{
    Write-Host $listItem.Title -ForegroundColor Green

    $listItemNode = AddListItemNode $listItem $listItemsNode

    $listItemProperiesNode = AddListItemPropertiesNode $listItemNode
    if($listItem.Properties.Count -gt 0)
    {
        $listItem.Properties.Keys | %{
          AddListItemPropertyNode $_ $listItem.Properties[$_] $listItemProperiesNode
        }
    } 
}

function ExportSPList($list, $listsNode)
{
    Write-Host $list.Title -ForegroundColor Green

    $listNode = AddListNode $list $listsNode
    $listItemsNode = AddListItemsNode $listNode

    $list.Items | %{
      ExportSPListItem $_ $listItemsNode
    } 
}

function ExportSPWeb($web)
{
    Write-Host $web.Url -ForegroundColor Green

    $webNode = AddWebNode $web
    $listsNode = AddListsNode $webNode

    $web.Lists | %{
      ExportSPList $_ $listsNode 
    }
}


[System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument
[System.XML.XMLElement]$oXMLRoot=$oXMLDocument.CreateElement("root")
$tmp = $oXMLDocument.appendChild($oXMLRoot)
[System.XML.XMLElement]$websNode=$oXMLRoot.appendChild($oXMLDocument.CreateElement("webs"))


ExportSPWeb($web)

<#$web.Webs | %{
    ExportSPWeb $_
    $_.Dispose()
}#>

$oXMLDocument.Save("C:\listexp.xml")
