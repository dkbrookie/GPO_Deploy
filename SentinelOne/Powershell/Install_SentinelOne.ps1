
## Temporarily set execution policy
Set-ExecutionPolicy Bypass

## Get OS version
$os = (Get-CimInstance Win32_OperatingSystem).Caption
If ($os -like '*server*') {
    $siteKey = $serverKey
} Else {
    $siteKey = $workstationKey
}

## Check if SentinelOne is installed
$checkSent = Get-Service -Name 'Sentinel Agent' -EA 0
$Dir = "$env:windir\LTSvc\packages\Software\SentinelOne"

If (!$checkSent) {
    ## SentinelOne services don't exist, call in the generic EXE installer function
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Ssl3
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/dkbrookie/PowershellFunctions/master/Function.Install-EXE.ps1') | Invoke-Expression
    ## Install SentinelOne
    Install-EXE -AppName SentinelOne -FileDownloadLink $downloadURL -FileDir $Dir -FileEXEPath "$Dir\SentinelOne.exe" -Arguments "/SITE_TOKEN=$siteKey /QUIET /NORESTART"
}