$logPath = "C:\Temp\Logs"
$logFile = "$logPath\AppErrors.txt"

# Get latest 20 Application-level errors
$appErrors = Get-EventLog -LogName Application -EntryType Error -Newest 20

# If folder doesn't exist, create it
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
    Write-Host "$logPath created"
}
#
Import-Module ActiveDirectory

$logPath = "C:\Reports"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "$logPath\FinanceUsers_$timestamp.csv"
$errorLog = "$logPath\ErrorLog.txt"

if (-not (Test-Path $logPath)) {
    try {
        New-Item -Path $logPath -ItemType Directory
    } catch {
        $_ | Out-File $errorLog -Append
    }
}

$targetOU = "OU=Staff,DC=corp,DC=company,DC=com"

try {
    $targetUsers = Get-ADUser -SearchBase $targetOU -Filter "Department -eq 'Finance'" -Properties DisplayName, SamAccountName, Department
    $targetUsers | Select-Object Name, SamAccountName, Department | Export-Csv $logFile -NoTypeInformation
} catch {
    $_ | Out-File $errorLog -Append
}

#
$logPath = "C:\Temp"
$logFile = "${logPath}\StoppedAutoServices.csv"

if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}

$stoppedServices = Get-CimInstance -ClassName Win32_Service | Where-Object {
    $_.State -eq "Stopped" -and $_.StartMode -eq "Auto"
}

$stoppedServices | Select-Object DisplayName, State, StartMode | Export-Csv $logFile -NoTypeInformation

#

# Write each error to the file
foreach ($appError in $appErrors) {
    $appError | Out-File -Append $logFile
    # $appErrors | Select-Object TimeGenerated, EntryType, Source, Message | Export-Csv $logFile -NoTypeInformation
}
#

$services = Get-CimInstance Win32_Service | Where-Object { $_.StartMode -eq "Manual" -and $_.State -ne "Running" }
$services | Out-File "C:\Temp\Manual_NotRunning.txt"

$services = Get-Service | WhereObject { $_.Startup -eq "Manual" -and $_.Status "Stopped"}
$services | Out-File -Append $servicelog

Import-Module ActiveDirectory
$itusers = Get-ADUser -Filter * -Properties Department | Where-Object { $_.Department -eq "IT" }
$itusers | Select-Object Name, Department

$logPath = "C:\Logs\Today\"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}

Get-EventLog -LogName System -EntryType Warning -Newest 15 |
Out-File "$logPath\Logs_Today.txt"

$spooler = Get-Service -Name Spooler
if ($spooler.Status -eq "Stopped") {
    Start-Service -Name Spooler
    "Spooler restarted at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File "C:\Temp\SpoolerLog.txt" -Append
}



# -------------------------------------------------------------------------------------------------------------------

$logPath = "C:\Temp"
$csvFile = "$logPath\Services_W.csv"

if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}

$services = Get-Service | Where-Object { $_.Status -eq "Running" -and $_.Name -like "W*" }

$services | Export-Csv -Path $csvFile -NoTypeInformation


# -------------------------------------------------------------------------------------------------------------------

$logPath = "C:\Logs\Today"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "${logPath}\DiskErrors_$timestamp.txt"

$errors = Get-EventLog -LogName System -EntryType Error -Newest 50

foreach ($error in $errors) {
    if ($error.Source -eq "Disk") {
        $error | Out-File $logFile -Append
    }
}


# -------------------------------------------------------------------------------------------------------------------

Import-Module ActiveDirectory

New-ADComputer -Name "L4961" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L4961"
Set-ADComputer "L4961" -Add @{cdModel="Latitude 7400"}
Set-ADComputer "L4961" -Description "HO, Latitude 7400"

New-ADComputer -Name "L3822" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L3822"
Set-ADComputer "L3822" -Add @{cdModel="Latitude 7430"}
Set-ADComputer "L3822" -Description "HO, Latitude 7430"

New-ADComputer -Name "L1950" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L1950"
Set-ADComputer "L1950" -Add @{cdModel="Latitude 7440"}
Set-ADComputer "L1950" -Description "HO, Latitude 7440"

New-ADComputer -Name "L8517" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L8517"
Set-ADComputer "L8517" -Add @{cdModel="Latitude 7550"}
Set-ADComputer "L8517" -Description "HO, Latitude 7550"

