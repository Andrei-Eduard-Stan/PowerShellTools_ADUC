# OU Move Script – Notes 0.2

Andrei Eduard - Stan : 26/05/2025


---

## 🔧 Environment Changes

- **Domain Isolation:** Rebuilt the VM test environment setting the **connection** to use a **private virtual switch** in Hyper-V to keep it fully offline and separated from existent networks, including the corporate.

- **Domain Rename:** Changed the domain name from `fullers.local` to `dukufst.local` to avoid any potential clashes with live infrastructure.

- **Portability Test:** Exported the full VM (with checkpoint and config) to a USB stick and successfully ran it across personal and work machines. Encountered a processor compatibility warning when switching devices, but it didn’t affect stability or functionality.
	- *Note: It did not feel optimal, if I actively get involved with VM environments I might need to consider using an external SSD*

---

## 📜 Script Functionality & Improvements

- The script now produces **both a `.txt` log** (for simple traceability) **and a `.json` audit log**, which is structured and formatted for frontend reporting.
- The `ouMap` dictionary was updated to include **real laptop and desktop models** used in production (Latitude 3550, Optiplex 7070, etc.).

```powershell

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

```

- All actions (OU moves, group assignments, errors, etc.) are **timestamped and logged** in both formats.

```json
    {

        "Timestamp":  "2025-05-24 14:08:09",

        "ComputerName":  "L9009",

        "Action":  "Moved to",

        "Target":  "OU=Managed Houses,OU=FST Computers,DC=dukufst,DC=local"

    },

    {

        "Timestamp":  "2025-05-24 14:08:09",

        "ComputerName":  "L9009",

        "Action":  "Added to Group",

        "Target":  "Computer Certificate Enrolment"

    }
```

---

## 📊 Audit Log Dashboard

A new **HTML dashboard** was created to visually present the audit log:
- **Searchable, scrollable, filterable** table using [DataTables.js](https://datatables.net).
- Built-in sorting, responsive design, and clean layout with Bootstrap.

![[Pasted image 20250527095911.png|600]]

---
### ⚠️ Note:
The dashboard **requires a local server context** (not `file://` but like `http://127.0.0.1:5500`) to load the `.json` file due to browser security policies.

To view and test it, I:
- Opened the folder in **Visual Studio Code**.
- Used the **Live Server extension** to serve the HTML.

Without this, the table won’t populate due to blocked cross-origin requests when opened as a local file.

---

## 🧭 MMC Console Integration

Originally, I wanted to customize the **ADUC UI tabs** directly (yes, I don’t know what I was thinking 😅), but since that's not supported, I attempted to learn the following workaround

- Created a **custom MMC console** with:
  - A button to **run the OU Move script**.
  - A button to **open the audit dashboard** in the default browser.

```powershell
-ExecutionPolicy Bypass -File "C:\Windows\Scripts\MoveOU.ps1"
```

```powershell
Start-Process "C:\Windows\Scripts\OU_Move_Index.html"
```

![[Pasted image 20250527000605.png|400]]

This gives **intuitive and fast access** to the functionality without needing to browse for files or open PowerShell manually.

---

## ✅ Testing Outcome

The system has been tested with various mock devices and groups in the isolated VM and is now at what I’d call a **first stable and functional prototype**.

---

## 🔜 Next Steps

If you're happy with it so far, I’d like to propose:

- Creating a **Test OU in our actual AD**.
- Running the script in a safe corner of our real domain to confirm it behaves as expected and adapting anything as needed.

Once that’s in place, I’d personally be happy to start **using it in day-to-day work** instead of handling OU and group assignment manually.

---

## 💡 Ideas for Extension

If you can think of any other areas this could tie into or expand toward, I'd love to hear them. The dashboard started as a logging layer just for OU moves — but there's **nothing stopping us from making it a broader reporting hub** (compliance views, machine status tracking, performance statistics, etc.).

If nothing springs to mind right now, no worries — once it's running live, I’ll explore what other reporting blocks might be useful to build around it.