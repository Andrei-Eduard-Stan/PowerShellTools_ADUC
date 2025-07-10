function Export-LocalAdminGroupMembers {
    [CmdletBinding()]
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )

    # Get current timestamp safely for filenames
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"

    # Define where logs and CSVs go
    $logPath = "C:\Audit"
    $logFile = "${logPath}\AdminGroup_${ComputerName}_${timestamp}.csv"
    $logError = "${logPath}\AdminCheck_Errors.log"

    # Make sure the folder exists
    if (-not (Test-Path $logPath)) {
        New-Item -Path $logPath -ItemType Directory | Out-Null
    }

    try {
        # 🔹 CASE 1: Local computer — we can use Get-LocalGroupMember
        if ($ComputerName -eq $env:COMPUTERNAME) {
            $members = Get-LocalGroupMember -Group "Administrators"
            $members | Select-Object Name, ObjectClass, PrincipalSource | Export-Csv $logFile -NoTypeInformation
        }
        # 🔹 Invoke Method if allowed
        #Invoke-Command -ComputerName $targetComputer -ScriptBlock {
        #    Get-LocalGroupMember -Group "Administrators"
        #}
        # 🔹 CASE 2: Remote computer — use CIM session to query WMI
        else {
            # Create a CIM session to the remote computer
            $session = New-CimSession -ComputerName $ComputerName

            # Get all local group-user links
            $groupUsers = Get-CimInstance -ClassName Win32_GroupUser -CimSession $session

            # Filter only the Administrators group
            $admins = $groupUsers | Where-Object {
                $_.GroupComponent -like '*"Administrators"*'
            }

            # Build a list of usernames from the references
            $output = foreach ($admin in $admins) {
                # Parse account name
                $accountMatch = [regex]::Match($admin.PartComponent, 'Win32_(User|Group)\.Domain="(?<domain>[^"]+)",Name="(?<name>[^"]+)"')

                if ($accountMatch.Success) {
                    [PSCustomObject]@{
                        Name = $accountMatch.Groups["name"].Value
                        Domain = $accountMatch.Groups["domain"].Value
                        Type = $accountMatch.Groups[1].Value  # User or Group
                    }
                }
            }

            # Output to CSV
            $output | Export-Csv $logFile -NoTypeInformation

            # Clean up session
            Remove-CimSession $session
        }

        Write-Host "Admin group exported to $logFile"
    }
    catch {
        "[$(Get-Date)] Failed on $ComputerName - $($_.Exception.Message)" | Out-File $logError -Append
        Write-Host "An error occurred see $logError"
    }
}
