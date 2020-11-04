param (
    [Parameter(Mandatory)][ValidatePattern("^[0-9A-Z]{2,8}$")]$bld, 
    [Parameter(Mandatory)][ValidatePattern("^[0-9A-Z]{2,8}$")]$rm, 
    [Parameter(Mandatory)][ValidatePattern("\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b")]$ip, 
    [Parameter(Mandatory)][ValidatePattern("^[0-9A-F]{2}$")]$ipid,
    [ValidateSet('DMPS3-300-C', 'fake')]$type="DMPS3-300-C",
    [switch]$force = $false
)



#defaults / setup
$path = "c:\xPanels"
$genFolder = "\generic"
$fileExt = "c3p"
$fileConfig = "swf/Environment.xml"
Add-Type -Assembly 'System.IO.Compression.FileSystem'
$compressionLevel = [System.IO.Compression.CompressionLevel]::Fastest
$fileConfigTemp = $path + "\" + [guid]::NewGuid().ToString() + ".xml"                # make this a tmp file and check



#Source xPanel
$zipSrc = $path + $genFolder + "\" + $type + "." + $fileExt
if (-not [System.IO.File]::Exists($zipSrc))
{
    write-host "Error: Source File Not Found: $zipSrc"
    exit
}

#Destination xPanel
$zipDst = $path +"\" + $bld + "_" + $rm + "." + $fileExt
if (    ([System.IO.File]::Exists($zipDst)) -and (-not $force) )
{
    write-host "Error: Destination File Exists: $zipDst, use -force"
    exit
}



#Copy Generic Panel File
Copy-Item $zipSrc -Destination $zipDst  -Force


#Extract Config File
$zip = [System.IO.Compression.ZipFile]::Open($zipDst, 'update')
$entry = $zip.Entries | Where-Object { $_.FullName -eq $fileConfig }
[System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $fileConfigTemp, $true)

#Update Config File
[xml]$xmlDoc = Get-Content $fileConfigTemp
$xmlDoc.Crestron.Properties.CNXConnection.Host.'#cdata-section' = $ip
$xmlDoc.Crestron.Properties.CNXConnection.IPID.'#cdata-section' = $ipid
$xmlDoc.Save($fileConfigTemp)

#Delete existing entry from ZIP
$entry.Delete()

#Add new file to ZIP
$clean = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $fileConfigTemp, $fileConfig)

#Cleanup
Remove-Item -Path $fileConfigTemp
$zip.Dispose()





#Add To RemoteApp Collection
$clean = New-RDRemoteApp -CollectionName "Admin Tools" -DisplayName "$bld $rm" -FilePath "C:\Program Files (x86)\Crestron\XPanel\CrestronXPanel\CrestronXPanel.exe" -FolderName  "xPanel" -CommandLineSetting Require -RequiredCommandLine $zipDst
