#!/bin/bash    
#title          :user-data.sh
#description    :This script will configure a php web server
#author         :dvillarraga
#date           :2019-03-21
#==============================================================================

install() {
sudo mkdir -p /var/www/app/web
domain_name=$1
###
# Adding default configuration for Apache and PHP
###

#### --- Apache Global Configuration ---
sudo bash -c  "cat > /etc/apache2/conf-enabled/config-apache.conf" << EOF
  ServerName $domain_name
  ServerSignature Off
  ServerTokens Prod

  <IfModule security2_module>
    SecRuleEngine on
    ServerTokens Full
    SecServerSignature "Microsoft-IIS/6.0"
    SecRequestBodyLimit 30000000
    SecRequestBodyInMemoryLimit 30000000
  </IfModule>

  <Directory "/">
    Require all denied
  </Directory>
EOF

#### --- Apache App Virtual Host ---
sudo bash -c "cat > /etc/apache2/conf-enabled/app.conf" << EOF

<VirtualHost *:80>
  ServerName $domain_name
  DocumentRoot "/var/www/app/web"
  UseCanonicalName On
  DirectoryIndex index.php
  
  ## Redirection from http to https for aws-elb  
  <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP:X-Forwarded-Proto} !https
    #RewriteCond %{HTTP_USER_AGENT} !^ELB-HealthChecker
    RewriteCond %{REQUEST_URI} !^/health-check.php
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
  </IfModule>
  
  <Directory "/var/www/app/web">
    Options +FollowSymLinks
    
    # Removing false-positive security errors
    SecRuleRemoveById 949110

    ## Rewrite rules for symfony1 projects
    <IfModule mod_rewrite.c>
      RewriteEngine On
      RewriteRule ^$ index.html [QSA]
      RewriteRule ^([^.]+)$ \$1.html [QSA]
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteRule ^(.*)$ index.php [QSA,L]
    </IfModule>

    AllowOverride None
    Require all granted

  </Directory>

  Alias "/sf" "/var/www/app/lib/vendor/lexpress/symfony1/data/web/sf"
  <Directory "/var/www/app/lib/vendor/lexpress/symfony1/data/web/sf">
    AllowOverride None
    Require all granted
  </Directory>
  ErrorLog "/var/log/apache2/app-error.log"
</VirtualHost>
EOF
###
# Testing Apache Conf and Starting Services
###
sudo apachectl -t
sudo /etc/init.d/apache2 restart
}

"$@"
