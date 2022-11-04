
This talk is about the simbiotic relationship between kubernetes and ovn.
If you know a lot a bount one of them, I hope to intrigue you about the other.
If you already know both, then I will do my best not to make you too sleepy.

this is intended to be as a hands on workshop, so you will need a ssh session
to a linux system to follow alond.
        
3 choices:

    use a vm I have ready

         - the steps I took on a beefy bare metal to carve out a bunch of vms
         - reserves
               -- show that code a little bit
         ❯ curl reserves.flaviof.dev
         Welcome to OVSCON 2022!
    
    if you have Vagrant installed in your system, use a Vagrant file

         - clone this repo
         - vagrant up

    create a 4Gb fedora-36 vm and follow along with me in getting it going


go over the scripts in /provisioning
- explain use-quay

=-=-=

show diagram of what is created

cover kind's main concept (docker in docker)

what is cni
- dan Williams has a nice talk on that :)
    
tmux a || tmux
cd /home/vagrant/ovn-kubernetes/contrib
time ./kind.sh && echo ok

k get nodes -owide
k get pod -A

go inside a 'node' and show running processes
        
=-=-=-

start some observability tools
        
install k9s
wget https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_x86_64.tar.gz

install ovsdbmon
...


=-=-=-=
    
show kube master and kube-node  

show how there is a switch per node

create a pod and show kubelet logs

create a service and show dnat

do an ovnkube-trace

rebuild the code

egressip -- show snat moving when node goes down
    
=-=-=-=

```

POD=$(kubectl get pod -n ovn-kubernetes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep ovnkube-db-)
k exec -ti $POD -n ovn-kubernetes -c nb-ovsdb -- bash

ovn-nbctl lr-route-list ovn_cluster_router
```

From a separate tmux session
```
cd && git clone https://github.com/flavio-fernandes/ovsdb-mon.git -b security-admission-labels-for-namespaces
cd ovsdb-mon/dist
. ./ovsdb-mon-ovn.source

ovsdb-mon.nb -auto -no-monitor nb_global,connection
```

From a separate tmux session
```
IMG="quay.io/ffernand/busybox" ; CLUSTER=ovn ; kind load docker-image $IMG --name $CLUSTER && echo ok

k run --rm -it bbox --image quay.io/ffernand/busybox -- sh

k create deploy busyb --image quay.io/ffernand/busybox --replicas=3 -- sleep infinity

k get pod -owide --show-labels --watch
k delete pod -l "app=busyb" --grace-period=0 --force
k scale deploy busyb --replicas=1
k delete deploy busyb
```




    

