
Set-ExecutionPolicy -ExecutionPolicy Bypass
<# AUTOMATION FOR JOINING TO AAD 


PROCESS 

1.) Backup Chrome Bookmarks to Onedrive
2.) Backup Edge bookmarks to onedrive
3.) Phase 2 Disconnect Email Accounts - has to be done Manually 
4.) Add domain admin local user.
4.) Disconnect from The domain (will need the domain admin creds) Complete 
5.) Log the user into AAD - Has to be done manually.

#> 


# START THE BACKUP PROCESS 

Function Backup_Folder {
New-item "$($env:userprofile)\Desktop\AAD Backup" -Type Directory
$export = "$($env:userprofile)\Desktop\AAD Backup"
}

Function Backup_Desktop {
Copy-Item -Path "$($env:userprofile)\Desktop\*" -Destination "$($env:userprofile)\Desktop\AAD Backup" -Recurse
}

Function Backup_Documents { 
Copy-Item -Path "$($env:userprofile)\Documents\*" -Destination "$($env:userprofile)\Desktop\AAD Backup" -Recurse
}



# 1. BACKUP EDGE BOOKMARKS 

function Edge_Bookmarks {
### Definitions
$EdgeStable="Edge"
$EdgeBeta="Edge Beta"
$EdgeDev="Edge Dev"
$ExportedTime = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'

### Choose the Edge Release ($EdgeStable, $EdgeBeta, $EdgeDev) you like to Backup:
$EdgeRelease=$EdgeStable

### Path to Edge Bookmarks Source-File
$JSON_File_Path = "$($env:localappdata)\Microsoft\$($EdgeRelease)\User Data\Default\Bookmarks"

### Directory where to store HTML-Export (Backup-Destination-Directory)
#$HTML_File_Dir = "C:\Temp"
#$HTML_File_Dir = "$($env:userprofile)\backup"
#$HTML_File_Dir = "$($env:userprofile)"
$HTML_File_Dir = "$($env:userprofile)\Desktop\AAD Backup"

### Filename of HTML-Export (Backup-Filename), choose with YYYY-MM-DD_HH-MM-SS Date-Suffix or fixed Filename
#$HTML_File_Path = "$($HTML_File_Dir)\EdgeChromium-Bookmarks.backup.html"
$HTML_File_Path = "$($HTML_File_Dir)\Edge-Bookmarks.backup_$($ExportedTime).html"

## Reference-Timestamp needed to convert Timestamps of JSON (Milliseconds / Ticks since LDAP / NT epoch 01.01.1601 00:00:00 UTC) to Unix-Timestamp (Epoch)
$Date_LDAP_NT_EPOCH = Get-Date -Year 1601 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0

if (!(Test-Path -Path $JSON_File_Path -PathType Leaf)) {
    throw "Source-File Path $JSON_File_Path does not exist!" 
}
if (!(Test-Path -Path $HTML_File_Dir -PathType Container)) { 
    throw "Destination-Directory Path $HTML_File_Dir does not exist!" 
}

# ---- HTML Header ----
$BookmarksHTML_Header = @'
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
'@

$BookmarksHTML_Header | Out-File -FilePath $HTML_File_Path -Force -Encoding utf8

# ---- Enumerate Bookmarks Folders ----
Function Get-BookmarkFolder {
    [cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        $Node 
    )
    function ConvertTo-UnixTimeStamp {
        param(
            [Parameter(Position = 0, ValueFromPipeline = $True)]
            $TimeStamp 
        )
        $date = [Decimal] $TimeStamp
        if ($date -gt 0) { 
            # Timestamp Conversion: JSON-File uses Timestamp-Format "Ticks-Offset since LDAP/NT-Epoch" (reference Timestamp, Epoch since 1601 see above), HTML-File uses Unix-Timestamp (Epoch, since 1970)																																																   
            $date = $Date_LDAP_NT_EPOCH.AddTicks($date * 10) # Convert the JSON-Timestamp to a valid PowerShell date
            # $DateAdded # Show Timestamp in Human-Readable-Format (Debugging-purposes only)																					
            $date = $date | Get-Date -UFormat %s # Convert to Unix-Timestamp
            $unixTimeStamp = [int][double]::Parse($date) - 1 # Cut off the Milliseconds
            return $unixTimeStamp
        }
    }   
    if ($node.name -like "Favorites Bar") {
        $DateAdded = [Decimal] $node.date_added | ConvertTo-UnixTimeStamp
        $DateModified = [Decimal] $node.date_modified | ConvertTo-UnixTimeStamp
        "        <DT><H3 FOLDED ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`" PERSONAL_TOOLBAR_FOLDER=`"true`">$($node.name )</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
        "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
    }
    foreach ($child in $node.children) {
        $DateAdded = [Decimal] $child.date_added | ConvertTo-UnixTimeStamp    
        $DateModified = [Decimal] $child.date_modified | ConvertTo-UnixTimeStamp
        if ($child.type -eq 'folder') {
            "        <DT><H3 ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`">$($child.name)</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
            "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
            Get-BookmarkFolder $child # Recursive call in case of Folders / SubFolders
            "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
        }
        else {
            # Type not Folder => URL
            "        <DT><A HREF=`"$($child.url)`" ADD_DATE=`"$($DateAdded)`">$($child.name)</A>" | Out-File -FilePath $HTML_File_Path -Append -Encoding utf8
        }
    }
    if ($node.name -like "Favorites Bar") {
        "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
    }
}

# ---- Convert the JSON Contens (recursive) ----
$data = Get-content $JSON_File_Path -Encoding UTF8 | out-string | ConvertFrom-Json
$sections = $data.roots.PSObject.Properties | Select-Object -ExpandProperty name
ForEach ($entry in $sections) { 
    $data.roots.$entry | Get-BookmarkFolder
}

# ---- HTML Footer ----
'</DL>' | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
}



