# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_VMS = (ENV['VMS'] || 1).to_i
RAM = 5120
VCPUS = 4

Vagrant.configure("2") do |config|
  vm_memory = ENV['VM_MEMORY'] || RAM
  vm_cpus = ENV['VM_CPUS'] || VCPUS

  config.vm.box = "fedora/37-cloud-base"

  # libvirt
  config.vm.provider "libvirt" do |lv, override|
    lv.cpus = vm_cpus
    lv.memory = vm_memory
    lv.nested = true
  end

  # virtualbox
  config.vm.provider "virtualbox" do |vb, override|
    vb.cpus = vm_cpus
    vb.memory = vm_memory
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end

  (1..NUM_VMS).each do |i|
      config.vm.define "ovscon#{i}" do |node|
        node.vm.hostname = "ovscon#{i}"
        # node.vm.synced_folder ".", "/vagrant", type: "sshfs"

        # node.vm.provision :shell do |shell|
        #   shell.privileged = true
        #   shell.path = 'provision/checkNested.sh'
        # end
      
        node.vm.provision :shell do |shell|
          shell.privileged = false
          shell.path = 'provision/setup.sh'
        end
    end
  end
end
