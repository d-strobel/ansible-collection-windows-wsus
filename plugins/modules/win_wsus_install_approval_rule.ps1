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

