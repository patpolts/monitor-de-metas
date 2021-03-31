#!/bin/bash

cd /monitor-de-metas
git pull
chown -R www-data: /monitor-de-metas

wget https://github.com/ufoscout/docker-compose-wait/releases/download/2.8.0/wait waitingfor
cp waitingfor /usr/local/bin

sed -i -e "s/root %%NGINX_ROOT%%;/root \/monitor-de-metas;/g" /etc/nginx/sites-available/default.conf

sh -c "waitingfor && wp-cli config create --dbhost=${DBHOST} --dbname=${DBNAME} --dbuser=${DBUSER} --dbpass=${DBPASS} --dbprefix=${DBPREFIX} --locale=pt_BR --path=/monitor-de-metas --allow-root"
sh -c "waitingfor && wp-cli core install --url=${URL} --title=${TITLE} --admin_user=${ADMUSER} --admin_password=${ADMPASS} --admin_email=${ADMMAIL} --path=/monitor-de-metas --allow-root"

cd /monitor-de-metas/wp-content/themes/pdm-andamento/

composer install
bower install --allow-root

wp-cli plugin activate timber-library --allow-root --path=/monitor-de-metas
wp-cli theme activate pdm-andamento --allow-root --path=/monitor-de-metas

/etc/init.d/php5.6-fpm start
nginx
