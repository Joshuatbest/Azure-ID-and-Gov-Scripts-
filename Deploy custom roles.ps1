# Deploy Custom Roles 

# Portal > launch cloud shell > Powershell> 
get-azprovideroperation */virtualmachines/* | FT Operation, Opernation Name 

# Need to know the gui of of the vm 

Get-azSubscription | FL 

Get-azreoledefinition -Name “Reader” | Convert-to-json | Out-File $home/Clouddriver/ReaderVM.json 

Code $home/clouddriver



New-azroledefiniton -InputFile $home/clouddrive/readerVM.json

Get-AzRoleDefintion | where-Object {$._.Iscustom -eq $true} | fl 

