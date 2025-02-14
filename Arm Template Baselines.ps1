﻿#Microsoft Azure has datacenters EVERYWHERE! I would recommend you choose the closest region to you and input that in the location below.
#Replace 'southcentralus' with your local region. Or, just leave it as is!
#Also, feel free to change the user name and password below. If not, don't worry about it. 
#If you don't change the username/password below, here they are again so you can login to your GNS3 server:
#username: cbtnuggetsadmin
#password: CBTNu$$ets!@#4
#Hey again, please change the domainname to something unique to you or you might get errors!


#START----Copy everything between this line and the STOP below. Paste into the Azure Cloud Shell--------------------------

$location = 'southcentralus'
$user = "cbtnuggetsadmin"
$password = convertto-securestring 'CBTNu$$ets!@#4' -asplaintext -force
$credential = new-object System.Management.Automation.PSCredential ($user, $password);
$domainname = "mygns3server"


new-azresourcegroup -name GNS3 -location $location
New-AzureRmNetworkSecurityGroup -Name GNS3 -ResourceGroupName GNS3 -Location $location

$nsg=Get-AzureRmNetworkSecurityGroup -Name GNS3 -ResourceGroupName GNS3
$nsg | Add-AzureRmNetworkSecurityRuleConfig -Name Allow_All_the_things -Description "Let it all through" -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange * | Set-AzureRmNetworkSecurityGroup

new-azvm -resourcegroup GNS3 -location $location -name 'GNS3-SERVER' -image UbuntuLTS -size 'Standard_D4s_v3' -securitygroupname GNS3 -credential $credential -DomainNameLabel $domainname

#STOP ------------------------------------------------------------------------------------------------------------------




#START -- Copy the code below and paste into your GNS3 server----------------------------------------------------------
cd /tmp
curl https://raw.githubusercontent.com/GNS3/gns3-server/master/scripts/remote-install.sh > gns3-remote-install.sh
sudo bash gns3-remote-install.sh --with-iou --with-i386-repository