#2. BACKUP CHROME BOOKMARKS 

function Chrome_Bookmarks {
### Definitions
$ChromeStable="Chrome"
$ChromeBeta="Chrome Beta"
$ChromeDev="Chrome Dev"
$ExportedTime = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'

### Choose the Edge Release ($EdgeStable, $EdgeBeta, $EdgeDev) you like to Backup:
$ChromeRelease=$ChromeStable

### Path to Edge Bookmarks Source-File

$JSON_File_Path = "$($env:localappdata)\google\chrome\User Data\Default\Bookmarks"

### Directory where to store HTML-Export (Backup-Destination-Directory)
#$HTML_File_Dir = "C:\Temp"
#$HTML_File_Dir = "$($env:userprofile)\backup"
#$HTML_File_Dir = "$($env:userprofile)"
$HTML_File_Dir = "$($env:userprofile)\Desktop\AAD Backup"

### Filename of HTML-Export (Backup-Filename), choose with YYYY-MM-DD_HH-MM-SS Date-Suffix or fixed Filename
#$HTML_File_Path = "$($HTML_File_Dir)\EdgeChromium-Bookmarks.backup.html"
$HTML_File_Path = "$($HTML_File_Dir)\Chrome-Bookmarks.backup_$($ExportedTime).html"

## Reference-Timestamp needed to convert Timestamps of JSON (Milliseconds / Ticks since LDAP / NT epoch 01.01.1601 00:00:00 UTC) to Unix-Timestamp (Epoch)
$Date_LDAP_NT_EPOCH = Get-Date -Year 1601 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0

if (!(Test-Path -Path $JSON_File_Path -PathType Leaf)) {
    throw "Source-File Path $JSON_File_Path does not exist!" 
}
if (!(Test-Path -Path $HTML_File_Dir -PathType Container)) { 
    throw "Destination-Directory Path $HTML_File_Dir does not exist!" 
}

# ---- HTML Header ----
$BookmarksHTML_Header = @'
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
'@

$BookmarksHTML_Header | Out-File -FilePath $HTML_File_Path -Force -Encoding utf8

# ---- Enumerate Bookmarks Folders ----
Function Get-BookmarkFolder {
    [cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        $Node 
    )
    function ConvertTo-UnixTimeStamp {
        param(
            [Parameter(Position = 0, ValueFromPipeline = $True)]
            $TimeStamp 
        )
        $date = [Decimal] $TimeStamp
        if ($date -gt 0) { 
            # Timestamp Conversion: JSON-File uses Timestamp-Format "Ticks-Offset since LDAP/NT-Epoch" (reference Timestamp, Epoch since 1601 see above), HTML-File uses Unix-Timestamp (Epoch, since 1970)																																																   
            $date = $Date_LDAP_NT_EPOCH.AddTicks($date * 10) # Convert the JSON-Timestamp to a valid PowerShell date
            # $DateAdded # Show Timestamp in Human-Readable-Format (Debugging-purposes only)																					
            $date = $date | Get-Date -UFormat %s # Convert to Unix-Timestamp
            $unixTimeStamp = [int][double]::Parse($date) - 1 # Cut off the Milliseconds
            return $unixTimeStamp
        }
    }   
    if ($node.name -like "Favorites Bar") {
        $DateAdded = [Decimal] $node.date_added | ConvertTo-UnixTimeStamp
        $DateModified = [Decimal] $node.date_modified | ConvertTo-UnixTimeStamp
        "        <DT><H3 FOLDED ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`" PERSONAL_TOOLBAR_FOLDER=`"true`">$($node.name )</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
        "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
    }
    foreach ($child in $node.children) {
        $DateAdded = [Decimal] $child.date_added | ConvertTo-UnixTimeStamp    
        $DateModified = [Decimal] $child.date_modified | ConvertTo-UnixTimeStamp
        if ($child.type -eq 'folder') {
            "        <DT><H3 ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`">$($child.name)</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
            "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
            Get-BookmarkFolder $child # Recursive call in case of Folders / SubFolders
            "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
        }
        else {
            # Type not Folder => URL
            "        <DT><A HREF=`"$($child.url)`" ADD_DATE=`"$($DateAdded)`">$($child.name)</A>" | Out-File -FilePath $HTML_File_Path -Append -Encoding utf8
        }
    }
    if ($node.name -like "Favorites Bar") {
        "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
    }
}

# ---- Convert the JSON Contens (recursive) ----
$data = Get-content $JSON_File_Path -Encoding UTF8 | out-string | ConvertFrom-Json
$sections = $data.roots.PSObject.Properties | Select-Object -ExpandProperty name
ForEach ($entry in $sections) { 
    $data.roots.$entry | Get-BookmarkFolder
}

# ---- HTML Footer ----
'</DL>' | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
}



