function Import-WsusPowershellModule {
    $module = "UpdateServices"

    try {
        if ($null -eq (Get-Module $module -ErrorAction SilentlyContinue)) {
            Import-Module $module
        }
    }
    catch {
        return $Error[0]
    }
}

# Export functions
$exportMembers = @{
    Function = @(
        'Import-WsusPowershellModule'
    )
}
Export-ModuleMember @exportMembers