#!/usr/bin/env bash

[ $EUID -eq 0 ] && { echo 'must not be root' >&2; exit 1; }

cd
git clone --depth 1 https://github.com/ovn-org/ovn-kubernetes.git
