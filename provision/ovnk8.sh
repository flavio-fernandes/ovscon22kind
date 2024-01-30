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

# https://superuser.com/questions/272061/reload-a-linux-users-group-assignments-without-logging-out
# newgrp $USER ||:
sudo docker pull quay.io/ffernandes/busybox:latest
