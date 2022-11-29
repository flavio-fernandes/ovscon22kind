# ovscon22kind

[OVS Conf 2022](https://www.openvswitch.org/support/ovscon2022/): Kind with OVN Kubernetes workshop

This repo has all the bits used for the [**Easily deploying Kubernetes with OVN as CNI using Kind**](https://youtu.be/LjAzW8C1VAU) talk for the [OVSCON 2022 event](https://www.openvswitch.org/support/ovscon2022/).
[Click here](https://youtube.com/playlist?list=PLaJlRa-xItwAGoQaULWr5gdwmUkAnZOkx) to see all the awesome talks recorded during that event.

![ovscon2022](images/ovscon2022.png "OVScon, November 2022")

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
