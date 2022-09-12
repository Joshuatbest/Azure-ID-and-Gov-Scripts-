# Move Resources to new subscriptions 

#Go into RG > Move button or change under subscription > when you move a resource it will get a new RESOURCEID so make sure you dont reference these items with resource id for when its moved. 

Get-azreosurce -resourcegroupname morepowershelldsc | format-list -property resourceid
#Now that we have a list of Resource IDs from the morepowershelldsc group so now we can put that into a variable 

$vnetid = (get-azresoruce -resourcegroupname morepowershelldsc -resourcename beardsite-vnet).resource.id

Move-azresource -destinationresourcegroupname beardproduction -resourceid $vnetid

# Now we will work on moving a vm from one subscription to another. Resource > change, next to subscription. > then select the resources you would like to move. Then select your subscription and the resource group. 

# Or in powershell 
Move-azresource -destinationresourcegroupname beardproduction -resourceid $nicid, all the variables with resource ids in them. -destinationsubscriptionname networkchuckcoffee.
