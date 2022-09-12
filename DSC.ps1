# Desired State Configuration (DSC) for VMs

 Configuration HelloWorld {

# import the module that contains the file resource. 
Import-dscresource -ModuleName PsDesiredStateConfirguration 
# The node statement specifies which targets to compile MOF files for, when this configuration is executed. 
Node ‘localhost’ {

#The file resource can ensure the state of files, or copy them from a source to a destination with persistent updates. 
File HelloWorld {
DestinationPath = “C:\Temp\HelloWorld.txt”
Ensure = “present”
Contents = “hello World from DSC!”
}
}
}
#In windows powershell
#Az login (prompts you to login 

Publsh-azvmdscconfiguration -resourcegroupname storage -storageaccountname networkchuckstorage “.\HelloWorld.ps1” -force

#Now in azure portal confirm its there.
Set-azvmdscextension -version “2.80” -resourcegroupname morePOWERSHELLDSC ‘ -vmname backendserver ‘
-arciveresourcegroupname storage ‘
-archievestorageaccountname networkchuckstorage ‘
-archieveblobname “helloWorld.ps1.zip” ‘
-autoupdate ‘
-configurationname “HelloWorld” 

<#This will make the file and make sure its there. 

Now on the server this is how you get it to fix the file if it accidentally gets deleted. 
Get-dsclocalconfigurationmanager 
This will tell you what the configuration mode setting is. In this case its apply and monitor. In order to change this file we need to go to it and open it in file explorer. 

C:\windows\System32\configuration\metaconfig

Once you are editing the file in notepad you will need to change the confgiurationMode to ApplyandAutocorrect #> 

#Cloud shell basg 
Ls 

. . \HelloWorld.ps1
HelloWorld
# This makes a localhost.mof file. 

# On the portal > go to automation accounts > State configuration > add > add the MOF file. And make sure the configuration name matches the configuration name in the file. Then Nodes > (note: you can also use powershell DSC with linux) then you select the node and select connect 




