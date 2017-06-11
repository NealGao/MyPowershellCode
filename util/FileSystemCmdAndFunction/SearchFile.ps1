#1. Resolving path
Resolve-Path .\test.txt
#Resolve-Path expects the file to exist. if the file not exist, there will be an exception happend

#If you would like to resolve all paths, whether they exist or not, use the below one
$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\test.txt')
#This cmd will combine your file name with current path together, no matter the file name you put exist or not.

#2. Directory filter in Powershell 3.0+
Get-ChildItem $env:windir -Attributes !Directory+!System+Encrypted,!Directory+!System+Compressed -Recurse -ErrorAction SilentlyContinue
#pls note the -Attributes parameters supports these attributes:Archive,Compressed,Device,Directory,Encrypted,Hidden,Normal,NotContentIndexed,Offline,ReadOnly,ReparsePoint,SparseFile,System,Temporary

#3. find files only or folders only
#Powershell version 2 methods
Get-ChildItem E:\MySourceCode | Where-Object {$_.PSIsContainer -eq $true}
Get-ChildItem E:\MySourceCode | Where-Object {$_.PSIsContainer -eq $false}
#Can use the method like below in Powershell Version 3+
Get-ChildItem E:\MySourceCode -File
Get-ChildItem E:\MySourceCode -Directory

#4.find all commands that related with file system
Get-Command -Noun item*,path

#Also can find the commands accordinng to alias
Get-Alias -Definition *item*,*-path* | Select-Object Name,Definition | Out-GridView

#5. Clean temp folder with Powershell
$cutoff = (Get-Date) - (New-TimeSpan -Days 30)
$before = (Get-ChildItem $env:TEMP | Measure-Object Length -Sum).Sum

Get-ChildItem $env:TEMP | Where-Object {$_.Length -ne $null} | 
                         #remove -WhatIf to delete or replace with -Confirm to delete the temp file
                          Where-Object {$_.LastWriteTime -lt $cutoff} | Remove-Item -Force -ErrorAction SilentlyContinue -Recurse -WhatIf
$after = (Get-ChildItem $env:TEMP | Measure-Object Length -Sum).Sum
$freed = $before - $after

"Cleanup freed {0:0.0} MB" -f ($freed/1MB)

#6. Unblocking and unpacking zip file
#Pls note that this requires the built-in Windows ZIP support to be present and not replace with other ZIP tools
$source = 'F:\xxx\xxxx\xxxx.zip'
$destination= 'F:\xxxx\xxxx' #This folder must exist

Unblock-File $destination
$helper = New-Object -ComObject Shell.Application
$files = $helper.NameSpace($source).Items()
$helper.NameSpace($destination).CopyHere($files)

#7. Find Open Files
#To find open files on a remote system,use openfile.exe and convent the results to rich object
openfiles /Query /S remoteServerName /FO csv /V | ConvertFrom-Csv | Out-GridView

#8. Finding the Newest and oldest files
Get-ChildItem $env:windir | Measure-Object -Property Length -Minimum -Maximum | Select-Object -Property Minimum,Maximum

#In Powershell 3.0, can also measure properties like LastWriteTime，telling you the oldest and newest dates
Get-ChildItem $env:windir | Measure-Object -Property LastWriteTime -Minimum -Maximum | Select-Object -Property Minimum,Maximum

#Can also get the mininum and maximum start times of all the running process.Make sure you use Where-Object to exclude any process that has no StartTime value
Get-Process | Where-Object StartTime | Measure-Object -Property StartTime -Minimum -Maximum | Select-Object -Property Minimum,Maximum

#9. Finding duplicate files
Function Find-DuplicateName {  $Input | ForEach-Object {    if ($lookup.ContainsKey($_.Name))    {      ‘{0} ({1}) already exists in {2}.’ -f $_.Name, $_.FullName, $lookup.$($_.Name)    }    else    {      $lookup.Add($_.Name, $_.FullName)    }  } }

#Then you can use the function like below
$lookup = @{} 
Get-ChildItem $home | Find-DuplicateName 
Get-ChildItem $env:windir | Find-DuplicateName 
Get-ChildItem $env:windir\system32 | Find-DuplicateName

#10. find files that are older than a give number kof days to delete or backup those files.
#pls note you cannot change the "Filter" to "function", or the method will not work
Filter Filter-Age($Days = 30)
{
    if($_.CreationTime -le (Get-Date).AddDays($Days * -1))
    {
        $_ # you can delete or backup the file here
    }
}

#Then you can filter the file like below cmd
Get-ChildItem $HOME | Filter-Age -Days 10









