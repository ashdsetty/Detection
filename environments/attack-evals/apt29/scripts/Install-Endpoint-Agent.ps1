$uri = "https://www.dropbox.com/s/yf21t64hjle1gv4/cagent-windows-x64.exe?dl=1";
invoke-webrequest -uri $uri -outfile "c:\windows\temp\cagent-windows-x64.exe";
& "c:\windows\temp\cagent-windows-x64.exe";

Restart-Service -Name "Cylerian endpoint agent"

#Add-Type -AssemblyName System.IO.Compression.FileSystem
#function Unzip
#{
#    param([string]$zipfile, [string]$outpath)
#
#    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
#}

#Unzip "c:\windows\temp\etw_logger.zip" "c:\program files\cylerian\sensors\etw_logger"
