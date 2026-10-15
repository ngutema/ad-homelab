# 🏢 AD Home Lab: BehelitTech

![Cost](https://img.shields.io/badge/cost-%240-brightgreen)
![Windows Server](https://img.shields.io/badge/Windows%20Server-2022-0078D6?logo=windows&logoColor=white)
![VirtualBox](https://img.shields.io/badge/VirtualBox-free-183A61?logo=virtualbox&logoColor=white)
![Status](https://img.shields.io/badge/status-in%20progress-yellow)

A Windows Server Active Directory home lab where I build a small fake company, **BehelitTech**, from scratch and run it like a real IT help desk: domain setup, user management, permissions, Group Policy, automation, and real support tickets.

**Built entirely with free tools. No subscriptions, no cloud bills.**

---

##  Tools Used (All Free)

| Tool | What it's for | Cost |
|---|---|---|
| [VirtualBox](https://www.virtualbox.org/) | Runs the virtual machines on my laptop | Free, open source |
| [Windows Server 2022 Evaluation](https://www.microsoft.com/en-us/evalcenter) | Domain controller, Active Directory, DNS | Free 180 day trial |
| [Windows 11 Enterprise Evaluation](https://www.microsoft.com/en-us/evalcenter) | Employee workstation | Free 90 day trial |
| PowerShell | Admin commands and automation | Built into Windows |
| [GitHub Issues](https://docs.github.com/en/issues) | Help desk ticketing system | Free |

>  **Want to build your own?** You don't need paid cloud servers or a ticketing subscription. A laptop with 16 GB of RAM, VirtualBox, and Microsoft's free evaluation downloads are enough to practice real IT work. Take snapshots often, and you can rebuild when a trial expires.

---

## 🖥️ Lab Setup

| Machine | Role | Specs | IP |
|---|---|---|---|
| DC01 | Domain Controller, DNS, file shares | Windows Server 2022, 4 GB RAM, 2 CPUs, 50 GB | 10.0.2.10 (static) |
| CLIENT01 | Employee PC | Windows 11 Enterprise, 4 GB RAM, 2 CPUs, 64 GB | DHCP |

- **Host:** VirtualBox on a 16 GB RAM laptop
- **Network:** VirtualBox NAT Network "ADLab" (10.0.2.0/24)
- **Domain:** nahemalab.local


---

## 📚 Lab Parts

### [Part 1-3: Building the server and creating the domain](docs/01-server-setup.md)
- Installed Windows Server on a private virtual network
- Configured a static IP address and DNS
- Installed Active Directory and promoted the server to a Domain Controller

### [Part 4-6: Users, groups, and department shared folders](docs/02-users-groups-shares.md)
- Created Organizational Units for each department
- Created user accounts and added them to security groups
- Set up shared folders with share and NTFS permissions

### [Part 7: Joining a Windows 11 PC to the domain](docs/03-client-join.md)
- Configured client DNS and joined a Windows 11 PC to the domain
- Troubleshot connectivity, DNS, and admin permission issues
- Verified access control by testing allowed and denied users

### [Part 8: Help desk ticketing and real tickets](docs/04-help-desk-tickets.md)
- Built a ticketing workflow with priority, tier, and category labels
- Resolved a share permission issue, a password reset, and a device service request
- Documented each ticket with investigation, resolution, and root cause
- 🎫 [View all tickets](../../issues?q=is%3Aissue
