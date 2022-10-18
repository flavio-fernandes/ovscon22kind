#!/usr/bin/env bash

[ $EUID -eq 0 ] && { echo 'must not be root' >&2; exit 1; }

sudo dnf install -y docker
systemctl is-active --quiet docker || {
    sudo usermod -a -G docker $(whoami)
    sudo systemctl enable docker
    sudo systemctl start docker
}

CONFIG="/home/vagrant/.bashrc.d/docker.sh"
mkdir -p $(dirname $CONFIG)
cat << EOT > $CONFIG
alias podman=docker
EOT
