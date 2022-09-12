# Apply resource Group Tags to Reosurces 
# Adding tags using azure cloud shell 
Set-azresourcegroup -name Bestgroup1 -tag @{ Product=”guitar”; Owner=”Josh” }

Now to apply this tag to all of the items in this resource group 

$group = get-azresourcegroup -name Bestgroup1

$group 

Get-azresource -resourcegroupname $group.resourcegroupname | foreach-object {set-azreosurce -resourceid $_.resourceid -tag $group.tags -force } 

$group = azresourcegroup 

Foreach ($g in $group) 

Get-azresourcegroup -resourcegroupname $g .resourcegroupname | foreach-object {set-azresource -resouceid $_.resourceid -tag $g.tags  -force)
