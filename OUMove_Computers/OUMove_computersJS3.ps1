Import-Module ActiveDirectory

$logText = "C:\Windows\Temp\OU_Move_Log.txt"
$logJson = "C:\Windows\Temp\OU_Move_Log.json"

# Load existing JSON logs
if (Test-Path $logJson) {
    $raw = Get-Content $logJson -Raw | ConvertFrom-Json
    if ($null -ne $raw) {
        $logData = if ($raw -is [System.Collections.IEnumerable]) { @() + $raw } else { @($raw) }
    } else {
        $logData = @()
    }
} else {
    $logData = @()
}

# OU mapping
$ouMap = @{
    "Latitude 7400" = "OU=Head Office,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 7420" = "OU=Head Office,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 7430" = "OU=Head Office,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 7440" = "OU=Head Office,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 7450" = "OU=Head Office,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 7550" = "OU=Head Office,OU=FST Computers,DC=dukufst,DC=local"
    "Optiplex 7070" = "OU=Managed Houses,OU=FST Computers,DC=dukufst,DC=local"
    "Optiplex Micro 7010" = "OU=Managed Houses,OU=FST Computers,DC=dukufst,DC=local"
    "Optiplex SFF" = "OU=Managed Houses,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 3520" = "OU=Managed Houses,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 3540" = "OU=Managed Houses,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 5490" = "OU=Managed Houses,OU=FST Computers,DC=dukufst,DC=local"
    "Latitude 3550" = "OU=Managed Houses,OU=FST Computers,DC=dukufst,DC=local"
}

# Static groups
$staticGroups = @(
    "Computer Certificate Enrolment",
    "OneDrive for Business",
    "VPN Computers",
    "Workstations VLAN - 802.1x Authentication",
    "WSUS - Computers - All"
)

# Get all computers in CN=Computers
$computers = Get-ADComputer -SearchBase "CN=Computers,DC=dukufst,DC=local" -Filter * -Properties *

foreach ($comp in $computers) {
    $compName = $comp.Name
    $cdModel = $comp.cdModel

    Add-Content $logText "[$(Get-Date)] Processing: $compName (cdModel: '$cdModel')"

    if (![string]::IsNullOrEmpty($cdModel) -and $ouMap.ContainsKey($cdModel)) {
        $targetOU = $ouMap[$cdModel]
        try {
            Move-ADObject -Identity $comp.DistinguishedName -TargetPath $targetOU
            Add-Content $logText "[$(Get-Date)] $compName moved to $targetOU"
            $logData += [PSCustomObject]@{
                Timestamp    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                ComputerName = $compName
                Action       = "Moved to"
                Target       = $targetOU
            }
            $comp = Get-ADComputer -Identity $compName
        } catch {
            Add-Content $logText "[$(Get-Date)] ERROR moving ${compName}: $_"
            $logData += [PSCustomObject]@{
                Timestamp     = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                ComputerName  = $compName
                Action        = "Move Failed"
                Target        = $targetOU
                ErrorMessage  = $_.ToString()
            }
        }
    } else {
        Add-Content $logText "[$(Get-Date)] Missing or unrecognized cdModel for $compName"
        $logData += [PSCustomObject]@{
            Timestamp    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            ComputerName = $compName
            Action       = "Unrecognized cdModel"
            Target       = $cdModel
        }
    }

    foreach ($group in $staticGroups) {
        try {
            Add-ADGroupMember -Identity $group -Members $comp.DistinguishedName -ErrorAction Stop
            Add-Content $logText "[$(Get-Date)] $compName added to group: $group"
            $logData += [PSCustomObject]@{
                Timestamp    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                ComputerName = $compName
                Action       = "Added to Group"
                Target       = $group
            }
        } catch {
            $message = if ($_ -like "*already a member*") {
                "Already in Group"
            } else {
                "Group Add Failed: $_"
                console.log($_.toString())
            }

            Add-Content $logText "[$(Get-Date)] $compName ${message}: $group"
            $entry = [PSCustomObject]@{
                Timestamp     = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                ComputerName  = $compName
                Action        = $message
                Target        = $group
            }

            if ($message -eq "Group Add Failed") {
                $entry | Add-Member -NotePropertyName "ErrorMessage" -NotePropertyValue $_.ToString()
            }

            $logData += $entry
        }
    }

    # Save JSON after processing each computer
    $logData | ConvertTo-Json -Depth 3 | Set-Content $logJson -Encoding UTF8
}
