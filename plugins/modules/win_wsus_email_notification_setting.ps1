#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType
#AnsibleRequires -PowerShell ansible_collections.d_strobel.windows_wsus.plugins.module_utils.Helper

$spec = @{
    options             = @{
        smtp_host                      = @{ type = "str" }
        smtp_port                      = @{ type = "int"; default = 25 }
        smtp_username                  = @{ type = "str" }
        smtp_password                  = @{ type = "str" }
        smtp_password_update           = @{ type = "str"; choices = "always", "on_create"; default = "on_create" }
        smtp_authentication_required   = @{ type = "bool"; default = $false }
        sender_display_name            = @{ type = "str" }
        sender_email_address           = @{ type = "str" }
        email_language                 = @{ type = "str"; default = "en" }
        send_sync_notification         = @{ type = "bool"; default = $false }
        sync_notification_recipients   = @{ type = "list"; elements = "str" }
        send_status_notification       = @{ type = "bool"; default = $false }
        status_notification_frequency  = @{ type = "str"; choices = "daily", "weekly"; default = "daily" }
        status_notification_time       = @{ type = "str" }
        status_notification_recipients = @{ type = "list"; elements = "str" }
        state                          = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    required_if         = @(
        , @("smtp_authentication_required", $true, @("smtp_username", "smtp_password"))
        , @("send_sync_notification", $true, @("smtp_host", "sender_display_name", "sender_email_address", "sync_notification_recipients"))
        , @("send_status_notification", $true, @("smtp_host", "sender_display_name", "sender_email_address", "status_notification_recipients"))
    )
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$smtpHost = $module.Params.smtp_host
$smtpPort = $module.Params.smtp_port
$smtpUsername = $module.Params.smtp_username
$smtpPassword = $module.Params.smtp_password
$smtpPasswordUpdate = $module.Params.smtp_password_update
$smtpAuthenticationRequired = $module.Params.smtp_authentication_required
$senderDisplayName = $module.Params.sender_display_name
$senderEmailAddress = $module.Params.sender_email_address
$emailLanguage = $module.Params.email_language
$sendSyncNotification = $module.Params.email_language
$syncNotificationRecipients = $module.Params.sync_notification_recipients
$sendStatusNotification = $module.Params.send_status_notification
$statusNotificationFrequency = $module.Params.status_notification_frequency
$statusNotificationTime = $module.Params.status_notification_time
$statusNotificationRecipients = $module.Params.status_notification_recipients
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Ensure powershell module is loaded
# if (-not (Import-WsusPowershellModule)) {
#     $module.FailJson("Failed to load PowerShell-Module for Wsus")
# }

# Get configuration
try {
    $wsusConfig = (Get-WsusServer).GetEmailNotificationConfiguration()
}
catch {
    $module.FailJson("Failed to get WSUS email notification configuration", $Error[0])
}

# ------------------
# SMTP configuration
# ------------------

# SMTP Host
if ($smtpHost -and $wsusConfig.SmtpHostName -and ($state -eq "absent")) {
    try {
        $wsusConfig.SmtpHostName = ""
        $wsusConfig.Save()
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove smtp host", $Error[0])
    }
}
elseif ($smtpUsername -and ($wsusConfig.SmtpHostName -ne $smtpHost) -and ($state -eq "present")) {
    try {
        $wsusConfig.SmtpHostName = $smtpHost
        $wsusConfig.Save()
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set smtp host", $Error[0])
    }
}

# SMTP Port
if ($smtpPort -and ($wsusConfig.SmtpPort -ne $smtpPort) -and ($state -eq "present")) {
    try {
        $wsusConfig.SmtpPort = $smtpPort
        $wsusConfig.Save()
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set smtp port", $Error[0])
    }
}

# SMTP Username
if ($smtpUsername -and $wsusConfig.SmtpUserName -and ($state -eq "absent")) {
    try {
        $wsusConfig.SmtpUserName = ""
        $wsusConfig.Save()
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove smtp username", $Error[0])
    }
}
elseif ($smtpUsername -and ($wsusConfig.SmtpUserName -ne $smtpUsername) -and ($state -eq "present")) {
    try {
        $wsusConfig.SmtpUserName = $smtpUsername
        $wsusConfig.save()
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set smtp host", $Error[0])
    }
}

# SMTP Password
if ($smtpPassword -and $wsusConfig.HasSmtpUserPassword -and ($state -eq "absent")) {
    try {
        $wsusConfig.SetSmtpUserPassword("")
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove smtp password", $Error[0])
    }
}
elseif (
    $smtpPassword -and
    (((-not $wsusConfig.HasSmtpUserPassword) -and ($state -eq "present")) -or
    ($wsusConfig.HasSmtpUserPassword -and ($smtpPasswordUpdate -eq "always") -and ($state -eq "present")))
) {
    try {
        $wsusConfig.SetSmtpUserPassword($smtpPassword)
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set smtp password", $Error[0])
    }
}

$module.ExitJson()