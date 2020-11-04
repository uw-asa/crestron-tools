#Config
$targetBuildingCode = "UW"
$targetRoomNumber = "2020"
$targetHost = "172.25.0.1"
$targetIPID = "15"

#Defaults
$pathRoot = "C:\xPanels\"
$zipFileSource = "zzzGenericDMPS.c3p"
$fileToEdit = "swf/Environment.xml"
$zipFile = $targetBuildingCode + "_" + $targetRoomNumber + ".c3p"



#Copy Generic Panel File
Copy-Item "$pathRoot$zipFileSource" -Destination "$pathRoot$zipFile"  -Force

#Define Compression Options
Add-Type -Assembly 'System.IO.Compression.FileSystem'
$compressionLevel = [System.IO.Compression.CompressionLevel]::Fastest
$zipFilePath = $pathRoot + $zipFile

#Extract Environment.xml
$zip = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'update')
$entry = $zip.Entries | Where-Object { $_.FullName -eq $fileToEdit }
$fileName = $entry.Name
[System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, "$pathRoot$fileName", $true)

#Update Environment.xml
[xml]$xmlDoc = Get-Content "$pathRoot$fileName"
$xmlDoc.Crestron.Properties.CNXConnection.Host.'#cdata-section' = $targetHost
$xmlDoc.Crestron.Properties.CNXConnection.IPID.'#cdata-section' = $targetIPID
$xmlDoc.Save("$pathRoot$fileName")

#Delete existing entry from ZIP
$entry.Delete()

#Add new file to ZIP
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$pathRoot\$fileName", $fileToEdit)

#Cleanup
Remove-Item -Path "$pathRoot\$fileName"
$zip.Dispose()


#Add To RemoteApp Collection
$appDisplayName = $targetBuildingCode + " " + $targetRoomNumber
New-RDRemoteApp -CollectionName "Admin Tools" -DisplayName $appDisplayName -FilePath "C:\Program Files (x86)\Crestron\XPanel\CrestronXPanel\CrestronXPanel.exe" -FolderName  "xPanel" -CommandLineSetting Require -RequiredCommandLine $zipFilePath