<#3 BACKUP FIREFOX BOOKMARKS #> 

function Firefox_Bookmarks {
$MozillaPlaces = (gci "$env:userprofile\appdata\Roaming\Mozilla\Firefox\Profiles" -force -recurse -ErrorAction SilentlyContinue | ?{$_.Name -eq 'places.sqlite'}).DirectoryName


# "C:\whateverpath" MUST be a folder as robocopy asks for source then dest then the single file to copy which is the places.sqlite
# I suggest creating a foldername that is unique to the user as when you move the places.sqlite back to that users mozilla appdata folder, it must be named exactly the same or mozilla will ignore it and just create a new one.


Robocopy "$MozillaPlaces" "$($env:userprofile)\Desktop\AAD Backup\firefox" 'places.sqlite' /s /e /W:1 /R:1 | Out-Null


# To copy it back... SIDE NOTE*** if mozilla being re-installed or fresah installed, must open mozilla first to recreate a default place.sqlite to replace


# This will find the directory of the places.sqlite to replace the file and catalog it

#$MozillaPlaces = (gci "$env:userprofile\appdata\Roaming\Mozilla\Firefox\Profiles" -force -recurse -ErrorAction SilentlyContinue | ?{$_.Name -eq 'places.sqlite'}).DirectoryName

#This will replace the file with the copy you backed up

#Robocopy "C:\$MozillaPlaces"  'places.sqlite' /s /e /W:1 /R:1 /xx | Out-Null
}



<# 4 CREATE LOCAL ADMIN #> 


function Local_Admin ($LA){

$password = Read-Host "Enter the new password:" -AsSecureString

New-LocalUser -Name $LA | Set-LocalUser -Password $password

Add-LocalGroupMember -Group "Administrators" -Member $LA
}


<# 5 Rename Computer #> 

function Rename_Computer($Brand,$LD) {

 $SN = (gwmi win32_bios).SerialNumber
 $S_SN = $SN.ToString()
 $NN = -Join($Brand + $LD + $S_SN)
 $NN.ToString()

 #if laptop make it L if Desktop make it D

 Rename-Computer -NewName ($NN)
 }
 


 #### Functions ####

 #1. BACKUP FOLDER
