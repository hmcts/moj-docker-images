# -*- mode: ruby -*-"
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end
  config.vm.network "forwarded_port", guest: 80, host: 8888
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
    ansible.extra_vars = "provisioning/files/build_versions.json"
  end
end
