#!/usr/bin/bash
apt-get install -y wget
apt-get update -y
apt-get install ca-certificates apt-transport-https software-properties-common -y
apt-get update -y
#install nginx, php
apt-get install nginx -y
sed -i "s/^user www-data;/user ${user_and_group};/" /etc/nginx/nginx.conf
systemctl start nginx.service
systemctl enable nginx.service
apt install -y php8.1 php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-bcmath php8.1-fpm php8.1-phpdbg php8.1-cgi libphp8.1-embed libapache2-mod-php8.1 php8.1-redis php-pear php8.1-dev php8.1-mongodb 
systemctl enable php8.1-fpm
systemctl start php8.1-fpm
#edit php8.1 www.conf file to use user and group ubuntu
user_and_group=${user_and_group}
sed -i "s/^user\s*=.*/user=${user_and_group}/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/^group\s*=.*/group=${user_and_group}/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/^listen.owner\s*=.*/listen.owner=${user_and_group}/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/^listen.group\s*=.*/listen.group=${user_and_group}/" /etc/php/8.1/fpm/pool.d/www.conf
#install sql, create db and db user
apt install mysql-server -y
systemctl start mysqld
systemctl enable mysqld
db_name=${db_name}
db_user=${db_user}
db_pwd=${db_pwd}
mysql -u root -e "CREATE DATABASE ${db_name};"
mysql -u root -e "CREATE USER '${db_user}'@'%' IDENTIFIED BY '${db_pwd}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%';"
mysql -u root -e "FLUSH PRIVILEGES;"
#db-dump
default_region=${default_region}
bucket_name=${bucket_name}
bucket_object_key=${bucket_object_key}
bucket_object_path=${bucket_object_path}
if [ ! -f "/home/ubuntu/${bucket_object_key}" ]; then
    wget -P /home/ubuntu https://${bucket_name}.s3.${default_region}.amazonaws.com/${bucket_object_path}
    else
        echo "........DB Dump already exists.........."
fi 
mysql -u ${db_user} -p${db_pwd} ${db_name} < /home/ubuntu/${bucket_object_key}
#nginx-conf 
server_name=${server_name}
project_folder=${project_folder}
nginx_conf_file=${nginx_conf_file}
if [ ! -f "/etc/nginx/sites-available/${nginx_conf_file}" ]; then
    cat <<EOL > /etc/nginx/sites-available/${nginx_conf_file}
server {
    listen 80;
    server_name ${server_name};
    root /var/www/${project_folder}/public;

    index index.html index.htm index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    access_log /var/log/nginx/${server_name}-access.log;
    error_log  /var/log/nginx/${server_name}-error.log error;
    error_page 404 /index.php;

    location ~ \.php\$ {
        ssi on;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        fastcgi_read_timeout 301;
        fastcgi_connect_timeout 60;
        fastcgi_buffers 16 32k;
        fastcgi_buffer_size 64k;
        fastcgi_busy_buffers_size 64k;
        include fastcgi_params;
        proxy_connect_timeout 301;
        proxy_send_timeout   301;
        proxy_read_timeout   301;
        proxy_ignore_client_abort off;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOL
    ln -s /etc/nginx/sites-available/${nginx_conf_file} /etc/nginx/sites-enabled/
else
    echo ".......A conf file with the provided name already exists......."
fi

#permissions
chown -R ${user_and_group}:${user_and_group} /var/run/php
chmod -R 0755 /var/run/php
echo "........script 1 run complete........." 

