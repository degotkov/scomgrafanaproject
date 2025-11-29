# Restric folder access to system administrators to ensure users cannot read secrets
$Folder = "C:\Program Files\sql_exporter"
# Remove permissions inheritance
$Acl = Get-Acl -Path $Folder
$Acl.SetAccessRuleProtection($True, $True)
Set-Acl -Path $Folder -AclObject $Acl
# Remove users
$Acl = Get-Acl -Path $Folder
$Users = "BUILTIN\Users","NT SERVICE\TrustedInstaller"
foreach ($User in $Users)
{
	$Rule = New-Object system.security.AccessControl.FileSystemAccessRule("$User","Read",,,"Allow")
	$acl.RemoveAccessRuleAll($rule)
}
Set-Acl -Path $Folder -AclObject $Acl
