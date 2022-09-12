## lists all storage accounts 
Get-azstorage account 

## variable for storage account location of logs 
$sa = (get-aztorageaccount -storageaccountname Blackbearddiag -resorucegroupname blackbeard).id 

## variable for resource type. Which resource do you want to log resources for? 
$resource = (get-azresource - name Frenchpress -Resourcegroupname beardco iresourcetype microsoft.network/loadbalancers).id 

## set the resource to log under the storage account for the logs to go into.
set-azdiangostic setting -resourceid $resource -storageaccountid $sa -enable $true 
