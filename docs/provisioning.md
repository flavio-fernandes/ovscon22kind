
This document shows the steps used for preparing a vm to use with this workshop.
If VM was deployed using Vagrant method, there is nothing to see here; this
is intended for cases where we have a brand new Fedora 37 VM running and
need to run the steps Vagrant provisioning would have performed.

ssh into a VM running Fedora 37. It should have 4Gb+ RAM and ~20Gb disk.

```bash
$ ssh root@${FEDORA_VM_IP}

$ # as root user, in side the Fedora VM ; \
  dnf install -y git

$ # set hostname, if needed ; \
  hostnamectl set-hostname ovscon

$ # create non-root user and give it sudo powers ; \
  groupadd  vagrant && \
  useradd --gid vagrant --groups vagrant,users,adm --shell /bin/bash  -c "vagrant ovscon" --create-home  vagrant

$ # give it sudo powers ; \
cat <<EOT >> /etc/sudoers.d/90-vagrant
vagrant ALL=(ALL) NOPASSWD:ALL
EOT

$ # copy key root has to new user, so you can access it using ssh ; \
  (cd /root ; tar cSf - .ssh ) | ( cd /home/vagrant ; tar xSvfp - ) ; \
  chown -R vagrant:vagrant ~vagrant/.ssh

$ exit   ; # exit to confirm that vagrant user is useable
```

ssh back into system as the vagrant user and start the workshop installation
```bash
$ ssh vagrant@${FEDORA_VM_IP}

$ # clone this repo for install scripts ; \
  [ -d /vagrant ] && { echo "error: /vagrant dir should not exist"; } || \
  ( cd && git clone https://github.com/flavio-fernandes/ovscon22kind.git && \
  sudo mv ~vagrant/ovscon22kind /vagrant && echo ok )

$ # run setup.sh, just like Vagrant install would. It should take about 4 minutes ; \
  /vagrant/provision/setup.sh

$ exit  ; # exit one more time, so usermod for vagrant kicks in
```
