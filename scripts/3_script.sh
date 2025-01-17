#!/usr/bin/bash
#disable apache2
echo ".......script 3 start by disabling apache2........"
systemctl stop apache2.service
systemctl disable apache2.service
#composer install
echo 'export COMPOSER_HOME="$HOME/.composer"' >> /etc/profile.d/composer.sh
source /etc/profile.d/composer.sh
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
sudo -u ubuntu -i <<EOF
cd /var/www/${project_folder}
export COMPOSER_HOME=/home/ubuntu/.composer
composer update
composer install
php artisan migrate --force
EOF
#reload the services
systemctl daemon-reload
systemctl restart php8.1-fpm.service
systemctl restart mongod.service
systemctl restart nginx
nginx -t
echo "........script 3 run complete........." 


