
This document shows the steps used for preparing a lab server to host multiple
vms used as the basis for this workshop. It is a bit outside the context of the talk
itself but may be interesting for preparing for similar events.

The objective here is to have a Fedora 36 system using a bridge interface,
so vms can connect to the network just like the host server does. It also
installs Vagrant, so the provisioning of these vms can be automated.

## pre-reqs
    
- reserve a bare metal lab system. Use a beefy one, with at least 128Gb memory!
- have it provisioned with Fedora
- ssh into it as root

## remove /home partition to have a single big storage mount

A large portion of the disk in the system was provisioned to /home directory.
It is relatively easy to undo that for the provisioned bare metal, since
Fedora has that partition mounted using [btrfs subvolume](https://ask.fedoraproject.org/t/deleting-non-mounted-btrfs-subvolumes/22817).

```bash
[root@baremetal ~]# whoami
root

[root@baremetal ~]# head -1 /etc/redhat-release
Fedora release 36 (Thirty Six)
        
[root@baremetal ~]# umount /home

# comment out home partition from fstab
[root@baremetal ~]# vi /etc/fstab

[root@baremetal ~]# btrfs subvolume list /
ID 256 gen 52 top level 5 path home
ID 257 gen 56 top level 5 path root
ID 258 gen 45 top level 257 path var/lib/portables
ID 259 gen 46 top level 257 path var/lib/machines

[root@baremetal ~]# btrfs subvolume delete -i 256 /
Delete subvolume (no-commit): '//home'

[root@baremetal ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        4.0M     0  4.0M   0% /dev
tmpfs            94G     0   94G   0% /dev/shm
tmpfs            38G  2.1M   38G   1% /run
/dev/sda2       893G  1.5G  889G   1% /
/dev/sda1       974M  126M  781M  14% /boot
tmpfs            94G     0   94G   0% /tmp
tmpfs            19G  4.0K   19G   1% /run/user/0
```

## create a bridge interface and move the main ethernet interface into it

Ref: https://lukas.zapletalovi.com/2015/09/fedora-22-libvirt-with-bridge.html

```bash
dnf -y install bridge-utils

# Looking at system's current ip and routes as well as dns, I wrote down the info needed to
# fill in the commands below. since this is being done while using the affected interface,
# it is best to do it in one swoop. Getting it wrong means getting into the system console and
# fixing that mistake. :)

ip a ; # getting the address to be moved to the bridge interface
ip r ; # getting the default gateway
cat /etc/resolv.conf ; resolvectl status ; # getting dns servers

## In this example, these were the values needed:
export MAIN_CONN=eno1np0
export ADDR='10.16.209.112/24'
export GW='10.16.209.254'
export DNS='10.11.5.160 10.2.70.215'
        
bash -x <<EOS
#systemctl stop libvirtd
nmcli c delete "$MAIN_CONN"
nmcli c add type bridge ifname bridge0 autoconnect yes con-name bridge0 stp off
#nmcli c modify bridge0 ipv4.method auto
nmcli c modify bridge0 ipv4.addresses ${ADDR} ipv4.method manual ipv4.gateway ${GW} ipv4.dns "${DNS}"
nmcli c add type bridge-slave autoconnect yes con-name "$MAIN_CONN" ifname "$MAIN_CONN" master bridge0
systemctl restart NetworkManager
#systemctl enable --now libvirtd
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf
EOS

# Disable netfilter
cat << EOT > /etc/sysctl.d/99-netfilter-bridge.conf
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOT

cat << EOT > /etc/modules-load.d/br_netfilter.conf
br_netfilter
EOT

modprobe br_netfilter
# lsmod br_netfilter
sysctl -p /etc/sysctl.d/99-netfilter-bridge.conf
        
[root@baremetal ~]# nmcli con show
NAME     UUID                                  TYPE      DEVICE
bridge0  f55e8726-c216-4dbe-9be1-b88a0bc0586c  bridge    bridge0
eno1np0  9cbf017e-20cf-4323-961f-e23d954f04a6  ethernet  eno1np0
eno1np0  6bfadd6c-2ff0-4ba3-bdf0-493c6ea217bd  ethernet  --

# confirming that ip moved and default gw route to bridge interface
[root@baremetal ~]# ip r | grep default
default via 10.16.209.254 dev bridge0 proto static metric 427
```
        
## install libvirt + vagrant

Ref: https://docs.fedoraproject.org/en-US/quick-docs/getting-started-with-virtualization/

```bash
dnf group install -y --with-optional virtualization
systemctl enable --now libvirtd

[root@baremetal ~]# lsmod | grep kvm
kvm_intel             389120  50
kvm                  1118208  1 kvm_intel
irqbypass              16384  201 kvm
```
    
Vagrant install

Ref: https://developer.hashicorp.com/vagrant/downloads
    
```bash
dnf install -y dnf-plugins-core
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
dnf install -y vagrant

# Note: install vagrant plugins as non-root user (below)
```
    
## create non-root user

```bash
[root@baremetal ~]# groupadd ff && \
useradd --gid ff --groups ff,users,libvirt,adm --shell /bin/bash  -c "flaviof devel" --create-home ff

cat <<EOT >> /etc/sudoers.d/90-ff
ff ALL=(ALL) NOPASSWD:ALL
EOT

# Copy keys used by root user to ff user
(cd /root ; tar cSf - .ssh ) | ( cd /home/ff ; tar xSvfp - ) ; chown -R ff:ff ~ff/.ssh

```    
    
## initial non-root user tweaks

All steps mentioned from this point  are performed as the non-root user (i.e. ff)
    
```bash
[root@baremetal ~]# su - ff
[root@baremetal ~]$ whoami
ff

sudo dnf -y install tmux git

# create a key pair to be used to access vagrant vms
cd ~/.ssh && ssh-keygen -t rsa -N '' -C "ovscon@example.com vagrantovscon" -f ./id_rsa_ovscon
```

Install vagrant plugins
    
```bash
sudo dnf install -y libvirt libvirt-devel rsync
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-sshfs
```
    
## start ovscon workshop vms

```bash
git clone git@github.com:flavio-fernandes/ovscon22kind.git && cd ovscon22kind

# use Vagrantfile where vms connect to the bridge via a second interface
mv Vagrantfile.second_nic Vagrantfile

# use environment variable to control how many VMs will be created
export VMS=25
time vagrant up --no-destroy-on-error

# collect ips given to each vm into a file, which will be managed via the reserves application
echo > ips.txt
for i in {1..25}; do echo -n "ovscon${i} " ; vagrant ssh ovscon${i} -- ip r | grep 'dev eth1 proto kernel scope link src' | cut -d' ' -f9 | tee -a ips.txt ; done

# using ips collected, create ini file for the reserves application
echo '[vms]' > db.ini
for IP in $(cat ips.txt) ; do \
    H=$(ssh vagrant@${IP} -i ~/.ssh/id_rsa_ovscon -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null hostname 2>/dev/null) ; \
    echo "${H} = ${IP}" | tee -a db.ini ; \
done

# store files needed by reserves.
cp -v db.ini ./reserves/
cp -v ~/.ssh/id_rsa_ovscon ./reserves/key.txt
```

From here, go to https://github.com/flavio-fernandes/ovscon22kind/tree/main/reserves
