# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$domainFQDN,

    [Parameter(Mandatory=$true, Position=2)]
    [string]$dcVMName
)

$uri = "https://www.dropbox.com/s/yf21t64hjle1gv4/cagent-windows-x64.exe?dl=1";
invoke-webrequest -uri $uri -outfile "c:\windows\temp\cagent-windows-x64.exe";
& "c:\windows\temp\cagent-windows-x64.exe";

$uri = "https://www.dropbox.com/s/a0bhndzvbb8elhn/etw_logger.zip?dl=1";
invoke-webrequest -uri $uri -outfile "c:\windows\temp\etw_logger.zip";

Expand-Archive "c:\windows\temp\etw_logger.zip" -DestinationPath "c:\program files\cylerian\sensors\lmao"

$uri = "https://www.dropbox.com/s/uyxziatvg4whzac/overrides.json?dl=1";
invoke-webrequest -uri $uri -outfile "c:\program files\cylerian\overrides.json";

Restart-Service -Name "Cylerian endpoint agent"

& .\Set-OUs.ps1 -domainFQDN $domainFQDN
& .\Add-DomainUsers.ps1 -domainFQDN $domainFQDN -dcVMName $dcVMName
& .\Set-AuditSAMRemoteCalls.ps1
