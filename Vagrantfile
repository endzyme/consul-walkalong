# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise64"

  {dc1: 20}.each do |dc,net|
    # Consul Servers
    (10..10).each do |id|
      config.vm.define "#{dc}-consul-server-#{id}" do |n|
        n.vm.hostname = "#{dc}-consul-server-#{id}"
        n.vm.network "private_network", ip: "172.20.#{net}.#{id}"
        n.vm.provision "puppet" do |p|
          p.manifests_path = 'puppet_module'
          p.manifest_file = 'default.pp'
          p.module_path = 'puppet_module'
          p.facter = {
            "datacenter_name" => dc,
            "consul_cluster_masters" => "172.20.#{net}.10"
          }
        end
      end
    end

    # Web App + Consul Agents
    (20..20).each do |id|
      config.vm.define "#{dc}-web-#{id}" do |n|
        n.vm.hostname = "#{dc}-web-#{id}"
        n.vm.network "private_network", ip: "172.20.#{net}.#{id}"
        n.vm.provision "puppet" do |p|
          p.manifests_path = 'puppet_module'
          p.manifest_file = 'default.pp'
          p.module_path = 'puppet_module'
          p.facter = {
            "datacenter_name" => dc,
            "consul_cluster_masters" => "172.20.#{net}.10"
          }
        end
      end
    end

    # Database + Consul Agents
    (30..30).each do |id|
      config.vm.define "#{dc}-db-#{id}" do |n|
        n.vm.hostname = "#{dc}-db-#{id}"
        n.vm.network "private_network", ip: "172.20.#{net}.#{id}"
        n.vm.provision "puppet" do |p|
          p.manifests_path = 'puppet_module'
          p.manifest_file = 'default.pp'
          p.module_path = 'puppet_module'
          p.facter = {
            "datacenter_name" => dc,
            "consul_cluster_masters" => "172.20.#{net}.10"
          }
        end
      end
    end
  end
end