$t1 = 'Begin Backup Folders and Bookmarks?'
$q1 = 'Do you want to Backing up Folders and Documents?'
$c1 = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($t1, $q1, $c1, 1)
if ($decision -eq 0) {
    Write-Host 'Backup Folder AAD Backup is now on the desktop.'
    Backup_Folder
} else {
    Write-Host 'Dont Backup.'
}
#---------------------#

 #2. BACKUP DEKSTOP
$t1 = 'Backup Desktop?'
$q1 = 'Do you want to Back up the desktop documents?'
$c1 = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($t1, $q1, $c1, 1)
if ($decision -eq 0) {
    Write-Host 'Dekstop Files are now backed up.'
    Backup_Desktop
} else {
    Write-Host 'Dont Backup.'
}
#---------------------#

 #3. BACKUP Documents
$t1 = 'Backup Desktop?'
$q1 = 'Do you want to Back up the desktop documents?'
$c1 = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($t1, $q1, $c1, 1)
if ($decision -eq 0) {
    Write-Host 'Document Files are now backed up.'
    Backup_Documents
} else {
    Write-Host 'Dont Backup.'
}
#---------------------#


#4. BACKUP EDGE BOOKMARKS
$t1 = 'Backup Edge Bookmarks?'
$q1 = 'Do you want to backup Edge Bookmarks?'
$c1 = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($t1, $q1, $c1, 1)
if ($decision -eq 0) {
    Write-Host 'Backup Edge Bookmarks.'
    Edge_Bookmarks
} else {
    Write-Host 'Dont Backup Edge Bookmarks.'
}
#---------------------#

#5. BACKUP CHROME BOOKMARKS 
$t1 = 'Backup Chrome Bookmarks?'
$q1 = 'Do you want to backup Chrome Bookmarks?'
$c1 = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($t1, $q1, $c1, 1)
if ($decision -eq 0) {
    Write-Host 'Backup Chrome Bookmarks.'
    Chrome_Bookmarks
} else {
    Write-Host 'Dont Backup Chrome Bookmarks.'
}

#---------------------#

<#6. BACKUP FIREFOX BOOKMARKS #> 
$t1 = 'Backup Firefox Bookmarks?'
$q1 = 'Do you want to backup Firefox Bookmarks?'
$c1 = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($t1, $q1, $c1, 1)
if ($decision -eq 0) {
    Write-Host 'Backup Firefox Bookmarks.'
    Firefox_Bookmarks
} else {
    Write-Host 'Dont Backup Firefox Bookmarks.'
}
#---------------------#

#7. CREATE LOCAL ADMIN #
$t1 = 'Create a Local Admin Account?'
$q1 = 'Do you want to create a Local Admin account?'
$c1 = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($t1, $q1, $c1, 1)
if ($decision -eq 0) {
    $LA = Read-Host "Enter the Local Admin account to create?:"

    Local_Admin($LA)
    Write-Host 'Create Local Admin: ' $LA
} else {
    Write-Host 'Dont Create Local Admin.'
}

#---------------------#

<#8. Rename Computer #> 
$t1 = 'Rename Computer?'
$q1 = 'Do you want to Rename the Computer?'
$c1 = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($t1, $q1, $c1, 1)
if ($decision -eq 0) {
    $Brand = Read-Host "First 3 letters of the brand:"
    $LD = Read-Host "Type L for Laptop OR D for Desktop:"

    Write-Host 'The computer will be renamed to: '
    Rename_Computer($Brand,$LD)
} else {
    Write-Host 'Dont rename the computer.'
}

#---------------------#

Set-ExecutionPolicy -ExecutionPolicy Default


## Now that you have backup up all of the important information to that folder upload it to the users one drive. 
## Once the files are now backed up You can


# 1.)  Unjoin the domain
# 2.) restart 
# 3.) Login as the domain local user 
# 4.) Remove all registry keys inside of the HKLM\software\microsoft\enrollments besidesContext,Ownership,Status,ValidNodePaths
# 5.) Go to settings > Work or school > Join the device to AAD. 
# 6.) Verify Registration status by putting in dsregcmd into a administrative command prompt 