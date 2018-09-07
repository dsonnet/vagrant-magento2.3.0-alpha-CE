# Magento2.3.0-alpha Vagrant

![magento 2.3.0-alpha](https://image.noelshack.com/fichiers/2018/36/5/1536313361-selection-014.png)

A simple Vagrant Magento installation on Debian Stretch to take a look on Magento 2.3.0-alpha*<br>
Setup is based on [magento documentation](https://devdocs.magento.com/guides/v2.3/release-notes/2.3.0-alpha-install.html)

## Requirements

1. [Oracle VirtualBox](https://www.virtualbox.org/)
2. [Vagrant](https://www.vagrantup.com/)

### Configurations

Copy and paste ``config.yml.sample``, rename it ``config.yml``
- Open it and set your composer credentials for ``repo.magento.com`` accessible here:
https://marketplace.magento.com/customer/accessKeys/
- Set edition to ``community`` (open source) or ``enterprise`` (commerce)
- Set magento2.3.0 version ``alpha64`` 
- Set sample to ``true`` to get sample data on your installation
- Set mount to ``short`` to mount only /app directory (highly improve vm performance) or ``full` if you wish to share all magento installation

### Project path

<b>Use shortcurt ``magento`` to use bin/magento CLI.</b> This shortcut allow you to use binary as www-data user and prevent error on permissions. Do not use bin/magento as vagrant user.

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
