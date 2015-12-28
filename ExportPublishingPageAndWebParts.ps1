Add-PSSnapin microsoft.sharepoint.powershell

function AddWebNode($web)
{
    Write-Host "Добавление SPSite" -BackgroundColor Cyan
    [System.XML.XMLElement]$webNode=$websNode.appendChild($oXMLDocument.CreateElement("web"))
    $webNode.SetAttribute("url", $web.ServerRelativeUrl)
    $webNode.SetAttribute("folder", $web.ServerRelativeUrl.Replace("/",""))
    return $webNode
}

function AddPagesNode($webNode)
{
    Write-Host "Добавление Pages" -BackgroundColor Cyan
    [System.XML.XMLElement]$pagesNode=$webNode.appendChild($oXMLDocument.CreateElement("pages"))
    return $pagesNode
}

function AddPageNode($page, $pagesNode)
{
    Write-Host "Добавление Page" -BackgroundColor Cyan
    [System.XML.XMLElement]$pageNode=$pagesNode.appendChild($oXMLDocument.CreateElement("page"))
    $pageNode.SetAttribute("url", ("/"+$page.Url))
    $pageNode.SetAttribute("folder", $page.DisplayName)
    $pageNode.SetAttribute("PublishingPageLayout", $page.Properties["PublishingPageLayout"])
    return $pageNode
}

function AddWebPartsNode($pageNode)
{
    Write-Host "Добавление WebParts" -BackgroundColor Cyan
    [System.XML.XMLElement]$webPartsNode=$pageNode.appendChild($oXMLDocument.CreateElement("webparts"))
    return $webPartsNode
}

function AddWebPartNode($webPart, $wpm, $webPartsNode)
{
    Write-Host "Добавление WebPart" -BackgroundColor Cyan
    [System.XML.XMLElement]$webPartNode=$webPartsNode.appendChild($oXMLDocument.CreateElement("webpart"))
    $webPartNode.SetAttribute("TypeName", $webPart.GetType().Name)
    $webPartNode.SetAttribute("ZoneID", $wpm.GetZoneID($webPart))
    $webPartNode.SetAttribute("TabIndex", $webPart.TabIndex)
    $webPartNode.SetAttribute("ZoneIndex", $webPart.ZoneIndex)
    $webPartNode.SetAttribute("FileName", ($webPart.GetType().Name + "_" + $wpm.GetZoneID($webPart) + "_" + $webPart.ZoneIndex + ".xml"))

    return $webPartNode
}

function CheckPublishingWebFeatureActivated($web)
{
    try{
        $feature = Get-SPFeature 94c94ca6-b32f-4da9-a9e3-1f3d343d7ecb -Web $rootWeb
    }catch [system.exception]
    {
        return $false
    }
    if($feature -ne $null)
    {
        return $true;
    }
    else
    {
        return $false;
    }
}

