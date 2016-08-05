Vagrant.configure(2) do |config|


  config.vm.box = "swizzley88/centos-7.0_puppet-3.8"
  config.vm.host_name = "kibi-el7.vagrant"

  #config.vm.network "private_network", ip: "172.16.2.101"
  config.vm.network "forwarded_port", guest: 5606, host: 5606
  config.vm.network "forwarded_port", guest: 9220, host: 9220
  config.vm.network "forwarded_port", guest: 9330, host: 9330



  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end
  # config.vm.provision "shell" do |kibi|
  #   kibi.args   = "reinstall lite"
  #   kibi.args   = "reinstall full"
  # end
  config.vm.provision "shell", path: "provision.sh"
end
