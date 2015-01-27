require "yaml"

_config = YAML.load(File.open(File.join(File.dirname(__FILE__), "vagrantconfig.yaml"), File::RDONLY).read)

begin
  _config.merge!(YAML.load(File.open(File.join(File.dirname(__FILE__), "vagrantconfig_local.yaml"), File::RDONLY).read))
rescue Errno::ENOENT

end

CONF = _config

Vagrant.configure("2") do |config|
  config.vm.box = "centos-64-x64-vbox4210-nocm"

  #puppet master
  config.vm.define "master" do |master|
    master.vm.synced_folder ".", "/home/vagrant/share"
    master.vm.host_name  = CONF['master']['hostname']
    master.vm.network "private_network", ip: CONF['master']['ip_address']

    master.vm.provider :virtualbox do |vbox1|
      # Config memmory and cps
      vbox1.customize ["modifyvm", :id, "--memory", CONF['master']['memory']]
      vbox1.customize ["modifyvm", :id, "--cpus", CONF['master']['cpus']]
    end

    master.vm.provision :shell, path: "master-bootstrap.sh"
  end

  begin
    #puppet agent
    config.vm.define "agent" do |agent|
      agent.vm.synced_folder ".", "/home/vagrant/share"
      agent.vm.host_name  = CONF['agent']['hostname']
      agent.vm.network "private_network", ip: CONF['agent']['ip_address']

      agent.vm.provider :virtualbox do |vbox2|
        # Config memmory and cps
        vbox2.customize ["modifyvm", :id, "--memory", CONF['agent']['memory']]
        vbox2.customize ["modifyvm", :id, "--cpus", CONF['agent']['cpus']]
      end
    end
  end
end
