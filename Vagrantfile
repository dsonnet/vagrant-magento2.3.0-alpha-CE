rootPath = File.dirname(__FILE__)

config = YAML.load_file("#{rootPath}/config.yml")
host_vagrant_dir = Dir.pwd + ''
host_magento_dir = host_vagrant_dir + '/magento-ce/'
guest_magento_dir = '/var/www/magento-ce/'

Vagrant.configure(2) do |conf|
  # vm conf
  conf.vm.box = 'debian/stretch64'
  conf.vm.network :private_network, ip: '192.168.33.100'
  conf.vm.network :forwarded_port, guest: 22, host: 2200, auto_correct: true, id: 'ssh'

  # mount
  conf.vm.synced_folder ".", "/vagrant", disabled: true
  if config['mount'] == 'app'
    conf.vm.synced_folder host_magento_dir + 'app/', guest_magento_dir + 'app/', create: true,
    :owner => "www-data", :group => "www-data", :mount_options => ["dmode=777", "fmode=777"]
  else
    conf.vm.synced_folder host_magento_dir , guest_magento_dir, create: true,
    :owner => "www-data", :group => "www-data", :mount_options => ["dmode=777", "fmode=777"]
  end

  # provider
  conf.vm.provider 'virtualbox' do |vb|
    vb.memory = '4096'
    vb.cpus = 2
    vb.name = 'Magento 2.3.0-alpha'
  end
  
  # provisioner
  conf.vm.provision "shell", :path => "provision/magento.sh", :keep_color => true, :args => [
    config['username'], config['password'], config['edition'], config['version'], config['sample'], config['mount']
  ]

  conf.ssh.forward_agent = true
end
