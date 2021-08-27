<#
Important Note
    $apiKey and $sensorIP need to have values before this script is called. The intent is for this
    script to be called form a GPO, and before the GPO is called the call mechanism would fill out these
    variables. This keeps the API key out of Github which I prefer (even thoguh Perch has stated this is
    not sensitive information-- put in a ticket to verify).

Script Workflow
    -Checks for server or workstation OS, then sets the reporting method to IP for server, or API for workstation
    -Sets the download TLS method to TLS1.2 so Powershell download will succeed
    -Checks if Perch is installed, installs if missing
    -Verify all Perch dependent services are running, start if not running
    -Verify all Perch services are running, start if not running

Clients known to be using this in GPOs
    -GTMSSP
#>


# Temporarily set execution policy
Set-ExecutionPolicy Bypass


Function Show-Output ($output) {
    $output = $output -join "`n"
    Write-Output $output
}


# Set vars
$output = @()
$downloadURL = 'https://cdn.perchsecurity.com/downloads/perch-log-shipper-latest.exe'


# Determine if server or workstation OS, set $reportDestination accordingly
$os = (Get-WMIObject win32_operatingsystem).name
If ($os -like '*Server*') {
    $output += "Determined this is a Server OS, using local sensor IP connect method."
    If ($sensorIp) {
        $reportDestination = $sensorIp
        # If server, we want it to report to the local sensor IP
        $arguments = "/qn OUTPUT=IP VALUE=$reportDestination"
    } Else {
        $output += '$sensorIp has no value! This must contain an IP address for this script to successfully install the log shipper to a Server OS, exting script.'
        Show-Output $output
        Break
    }
} Else {
    $output += "Determined this is a Workstations OS, using API connect method."
    If ($apiKey) {
        $reportDestination = $apiKey
        # If workstation, we want it to report to the cloud via API
        $arguments = "/qn OUTPUT=TOKEN VALUE=$reportDestination"
    } Else {
        $output += '$apiKey has no value! This must contain an API Key for this script to successfully install the log shipper to a Workstation OS, exting script.'
        Show-Output $output
        Break
    }
}


# To ensure successful downloads we need to set TLS protocal type to Tls1.2. Downloads regularly fail via Powershell without this step.
Try {
    [Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
    $output += "Successfully enabled TLS1.2 to ensure successful file downloads."
} Catch {
    $output += "Encountered an error while attempting to enable TLS1.2 to ensure successful file downloads. This can sometimes be due to dated Powershell. Checking Powershell version..."
    # Generally enabling TLS1.2 fails due to dated Powershell so we're doing a check here to help troubleshoot failures later
    $psVers = $PSVersionTable.PSVersion
    If ($psVers.Major -lt 3) {
        $output += "Powershell version installed is only $psVers which has known issues with this script directly related to successful file downloads. Script will continue, but may be unsuccessful."
    }
}


# Check if installed, install if missing
(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/dkbrookie/PowershellFunctions/master/Function.Install-EXE.ps1') | Invoke-Expression
$output += Install-EXE -AppName 'Perch Log Shipper' -FileDownloadLink $downloadURL -Arguments $arguments


# Give a brief pause before we check services
Start-Sleep -Seconds 10


# Check services, start if stopped
(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/dkbrookie/PowershellFunctions/master/Function.Service-Check.ps1') | Invoke-Expression
$output += Service-Check -Role 'Perch Log Shipper' -CheckDependencies Y -StartDependencies Y -RunAsMonitor N


Show-Output $output