$rg = “morepowershelldsc” 
$vmname = “backendserver2”

Get-azvmsize -resourcegroupname $rg -vmname $vmname

$newvmsize = “stanmdard DS1 v2” 
$vm = get-azvm -resourcegroupname $rg -vmname $vmname

$vm.hardwareprofile.vmsize = $newvmsize

update -azvm -vm $vm -resourcegroupname $rg 
