#! /bin/bash
#
# This script is used to do basic OS Sanity check
# Define Variables
MyName=$(/bin/hostname)
##IpAd=$(/bin/hostname -i)
DT=$(/bin/date)
HW=$(sudo /sbin/hwclock)
SL=$(/usr/sbin/sestatus)

#IN1=$IN2=$IN3=$IN4

# Define Colours
color() {
        printf '\033[%sm%s\033[m\n' "$@"
        }

# Showing Start status message
color '33;5' "OS SANITY IN PROGRESS OF  $MyName ON $DT"; echo

# Server uptime & load status
echo "=========================================================="
color '35;1' " Showing current uptime of $MyName server"; echo
/usr/bin/uptime
echo
echo "=========================================================="
echo "=========================================================="
echo "=============HyperV Host Node Info ============================================="
cat /var/lib/hyperv/.kvp_pool_3|cut -c9-555 | awk '{ print substr( $0, 1, length($0)-15 ) }' | awk '{ print substr( $0, 500 ) }'
echo " "
echo "=========================================================="
# Check Server date / Time
echo "=========================================================="
color '32;1' " Date / Time on $MyName is $DT:"
color '32;1' " HW clock time is                : $HW"
#color '32;1' " Server NTP time sync status is : "; /usr/sbin/ntpq -p; echo
#cat /etc/localtime;
#cat /etc/sysconfig/clock;
/usr/sbin/ntpq -p
echo "=========================================================="
# Current OS Version
echo "=========================================================="
color '32;1' "Current OS version :"
cat /etc/os-release
cat /etc/redhat-release
echo "=========================================================="
# Check Latest Kernel
echo "=========================================================="
color '35;1' " Showing currently installed Kernels on $MyName server"; echo
rpm -qa | grep kernel- | egrep -iv "loop|drac|firmwar|header|devel"; echo
color '32;1' "Server running with kernel : $(uname -r)"; echo
echo "=========================================================="


# Firewall & SELINUX status
echo "=========================================================="
color '35;1'  " Showing Firewall, SELinux & DNS status on $MyName server"; echo
sudo /etc/init.d/iptables status
sudo /etc/init.d/ip6tables status
/etc/init.d/NetworkManager status
/usr/bin/systemctl status firewalld

echo "$SL"
echo ""
color '32;1' " DNS settings on $MyName are :"
grep -v '#' /etc/resolv.conf; echo
echo "=========================================================="

# Memory  status
echo "=========================================================="
color '35;1'  " Showing Memory status on $MyName server"; echo
/usr/bin/free -m
echo ""
echo "=========================================================="

# fstab
echo "=========================================================="
color '35;1'  " Below is the /etc/fstab from server $MyName"; echo

cat /etc/fstab ;
echo "=========================================================="


color '35;1'  " Below is the /etc/*release from server $MyName"; echo

