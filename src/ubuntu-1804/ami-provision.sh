#!/bin/bash    
#title          :ami-provision-ubuntu-1804
#description    :This script will provision a php server
#author         :dvillarraga
#date           :2019-03-21
#==============================================================================

install() {
# params
code_deploy_bucket_name=$1

###
# Configuring Locales
###
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
sudo apt-get update && sudo apt-get install -y language-pack-es-base

###
# Configuring localtime to Bogota
###
sudo apt-get install -y tzdata \
     && sudo ln -fs /usr/share/zoneinfo/America/Bogota /etc/localtime

###
# Configuring Swap Volumes for EC2
# for performance improvements.
###
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1

###
# Installing AWS Code Deploy Agent
###
sudo apt-get install -y ruby wget
cd /home/ubuntu
wget https://"$code_deploy_bucket_name".s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

###
# Installing Apache2 Curl PHP ModApache ModSecurity2
# Installing PHP Extensions and Composer
###

sudo apt-get update && sudo apt-get install -y apache2 curl language-pack-es-base \
    && sudo apt-get install -y php libapache2-mod-php libapache2-mod-security2 \
    && sudo apt-get install -y php-common php-cli php-mysql php-gd php-mbstring \
    && sudo apt-get install -y php-curl php-zip zip php-xml php-intl php-json php-soap \
    && sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

###
# Configuring ModSecurity
###

sudo mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf \
    && sudo sed -i -e 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/modsecurity/modsecurity.conf \
    && sudo sed -i -e 's/SecResponseBodyAccess On/SecResponseBodyAccess Off/g' /etc/modsecurity/modsecurity.conf

###
# Configuring Apache Modules
###
sudo a2enmod rewrite

#### --- PHP ---
sudo bash -c "cat > /etc/php/7.2/apache2/conf.d/config-php.ini" << EOF
date.timezone = America/Bogota
max_execution_time = 300
max_input_vars = 1620
upload_max_filesize = 30M
post_max_size = 30M
sendmail_path = mailserver-pending
display_errors = 1
session.gc_maxlifetime = 2000
EOF

###
# Testing Apache Conf and Starting Services
###
sudo apachectl -t
sudo /etc/init.d/apache2 restart
}

"$@"