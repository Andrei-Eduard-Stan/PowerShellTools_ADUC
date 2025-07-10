# ================================================
# Dukershell.psm1
# Author: Andrei Stan
# Description: PowerShell Infrastructure Toolkit
# ================================================

# -----------------------------------------------
# Export-ADUsersByOU
# Description:
# Queries AD for users in a target OU, optionally filtered by Department, and exports them to a timestamped CSV.
# -----------------------------------------------

function Export-ADUsersByOU {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$targetOU,
        [Parameter()][string]$Department,
        [Parameter(Mandatory)][string]$filePath
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $errorLogPath = "C:\Logs"
    $errorLog = "${errorLogPath}\errors.txt"

    if (-not (Test-Path $errorLogPath)) {
        New-Item -Path $errorLogPath -ItemType Directory | Out-Null
    }

    try {
        if (-not $Department) {
            $targetUsers = Get-ADUser -SearchBase $targetOU -Filter * -Properties Name, SamAccountName, Department
        } else {
            $filter = "Department -eq '$Department'"
            $targetUsers = Get-ADUser -SearchBase $targetOU -Filter $filter -Properties Name, SamAccountName, Department
        }

        $file = "$filePath\ADUsers_$timestamp.csv"
        $targetUsers | Select-Object Name, SamAccountName, Department | Export-Csv $file -NoTypeInformation
    }
    catch {
        $_ | Out-File $errorLog -Append
    }
}

# -----------------------------------------------
# Export-DiskLogs
# Description:
# Gathers recent disk-related errors from the System event log and exports to CSV.
# -----------------------------------------------

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

        $diskErrors | Export-Csv $logFile -NoTypeInformation

    } catch {
        "[$(Get-Date)] Failed: $($_.Exception.Message)" | Out-File $errorFile -Append
    }
}

# -----------------------------------------------
# Export-LocalAdminGroupMembers
# Description:
# Lists members of the local Administrators group, local or remote, and exports to CSV.
# -----------------------------------------------

function Export-LocalAdminGroupMembers {
    [CmdletBinding()]
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
    $logPath = "C:\Audit"
    $logFile = "${logPath}\AdminGroup_${ComputerName}_${timestamp}.csv"
    $logError = "${logPath}\AdminCheck_Errors.log"

    if (-not (Test-Path $logPath)) {
        New-Item -Path $logPath -ItemType Directory | Out-Null
    }

    try {
        if ($ComputerName -eq $env:COMPUTERNAME) {
            $members = Get-LocalGroupMember -Group "Administrators"
            $members | Select-Object Name, ObjectClass, PrincipalSource | Export-Csv $logFile -NoTypeInformation
        } else {
            $session = New-CimSession -ComputerName $ComputerName
            $groupUsers = Get-CimInstance -ClassName Win32_GroupUser -CimSession $session

            $admins = $groupUsers | Where-Object {
                $_.GroupComponent -like '*"Administrators"*'
            }

            $output = foreach ($admin in $admins) {
                $accountMatch = [regex]::Match($admin.PartComponent, 'Win32_(User|Group)\.Domain="(?<domain>[^"]+)",Name="(?<name>[^"]+)"')

                if ($accountMatch.Success) {
                    [PSCustomObject]@{
                        Name = $accountMatch.Groups["name"].Value
                        Domain = $accountMatch.Groups["domain"].Value
                        Type = $accountMatch.Groups[1].Value
                    }
                }
            }

            $output | Export-Csv $logFile -NoTypeInformation
            Remove-CimSession $session
        }

        Write-Host "Admin group exported to $logFile"
    }
    catch {
        "[$(Get-Date)] Failed on $ComputerName - $($_.Exception.Message)" | Out-File $logError -Append
        Write-Host "An error occurred see $logError"
    }
}

# -----------------------------------------------
# Restart-StoppedAutoServices
# Description:
# Finds services set to Automatic that are Stopped and attempts to restart them, logging success/failure.
# -----------------------------------------------

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

# -----------------------------------------------
# Export all module functions explicitly
# -----------------------------------------------
Export-ModuleMember -Function Export-ADUsersByOU, Export-DiskLogs, Export-LocalAdminGroupMembers, Restart-StoppedAutoServices