cat /etc/*release
echo "=========================================================="


## DISK / Mount point Details
echo "=========================================================="
color '35;1'  " Showing Disk details on $MyName server"; echo

color '32;1'  " Mount Point details on $MyName are :"
df -Th | awk '{if (NF==1) {line=$0;getline;sub(" *"," ");print line$0} else {print}}'; echo;
IN1=$(df -Th | awk '{if (NF==1) {line=$0;getline;sub(" *"," ");print line$0} else {print}}' | egrep 'ext|cifs|nfs' | egrep -v "nfsd|rpc" | wc -l)
IN2=$(cat /etc/fstab | grep -v "^#" | egrep 'ext|cifs|nfs' | wc -l)
IN4=0
IN4=$(egrep -i 'ext|cifs|nfs' /proc/mounts | egrep -vc 'rw,|nfsd|rpc')
        if [ $IN4 -gt 0 ]; then
                color '31;1' "Below File Systems are read only mounted."
                IN5=$(sudo /bin/egrep -i 'ext|cifs|nfs' /proc/mounts | egrep -v 'rw,|nfsd|rpc')
                color '31;1' "$IN5"; echo
        else
                color '32;1'  "All mount points are in read write state"; echo;
        fi
if [ $IN1 -eq $IN2 ]; then
                color '32;1' "Mount Point count on $MyName are : Same"; echo
        else
                color '31;1' "Mount Point count on $MyName are : Different"; echo
        fi
echo "=========================================================="

echo "=========================================================="
        ### Checking Multipath Package##############################

        /etc/init.d/multipathd status &> /dev/null
        IN1=$(echo $?)
        if [ $IN1 -eq 0 ]; then
                IN2=$(sudo /sbin/multipath -ll | egrep -c "inactive|fail|fault")
                IN3=$(sudo /sbin/multipath -ll | grep -c 'dm-' )
                color '32;1' "Total $IN3 Disks are configured via Multipath. Below are disk details."; echo
                sudo /sbin/multipath -ll | grep dm-
                if [ $IN2 -gt 0 ]; then
                        color '31;1' "Below Disk paths are either inactive or failed"
                        sudo /sbin/multipath -ll | egrep "inactive|fail|fault"; echo
                else
                        color '32;1' "All Disk Paths are active"; echo
                fi
echo "=========================================================="
echo "=========================================================="
########## Checking OracleASM Package###########################
                ls -ld /usr/sbin/oracleasm &> /dev/null
                IN2=$(echo $?)
                if [ $IN2 -eq 0 ]; then
                        IN1=$(sudo /usr/sbin/oracleasm listdisks | wc -l)
                        color '32;1' " Total $IN1 OrcaleASM disk are installed. Below are disk details."
                        sudo /usr/sbin/oracleasm listdisks
                else
                         color '32;1' "OracleASM is not installed"
                fi
        else
                color '32;1' "Multipath is not configured"; echo
        fi

echo "=========================================================="
echo "=========================================================="
#### Below route are added in server
color '32;1' "Please find Below route are added in server:"

sudo /sbin/route -n |nl
echo "=========================================================="
sudo ip r |nl;
echo "=========================================================="
#### Beloow Mail services running on server
color '32;1' "Please find Mail service Status on Server:"
echo "Postfix Mail Service status"
systemctl status postfix
/etc/init.d/postfix status
echo "=========================================================="
echo "Sendmail Mail Service status"
systemctl status sendmail
/etc/init.d/sendmail status

echo "=========================================================="

color '32;1' "Patrol Agent status is below :"
/opt/bmc/Patrol3/scripts.d/S50PatrolAgent.sh status

echo "=========================================================="
sudo ps -ef|grep patrol; echo

echo "=========================================================="

echo "=========================================================="
color '32;1' "SSSd status is below :"
sudo  systemctl status sssd
sudo /etc/init.d/sssd status



echo "=========================================================="
color '32;1' "Rsyslog status is below :"
sudo  systemctl status rsyslog
sudo /etc/init.d/rsyslog status

echo "=========================================================="
color '32;1' "TSSA Agent status is below :"

ps -ef |grep rscd
systemctl status rscd
/etc/init.d/rscd status
echo "=========================================================="
echo "=========================================================="
color '32;1' "List all running service  :"
### For  RHEL 5,6,suse 11
service --status-all |grep -i running
### For  RHEL 7,8,9 suse 12,15

systemctl --type=service --state=running
echo "=========================================================="

color '32;1' "VMTOOL status is below :"
ps -ef | grep -i vmtool;
echo "=========================================================="
echo "=========================================================="
color '32;1' "Cluster status is below :"
cmviewcl
echo "=========================================================="
echo "=========================================================="
color '32;1' "MD Disk status is below :"
cat /proc/mdstat
mdadm --detail /dev/md0

echo "=========================================================="

#### Java Patch details
echo "=========================================================="
color '35;1' " Showing Installed Java Packages on $MyName server"; echo
echo " Current running java version"
java -version
echo;
rpm -qa | grep java; echo

echo " "
echo "=========================================================="
echo "=========================PVS_Output================================="
pvs;
echo " "
echo "=========================================================="
echo "=========================VGS_Output================================"
vgs;
echo " "
echo "=========================================================="
echo "=========================LVS_Output================================"
lvs;
echo " "
echo "=========================================================="
echo "=========================df  -ThP_Output==============================="
df -ThP |nl;
echo " "
echo "=========================================================="
echo "=========================================================="
color '32;1' "Mount Point count Filesystemwise :"
echo " ############ NFS Filesyetm ##################"
df -ThP |grep nfs|grep -v xfs |wc -l;
df -ThP |grep nfs|grep -v xfs |nl;
echo " "
echo " ############ XFS Filesyetm ##################"
df -ThP |grep xfs |wc -l;
df -ThP |grep xfs |nl;
echo " "
echo " ############ EXT Filesyetm ##################"
df -ThP |grep ext |wc -l;
df -ThP |grep ext |nl;
echo " "
echo " ############ CIFS Filesyetm ##################"
echo " "
df -ThP |grep cifs |wc -l;
df -ThP |grep cifs;
echo " "
echo " ############ btrfs Filesyetm ##################"
echo " "
df -ThP |grep btrfs |wc -l;
df -ThP |grep btrfs;
echo " "
echo " ############ tmpfs Filesyetm ##################"
echo " "
df -ThP |grep tmpfs |wc -l;
df -ThP |grep tmpfs;
echo " "
echo " ############ vfat Filesyetm ##################"
echo " "
df -ThP |grep vfat |wc -l;
df -ThP |grep vfat;
echo " "

echo "=========================================================="

echo "=========================Mount_Output=================================="
mount |nl;
echo " "
echo "=========================================================="


#### Below is the Output of Immportant commands and files.
color '32;1' "Please find Output of Immportant commands and files  below:"
echo " "
echo "=======================netstat  ==================================="
echo " "
netstat -tunlp
echo " "

echo " "
echo "=======================/etc/ssh/sshd_config ==================================="
echo " "
systemctl status sshd
/etc/init.d/sshd status

echo " "
egrep -v "^#|^$" /etc/ssh/sshd_config

color '32;1' "SSSd Configuration file :"
cat /etc/sssd/sssd.conf

echo "=======================/etc/exports_File==================================="
cat /etc/exports |nl;
echo " "
echo "=======================/etc/netgroup_File==================================="
cat /etc/netgroup |nl;
echo " "
echo "===========================multipath -ll _Output ==============================="
/sbin/multipath -ll |nl;
echo " "
echo "===========================multipath -ll  -v2_Output==============================="
/sbin/multipath -ll -v2;
echo " "
echo "=======================multipath grep dm- | count_Output==================================="
/sbin/multipath -ll |grep dm-| wc -l;
echo " "
echo "=========================================================="
echo "=====================grub_File ====================================="
cat /etc/grub.cfg
cat /etc/grub2.cfg
cat /boot/grub2/grub.cfg
ls -l /boot/grub2/user.cfg
ls -l /boot/efi/EFI/redhat/*
echo " "
echo " Grub file linkikg "
ls -l /etc/grub2*;
echo "   "
ls -l /boot/grub2/grub*;
echo " "
echo "=========================================================="
echo "================passwd_File=========================================="
cat /etc/passwd;
echo " "
echo "=========================================================="
echo "===============group_File==========================================="
cat /etc/group;
echo " "
echo "=========================================================="
echo "===============hosts_File==========================================="
cat /etc/hosts;
echo " "
echo "=========================================================="
echo "=============fdisk -l============================================="
fdisk -l | grep ^Disk|nl;
echo " "
echo "=========================================================="

echo "=============ntp.conf_File============================================="
cat /etc/ntp.conf | egrep -v "^#|^$";
echo " "

echo "=========================================================="
echo "=============Syslog Service Status============================================="
systemctl status rsyslog;
echo " "
echo "=========================================================="
echo "==============Docker Service status============================================"
docker –-version
echo "" 
systemctl status docker;
echo " Docker container Status "
echo " "
docker ps
echo " "
systemctl status kubelet.service
kubectl get nodes
echo ""
echo " "
echo "=========================================================="
echo "==============Database service status============================================"
ps -ef |grep -i pmon
ps -ef |grep -i mysql
systemctl status mysqld
echo " "
echo "=========================================================="
echo " "
echo "=========================================================="
echo "==============nfs service status============================================"
/etc/init.d/nfs status
systemctl status nfs
systemctl status nfs-server
echo "See below mount point are shared by NFS service"
cat /etc/exports

cat /etc/autofs.direct
echo " "
echo "=========================================================="

#### Below is the ip configuration of the server
color '32;1' "Please find Network configuration below:"

sudo /sbin/ifconfig -a
echo "=========================================================="
cat /etc/sysconfig/network-scripts/ifcfg-*;
echo " "
echo "=========================================================="
echo "============================================================"
echo "Network configuration in SUSE System "
cat /etc/sysconfig/network/ifcfg-*
echo " "
echo "=========================================================="

echo " "
echo "====================WWN Number Details ======================================"
cat /sys/class/fc_host/host1/port_name
cat /sys/class/fc_host/host2/port_name
cat /sys/class/fc_host/host3/port_name
echo " "
echo "=========================================================="

systool -c fc_host -v | grep port_name
systool -c fc_host -v | grep port_state
adapter_info
echo "======================nproc===================================="
nproc;
echo " "
echo "=========================================================="
echo "===============dmidcode==========================================="
/usr/sbin/dmidecode -t system;
echo " "
echo "=========================================================="
color '32;1' "Disk UID Information:"
echo "=============lsblk command output ============================================="
lsblk |nl;
echo " "
echo "=========================================================="
echo "=============blkid command output ============================================="
blkid |nl ;
echo " "
echo "=========================================================="
echo "=====================Installed RPM List====================================="
rpm -qa |nl;
echo " "
echo "=========================================================="
echo "==============Kernel Parameters============================================"
sysctl -a |nl;
echo " "
echo "=========================================================="




