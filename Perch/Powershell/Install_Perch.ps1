## Temporarily set execution policy
Set-ExecutionPolicy Bypass

## Check if Perch is installed
$checkSent = Get-Service -Name 'Sentinel Agent' -EA 0
$Dir = "$env:windir\LTSvc\packages\Software\Perch"

If (!$checkSent) {
    ## Perch services don't exist, call in the generic EXE installer function
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Ssl3
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/dkbrookie/PowershellFunctions/master/Function.Install-EXE.ps1') | Invoke-Expression
    ## Install Perch
    Install-EXE -AppName Perch -FileDownloadLink $downloadURL -FileDir $Dir -FileEXEPath "$Dir\Perch.exe" -Arguments "/qn OUTPUT=TOKEN VALUE=$api"
}