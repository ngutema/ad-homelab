# Part 9: Group Policy and Account Lockout

## Dilemma: BehelitTech has users and PCs, but no company wide rules. Someone could guess a password thousands of times and nothing would stop them, and changing settings on every PC by hand doesn't scale.
## Objective: Use Group Policy to set rules for the whole domain from one place, starting with an account lockout policy, then handle the lockout tickets it creates.

Steps

1) First we open Tools > Group Policy Management on DC01. This is where every policy for the domain lives.

![Group Policy Management](../SetupScreenshots/10_gpmc_overview.png)

** A policy only does something once it's linked to a spot in this tree. Link it to the domain and it hits everyone. Link it to HR and only HR gets it. That's why we built OUs earlier.

2) Password and lockout rules for domain accounts only work at the domain level, so we edit the Default Domain Policy, which is linked to all of nahemalab.local.

![Default Domain Policy linked to the domain](../SetupScreenshots/10_default_domain_policy.png)

3) Before changing anything, I checked the existing Password Policy. This finally explained why the domain rejected my simple passwords back when I created users.

![Password policy defaults](../SetupScreenshots/10_password_policy.png)

** Max password age is 42 days by default. Current guidance like NIST actually advises against forced regular changes, since people just go from Summer2026! to Fall2026!. Longer passwords and changing them only after a compromise work better.

4) Next we open Account Lockout Policy. By default, there is no lockout at all, so an attacker could guess passwords forever.

![Lockout before](../SetupScreenshots/10_lockout_before.png)

5) I set the threshold to 5 invalid attempts, with a 15 minute lockout and a 15 minute counter reset. 5 gives real people room for typos while stopping brute force guessing.

![Lockout after](../SetupScreenshots/10_lockout_after.png)

6) To apply it right away instead of waiting about 90 minutes, I ran this on DC01:
   terminal> gpupdate /force

![gpupdate](../SetupScreenshots/10_gpupdate.png)

7) Great, now we test it. On CLIENT01 I typed a wrong password for Light Yagami 5 times, and Windows locked him out.

![Locked out on CLIENT01](../SetupScreenshots/10_lockout_message.png)

8) DC01 confirms it too. Light's Account tab in Active Directory now says the account is locked out.

![Locked out in AD](../SetupScreenshots/10_lockout_aduc.png)

# Ticket #4: Locked Out of My Account

## Dilemma: The new policy works, which means people will now get locked out. Light called saying his account is locked but he's sure he knows his password.
## Objective: Confirm the lockout, make sure it's not an attack, and unlock him without resetting his password.

P3-medium / tier-1 / access

1) Same as any account ticket, I verified Light's identity by calling back the number on file first.

** A lockout isn't a forgotten password. Light knows his password, so the right fix is an unlock, not a reset. Resetting when you don't need to just creates a temp password floating around for no reason.

2) To investigate, I needed to see if Light was locked out, how many wrong passwords were typed, and when. Microsoft's documentation for Get-ADUser (Microsoft Learn) shows these are stored as properties on the account:
   terminal> Get-ADUser god_yagami -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt | Select-Object Name, LockedOut, BadLogonCount, LastBadPasswordAttempt

** Tip: if you don't know what a property is called, run Get-ADUser <username> -Properties * to see everything AD stores about that user.

** That command works, but it's way too long to type every time. Light won't be the only person who gets locked out, and lockouts are one of the most common help desk tickets. So I turned it into a small reusable script.

3) I wrote Check-Lockout.ps1 in PowerShell ISE and saved it in C:\Scripts (also in this repo's [scripts folder](../scripts/Check-Lockout.ps1)):

   param($user)
   Get-ADUser $user -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt |
       Select-Object Name, LockedOut, BadLogonCount, LastBadPasswordAttempt

   Now any lockout check is one short line:
   terminal> .\Check-Lockout.ps1 god_yagami

** param($user) is what lets the script take a username, like a function argument in Python. Same script, any employee.

4) My first run failed with "the term is not recognized." I was still in C:\Users\Administrator, not C:\Scripts. PowerShell only runs scripts from the folder you're in (or a full path).

![Script not recognized](../SetupScreenshots/11_script_error.png)

5) After moving into C:\Scripts and fixing a typo (BadLogoutCount instead of BadLogonCount, which made that column come out empty), the script worked. Interesting part: it showed LockedOut False with 5 bad attempts at 1:25 PM. The 15 minute lockout duration had already passed, so AD unlocked him on its own. The policy was doing exactly what I set it to.

![Script working, auto unlocked](../SetupScreenshots/11_check_lockout_script.png)

6) To work the full ticket, I locked Light out again and checked right away. Locked out, 5 bad attempts, and the timing matched his own attempts, so no sign of someone else guessing.

![Locked out](../SetupScreenshots/11_ticket4_lockedout.png)

** Why check the timing? If he says "I tried twice this morning" but it shows 50 attempts at 3am, that's not a typo. That's someone trying to guess his password, and the ticket becomes a security issue.

7) Then we unlock him without touching his password:
   terminal> Unlock-ADAccount god_yagami
   Running the script again shows LockedOut False and the bad logon count back at 0.

![Unlocked](../SetupScreenshots/11_ticket4_unlocked.png)

8) Light signed in on CLIENT01 with his normal password.

![Light signing in](../SetupScreenshots/11_ticket4_verified.png)

Root cause: user mistyped his password 5 times, triggering the new lockout policy. Policy working as intended.

# Wrapping Up

Turning on one setting created a whole new type of ticket, which is pretty much how real IT works: every rule you add for security also adds something users can run into. Getting that balance right is the job.

The part I liked most was the script. It came from a real annoyance, typing the same long command, and now it's a tool I'll reuse for every lockout ticket. Next up in Group Policy: mapped drives so each department gets its folder automatically.
