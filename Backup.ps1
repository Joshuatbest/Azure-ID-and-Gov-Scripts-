#Backing up a vm 

New-azrecoveryservicesvault -resourcegroupname backupcli -name voldemort -location central us

Set the context. Get-azrecoveryservicesvualt -name voldemort | set-azrecoveryservicesvaultcontext 
