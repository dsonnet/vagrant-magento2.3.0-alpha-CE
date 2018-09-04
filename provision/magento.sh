#!/usr/bin/env bash

###########################################
# by Ricardo Canelas                      #
# https://gist.github.com/ricardocanelas  #
#-----------------------------------------#
# + Apache                                #
# + PHP 7.2                               #
# + MySQL 5.6 or MariaDB 10.1             #
# + NodeJs, Git, Composer, etc...         #
###########################################



# ---------------------------------------------------------------------------------------------------------------------
# Variables & Functions
# ---------------------------------------------------------------------------------------------------------------------
COMPOSER_USERNAME="$1"
COMPOSER_PASSWORD="$2"
APP_NAME='magento-ce'

echoTitle () {
    echo -e "\033[0;30m\033[42m -- $1 -- \033[0m"
}



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Virtual Machine Setup'
# ---------------------------------------------------------------------------------------------------------------------
# Update packages
apt-get update -qq
apt-get upgrade -y 
apt-get autoremove -y
apt-get install -y git curl vim openssl zip unzip redis-server



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing and Setting: Apache'
# ---------------------------------------------------------------------------------------------------------------------
# Install packages
apt-get install -y apache2

# linking Vagrant directory to Apache 2.4 public directory

# Add ServerName to httpd.conf
echo "ServerName localhost" > /etc/apache2/httpd.conf

# Setup hosts file
# Default
cat <<'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
  ServerName default
  DocumentRoot /var/www/html
  ErrorLog /var/log/apache2/default.error.log
  CustomLog /var/log/apache2/default.access.log combined
  SetEnvIf X-Forwarded-Proto https HTTPS=on
</VirtualHost>
EOF
a2ensite 000-default

cat <<'EOF' > /etc/apache2/sites-available/001-ssl.conf
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    SSLEngine on
    SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
    SSLHonorCipherOrder On
    SSLProtocol All -SSLv2 -SSLv3
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

    <Proxy *>
      Order deny,allow
      Allow from all
    </Proxy>

    ProxyPass / http://localhost:80/ retry=0
    ProxyPassReverse / http://localhost:80/
    ProxyPreserveHost on
    RequestHeader set X-Forwarded-Proto "https" early

    <FilesMatch "\.(shtml|phtml|php)$">
      SSLOptions +StdEnvVars
    </FilesMatch>

    ErrorLog ${APACHE_LOG_DIR}/default.error.log
    CustomLog ${APACHE_LOG_DIR}/default.access.log combined
  </VirtualHost>
</IfModule>
EOF
a2ensite 001-ssl.conf
a2enmod deflate expires headers proxy proxy_http rewrite ssl


cat <<EOF > /etc/apache2/sites-available/010-$APP_NAME.conf
<VirtualHost *:80>
  ServerName ${APP_NAME}.com
  DocumentRoot "/var/www/${APP_NAME}"
  ErrorLog /var/log/apache2/${APP_NAME}.error.log
  CustomLog /var/log/apache2/${APP_NAME}.access.log combined
  SetEnvIf X-Forwarded-Proto https HTTPS=on
  <Directory "/var/www/${APP_NAME}">
    Options Indexes FollowSymLinks MultiViews
    Require all granted
    Allow from all
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
a2ensite 010-$APP_NAME

usermod -a -G www-data vagrant

service apache2 restart


# ---------------------------------------------------------------------------------------------------------------------
# echoTitle 'MYSQL-Database'
# ---------------------------------------------------------------------------------------------------------------------
# Setting MySQL (username: root) ~ (password: password)
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password password'
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password password'

# Installing packages
apt-get install -y  mysql-client mysql-server

# Setup database
mysql -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS magento;";
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password';"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password';"

sed -i s/^bind\-address/\#bind\-address/ /etc/mysql/mariadb.conf.d/50-server.cnf



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: PHP'
# ---------------------------------------------------------------------------------------------------------------------
# Add repository
sudo apt-get install -y apt-transport-https lsb-release ca-certificates
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
apt-get update -y

# Install packages
apt-get install -y php7.2-mysql
apt-get install -y php7.2-cli php7.2-curl php7.2-mbstring php7.2-xml php7.2-mysql
apt-get install -y php7.2-json php7.2-cgi php7.2-gd php-imagick php7.2-bz2 php7.2-zip
apt-get install -y php7.2-gd php7.2-intl php7.2-xsl php7.2-soa php7.2-bcmath



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Setting: PHP with Apache'
# ---------------------------------------------------------------------------------------------------------------------
apt-get install -y libapache2-mod-php7.2

# Trigger changes in apache
sudo a2enmod proxy_fcgi setenvif
sudo service apache2 reload



if [ ! -x /usr/bin/node ]; then
# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: Node 8 and update NPM'
# ---------------------------------------------------------------------------------------------------------------------
  curl -sL https://deb.nodesource.com/setup_8.x | bash
  apt-get install -y nodejs
fi




if [ ! -x /usr/local/bin/composer ]; then
# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: Composer'
# ---------------------------------------------------------------------------------------------------------------------
  curl -sLS -o /usr/local/bin/composer https://getcomposer.org/composer.phar
  chmod +x /usr/local/bin/composer
fi


# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: Magento CE-2.3.0-alpha'
# ---------------------------------------------------------------------------------------------------------------------
# install
rm -rf /var/www/${APP_NAME}
mkdir -p /var/www/${APP_NAME}
chown -R vagrant:www-data /var/www/.
sudo -u vagrant composer global config http-basic.repo.magento.com $COMPOSER_USERNAME $COMPOSER_PASSWORD
sudo -u vagrant composer global require hirak/prestissimo
cp /home/vagrant/provision/composer.json /var/www/${APP_NAME}
sudo -u vagrant php -d memory_limit=-1 /usr/local/bin/composer update -d /var/www/${APP_NAME}

# db
sudo -u vagrant php /var/www/${APP_NAME}/bin/magento setup:install \
--base-url="http://${APP_NAME}.com/" --base-url-secure="https://${APP_NAME}.com/" \
--db-host="localhost" --db-name="magento" --db-user="root" --db-password="password" \
--admin-firstname="john" --admin-lastname="doe" --admin-email="john@doe.com" \
--admin-user="admin" --admin-password="admin123" --language="en_US" --currency="USD" \
--timezone="Europe/London" --use-rewrites="1" --backend-frontname="admin"

sudo -u vagrant php /var/www/${APP_NAME}/bin/magento deploy:mode:set developer



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Configuring: Redis Cache'
# ---------------------------------------------------------------------------------------------------------------------
su -s /bin/bash -c " \
    /var/www/${APP_NAME}/bin/magento setup:config:set \
      --cache-backend=redis \
      --cache-backend-redis-server=127.0.0.1 \
      --cache-backend-redis-port=6379 \
      --cache-backend-redis-db=0 \
      --page-cache=redis \
      --page-cache-redis-server=127.0.0.1 \
      --page-cache-redis-port=6379 \
      --page-cache-redis-db=1 \
      --page-cache-redis-compress-data=1 \
    " vagrant

  su -s /bin/bash -c " \
    /var/www/${APP_NAME}/bin/magento setup:config:set \
      --session-save=redis \
      --session-save-redis-host=127.0.0.1 \
      --session-save-redis-port=6379 \
      --session-save-redis-db=2 \
    " vagrant

sudo service mysql restart
sudo service redis restart
sudo service apache2 restart