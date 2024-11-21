# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_VMS = (ENV['VMS'] || 1).to_i
RAM = 5120
VCPUS = 4

$tweak_disk = <<SCRIPT
sgdisk -e /dev/vda
yes | parted /dev/vda ---pretend-input-tty resizepart 5 100%
btrfs filesystem resize max /
SCRIPT

Vagrant.configure("2") do |config|
  vm_memory = ENV['VM_MEMORY'] || RAM
  vm_cpus = ENV['VM_CPUS'] || VCPUS

  config.vm.box = "fedora/37-cloud-base"

  # libvirt
  config.vm.provider "libvirt" do |lv, override|
    lv.cpus = vm_cpus
    lv.memory = vm_memory
    lv.nested = true
    # Set the primary disk size to 100 GB
    lv.machine_virtual_size = 100
  end

  # virtualbox
  config.vm.provider "virtualbox" do |vb, override|
    vb.cpus = vm_cpus
    vb.memory = vm_memory
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end

  

  (1..NUM_VMS).each do |i|
      config.hostmanager.enabled = true
      config.hostmanager.manage_host = true
      config.hostmanager.manage_guest = true
      config.ssh.forward_agent = true
      config.vm.define "testflowsvm#{i}" do |node|
        node.vm.hostname = "testflowsvm"
        # node.vm.synced_folder ".", "/vagrant", type: "sshfs"
        node.vm.synced_folder "#{ENV['PWD']}", "/vagrant", type: "nfs", nfs_udp: false, nfs_udp: false
        node.vm.synced_folder "~/dev", "/home/vagrant/dev", type: "nfs", nfs_udp: false, nfs_udp: false
      
        # node.vm.provision :shell do |shell|
        #   shell.privileged = true
        #   shell.path = 'provision/checkNested.sh'
        # end
      
        node.vm.provision :shell do |shell|
          shell.privileged = false
          shell.path = 'provision/setup.sh'
        end

        node.vm.provision "tweak_disk", type: "shell",
                           inline: $tweak_disk
    end
  end
end
