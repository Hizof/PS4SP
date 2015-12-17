#variant A
$list = $web.GetList("/Lists/TestList")
$items = $list.items
foreach ($item in $items)
{
    $list.GetItemById($Item.id).Delete()
}

#variant B
$list = $web.GetList("/Lists/TestList")
$items = $list.items
$count = $items.Count -1;
for($intIndex = $count; $intIndex -ge 0; $intIndex--)
{
   $items[$intIndex].Delete();
}
