# Bulk user import for azure using CSV 

$admin = admin@nutex.com 
$AdminPassword = “Password123”
$Directory = nutex.com” 
$newuserpassword = “new userpasswords” 
$Csvfilepath = “C;|work\users.csv 
$SecPass = ConvertTo-SecureString $adminpassword -aspainttext -force 
$Cred = new-object System.management.automation.PSCredential ($Admin, $SecPass) 

Connect-AzureAD -Credential $Cred 
$PasswordProfile = New-Object -TypeNmae Microsoft.open.azuread.model.passwordprofile
$passwordprofile.password = $NewUserPassword
$NewUsers = Import-csv -path $Csvfilepath 

Foreach ($newUser in $newusers) 
{ 
$upn = $newuser.firstname + “.” + $NewUser.LastName + “@” + $Directory 
$DisplayName = $NewUser.Firstname + “ “ + NewUser.lastname + “ (“ + $NewUser.Department + “)”
$MailNickName = $NewUser.Firstname + “.” + $NewUser.LastName 
New-AzureADuser  -UserPrincipleName $upn -AccountEnabled $true -Displayname $Displayname -GivenName $NewUser.Firstname -mailnickname $MAILnICKnAME -Surname $newUser.lastname -Department $NewUser.department -Jobtitle $newuser.jobtitle -PasswordProfile $PasswordProfile 
}