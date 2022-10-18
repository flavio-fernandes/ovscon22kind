# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_VMS = (ENV['VMS'] || 1).to_i
RAM = 4096
VCPUS = 2
#RAM = 16384
#VCPUS = 4
#RAM = 49152
#VCPUS = 6

Vagrant.configure("2") do |config|
  vm_memory = ENV['VM_MEMORY'] || RAM
  vm_cpus = ENV['VM_CPUS'] || VCPUS

  config.vm.box = "fedora/36-cloud-base"
  config.vm.provider "libvirt" do |provider|
    provider.cpus = vm_cpus
    provider.memory = vm_memory
    provider.nested = true
  end
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = vm_cpus
    vb.memory = vm_memory
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
  end
  
  (1..NUM_VMS).each do |i|
      config.vm.define "ovscon#{i}" do |node|
        node.vm.hostname = "ovscon#{i}"
        node.vm.synced_folder ".", "/vagrant", type: "sshfs"

        node.vm.provision :shell do |shell|
          shell.privileged = true
          shell.path = 'provision/checkNested.sh'
        end
      
        node.vm.provision :shell do |shell|
          shell.privileged = true
          shell.path = 'provision/pkgs.sh'
        end
        
        node.vm.provision :shell do |shell|
          shell.privileged = true
          shell.path = 'provision/golang.sh'
        end
        
        node.vm.provision :shell do |shell|
          shell.privileged = false
          shell.path = 'provision/docker.sh'
        end
        
        node.vm.provision :shell do |shell|
          shell.privileged = true
          shell.path = 'provision/kind.sh'
        end
        
        node.vm.provision :shell do |shell|
          shell.privileged = false
          shell.path = 'provision/kube.sh'
        end
        
        node.vm.provision :shell do |shell|
          shell.privileged = false
          shell.path = 'provision/ovnk8.sh'
        end
    end
      
  end
end
