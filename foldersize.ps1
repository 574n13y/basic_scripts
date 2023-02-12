$logtime=Get-Date -Format yyyyMMddhhmm
$findFilesFoldersOutput = "C:\KchOps-Automations\Analyst Scripts\Test\Logs\log_$logtime.html";
$ServerList=Get-Content -Path "C:\KchOps-Automations\Analyst Scripts\Test\ServerList.txt"

foreach($ServerName in $ServerList)
{
$ServerName=$ServerName.ToUpper()
$Test_connection=Test-Path \\$ServerName\c$\ -ErrorAction SilentlyContinue
if($Test_connection -eq 'True')
{

Write-Host "*******------ Connected to $ServerName ------*******"
Invoke-Command -ComputerName $ServerName -ScriptBlock{
$ServerName=(Get-WmiObject Win32_OperatingSystem).CSName

$startFolder = "C:\Program Files", "C:\PerfLogs";
$totalSize = 0;

$colItems = Get-ChildItem $startFolder
foreach ($i in $colItems)
{
    $subFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
    $totalSize = $totalSize + $subFolderItems.sum / 1MB

}

$startFolder + " | " + "{0:N2}" -f ($totalSize) + " MB"

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$body= @" 
<table>
  <tr>
    <th>Step</th>
    <th>Status</th>
  </tr>
  <tr>
    <td>D</td>
    <td>FolderDected</td>
  </tr> 
</table><br><br>
"@


}
}
$body_part_2=$null


$datavalue=$datavalue=invoke-command -ComputerName $ServerName -scriptblock{ Get-WmiObject  -Class Win32_logicaldisk -Filter "DriveType = '3'" | Select-Object -Property DeviceID, VolumeName, @{L='startFolder';E={"{0:N2}" -f ($_.FreeSpace /1GB)}},@{L="totalSize";E={"{0:N2}" -f ($_.Size/1GB)}},@{L="FreePercent";E = {[Math]::floor((($_.FreeSpace/$_.Size) * 100))}}
}
foreach($data in $datavalue)
{
if($data.DeviceID -like "*c*")
{

    $Drive=$data.DeviceID
    
    $startFolder=$data.startFolder
    $totalSize=$data.totalSize
    $body_part_2=$body_part_2+ @" 
    
  <tr>
    <td>$servername</td>
    <td>$Drive</td>
    
     <td>$startFolder</td>
     <td>$totalSize</td>
     <td>$FreePercent</td>
	 <td>21</td>
  </tr>
  
  
"@
Write-Host "Drive : $Drive"
Write-Host "CurrentFreeSpace (in GB) : $startFolder"
Write-Host "TotalSpace (in GB) : $totalSize"
Write-Host "FreeSpaceInPercent : $FreePercent"
Write-Host "RecommendedFreeSpaceInPercent : 21"
Write-Host ""
  }  
     
}

$final_body=$body_part_1+$body_part_2+"</Table>"

ConvertTo-Html -Head $Header -Body $final_body|Out-File "$findFilesFoldersOutput" -Append

#Test_connection If ends
else
{
ConvertTo-Html -Body "<br><br><span style='font-family:Verdana;font-size:18pt;font-weight:bold;background-color:Red'>*******------ Unable to Connect $ServerName ------*******</span><br><br>" | Out-File "$findFilesFoldersOutput" -Append
Write-Host "*******------ Unable to Connect $ServerName ------*******" 
Write-Host ""
}#Test_connection else ends
}#Servername Foreach ends

$Subject = "Flodersize Utility Report | $logtime"
$smtp = "smtp.hosting.local"
$to="Email <viveshrokzz@yahoo.com>"
$from = "Foldersize Utility<noreply@vivesh.net>"
$body=Get-Content -Path "$findFilesFoldersOutput"|Out-String
send-MailMessage -SmtpServer $smtp -To $to -From $from  -Subject $Subject -BodyAsHtml $body
