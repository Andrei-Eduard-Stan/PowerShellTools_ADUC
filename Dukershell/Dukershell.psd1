@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'Dukershell.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    GUID              = 'b78e7bb7-bef1-4a30-8e4e-cb7f731edabc'

    # Author of this module
    Author            = 'Andrei-Eduard Stan'

    # Description of this module
    Description       = 'Dukershell: Infrastructure Automation Toolkit for Admin Audits, Services, Logs.'

    # Minimum version of the Windows PowerShell engine required
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
    "Export-ADUsersByOU",
    "Export-DiskLogs",
    "Export-LocalAdminGroupMembers",
    "Restart-StoppedAutoServices"
    )
}
