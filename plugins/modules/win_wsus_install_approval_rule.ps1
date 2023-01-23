#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        name                  = @{ type = "str"; required = $true }
        computer_target_group = @{ type = "list"; element = "str" }
        update_classification = @{ type = "list"; element = "str" }
        update_product        = @{ type = "list"; element = "str" }
        deadline              = @{ type = "str" }
        state                 = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$ErrorActionPreference = 'Stop'

# Map variables
$name = $module.Params.name
$computerTargetGroup = $module.Params.computer_target_group
$updateClassification = $module.Params.update_classification
$updateProduct = $module.Params.update_product
$deadline = $module.Params.deadline
$state = $module.Params.state

# Get wsus config
$wsusConfig = Get-WsusServer

# Check Approval rule existing
$approvalRule = $wsusConfig.GetInstallApprovalRules() | Where-Object {$_.Name -eq $name}

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

