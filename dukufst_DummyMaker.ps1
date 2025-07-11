Import-Module ActiveDirectory

$OU = "OU=Head Office,OU=FST Computers,DC=dukufst,DC=local"

if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OU'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Head Office" -Path "OU=FST Computers,DC=dukufst,DC=local"
    Write-Host "OU 'Head Office' created."
} else {
    Write-Host "OU 'Head Office' already exists."
}

$computers = @("L1000", "L1001", "L1002", "L1003", "L1004")
foreach ($c in $computers) {
    if (-not (Get-ADComputer -Filter "Name -eq '$c'" -SearchBase $OU -ErrorAction SilentlyContinue)) {
        New-ADComputer -Name $c -Path $OU -Enabled $true -Description "HO, Latitude 7400"
        Write-Host "Computer '$c' created in 'Head Office'."
    } else {
        Write-Host "Computer '$c' already exists."
    }
}

$users = @(
    @{SamAccountName="jdoe"; Name="John Doe"; Password="P@ssword1!"},
    @{SamAccountName="asmith"; Name="Alice Smith"; Password="P@ssword1!"}
)
foreach ($u in $users) {
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue)) {
        New-ADUser -SamAccountName $u.SamAccountName -Name $u.Name -AccountPassword (ConvertTo-SecureString $u.Password -AsPlainText -Force) -Enabled $true -Path $OU
        Write-Host "User '$($u.Name)' created in 'Head Office'."
    } else {
        Write-Host "User '$($u.Name)' already exists."
    }
}

$groupName = "HO Admins"
if (-not (Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue)) {
    New-ADGroup -Name $groupName -GroupScope Global -Path $OU
    Write-Host "Group '$groupName' created in 'Head Office'."
} else {
    Write-Host "Group '$groupName' already exists."
}

if (-not (Get-ADGroupMember -Identity $groupName | Where-Object {$_.SamAccountName -eq "jdoe"})) {
    Add-ADGroupMember -Identity $groupName -Members "jdoe"
    Write-Host "User 'jdoe' added to group '$groupName'."
} else {
    Write-Host "User 'jdoe' already in group '$groupName'."
}

$extraUsers = 1..10 | ForEach-Object {
    @{ SamAccountName = "testuser$_"; Name = "Test User $_"; Password = "P@ssword1!" }
}
foreach ($u in $extraUsers) {
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue)) {
        New-ADUser -SamAccountName $u.SamAccountName -Name $u.Name -AccountPassword (ConvertTo-SecureString $u.Password -AsPlainText -Force) -Enabled $true -Path $OU
        Write-Host "User '$($u.Name)' created in 'Head Office'."
    } else {
        Write-Host "User '$($u.Name)' already exists."
    }
}

$services = @("TestServiceA", "TestServiceB", "TestServiceC")
foreach ($svc in $services) {
    if (-not (Get-Service -Name $svc -ErrorAction SilentlyContinue)) {
        New-Service -Name $svc -BinaryPathName "C:\\Windows\\System32\\cmd.exe /k" -DisplayName $svc -StartupType Manual
        Write-Host "Service '$svc' created."
    } else {
        Write-Host "Service '$svc' already exists."
    }
}

Write-Host "Test objects and services created successfully."
