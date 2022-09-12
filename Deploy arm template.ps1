# Deploy arm template 

$rg = “bestsitegermany”
New-azresourcegroup -name $rg -location germanycentral

New-azreosurcegroupdeployment -name bestsitegermany -resourcegroup $rg -templateurl “URL from gitbub” 
