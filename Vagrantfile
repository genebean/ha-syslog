# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "puppetlabs/centos-7.0-64-puppet"

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  config.vm.define "log1" do |log1|
    log1.vm.hostname = "log1.localdomain"

    log1.vm.provision "shell", inline: <<-SHELL
      yum clean all
      yum -y install deltarpm
      yum -y install rsync pacemaker pcs resource-agents
      puppet apply -v /vagrant/hosts.pp

      firewall-cmd --permanent --add-service=high-availability
      firewall-cmd --permanent --add-port 514/udp
      firewall-cmd --reload

      puppet resource service pcsd ensure=running enable=true
      puppet resource package epel-release ensure=present
      puppet resource package syslog-ng ensure=present
      rsync -v /vagrant/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

      echo CHANGEME | passwd --stdin hacluster
    SHELL

    log1.vm.network "private_network", ip: "172.28.128.22"
    #log1.vm.network "forwarded_port", guest: 80,  host: 8082
  end

  config.vm.define "log2" do |log2|
    log2.vm.hostname = "log2.localdomain"

    log2.vm.provision "shell", inline: <<-SHELL1
      yum clean all
      yum -y install deltarpm
      yum -y install rsync pacemaker pcs resource-agents
      puppet apply -v /vagrant/hosts.pp

      firewall-cmd --permanent --add-service=high-availability
      firewall-cmd --permanent --add-port 514/udp
      firewall-cmd --reload

      puppet resource service pcsd ensure=running enable=true
      puppet resource package epel-release ensure=present
      puppet resource package syslog-ng ensure=present
      rsync -v /vagrant/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

      echo CHANGEME | passwd --stdin hacluster
    SHELL1

    log2.vm.provision "shell", inline: <<-SHELL2
      pcs cluster auth log1 log2 -u hacluster -p CHANGEME --force
      pcs cluster setup --force --name ha-logging log1 log2
      pcs cluster start --all

      pcs property set no-quorum-policy=ignore
      pcs property set stonith-enabled=false
      pcs resource create VirtualIP ocf:heartbeat:IPaddr2 ip=172.28.128.21 cidr_netmask=24 nic=enp0s8 op monitor interval=30s 
      pcs resource create Logger systemd:syslog-ng op monitor interval=30s
      pcs resource group add ha-syslog VirtualIP Logger
    SHELL2

    log2.vm.network "private_network", ip: "172.28.128.23"
    #log2.vm.network "forwarded_port", guest: 80,  host: 8082
  end

  config.vm.provider "vmware_desktop" do |v|
    v.gui = false
  end

  config.vm.define "log3" do |log3|
    log3.vm.hostname = "log3.localdomain"

    log3.vm.provision "shell", inline: "yum clean all"
    log3.vm.provision "shell", inline: "yum -y install deltarpm"
    #log3.vm.provision "shell", inline: "yum -y upgrade"
    log3.vm.provision "shell", inline: "puppet resource host raft ip='172.28.128.21'"
    log3.vm.provision "shell", inline: "puppet resource host log1 ip='172.28.128.22'"
    log3.vm.provision "shell", inline: "puppet resource host log2 ip='172.28.128.23'"

    log3.vm.network "private_network", ip: "172.28.128.24"
  end

  config.vm.provider "vmware_desktop" do |v|
    v.gui = false
  end

  config.vm.provider "vmware_fusion" do |v|
    v.gui = false
  end

  config.vm.provider "virtualbox" do |v|
    v.gui = false
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
end
