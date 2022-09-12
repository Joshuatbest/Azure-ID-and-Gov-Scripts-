# Locks for RG

Az group lock show --dontdeleteme --resource-group nctest2

Set a lock with powershell 

get -azresourcelock 
New-azresourcelock -locklevel cannotdelete  - lockness -resourcegroupname NCtest3
 
Remove the rg nctest3 using powershell 

Remove-azreosurcegroup -name NCTEST3

Remove lock from resource or rg, you will need to get the resourceid 

Get-azresourcelock

$nessie = (get-azresouircelock -resourcegroupname NCTESTT3).lockid 
remove=azresourcelock-lockid $nessie 
Y

Remove-azreosurcegroup -name NCTEST3 