function ExportWebPart($wpm, $webPart, $page, $webPartsNode)
{
    if($webPart -eq $null)
    {
        Write-Host "Произошла ошибка при экспорте веб части. Перепроверьте все ли выбчасти отображаются корректно." -BackgroundColor Red
        return;
    }

    try{
        if(!$exportedWebParts.Contains($webPart.GetType().Name.ToLower()))
        {
            Write-Host ("Веб часть с типом " + $webPart.GetType().Name + " была исключена из экспорта") -BackgroundColor DarkYellow
            return $false;
        }

        Write-Host ">>> >>>" $webPart.GetType().Name -ForegroundColor Green -NoNewLine
        Write-Host "`t" $wpm.GetZoneID($webPart) -ForegroundColor Cyan -NoNewLine
        Write-Host " `tPartOrder" $webPart.PartOrder "TabIndex" $webPart.TabIndex "ZoneIndex" $webPart.ZoneIndex "FilterName" $webPart.FilterName
        
        $path = ($page.ParentList.ParentWeb.ServerRelativeUrl.Remove(0,1) + "\"+ $page.DisplayName).Replace("/","\")
        if($path.IndexOf("\") -eq 0)
        {
            $path = $path.Remove(0,1)
        }
        $pageDirectory = [System.IO.Path]::Combine($LocalStorePath, $path)
        #Write-Host $pageDirectory
        [System.IO.Directory]::CreateDirectory($pageDirectory) | Out-Null
        $wpFile = [System.IO.Path]::Combine($pageDirectory, ($webPart.GetType().Name + "--" + $webPart.FilterName + ".xml"))
        $writer = New-Object XML.XmlTextWriter ( $wpFile , ([Text.Encoding]::Unicode) )
        $webPart.ExportMode = "All"
        $wpm.ExportWebPart($webPart, $writer)
        $writer.Flush()
        $writer.Close()
        
        $webPartNode = AddWebPartNode $webPart $wpm $webPartsNode

        return $true;
    }catch{
        write-host $_.Exception.Message
        Write-Host ("Не возможно экпортировать веб часть с типом " + $webPart.GetType())  -BackgroundColor Red
        return $false;
    }
}

function ExportPage($web, $page, $pagesNode)
{
    Write-Host ">>>" $page.Url -ForegroundColor Green -NoNewLine
    Write-Host "" $page.Properties["PublishingPageLayout"] -ForegroundColor DarkYellow
    
    $pageNode = AddPageNode $page $pagesNode
    $webPartsNode = AddWebPartsNode $pageNode

    $wpm = $web.GetLimitedWebPartManager($page.Url, [System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
    $successExportWebPart = $false;
    $wpm.WebParts | %{
        $ewpResult = ExportWebPart $wpm $_ $page $webPartsNode
        if($ewpResult -eq $true)
        {
            $successExportWebPart = $true;
        }
    }
    if(!$successExportWebPart)
    {
        $pagesNode.RemoveChild($pageNode)
        Write-Host ("Страница " + $page.Url + " была исключена из экспорта из отсутствия веб частей для экспорта") -BackgroundColor DarkYellow
    }
    
    $wpm.Web.Dispose();

    return $successExportWebPart;
}

function ExportSPWeb($web)
{
    Write-Host $web.Url -ForegroundColor Green
    $pweb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($web)
    if($pweb.PagesList -eq $null)
    {
        Write-Host "Бибилиотека Pages работает не корректно"  -BackgroundColor Red
        return;
    }

    $webNode = AddWebNode $web
    $pagesNode = AddPagesNode $webNode

    $successExportPage = $false;
    $pweb.PagesList.Items | %{
        $epresult = ExportPage $web $_ $pagesNode
        if($epresult -eq $true)
        {
            $successExportPage = $true;
        }
    }

    if(!$successExportPage)
    {
        $websNode.RemoveChild($webNode)
        Write-Host ("Сайт " + $web.Url + " был исключен из экспорта из отсутствия страниц для экспорта") -BackgroundColor DarkYellow
    }
    #return $successExportPage
}


[System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument
[System.XML.XMLElement]$oXMLRoot=$oXMLDocument.CreateElement("root")
$tmp = $oXMLDocument.appendChild($oXMLRoot)
[System.XML.XMLElement]$websNode=$oXMLRoot.appendChild($oXMLDocument.CreateElement("webs"))

$site = Get-SPSite http://rshbpr-wapp-01/
$rootWeb = $site.RootWeb

$exportedWebParts = ("MyWebPart").ToLower()
$LocalStorePath = "C:\export"


if(CheckPublishingWebFeatureActivated($rootWeb))
{
    ExportSPWeb $rootWeb
}

$rootWeb.Webs | %{
    if(CheckPublishingWebFeatureActivated($_))
    {
        ExportSPWeb $_
        $_.Dispose()
    }
}

$rootWeb.Dispose()
$site.Dispose()
$oXMLDocument.Save($LocalStorePath + "\webparts.xml")
