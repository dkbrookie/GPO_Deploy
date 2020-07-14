
## Temporarily set execution policy
Set-ExecutionPolicy Bypass

## Check if SentinelOne is installed
$checkSent = Get-Service -Name 'Sentinel Agent' -EA 0
$Dir = "$env:windir\LTSvc\packages\Software\SentinelOne"

If (!$checkSent) {
    ## SentinelOne services don't exist, call in the generic EXE installer function
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Ssl3
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/dkbrookie/PowershellFunctions/master/Function.Install-EXE.ps1') | Invoke-Expression
    ## Install SentinelOne
    Install-EXE -AppName SentinelOne -FileDownloadLink 'https://support.dkbinnovative.com/labtech/transfer/software/sentinelone/sentinelone.exe' -FileDir $Dir -FileEXEPath "$Dir\SentinelOne.exe" -Arguments "/quiet"
}