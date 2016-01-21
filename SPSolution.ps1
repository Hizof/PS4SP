#Download all wsp from farm

$dirName = "<directory path>" 
Write-Host Exporting solutions to $dirName  

foreach ($solution in Get-SPSolution)  
{  
    $id = $Solution.SolutionID  
    $title = $Solution.Name  
    $filename = $Solution.SolutionFile.Name 

    Write-Host "Exporting ‘$title’ to …\$filename" -nonewline  

    try {  
        $solution.SolutionFile.SaveAs("$dirName\$filename")  
        Write-Host " – done" -foreground green  
    }  
    catch  
    {  
        Write-Host " – error : $_" -foreground red  
    }  
}

#Add multiple farm solutions using power shell (Not Deploy)
#http://sharepoint.stackexchange.com/questions/38203/add-multiple-farm-solutions-using-power-shell-not-deploy

Remove-PSSnapin Microsoft.SharePoint.PowerShell -erroraction SilentlyContinue
Add-PSSnapin Microsoft.SharePoint.PowerShell -erroraction SilentlyContinue
function WaitForInsallation([string] $Name)
{
        Write-Host -NoNewline "Waiting for deployment job to complete" $Name "."
        $wspSol = get-SpSolution $Name
        while($wspSol.JobExists)
        {
            sleep 2
            Write-Host -NoNewline "."
            $wspSol = get-SpSolution $Name
        }
        Write-Host "job ended" -ForegroundColor green
}
Function Deploy-SPSolution ($WspFolderPath)
{
    $wspFiles = get-childitem $WspFolderPath | where {$_.Name -like "*.wsp"}

    ForEach($file in $wspFiles)
    {
        $wsp = Get-SPSolution | Where{$_.Name -eq $file.Name}
        if($wsp -eq $null)
        {
            write-host "Adding solution"
            Add-SPSolution -LiteralPath ($WspFolderPath + "\" + $file.Name)
        }
        else
        {
            write-host "solution already exists"

        }

    }
}
try
{
        Deploy-SPSolution "C:\EXPORTEDWSP"
}
catch
{
    write-host $_.exception

}
