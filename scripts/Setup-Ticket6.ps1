# Setup-Ticket6.ps1
# Lab exercise: makes hidden changes to Group Policy so I can practice
# troubleshooting a "policy not applying" ticket without knowing the cause upfront.
# Run on DC01 as admin, AFTER taking a snapshot.
# Commands documented on Microsoft Learn (Set-GPLink, Set-GPPermission).
# Scenario designed with an AI assistant; troubleshooting done blind by me.

Import-Module GroupPolicy

# Look the policy up with a wildcard, since typing the name exactly kept failing
$gpo = (Get-GPO -All | Where-Object { $_.DisplayName -like "Staff*Restrictions" }).DisplayName

# --- Spoilers below (what each line breaks) ---
# Cause 1: switch off the policy's link to the Sales OU
Set-GPLink -Name $gpo -Target "OU=Sales,OU=BehelitTech,DC=nahemalab,DC=local" -LinkEnabled No
# Cause 2: let HR-staff apply the policy...
Set-GPPermission -Name $gpo -TargetName "HR-staff" -TargetType Group -PermissionLevel GpoApply
# ...and downgrade Authenticated Users to read only, so nobody else gets it (security filtering)
Set-GPPermission -Name $gpo -TargetName "Authenticated Users" -TargetType Group -PermissionLevel GpoRead -Replace
