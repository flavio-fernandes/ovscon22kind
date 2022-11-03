#!/usr/bin/env bash

[ $EUID -eq 0 ] && { echo 'must not be root' >&2; exit 1; }

set -o xtrace
set -o errexit

[ -d /home/vagrant/ovn-kubernetes ] && { echo "/home/vagrant/ovn-kubernetes already created"; exit 0; }

cd
git clone --depth 1 https://github.com/ovn-org/ovn-kubernetes.git

cat << EOT > /home/vagrant/.gitconfig
[user]
       email = vagrant@example.com
       name = vagrant user
EOT

cd ovn-kubernetes
cat /vagrant/0001-use-quay.patch | git am

# https://superuser.com/questions/272061/reload-a-linux-users-group-assignments-without-logging-out
# newgrp $USER ||:
sudo docker pull quay.io/ffernand/kindest-node:v1.24.0
sudo docker pull quay.io/ffernand/fedora:36
sudo docker pull quay.io/ffernand/busybox:latest
