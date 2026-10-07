# ad-homelab
Windows Server Active Directory home lab: domain setup, user management, Group Policy, PowerShell automation, and help desk ticket practice.

## Lab Setup
- Host: VirtualBox on a 16 GB RAM laptop
- DC01: Windows Server 2022 (4 GB RAM, 2 CPUs, 50 GB disk)
- Network: VirtualBox NAT Network "ADLab" (10.0.2.0/24)
- Domain: nahemalab.local

[Part 1-3: Building the server and creating the domain](docs/01-server-setup.md)
- Installed Windows Server on a private virtual network
- Configured a static IP address and DNS
- Installed Active Directory and promoted the server to a Domain Controller

[Part 4-6: Users, groups, and department shared folders](docs/02-users-groups-shares.md)
- Created Organizational Units for each department
- Created user accounts and added them to security groups
- Set up shared folders with share and NTFS permissions

[Part 7: Joining a Windows 11 PC to the domain](docs/03-client-join.md)
- Configured client DNS and joined a Windows 11 PC to the domain
- Troubleshot connectivity, DNS, and admin permission issues
- Verified access control by testing allowed and denied users
