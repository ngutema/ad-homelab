# Offboard-User.ps1
# Disables a user, resets their password, removes their groups,
# documents the account, moves it to Disabled Users, and logs every step.
# Built from the manual steps in Ticket #7. Written with AI help, tested in the lab.
# Usage:   .\Offboard-User.ps1 -User <username> -Ticket <number> [-WhatIf]
# Example: .\Offboard-User.ps1 -User sgoodman -Ticket 8 -WhatIf   (dry run, changes nothing)
#          .\Offboard-User.ps1 -User sgoodman -Ticket 8           (real run)

[CmdletBinding(SupportsShouldProcess)]       # adds -WhatIf, which every AD cmdlet below respects
param(
    [Parameter(Mandatory)][string]$User,    # who is leaving
    [Parameter(Mandatory)][string]$Ticket   # ticket number, so every action traces back to a request
)

# Any error stops the script, so the log never claims a step worked when it didn't
$ErrorActionPreference = 'Stop'

$disabledOU = "OU=Disabled Users,OU=BehelitTech,DC=nahemalab,DC=local"
$logFile    = "C:\Scripts\Logs\Offboarding.log"
New-Item -ItemType Directory -Path "C:\Scripts\Logs" -Force -WhatIf:$false | Out-Null

# Writes a timestamped line to the screen and the log, including which admin ran it.
# Skipped during a dry run, since nothing actually happened.
function Write-Log($msg) {
    if ($WhatIfPreference) { return }
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$env:USERNAME] Ticket #$Ticket $User - $msg"
    Add-Content -Path $logFile -Value $line
    Write-Host $line
}

# Find the account first. Stop if it doesn't exist.
try   { $account = Get-ADUser $User -Properties MemberOf }
catch { Write-Host "User '$User' not found. Nothing changed."; exit 1 }

# Safety check: offboarding the wrong person is hard to undo (skipped on a dry run)
if (-not $WhatIfPreference) {
    $confirm = Read-Host "Offboard $($account.Name) for Ticket #$($Ticket)? Type YES to continue"
    if ($confirm -cne "YES") { Write-Host "Cancelled. Nothing changed."; exit }
}

try {
    # 1. Disable: blocks new logins right away
    Disable-ADAccount -Identity $account
    Write-Log "Account disabled"

    # 2. Reset to a random password nobody knows, so re-enabling it doesn't let them back in
    Add-Type -AssemblyName System.Web     # Windows PowerShell 5.1 only, not PowerShell 7
    $pw = [System.Web.Security.Membership]::GeneratePassword(24, 4)
    Set-ADAccountPassword -Identity $account -Reset -NewPassword (ConvertTo-SecureString $pw -AsPlainText -Force)
    $pw = $null
    Write-Log "Password reset to random value (not recorded)"

    # 3. Remove every group. The names go in the log, so access can be restored if HR reverses the decision.
    #    (Domain Users is the primary group and isn't in this list)
    foreach ($group in $account.MemberOf) {
        Remove-ADGroupMember -Identity $group -Members $account -Confirm:$false
        Write-Log "Removed from $((Get-ADGroup $group).Name)"
    }

    # 4. Leave a note so the next admin knows why it's disabled
    $date = Get-Date -Format "yyyy-MM-dd"
    Set-ADUser -Identity $account -Description "Disabled $date - Ticket #$Ticket - offboarded"
    Write-Log "Description set"

    # 5. Move to Disabled Users so they stop getting department policies
    Move-ADObject -Identity $account.DistinguishedName -TargetPath $disabledOU
    Write-Log "Moved to Disabled Users OU"
}
catch {
    # Record exactly where it broke, then stop. The admin finishes or fixes the rest by hand.
    Write-Log "FAILED: $($_.Exception.Message)"
    Write-Host "Stopped early. Check the log and finish the remaining steps manually." -ForegroundColor Red
    exit 1
}

if ($WhatIfPreference) {
    Write-Host "Dry run finished. Nothing was changed." -ForegroundColor Yellow
} else {
    # Disabling doesn't end sessions that are already open (lesson from Ticket #7)
    Write-Log "DONE. Reminder: force sign out on any device they're still logged into"
}
