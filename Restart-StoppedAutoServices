function Restart-StoppedAutoServices {
    [CmdletBinding()]
    param (
        [string]$optional_logFolder
    )

    $logFolder = if ($optional_logFolder -and (Test-Path $optional_logFolder)) {
        $optional_logFolder
    } else {
        $fallback = "C:\Logs"
        if (-not (Test-Path $fallback)) {
            New-Item -Path $fallback -ItemType Directory | Out-Null
        }
        Write-Host "Log folder not specified or not found. Using fallback: $fallback"
        $fallback
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
    $posLogs = "${logFolder}\ServiceRestarts_${timestamp}.log"
    $negLogs = "${logFolder}\ServiceErrors_${timestamp}.log"

    $services = Get-CimInstance Win32_Service | Where-Object {
        $_.StartMode -eq "Auto" -and $_.State -eq "Stopped"
    }

    foreach ($service in $services) {
        try {
            Start-Service -Name $service.Name
            "[$timestamp] Restarted service: $($service.Name)" | Out-File $posLogs -Append
        } catch {
            "[$timestamp] Failed to restart $($service.Name): $($_.Exception.Message)" | Out-File $negLogs -Append
        }
    }
}
