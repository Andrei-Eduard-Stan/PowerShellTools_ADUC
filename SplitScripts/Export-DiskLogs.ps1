function Export-DiskLogs {
    [CmdletBinding()]
    param(
        [string]$targetComputer = $env:COMPUTERNAME
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
    $logPath = "C:\Logs"
    $logFile = "${logPath}\DiskErrors_${timestamp}.csv"
    $errorFile = "${logPath}\errors.txt"

    try {
        if (-not (Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType Directory | Out-Null
        }

        if ($targetComputer -eq $env:COMPUTERNAME) {
            $diskErrors = Get-EventLog -LogName System -EntryType Error -Newest 100 |
                Where-Object { $_.Source -eq "Disk" } |
                Select-Object TimeGenerated, Source, Message
        } else {
            $session = New-CimSession -ComputerName $targetComputer
            $diskErrors = Invoke-Command -Session $session -ScriptBlock {
                Get-EventLog -LogName System -EntryType Error -Newest 100 |
                Where-Object { $_.Source -eq "Disk" } |
                Select-Object TimeGenerated, Source, Message
            }
            Remove-CimSession $session
        }

        $diskErrors | Select-Object TimeGenerated, Source, Message | Export-Csv $logFile -NoTypeInformation

    } catch {
        "[$(Get-Date)] Failed: $($_.Exception.Message)" | Out-File $errorFile -Append
    }
}
