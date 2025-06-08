
# 🛠️ PowerShellTools_ADUC

**Author:** Andrei Stan  
**Scope:** Internal IT Utilities for Active Directory (ADUC)

---

## 📁 Overview

This repository contains a collection of PowerShell-based tools and scripts designed to assist with Active Directory management through ADUC (Active Directory Users and Computers). These tools are built to streamline repetitive tasks, reduce human error, and offer enhanced visibility and automation within a Windows Server domain environment.

---

## 🧩 Use Case

These tools are intended to:

- Automate common AD tasks (e.g. sorting, logging, group membership)
- Enhance visibility into AD object actions via dashboards and logs
- Allow intuitive access through MMC integration
- Serve as a sandbox for ongoing IT automation scripts

---

## 🧱 Structure

Each folder in this repo represents a specific functional script or utility. For example:

```
PowerShellTools_ADUC/
│
├── OUMove_Automation/
│   ├── OUMove_computersJS3.ps1
│   ├── OU_Move_Log.json
│   ├── OU_Move_Log.txt
│   ├── OU_Move_Index.html
│   └── README.md
│
├── AnotherToolName/
│   ├── [Future Scripts and Components]
│   └── README.md
│
└── README.md
```

> 💡 Each subfolder includes its own `README.md` with setup instructions and a breakdown of logic and dependencies.

---

## 📌 Requirements

- PowerShell 5.1+
- Active Directory Module for Windows PowerShell
- Domain-joined environment (or lab/test environment)
- Optional: MMC custom console setup
- Optional: [Live Server VS Code extension](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) (for dashboards)

---

## 📖 Included Tools (so far)

| Tool | Function |
|------|----------|
| **OUMove_Automation** | Sorts computers into the correct OU based on model, assigns AD groups, generates audit logs, and shows a searchable dashboard |

> More tools will be added as they're developed and tested.

---

## 🧪 Testing

Most tools are first tested in a **private Hyper-V lab** with:

- A separate domain (e.g. `dukufst.local`)
- Mock computer objects
- Custom MMC task buttons
- Local dashboards hosted via Live Server

---

## 💬 Feedback & Iteration

All scripts are continuously improved based on live testing, feedback, and evolving internal needs. If a function proves useful, stable, and safe — it may be proposed for integration into the actual ADUC environment.

---

## 🧼 Disclaimer

These scripts are created and tested for **internal use only**. Always validate in a lab environment before applying to production.
