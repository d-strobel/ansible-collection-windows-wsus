#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        name                   = @{ type = "str"; required = $true }
        computer_target_groups = @{ type = "list"; elements = "str" }
        update_classifications = @{ type = "list"; elements = "str" }
        update_products        = @{ type = "list"; elements = "str" }
        deadline               = @{ type = "str" }
        state                  = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$name = $module.Params.name
$computerTargetGroups = $module.Params.computer_target_groups
$updateClassifications = $module.Params.update_classifications
$updateProducts = $module.Params.update_products
$deadline = $module.Params.deadline
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get wsus config
try {
    $wsus = Get-WsusServer
}
catch {
    $module.FailJson("Failed to get WSUS configuration", $Error[0])
}

# Check Approval rule existing
try {
    $approvalRule = $wsus.GetInstallApprovalRules() | Where-Object { $_.Name -eq $name }
}
catch {
    $module.FailJson("Failed to get approval rules", $Error[0])
}

if (($null -ne $approvalRule) -and ($state -eq "absent")) {
    try {
        $wsus.DeleteInstallApprovalRule($approvalRule.Id)
        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to remove WSUS approval rule $name", $Error[0])
    }
}
elseif (($null -eq $approvalRule) -and ($state -eq "present")) {
    try {
        $approvalRule = $wsus.CreateInstallApprovalRule($name)
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to create WSUS approval rule $name", $Error[0])
    }
}

# Ensure computer target groups
if ($computerTargetGroups) {

    # Check if all groups exists
    $unvalidComputerGroups = $computerTargetGroups | Where-Object {
        $_ -notin $wsus.GetComputerTargetGroups().Name
    }
    if ($unvalidComputerGroups) {
        $module.FailJson("Computer target groups $unvalidComputerGroups does not exist.")
    }

    # Build wanted computer target group collection
    try {
        $wantedComputerGroups = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -in $computerTargetGroups }
        $wantedComputerTargetGroupCollection = New-Object Microsoft.UpdateServices.Administration.ComputerTargetGroupCollection
        $wantedComputerTargetGroupCollection.AddRange($wantedComputerGroups)
    }
    catch {
        $module.FailJson("Failed to build new computer target group collection.")
    }

    # Compare if target groups must be set
    if (Compare-Object -ReferenceObject $approvalRule.GetComputerTargetGroups() -DifferenceObject $wantedComputerTargetGroupCollection){
        try {
            $approvalRule.SetComputerTargetGroups($wantedComputerTargetGroupCollection)
            $approvalRule.Save()
            $module.Result.changed = $true
        }
        catch {
            $module.FailJson("Failed to set computer target group collection to approval rule.")
        }
    }
}

$module.ExitJson()