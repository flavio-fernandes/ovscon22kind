#!/usr/bin/env bash
#

[ $EUID -eq 0 ] && { echo 'must not be root' >&2; exit 1; }

set -o errexit
# set -o xtrace

[ -d /home/vagrant ] || { echo "PROBLEM, vagrant homedir is not present"; exit 1; }

mkdir -pv /home/vagrant/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBal7sBQWDoKGAXa26lucRNoRCyyZIfXtyWkvvldDi6brSXsrBLZoNVf78hlgl2bQvjwNfg9FxseWVBtzAR5Kznee942X3/VUGm5P8w2GgE8aJrZE4v7wO5zCt3FOIJjuSRwr1EN/KPn4WxAuwlGCRsFXyggg5NByF9wF+hWYIauKqT2thLeIAQyDW9Nig4Ca+DDUZJVXvPEGr+w2uFAHaid3U6nOuMtQfsmoecjvjHyCn7shHqLGnT5aJDQiXO0qPpQBgCVdG9+ddu2C9K+F5SAGA89QVBuiXtsH8rKjVSAHhYV/W9RhJ9+DX+A7cMQgWPFndkRfDHgKGzuPj7YBYOmTEgkmgcF1BL29uCUZmv9VEwkQYT0u1A0FRYZzSWnb/cnSsFvV5SNdm2lZet/v31SRLYvWziCvvOvzTE56SA5FsvoUYd7HR19zmH5aPzcmWJM1bzchaofBs7fQhkqtlTSY5uQdPAo88ife6V25VGF0+qJ2VhmKrrQk7lmvfxeM= ovscon@example.com vagrantovscon' >> /home/vagrant/.ssh/authorized_keys ; \
chmod 644 /home/vagrant/.ssh/authorized_keys ; \
chmod 755 /home/vagrant/.ssh

cd /vagrant/provision || cd "$(dirname $0)"

sudo ./pkgs.sh
sudo ./golang.sh
./docker.sh
sudo ./kind.sh
./kube.sh
./ovnk8.sh

echo ok
