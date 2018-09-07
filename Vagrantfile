rootPath = File.dirname(__FILE__)

config = YAML.load_file("#{rootPath}/config.yml")['magento']

Vagrant.configure(2) do |conf|
  conf.vm.box = 'debian/stretch64'
  conf.vm.network :private_network, ip: '192.168.33.100'
  conf.vm.network :forwarded_port, guest: 22, host: 2200, auto_correct: true, id: 'ssh'

  conf.vm.synced_folder ".", "/vagrant", disabled: true
  if config['mount'] == 'short'
    conf.vm.synced_folder './www/magento-ce/app', '/var/www/magento-ce/app', create: true,
    :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=777", "fmode=777"]
  else
    conf.vm.synced_folder './www', '/var/www', create: true,
    :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=777", "fmode=777"]
  end

  conf.vm.provider 'virtualbox' do |vb|
    vb.memory = '4096'
    vb.cpus = 2
    vb.name = 'Magento 2.3 alpha'
  end
  
  conf.vm.provision "shell", :path => "provision/magento.sh", :keep_color => true, :args => [
    config['username'], config['password'], config['edition'], config['version'], config['sample'], config['mount']
  ]

  conf.ssh.forward_agent = true
end
