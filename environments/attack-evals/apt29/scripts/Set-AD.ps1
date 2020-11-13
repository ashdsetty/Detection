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

Restart-Service -Name "Cylerian endpoint agent"

& .\Set-OUs.ps1 -domainFQDN $domainFQDN
& .\Add-DomainUsers.ps1 -domainFQDN $domainFQDN -dcVMName $dcVMName
& .\Set-AuditSAMRemoteCalls.ps1