New-ADComputer -Name "L5485" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L5485"
Set-ADComputer "L5485" -Add @{cdModel="Latitude 7430"}
Set-ADComputer "L5485" -Description "HO, Latitude 7430"

New-ADComputer -Name "L6774" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L6774"
Set-ADComputer "L6774" -Add @{cdModel="Latitude 7440"}
Set-ADComputer "L6774" -Description "HO, Latitude 7440"

New-ADComputer -Name "L5576" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L5576"
Set-ADComputer "L5576" -Add @{cdModel="Latitude 7420"}
Set-ADComputer "L5576" -Description "HO, Latitude 7420"

New-ADComputer -Name "L1644" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L1644"
Set-ADComputer "L1644" -Add @{cdModel="Latitude 7400"}
Set-ADComputer "L1644" -Description "HO, Latitude 7400"

New-ADComputer -Name "L4491" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L4491"
Set-ADComputer "L4491" -Add @{cdModel="Latitude 7400"}
Set-ADComputer "L4491" -Description "HO, Latitude 7400"

New-ADComputer -Name "L9962" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L9962"
Set-ADComputer "L9962" -Add @{cdModel="Latitude 7450"}
Set-ADComputer "L9962" -Description "HO, Latitude 7450"

New-ADComputer -Name "L3572" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L3572"
Set-ADComputer "L3572" -Add @{cdModel="Latitude 7450"}
Set-ADComputer "L3572" -Description "HO, Latitude 7450"

New-ADComputer -Name "L8894" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L8894"
Set-ADComputer "L8894" -Add @{cdModel="Latitude 7420"}
Set-ADComputer "L8894" -Description "HO, Latitude 7420"

New-ADComputer -Name "L7503" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L7503"
Set-ADComputer "L7503" -Add @{cdModel="Optiplex SFF"}
Set-ADComputer "L7503" -Description "MH, Optiplex SFF"

New-ADComputer -Name "L6260" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L6260"
Set-ADComputer "L6260" -Add @{cdModel="Latitude 3550"}
Set-ADComputer "L6260" -Description "MH, Latitude 3550"

New-ADComputer -Name "L1331" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L1331"
Set-ADComputer "L1331" -Add @{cdModel="Optiplex SFF"}
Set-ADComputer "L1331" -Description "MH, Optiplex SFF"

New-ADComputer -Name "L1019" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L1019"
Set-ADComputer "L1019" -Add @{cdModel="Latitude 3540"}
Set-ADComputer "L1019" -Description "MH, Latitude 3540"

New-ADComputer -Name "L4313" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L4313"
Set-ADComputer "L4313" -Add @{cdModel="Optiplex SFF"}
Set-ADComputer "L4313" -Description "MH, Optiplex SFF"

New-ADComputer -Name "L2603" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L2603"
Set-ADComputer "L2603" -Add @{cdModel="Latitude 3520"}
Set-ADComputer "L2603" -Description "MH, Latitude 3520"

New-ADComputer -Name "L5726" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L5726"
Set-ADComputer "L5726" -Add @{cdModel="Latitude 3550"}
Set-ADComputer "L5726" -Description "MH, Latitude 3550"

New-ADComputer -Name "L7137" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L7137"
Set-ADComputer "L7137" -Add @{cdModel="Latitude 3550"}
Set-ADComputer "L7137" -Description "MH, Latitude 3550"

New-ADComputer -Name "L9431" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L9431"
Set-ADComputer "L9431" -Add @{cdModel="Latitude 3550"}
Set-ADComputer "L9431" -Description "MH, Latitude 3550"

New-ADComputer -Name "L4453" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L4453"
Set-ADComputer "L4453" -Add @{cdModel="Optiplex SFF"}
Set-ADComputer "L4453" -Description "MH, Optiplex SFF"

New-ADComputer -Name "L5374" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L5374"
Set-ADComputer "L5374" -Add @{cdModel="Optiplex 7070"}
Set-ADComputer "L5374" -Description "MH, Optiplex 7070"

New-ADComputer -Name "L9009" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L9009"
Set-ADComputer "L9009" -Add @{cdModel="Latitude 3550"}
Set-ADComputer "L9009" -Description "MH, Latitude 3550"

# ---------------------------------------------------------------------------------------------

