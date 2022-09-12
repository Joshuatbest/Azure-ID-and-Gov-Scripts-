#Adding tags to resources 

$R = Get-AzResource -ResourceName NutexVnet -ResourceGroupName NutexGroup Set-AzResource -Tag @{ Dept=”HR”; Environment=”Corporate” } -ResourceID $r.ResourceID -force. 