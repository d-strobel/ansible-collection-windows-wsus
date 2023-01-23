#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        name                  = @{ type = "str"; required = $true }
        computer_target_group = @{ type = "list"; elements = "str" }
        update_classification = @{ type = "list"; elements = "str" }
        update_product        = @{ type = "list"; elements = "str" }
        deadline              = @{ type = "str" }
        state                 = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$name = $module.Params.name
$computerTargetGroup = $module.Params.computer_target_group
$updateClassification = $module.Params.update_classification
$updateProduct = $module.Params.update_product
$deadline = $module.Params.deadline
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get wsus config
try {
    $wsusConfig = Get-WsusServer
}
catch {
    $module.FailJson("Failed to get WSUS configuration", $Error[0])
}


# Check Approval rule existing
try {
    $approvalRule = $wsusConfig.GetInstallApprovalRules() | Where-Object {$_.Name -eq $name}
}
catch {
    $module.FailJson("Failed to get approval rules", $Error[0])
}


if (($null -ne $approvalRule) -and ($state -eq "absent")) {
    try {
        $wsusConfig.DeleteInstallApprovalRule($approvalRule.Id)
        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to remove WSUS approval rule $name", $Error[0])
    }
}
elseif (($null -eq $approvalRule) -and ($state -eq "absent")) {
    try {
        $approvalRule = $wsusConfig.CreateInstallApprovalRule($name)
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to create WSUS approval rule $name", $Error[0])
    }
}

$module.ExitJson()