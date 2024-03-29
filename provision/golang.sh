#!/usr/bin/env bash

[ $EUID -eq 0 ] || { echo 'must be root' >&2; exit 1; }

set -o errexit
set -o xtrace

[ -e /usr/local/go ] && { echo "golang already installed"; exit 0; }

version="$(curl -L 'https://golang.org/VERSION?m=text' | head -1)"

wget "https://dl.google.com/go/${version}.linux-amd64.tar.gz"
rm -rf /usr/local/go && tar -C /usr/local -xzf ${version}.linux-amd64.tar.gz
rm -f ${version}.linux-amd64.tar.gz

CONFIG="/home/vagrant/.bashrc.d/golang.sh"
mkdir -p $(dirname $CONFIG)
rm -f $CONFIG
cat << EOT > $CONFIG
if ! [[ "\$PATH" =~ "/usr/local/go/bin:" ]]
then
    PATH="/usr/local/go/bin:\$PATH"
fi
export PATH
EOT

chown -R vagrant:vagrant $(dirname $CONFIG)
