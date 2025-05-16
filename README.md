# 🧪 Linux OS Sanity Check Script

This Bash script performs a detailed **Linux OS sanity check** to gather system health, configurations, and diagnostic information. It’s helpful for system administrators performing pre/post-patch validation, server health audits, or routine system checks.

---

## 📂 What it Checks

- ✅ Server uptime & load average
- 🧠 Memory and disk usage
- 📅 System & hardware clock time
- 🔥 Firewall, SELinux, DNS status
- 🧾 Kernel version and installed RPMs
- 💾 Mounted file systems & read-only status
- 💽 Multipath and Oracle ASM disk status
- 📬 Mail services (Postfix, Sendmail)
- 🛡️ SSSD, RSYSLOG, TSSA Agent
- 🐧 OS release details
- 📡 Network configuration and NFS
- 📦 Installed packages, Java version
- 🐳 Docker and Kubernetes services (if installed)
- 🗃️ GRUB, passwd, group, hosts, ntp.conf
- 🔗 WWN numbers, LVM (PVS/VGS/LVS)
- 📉 CPU, DMIDECODE, netstat, etc.

---

## 🚀 Usage

```bash
chmod +x os_sanity_check.sh
./os_sanity_check.sh > sanity_output_$(hostname)_$(date +%F).log
