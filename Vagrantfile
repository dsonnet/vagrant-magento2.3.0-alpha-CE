rootPath = File.dirname(__FILE__)

config = YAML.load_file("#{rootPath}/config.yml")['magento']
username = config['username']
password = config['password']

Vagrant.configure(2) do |conf|
  conf.vm.box = 'debian/stretch64'
  conf.vm.network :private_network, ip: '192.168.33.100'
  conf.vm.network :forwarded_port, guest: 22, host: 2200, auto_correct: true, id: 'ssh'

  conf.vm.synced_folder ".", "/vagrant", disabled: true
  conf.vm.provision "file", source: "./provision/composer.json", destination: "~/provision/composer.json"
  conf.vm.synced_folder './www', '/var/www', create: true, 
    :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=777", "fmode=777"]
  
  conf.vm.provider 'virtualbox' do |vb|
    vb.memory = '4096'
    vb.cpus = 2
    vb.name = 'Magento 2.3.0'
  end
  
  conf.vm.provision "shell", :path => "provision/magento.sh", :keep_color => true, :args => [username, password]

  conf.ssh.forward_agent = true
end
