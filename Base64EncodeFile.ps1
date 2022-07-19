$filename = "C:\sample.key"
[Convert]::ToBase64String([IO.File]::ReadAllBytes($filename)) | clip




#Encoding and decoding of strings
$ClientID = "ThisIsMyClientID"
$ClientSecret = "ThisIsMyClientSecretKEY"

$ClientIDEncoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ClientID))
$ClientSecretEncoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ClientSecret))

$ClientIDEncoded
$ClientSecretEncoded


$ClientIDDeoded = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($ClientIDEncoded))
$ClientSecretDecoded = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($ClientSecretEncoded))

$ClientIDDeoded
$ClientSecretDecoded
