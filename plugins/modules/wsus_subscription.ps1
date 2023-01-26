#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        update_classifications  = @{ type = "list"; elements = "str" }
        update_categories = @{ type = "list"; elements = "str"; aliases = "update_products" }
        state = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$updateClassifications = $module.Params.update_classifications
$updateCategories = $module.Params.update_categories
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get wsus config
try {
    $wsus = Get-WsusServer
    $subscription = $wsus.GetSubscription()
}
catch {
    $module.FailJson("Failed to get WSUS configuration", $Error[0])
}


$module.ExitJson()