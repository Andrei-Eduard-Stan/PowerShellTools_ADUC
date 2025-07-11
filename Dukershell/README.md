# Dukershell

Dukershell is a PowerShell module containing a set of reusable infrastructure automation tools designed for Windows environments.  
It provides auditing, monitoring, and recovery functions for administrators and engineers.

## Features

- Query local or remote members of the Administrators group
- Restart stopped automatic services and log results
- Export disk-related error logs from the System event log
- Error logging and timestamped output for all functions

## Requirements

- Windows PowerShell 5.1 or later (tested on Windows 10/11 and Server editions)
- Appropriate privileges for querying event logs and remote systems (Administrator recommended)
- PowerShell Remoting (WinRM) for certain remote scenarios
- `Get-LocalGroupMember` requires Windows 10/Server 2016 or later for local machine queries

## Installation

### Manual Installation

1. Clone or download this repository:

   ```powershell
   git clone https://github.com/Andrei-Eduard-Stan/PowerShellTools_ADUC/tree/main/Dukershell.git
   ```
Copy the Dukershell folder (containing Dukershell.psd1 and Dukershell.psm1) to one of the paths listed in `$env:PSModulePath`, for example:

```powershell
Copy-Item -Recurse -Path .\Dukershell\Dukershell -Destination "C:\Program Files\WindowsPowerShell\Modules\"
```
Import the module:

```powershell
Import-Module Dukershell
```
Verify the module is available:

```powershell
Get-Module -ListAvailable Dukershell
```
Usage from a local path (without install)
```powershell
Import-Module "C:\path\to\Dukershell\Dukershell.psm1"
```
## Functions
### Get-LocalAdminGroupMembers

Query local or remote Administrators group membership.

#### Syntax
```powershell
Get-LocalAdminGroupMembers [-ComputerName <string>]
```

#### Query local machine
```powershell
Get-LocalAdminGroupMembers
```
#### Query remote machine
```powershell
Get-LocalAdminGroupMembers -ComputerName "Server01"
```
> Output will be saved as a timestamped CSV in C:\Audit.

### Restart-StoppedAutoServices
Find and restart all stopped services set to Automatic start mode.

#### Syntax
```powershell
Restart-StoppedAutoServices [-optional_logFolder <string>]
```
#### Example
```powershell
Restart-StoppedAutoServices
```
```powershell
Restart-StoppedAutoServices -optional_logFolder "D:\ServiceLogs"
```

### Get-DiskLogs
Export the 20 most recent Disk-related error events from the System event log.

#### Syntax

```powershell
Get-DiskLogs [-targetComputer <string>]
```

#### Example

```powershell
# Query local machine logs
Get-DiskLogs

# Query a remote machine
Get-DiskLogs -targetComputer "Server02"
```

> Logs will be saved as CSV in C:\Logs.
---
### Notes:
For remote operations, ensure appropriate network connectivity, permissions, and that the remote computer allows PowerShell Remoting or CIM/WMI queries.

Log files are timestamped and stored in C:\Logs or C:\Audit depending on function.

---
### License
MIT License.

---

### Author
Andrei-Eduard Stan: https://github.com/Andrei-Eduard-Stan








