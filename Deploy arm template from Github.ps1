# Deploy arm template 

$rg = “bestsitegermany”
New-azresourcegroup -name $rg -location germanycentral

#Importing a arm template from github 
New-azreosurcegroupdeployment -name bestsitegermany -resourcegroup $rg -templateurl “URL from gitbub” 
