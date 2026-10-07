# ad-homelab
Windows Server Active Directory home lab: domain setup, user management, Group Policy, PowerShell automation, and help desk ticket practice.

## Lab Setup
- Host: VirtualBox on a 16 GB RAM laptop
- DC01: Windows Server 2022 (4 GB RAM, 2 CPUs, 50 GB disk)
- Network: VirtualBox NAT Network "ADLab" (10.0.2.0/24)
- Domain: nahemalab.local

[Part 1-3: Building the server and creating the domain](docs/01-server-setup.md)
- Built DC01 on a private VirtualBox network
- Set a static IP and explained DNS vs gateway
- Installed AD DS and created nahemalab.local

[Part 4-6: Users, groups, and department shared folders](docs/02-users-groups-shares.md)
- Built the BehelitTech company with IT, HR, and Sales OUs
- Onboarded users and sorted them into security groups
- Locked each department's folder with share and NTFS permissions

[Part 7: Joining a Windows 11 PC to the domain](docs/03-client-join.md)
- Built CLIENT01 and joined it to the domain
- Troubleshot a paused server, wrong DNS, and a non admin PowerShell window
- Tested access: Guts blocked from HR, Jon Snow allowed in
