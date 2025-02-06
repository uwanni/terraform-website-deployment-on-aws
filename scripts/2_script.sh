#!/usr/bin/bash
echo ".......script 2 start by cloning git repo........"
git_username=${git_username}
git_repo_url=${git_repo_url}
git_access_token=${git_access_token}
project_folder=${project_folder}
git_branch=${git_branch}
git clone -b ${git_branch} https://${git_username}:${git_access_token}@gitlab.com${git_repo_url}.git /var/www/${project_folder}
chown -R ubuntu:ubuntu /var/www/${project_folder}
chmod 777 -R /var/www/${project_folder}
#edit .env
db_name=${db_name}
db_user=${db_user}
db_pwd=${db_pwd}
server_name=${server_name}s
if [ ! -f "/var/www/${project_folder}/.env" ]; then
    echo ".......env file is downloading......."
    wget -P /var/www/${project_folder} https://${bucket_name}.s3.${default_region}.amazonaws.com/.env
    sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${db_name}/" /var/www/${project_folder}/.env
    sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${db_user}/" /var/www/${project_folder}/.env
    sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${db_pwd}/" /var/www/${project_folder}/.env
    sed -i "s|^SITE_URL=.*|SITE_URL=http://${server_name}/|" /var/www/${project_folder}/.env
    else
        echo "... .env file is already available. nothing changed......"
fi
echo "........script 2 run complete........." 

