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
