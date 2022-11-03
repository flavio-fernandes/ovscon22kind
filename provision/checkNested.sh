#!/usr/bin/env bash
#

[ $EUID -eq 0 ] || { echo 'must be root' >&2; exit 1; }

set -o errexit
# set -o xtrace

[ -e /dev/kvm ] || { echo "PROBLEM, you need to ensure hv can nest"; exit 1; }
grep -q Y /sys/module/kvm_intel/parameters/nested || {
  rmmod kvm-intel
  sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"
  modprobe kvm-intel
}
modinfo kvm_intel | grep -q 'nested:bool' || { echo "PROBLEM, nesting did not enable"; exit 1; }

