# Point to site certificate for Remote Access  

#Create Root Cert on the clients machine. 
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=P2SRootCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

#Create User Cert 
New-SelfSignedCertificate -Type Custom -DnsName PS2ChildCert -KeySpec Signature `
-Subject "CN=P2SChildCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "cert:\CurrentUser\My" `
-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
#Then Export the certification in the personal certifications store. 

#Then go to the VM you would like the client to access Under Settings > and point to site configuration put in the public certificate data, see from notepad) and then put in the name of the machine for the name and maybe -user for tracking 
#purposes. 

# Then you can download the vpn client to the machine you would like to have remote access. 
