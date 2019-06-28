Vagrant.configure("2") do |config|

  config.vm.define "zabbix" do |zb|
    zb.vm.box = "sbeliakou/centos"
    zb.vm.hostname = "zabbix"
    zb.vm.provider "virtualbox" do |zb1|
      zb1.name = "zabbix-VM-Machine"
    end
    zb.vm.network "private_network", ip: "192.168.219.90"
    zb.vm.provision "shell", path: "zabbix.sh"
  end

  config.vm.define "nginx" do |ng|
    ng.vm.box = "sbeliakou/centos"
    ng.vm.hostname = "nginx"
    ng.vm.provider "virtualbox" do |wb|
      wb.name = "nginx-Webserver-VM-Machine"
    end
    ng.vm.network "private_network", ip: "192.168.219.91"
    ng.vm.provision "shell", path: "nginx.sh"
  end

end

