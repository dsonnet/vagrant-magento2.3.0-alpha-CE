# Magento2.3.0-alpha Vagrant

![magento 2.3.0-alpha](https://image.noelshack.com/fichiers/2018/36/2/1536059208-selection-012.png)

A simple Vagrant Magento installation on Debian Stretch to take a look on Magento 2.3.0-alpha.<br>
Setup is based on [fooman article](https://store.fooman.co.nz/blog/upgrading-to-the-pre-release-of-magento-2-3-0.html) which details process to upgrade magento to this pre-release.

## Requirements

1. [Oracle VirtualBox](https://www.virtualbox.org/)
2. [Vagrant](https://www.vagrantup.com/)

### Configurations

Copy and paste ``config.yml.sample``, rename it ``config.yml``<br>
Open it and set your composer credentials for ``repo.magento.com`` accessible here:<br>
https://marketplace.magento.com/customer/accessKeys/

### Project path

Don't forget to add vagrant IP and host name in your /etc/hosts file or C:\WINDOWS\system32\drivers\etc\hosts:<br>
```
192.168.33.100  magento-ce.com
```

Vagrant IP:
- 192.168.33.100

Repository installation:
- /var/www/magento-ce/

Front-end:
- url: http://magento-ce.com/

Back-office:
- url: http://magento-ce.com/admin
- username: admin
- password: admin123
