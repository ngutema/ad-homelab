
# Check-Lockout.ps1
# Shows if a user is locked out, how many wrong passwords they typed, and when.
# Usage:   .\Check-Lockout.ps1 <username>
# Example: .\Check-Lockout.ps1 god_yagami

param($user)   # the username you type after the script name

# Look up the user in Active Directory and show only the lockout details
Get-ADUser $user -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt |
    Select-Object Name, LockedOut, BadLogonCount, LastBadPasswordAttempt
