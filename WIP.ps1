$logPath = "C:\Temp\Logs"
$logFile = "$logPath\AppErrors.txt"

# Get latest 20 Application-level errors
$appErrors = Get-EventLog -LogName Application -EntryType Error -Newest 20

# If folder doesn't exist, create it
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
    Write-Host "$logPath created"
}
#---
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

#---
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
Import-Module ActiveDirectory

$logPath="C:\Audit"
$logError="C:\Temp"
$errorFile="${logError}\errorlog.txt"
$logFile="${logPath}\InfraUsers.csv"
$targetOU="OU=IT,DC=corp,DC=company,DC=com"


if (-not (Test-Path $logPath)){

New-Item -Path $logPath -ItemType Directory

}



if (-not (Test-Path $logError)){

New-Item -Path $logError -ItemType Directory

}


try{
$targetUsers=Get-ADUser -SearchBase $targetOU -Filter "Department -eq  'Infrastructure'"  -Properties Name, SamAccountName, Department

$targetUsers | Select-Object Name, SamAccountName, Department |Export-Csv $logFile -NoTypeInformation 

}catch{

$_ | Out-File $errorFile -Append

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


# ---------------------------------------------------------------------------------------------

