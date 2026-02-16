# 🏢 Enterprise Active Directory with Samba 4

[![Samba Version](https://img.shields.io/badge/Samba-4.19.5-blue.svg)](https://www.samba.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20LTS-orange.svg)](https://ubuntu.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)]()

> A complete enterprise Active Directory implementation using Samba 4 on Ubuntu Server 24.04, featuring dual-domain forest trust, automated folder mapping, and cross-platform client integration.

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Infrastructure](#-infrastructure)
- [Quick Start](#-quick-start)
- [Documentation](#-documentation)
- [Network Architecture](#-network-architecture)
- [Sprints](#-sprints)
- [Screenshots](#-screenshots)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## 🎯 Overview

This project demonstrates a **production-grade Active Directory** infrastructure using open-source tools. It includes two complete AD domains with bidirectional forest trust, comprehensive user management, Group Policy Objects (GPO), and seamless integration with Windows 11 and Ubuntu Desktop clients.

### What's Included

✅ **Two Active Directory Domain Controllers** (LAB05 and LAB06)  
✅ **Bidirectional Forest Trust** between domains  
✅ **8 Domain Users** across multiple security groups  
✅ **3 Organizational Units** with delegation of control  
✅ **Group Policy Objects** for password security  
✅ **Shared Folders** with granular ACL permissions  
✅ **Automatic Folder Mapping** (logon scripts for Windows, PAM for Linux)  
✅ **Cross-Domain Authentication** and resource access  
✅ **Multi-Platform Clients** (Windows 11 & Ubuntu Desktop)

## ✨ Features

### Domain Controller Capabilities

- **Full AD DS functionality** with Samba 4.19.5
- **Internal DNS server** with SRV record support
- **Kerberos authentication** (KDC)
- **LDAP directory services**
- **Global Catalog** support
- **SYSVOL replication** ready

### Security & Compliance

- **Password complexity enforcement**
- **Account lockout policies**
- **Password history** (24 passwords)
- **Minimum password age** (1 day)
- **Maximum password age** (42 days)
- **12-character minimum length**

### Network Shares

| Share | Access | Purpose |
|-------|--------|---------|
| **FinanceDocs** | Finance group (R/W, no delete) | Financial documents with sticky bit |
| **HRDocs** | HR_Staff group (R/W) | Human resources documents |
| **Public** | All domain users (Read-only) | General shared resources |

### User & Group Structure

```
lab05.lan
├── Organizational Units (3)
│   ├── IT_Department
│   ├── HR_Department
│   └── Students
│
├── Security Groups (5)
│   ├── IT_Admins (iosif, karl, lenin)
│   ├── HR_Staff (vladimir)
│   ├── Students (alice, bob, charlie)
│   ├── Finance (empty)
│   └── Tech_Support (techsupport)
│
└── Domain Users (8)
    ├── alice, bob, charlie → Students
    ├── iosif, karl, lenin → IT_Admins
    ├── vladimir → HR_Staff
    └── techsupport → Tech_Support
```

## 🏗️ Infrastructure

### Domain Controllers

| Component | LAB05 | LAB06 |
|-----------|-------|-------|
| **Domain** | lab05.lan | lab06.lan |
| **Realm** | LAB05.LAN | LAB06.LAN |
| **NetBIOS** | LAB05 | LAB06 |
| **DC Hostname** | ls05.lab05.lan | ls06.lab06.lan |
| **Internal IP** | 192.168.1.1/24 | 192.168.1.2/24 |
| **Bridge IP** | 172.30.20.41/25 | 172.30.20.42/25 |
| **OS** | Ubuntu Server 24.04 | Ubuntu Server 24.04 |

### Client Systems

| Client | Hostname | IP Address | Domain | OS |
|--------|----------|------------|--------|-----|
| Windows 11 | wc-05 | 192.168.1.100 | lab05.lan | Windows 11 Pro |
| Ubuntu Desktop | lslc | 192.168.1.10 | lab05.lan | Ubuntu 24.04 |

### Default Credentials

**Domain Administrator (LAB05):**
- Username: `Administrator` or `administrator@LAB05.LAN`
- Password: `Admin_21`

**Domain Administrator (LAB06):**
- Username: `Administrator` or `administrator@LAB06.LAN`
- Password: `Admin_21`

**Linux System User:**
- Username: `administrador`
- Password: `admin_21`

## 🚀 Quick Start

### Prerequisites

- Ubuntu Server 24.04 LTS (minimal installation)
- 2GB RAM minimum (4GB recommended)
- 20GB disk space
- Static IP address or DHCP reservation
- Root or sudo access

### Installation (LAB05)

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Set hostname
sudo hostnamectl set-hostname ls05.lab05.lan

# 3. Configure network (edit accordingly)
sudo nano /etc/netplan/50-cloud-init.yaml

# 4. Disable systemd-resolved
sudo systemctl disable --now systemd-resolved
sudo unlink /etc/resolv.conf

# 5. Install Samba
sudo apt install -y samba samba-dsdb-modules samba-vfs-modules \
  winbind krb5-config krb5-user

# 6. Stop default services
sudo systemctl disable --now smbd nmbd winbind

# 7. Provision domain
sudo rm -f /etc/samba/smb.conf
sudo samba-tool domain provision --use-rfc2307 --interactive

# 8. Start Samba AD DC
sudo systemctl unmask samba-ad-dc
sudo systemctl enable samba-ad-dc
sudo systemctl start samba-ad-dc

# 9. Verify
sudo samba-tool domain info 127.0.0.1
```

### Verification

```bash
# Check domain level
sudo samba-tool domain level show

# Test DNS
host -t A ls05.lab05.lan
host -t SRV _ldap._tcp.lab05.lan

# Test Kerberos
kinit administrator@LAB05.LAN
klist
```

## 📚 Documentation

### Sprint-Based Implementation

This project is organized into 4 main sprints (~6 hours each):

1. **[Sprint 1: Domain Controller Setup](docs/sprint1-dc-setup.md)**
   - System configuration
   - Network setup
   - Samba installation and provisioning
   - DNS and Kerberos verification

2. **[Sprint 2: Users, Groups & OUs](docs/sprint2-users-groups.md)**
   - Organizational Units creation
   - Security groups configuration
   - User account creation
   - Password policy (GPO)

3. **[Sprint 3: Shared Folders & Permissions](docs/sprint3-shares.md)**
   - Shared directory structure
   - ACL configuration
   - Automatic folder mapping
   - Logon scripts (Windows/Linux)

4. **[Sprint 4: Forest Trust](docs/sprint4-forest-trust.md)**
   - Second domain controller setup
   - DNS forwarding
   - Forest trust creation
   - Cross-domain authentication

### Additional Documentation

- **[Windows 11 Client Configuration](docs/windows-client.md)**
- **[Ubuntu Desktop Client Configuration](docs/linux-client.md)**
- **[Cross-Domain Testing Guide](docs/cross-domain-testing.md)**
- **[Complete Command Reference](docs/command-reference.md)**
- **[Troubleshooting Guide](docs/troubleshooting.md)**

## 🌐 Network Architecture

```
                    Internet / External Network
                        DNS: 10.239.3.7/8
                              │
                        Gateway: 172.30.20.1
                              │
                  ┌───────────┴───────────┐
                  │   Bridge Network      │
                  │   172.30.20.0/25      │
                  └───────┬───────┬───────┘
                          │       │
                    .41   │       │   .42
                  ┌───────┴───┐ ┌─┴───────┐
                  │   ls05    │ │   ls06  │
                  │ LAB05 DC  │ │ LAB06 DC│
                  │172.30.20  │ │172.30.20│
                  │    .41    │ │    .42  │
                  └───────┬───┘ └─┴───────┘
                          │       │
                     .1   │       │   .2
                  ┌───────┴───────┴───────┐
                  │   Internal Network    │
                  │   192.168.1.0/24      │
                  │                       │
                  │   ls05: 192.168.1.1   │
                  │   ls06: 192.168.1.2   │
                  └───────┬───────────────┘
                          │
              ┌───────────┴───────────┐
              │   Domain Clients      │
              │                       │
              │  wc-05: .100 (Win11)  │
              │  lslc:  .10  (Ubuntu) │
              └───────────────────────┘

              Forest Trust (Bidirectional)
          LAB05.LAN ←──────────→ LAB06.LAN
```

### Trust Relationship

```
┌─────────────────────────────────┐     ┌─────────────────────────────────┐
│   Forest: lab05.lan             │     │   Forest: lab06.lan             │
│   ├─ DC: ls05.lab05.lan         │◄───►│   ├─ DC: ls06.lab06.lan         │
│   ├─ IP: 192.168.1.1            │     │   ├─ IP: 192.168.1.2            │
│   ├─ Users: 8                   │     │   ├─ Users: 2                   │
│   └─ Groups: 5                  │     │   └─ Trust Type: Forest         │
│                                 │     │                                 │
│   Trust Direction: BOTH         │     │   Trust Direction: BOTH         │
│   Trust Type: FOREST            │     │   Trust Type: FOREST            │
│   Transitive: YES               │     │   Transitive: YES               │
└─────────────────────────────────┘     └─────────────────────────────────┘
```

## 📊 Sprints

### Sprint Overview

| Sprint | Topic | Duration | Deliverables |
|--------|-------|----------|--------------|
| 1 | Domain Controller Setup | 6h | Functional AD DC, DNS, Kerberos |
| 2 | Users, Groups & OUs | 6h | 8 users, 5 groups, 3 OUs, password policy |
| 3 | Shared Folders & Permissions | 6h | 3 shares, ACLs, auto-mapping |
| 4 | Forest Trust | 6h | Second DC, bidirectional trust |

### Key Milestones

- [x] Domain provisioning complete
- [x] DNS and Kerberos operational
- [x] User and group structure created
- [x] Password policy (GPO) enforced
- [x] Shared folders with ACLs configured
- [x] Automatic folder mapping implemented
- [x] Second domain controller deployed
- [x] Forest trust established and validated
- [x] Windows 11 client joined
- [x] Ubuntu Desktop client joined
- [x] Cross-domain authentication tested

## 🖼️ Screenshots

### Domain Information

```bash
$ sudo samba-tool domain info 127.0.0.1

Forest           : lab05.lan
Domain           : lab05.lan
Netbios domain   : LAB05
DC name          : ls05.lab05.lan
DC netbios name  : LS05
Server site      : Default-First-Site-Name
Client site      : Default-First-Site-Name
```

### Password Policy

```bash
$ sudo samba-tool domain passwordsettings show

Password complexity: on
Password history length: 24
Minimum password length: 12
Minimum password age (days): 1
Maximum password age (days): 42
Account lockout duration (mins): 30
```

### Trust Validation

```bash
$ sudo samba-tool domain trust validate lab06.lan

OK: LocalValidation: DC[\\ls06.lab06.lan] CONNECTION[WERR_OK] TRUST[WERR_OK]
OK: LocalRediscover: DC[\\ls06.lab06.lan] CONNECTION[WERR_OK]
```

## 🔧 Troubleshooting

### Common Issues

#### DNS Resolution Failed

```bash
# Check DNS service
sudo systemctl status samba-ad-dc

# Verify resolv.conf
cat /etc/resolv.conf

# Test resolution
host -t A ls05.lab05.lan
host -t SRV _ldap._tcp.lab05.lan
```

#### Domain Join Failed

```bash
# Verify connectivity
ping ls05.lab05.lan

# Check DNS from client
nslookup lab05.lan

# Verify administrator password
sudo samba-tool user setpassword Administrator --newpassword='Admin_21'
```

#### Port 53 Conflict

```bash
# Check what's using port 53
sudo ss -tulnp | grep :53

# Disable systemd-resolved
sudo systemctl disable --now systemd-resolved
sudo unlink /etc/resolv.conf

# Create manual resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
```

### Getting Help

For detailed troubleshooting, see the [Troubleshooting Guide](docs/troubleshooting.md).

## 📈 Project Statistics

### Infrastructure Overview

- **Domain Controllers:** 2 (LAB05, LAB06)
- **Domains:** 2 (lab05.lan, lab06.lan)
- **Forest Trusts:** 1 (Bidirectional)
- **Client Systems:** 2 (Windows 11, Ubuntu Desktop)

### Active Directory Objects

- **Organizational Units:** 3
- **Security Groups:** 5
- **Domain Users:** 10 total (8 in LAB05, 2 in LAB06)
- **Computer Accounts:** 2

### Services Active

| Port | Protocol | Service | Status |
|------|----------|---------|--------|
| 53 | TCP/UDP | DNS | ✅ Active |
| 88 | TCP/UDP | Kerberos | ✅ Active |
| 389 | TCP | LDAP | ✅ Active |
| 636 | TCP | LDAPS | ✅ Active |
| 445 | TCP | SMB/CIFS | ✅ Active |
| 3268 | TCP | Global Catalog | ✅ Active |

## 🎓 Key Learnings

### Best Practices

1. **DNS is Critical** - DNS must resolve correctly for AD to function
2. **Disable systemd-resolved** - Samba requires full control of port 53
3. **Two-Layer Permissions** - Share + Filesystem (most restrictive wins)
4. **Time Synchronization** - Kerberos requires accurate time (< 5 min difference)
5. **Password Policies** - Apply domain-wide, affect new passwords only

### Samba-Specific Notes

- Netlogon errors in trust validation are **normal**
- Use `samba-tool` for most management tasks
- `systemd-resolved` MUST be disabled
- ACLs provide Windows-like granularity

## 🚀 Future Enhancements

### Recommended

- [ ] Advanced GPOs via RSAT from Windows
- [ ] LAM (LDAP Account Manager) web interface
- [ ] Email integration (Postfix/Dovecot with AD auth)
- [ ] Certificate Authority for LDAPS
- [ ] Single Sign-On (SSO) for web applications
- [ ] High availability with multiple DCs
- [ ] Centralized logging and monitoring

### Advanced Topics

- PowerShell remoting to Samba DC
- DFS (Distributed File System) namespace
- RODC (Read-Only Domain Controllers)
- Fine-Grained Password Policies

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **The Samba Team** - For creating and maintaining Samba 4
- **Ubuntu Community** - For excellent documentation
- **SSSD & Realmd Contributors** - For seamless Linux AD integration

## 📞 Contact

For questions, issues, or contributions:

- Open an issue in this repository
- Review the [documentation](docs/)
- Check the [troubleshooting guide](docs/troubleshooting.md)

---

**Project Status:** Production Ready ✅  
**Last Updated:** January 2026  
**Total Implementation Time:** ~29 hours

Made with ❤️ using Open Source tools
