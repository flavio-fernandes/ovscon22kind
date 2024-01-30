#!/usr/bin/env bash

[ $EUID -eq 0 ] && { echo 'must not be root' >&2; exit 1; }

set -o errexit
set -o xtrace

CONFIG="/home/vagrant/.bashrc.d/k8.sh"

[ -e ${CONFIG} ] && { echo "${CONFIG} already created"; exit 0; }

. /home/vagrant/.bashrc.d/golang.sh

# https://hidetatz.medium.com/colorize-kubectl-output-by-kubecolor-2c222af3163a
go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

mkdir -pv $(dirname $CONFIG)
cat << EOT > $CONFIG
if ! [[ "\$PATH" =~ "/home/vagrant/go/bin:" ]]
then
    PATH="/home/vagrant/go/bin:\$PATH"
fi
export PATH

# alias k=kubectl
alias k=kubecolor

source <(kubectl completion bash)
complete -o default -F __start_kubectl k

export KUBECONFIG=/home/vagrant/ovn.conf
EOT
