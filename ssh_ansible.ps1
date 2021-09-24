#OpenSSH feature on windows
Add-WindowsCapability –Online –Name OpenSSH.Server~~~~0.0.1.0
Set-Service sshd –StartupType Automatic
Start-Service sshd
New-ItemProperty –Path "HKLM:\SOFTWARE\OpenSSH" –Name DefaultShell –Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" –PropertyType String –Force
Restart-Service sshd

#ansible user and key
$length = 12
$nonAlphaChars = 6
Add-Type –AssemblyName 'System.Web'
$user = "ansible"
$pass = ([System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars))
$secureString = ConvertTo-SecureString $pass –AsPlainText –Force
New-LocalUser –Name $user –Password $secureString
$credential = New-Object System.Management.Automation.PsCredential($user,$secureString)
$process = Start-Process cmd /c –Credential $credential –ErrorAction SilentlyContinue –LoadUserProfile
$newPass = ([System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars))
$newSecureString = ConvertTo-SecureString $newPass –AsPlainText –Force
Set-LocalUser –Name $user –Password $newSecureString
New-Item –Path "C:\Users\$user" –Name ".ssh" –ItemType Directory
$content = "PASTE YOUR PUBLIC SSH KEY HERE"
$content | Set-Content –Path "c:\users\$user\.ssh\authorized_keys"

#Firewall rule
New-NetFirewallRule -DisplayName 'OpenSSH' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22
