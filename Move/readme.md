# 🧭 OU Move Automation – AD Scripting & Audit Tool

**Author:** Andrei Stan  
**Status:** Internal Prototype | Functional Stable Release  
**Tech Stack:** PowerShell | JSON | HTML/CSS | JavaScript (DataTables)

---

## 📌 Overview

OU Move Automation is a PowerShell-based tool designed to simplify and audit the process of automatically organizing computers in Active Directory based on their hardware model. It performs two key functions:

- Moves AD computer objects into appropriate OUs based on a defined model-to-OU mapping
- Adds computers to default AD groups
- Generates **both .txt and .json** audit logs
- Displays an interactive **dashboard** using DataTables.js

This reduces human error and repetitive manual sorting and lets IT teams clearly review and validate actions performed by the automation script.

---

## ⚙️ Core Features

|Feature|Description|
|---|---|
|🔁 Dynamic OU Mapping|Automatically sorts computers based on model names using a customizable dictionary|
|🧑‍🤝‍🧑 Group Assignment|Adds computers to essential AD groups (e.g., WSUS, VPN, Cert)|
|📁 Text + JSON Logging|Outputs a traditional log and structured JSON for dashboards|
|📊 Visual Audit Dashboard|JSON-fed HTML dashboard showing results in real time (sortable, searchable)|
|🔘 MMC Button Access|Integrates with MMC console for one-click access to script or dashboard|

---

## 🧪 Test Environment

- ✅ **New Domain:** `dukufst.local`
- ✅ **Isolated Network:** VM Switch set to *Private* to prevent domain conflicts
- ✅ **Live Simulation:** Mock computer objects created with defined `cdModel` attributes
- ✅ **Cross-machine Support:** Successfully exported VM to USB and tested on another laptop
- ✅ **No-impact Errors:** Encountered CPU feature warning when switching machines, but no blocking issues

---

## 📂 Files & Structure

```plaintext
OU_Move_Log.txt            # Raw text-based logs
OU_Move_Log.json           # Structured data for dashboards
OU_Move_Index.html         # Dashboard view (DataTables + JS)
OUMove_computersJS3.ps1    # Final script
```

---

## 🔧 Script Attached

```powershell

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


```


---

## 🌐Audit Dashboard

The HTML dashboard uses [DataTables.js](https://datatables.net) to render `OU_Move_Log.json` as a searchable, sortable, paginated table.


```html

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>OU Move Audit Log Dashboard</title>

    <!-- DataTables CSS -->
    <link
      rel="stylesheet"
      href="https://cdn.datatables.net/2.3.1/css/dataTables.dataTables.min.css"
    />

    <!-- Optional: Bootstrap for styling (optional) -->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
    />

    <!-- jQuery (required by DataTables) -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/2.3.1/js/dataTables.min.js"></script>
  </head>
  <body class="container py-4">
    <h2>OU Move Audit Log</h2>
    <table
      id="logTable"
      class="display table table-bordered table-hover"
      style="width: 100%"
    ></table>

    <script>
      fetch("OU_Move_Log.json")
        .then((response) => response.json())
        .then((data) => {
          $("#logTable").DataTable({
            data: data,
            columns: [
              { title: "Timestamp", data: "Timestamp" },
              { title: "Computer Name", data: "ComputerName" },
              { title: "Action", data: "Action" },
              { title: "Target", data: "Target" },
            ],
            pageLength: 15,
            order: [[0, "desc"]],
            responsive: true,
            dom: "Bfrtip",
          });
        });
    </script>
  </body>
</html>


```

**Note:** To view this dashboard correctly, you must run it via a local web server.
We used the **Live Server** VS Code extension for convenience. Without it, the dashboard won't load the JSON file due to browser security restrictions.

---

## 🧩 Video Explanation

https://youtu.be/jwF9O5bOdQ8

---

## 🗺️ Possible Future Extensions

- 📈 Graphs/stats to show group assignment frequency or time saved
    
- 📩 Email alert integration (failed moves, exceptions)
    
- 📊 Multi-script dashboard with other IT automation logs
    
- 🗃️ Integration with deployment/MDT tools
    

---

## 🧼 Cleanup

The original script `OUMove_computers.ps1` is deprecated and replaced with `OUMove_computersJS3.ps1`.

---

## 💬 Questions or Feedback?

Happy to hear any ideas for improvement — even small tweaks.

