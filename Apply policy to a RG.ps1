## Create a variable for your RG 

$group = get-azresourcegroup -name jbestGuitarWebsite2

## set the policy defintions 
$definition = get-azpolicydefinition | where-object { $_.properties.DisplayName -eq ‘Allowed Locations -Audit’} 

New-azpolicyassignemnt -name jbestguitarwebsitelocation -scope $group.resourceid -policydefintion $defintion 
