# Resource group migreation to different vnet. 
$f1 = get-azresource -resourcegroupname theDefaultsite -resourcename FrontEnd1

## test the variable 
$f1

Use this same process to make a variable for $f2

Move-azresource -destinationresourcegroupname TheSecondarySite -resourceid $f1.resourceid, $f2.resource.id 
