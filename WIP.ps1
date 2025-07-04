# ------------------------------------------------------------------------------------------------------
# Script 1: Export the latest 20 Application-level errors to a log file
# ------------------------------------------------------------------------------------------------------

$logPath = "C:\Temp\Logs"
$logFile = "$logPath\AppErrors.txt"

# Get the latest 20 error entries from the Application log
$appErrors = Get-EventLog -LogName Application -EntryType Error -Newest 20

# Ensure the log directory exists
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
    Write-Host "$logPath created"
}

# Append each error entry to the log file
foreach ($appError in $appErrors) {
    $appError | Out-File -Append $logFile
}

# ------------------------------------------------------------------------------------------------------
# Script 2: Export Finance department AD users to CSV, log errors
# ------------------------------------------------------------------------------------------------------

Import-Module ActiveDirectory

$logPath = "C:\Reports"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "$logPath\FinanceUsers_$timestamp.csv"
$errorLog = "$logPath\ErrorLog.txt"
$targetOU = "OU=Staff,DC=corp,DC=company,DC=com"

# Ensure log directory exists
if (-not (Test-Path $logPath)) {
    try {
        New-Item -Path $logPath -ItemType Directory
    } catch {
        $_ | Out-File $errorLog -Append
    }
}

# Attempt to export Finance users
try {
    $targetUsers = Get-ADUser -SearchBase $targetOU -Filter "Department -eq 'Finance'" -Properties DisplayName, SamAccountName, Department
    $targetUsers | Select-Object Name, SamAccountName, Department | Export-Csv $logFile -NoTypeInformation
} catch {
    $_ | Out-File $errorLog -Append
}

# ------------------------------------------------------------------------------------------------------
# Script 3: Export stopped services set to start automatically
# ------------------------------------------------------------------------------------------------------

$logPath = "C:\Temp"
$logFile = "${logPath}\StoppedAutoServices.csv"

# Ensure directory exists
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}

# Query stopped services that are set to Start Automatically
$stoppedServices = Get-CimInstance -ClassName Win32_Service | Where-Object {
    $_.State -eq "Stopped" -and $_.StartMode -eq "Auto"
}

# Export service info to CSV
$stoppedServices | Select-Object DisplayName, State, StartMode | Export-Csv $logFile -NoTypeInformation

# ------------------------------------------------------------------------------------------------------
# Script 4: Export Infrastructure department users, handle errors
# ------------------------------------------------------------------------------------------------------

Import-Module ActiveDirectory

$logPath = "C:\Audit"
$logError = "C:\Temp"
$errorFile = "${logError}\errorlog.txt"
$logFile = "${logPath}\InfraUsers.csv"
$targetOU = "OU=IT,DC=corp,DC=company,DC=com"

# Ensure log and error directories exist
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}
if (-not (Test-Path $logError)) {
    New-Item -Path $logError -ItemType Directory
}

# Attempt to export Infrastructure users
try {
    $targetUsers = Get-ADUser -SearchBase $targetOU -Filter "Department -eq 'Infrastructure'" -Properties Name, SamAccountName, Department
    $targetUsers | Select-Object Name, SamAccountName, Department | Export-Csv $logFile -NoTypeInformation
} catch {
    $_ | Out-File $errorFile -Append
}

# ------------------------------------------------------------------------------------------------------
# Script 5: List manually-started services that are not running
# ------------------------------------------------------------------------------------------------------

# Using CIM
$services = Get-CimInstance Win32_Service | Where-Object { $_.StartMode -eq "Manual" -and $_.State -ne "Running" }
$services | Out-File "C:\Temp\Manual_NotRunning.txt"

# Using Get-Service (with correction)
$servicelog = "C:\Temp\Manual_NotRunning_GetService.txt"
$services = Get-Service | Where-Object { $_.StartType -eq "Manual" -and $_.Status -eq "Stopped" }
$services | Out-File -Append $servicelog

# ------------------------------------------------------------------------------------------------------
# Script 6: Print AD users from IT department
# ------------------------------------------------------------------------------------------------------

Import-Module ActiveDirectory

$itusers = Get-ADUser -Filter * -Properties Department | Where-Object { $_.Department -eq "IT" }
$itusers | Select-Object Name, Department

# ------------------------------------------------------------------------------------------------------
# Script 7: Log latest System warnings to file
# ------------------------------------------------------------------------------------------------------

$logPath = "C:\Logs\Today\"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}

Get-EventLog -LogName System -EntryType Warning -Newest 15 |
Out-File "$logPath\Logs_Today.txt"

# ------------------------------------------------------------------------------------------------------
# Script 8: Restart print spooler if stopped, log action
# ------------------------------------------------------------------------------------------------------

$spooler = Get-Service -Name Spooler
if ($spooler.Status -eq "Stopped") {
    Start-Service -Name Spooler
    "Spooler restarted at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File "C:\Temp\SpoolerLog.txt" -Append
}

# ------------------------------------------------------------------------------------------------------
# Script 9: Export running services that start with W to CSV
# ------------------------------------------------------------------------------------------------------

$logPath = "C:\Temp"
$csvFile = "$logPath\Services_W.csv"

if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}

$services = Get-Service | Where-Object { $_.Status -eq "Running" -and $_.Name -like "W*" }
$services | Export-Csv -Path $csvFile -NoTypeInformation

# ------------------------------------------------------------------------------------------------------
# Script 10: Log Disk-related errors from System event log
# ------------------------------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------------------------------
# Script 11: Create and update AD computer objects
# ------------------------------------------------------------------------------------------------------

Import-Module ActiveDirectory

# Create and tag computer L4961
New-ADComputer -Name "L4961" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L4961"
Set-ADComputer "L4961" -Add @{cdModel = "Latitude 7400"}
Set-ADComputer "L4961" -Description "HO, Latitude 7400"

# Create and tag computer L3822
New-ADComputer -Name "L3822" -Path "CN=Computers,DC=dukufst,DC=local" -SamAccountName "L3822"
Set-ADComputer "L3822" -Add @{cdModel = "Latitude 7430"}
Set-ADComputer "L3822" -Description "HO, Latitude 7430"

# ------------------------------------------------------------------------------------------------------
