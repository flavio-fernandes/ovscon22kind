# ovscon22kind
OVS Conf 2022: Kind with OVN Kubernetes workshop

## Pre-Reqs

- install Vagrant
- clone this repo

## Quickstart

```bash
$ # cd this repo
$ vagrant up
$ vagrant ssh ovscon1

[vagrant@ovscon1 ~]$ cd ovn-kubernetes/
[vagrant@ovscon1 ovn-kubernetes]$ cd contrib/
[vagrant@ovscon1 contrib]$ ./kind.sh

[vagrant@ovscon1 contrib]$ k get nodes
...
```
