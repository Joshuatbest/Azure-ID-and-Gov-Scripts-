#New User Creation 

$pwprofile = New-Object -Type Microsoft.Open.AzureAd.Model.PasswordProfile

$pwprofile.password = “Password123!” 

New-AzureAdUser -AccountEnabled $true -PasswordProfile $pwprofile -DisplayName “Posh User” -UserPricinpaleName “poshuser@exampledomain.com” -MailNickName “PoshUser” 