# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

DNSMASQ_INSTALL = <<SCRIPT
sudo apt-get install -y dnsmasq
echo "server=/demo.local/127.0.0.1#8600" | sudo tee -a /etc/dnsmasq.d/10-consul
sudo service dnsmasq restart
SCRIPT

JOOMLA_SCRIPT = <<SCRIPT
sudo apt-get update
sudo apt-get install -y apache2 php5-mysql libapache2-mod-php5 php5-json  php5-curl unzip
SOURCEWWW=https://github.com/joomla/joomla-cms/releases/download/3.4.0/Joomla_3.4.0-Stable-Full_Package.zip
SOURCEPKG=Joomla_3.4.0-Stable-Full_Package.zip
mkdir joomla
cd joomla
wget $SOURCEWWW
unzip $SOURCEPKG
rm -f $SOURCEPKG
cd ..
sudo mv joomla /var/www/
sudo chown -R www-data:www-data /var/www/joomla
sudo find /var/www/joomla/ -type f -exec chmod 644 {} \;
sudo find /var/www/joomla/ -type d -exec chmod 755 {} \;
sudo service apache2 restart
SCRIPT

MYSQL_SCRIPT = <<SCRIPT
sudo apt-get update
debconf-set-selections <<< 'mysql-server mysql-server/root_password password foobar'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password foobar'
sudo apt-get install -y mysql-server
mysqladmin -u root -pfoobar create joomla
mysql -uroot -pfoobar -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON joomla.* TO 'joomla'@'%' IDENTIFIED BY 'foobar';"
mysql -uroot -pfoobar -e "CREATE USER 'test_user'@'localhost';"
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
sudo service mysql restart
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise64"

  {dc1: 20, dc2: 30}.each do |dc,net|
    # Consul Servers
    (10..10).each do |id|
      config.vm.define "#{dc}-consul-server-#{id}" do |n|
        n.vm.hostname = "#{dc}-consul-server-#{id}"
        n.vm.network "private_network", ip: "172.20.#{net}.#{id}"
        n.vm.network :forwarded_port, guest: 8400, host: 8400, auto_correct: true
        n.vm.network :forwarded_port, guest: 8500, host: 8500, auto_correct: true
        n.vm.network :forwarded_port, guest: 8600, host: 8600, auto_correct: true
        n.vm.provision "shell", inline: DNSMASQ_INSTALL
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
        n.vm.network :forwarded_port, guest: 80, host: 8000, auto_correct: true
        n.vm.provision "shell", inline: DNSMASQ_INSTALL
        n.vm.provision "shell", inline: JOOMLA_SCRIPT
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
        n.vm.network :forwarded_port, guest: 3306, host: 3306, auto_correct: true
        n.vm.provision "shell", inline: DNSMASQ_INSTALL
        n.vm.provision "shell", inline: MYSQL_SCRIPT
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
