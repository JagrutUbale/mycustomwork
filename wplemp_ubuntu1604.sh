#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "Please run script as root user" 
	exit 1
fi
if [ "$#" -ne 1 ]; then
    echo "Please provide domain name like example.com"
	exit 1
fi
echo "Domain : $1"
touch /tmp/tasks 
apt-get update >> /tmp/tasks
debconf-set-selections <<< "mysql-server mysql-server/root_password password root"  
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root" 
packages="mysql-server nginx php php-mysql php-fpm php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc nano wget curl ed elinks tar sudo adduser" 
for pkg in $packages; do
	dpkg -s $pkg &>> /tmp/tasks
	if [ $? -eq 0 ]; then
		echo -e "$pkg is already installed"
	else
		apt-get -yy install $pkg >> /tmp/tasks
        echo "$pkg successfully installed"
	fi
done
service mysql restart >> /tmp/tasks
mysql --user=root --password=root -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wordpress'; FLUSH PRIVILEGES;" >> /tmp/tasks

mkdir -p "/var/www/$1"  
echo "127.0.0.1 $1" >> /etc/hosts
cat <<EOF> /etc/nginx/sites-available/$1
server {
        listen   80 default_server;
        root /var/www/$1;
        index index.php index.html index.htm;
        server_name _;
        location / {
                try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
        }
        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }
        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
              root /var/www/$1;
        }
        location ~ \.php$ {
                try_files \$uri =404;
                fastcgi_pass unix:/run/php/php7.0-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME \$document_root/\$fastcgi_script_name;
                include fastcgi_params;
        } 
}
EOF
ln -sf /etc/nginx/sites-available/$1 /etc/nginx/sites-enabled/$1
rm /etc/nginx/sites-enabled/default

chown -R www-data:www-data /var/www/$1
chmod -R g+s /var/www/$1

cd /var/www/
wget http://wordpress.org/latest.tar.gz >> /tmp/tasks
tar -xvf latest.tar.gz >> /tmp/tasks
cp -rf wordpress/* $1/
cd /var/www/$1/
mv wp-config-sample.php wp-config.php
sed -i "s/username_here/wordpress/"  wp-config.php >> /tmp/tasks
sed -i "s/database_name_here/wordpress/"  wp-config.php >> /tmp/tasks
sed -i "s/password_here/wordpress/"   wp-config.php >> /tmp/tasks
echo "define('FS_METHOD', 'direct');" >> wp-config.php 
SALT=$(curl -s -L https://api.wordpress.org/secret-key/1.1/salt/)
printf '%s\n' "g/put your unique phrase here/d" a "$SALT" . w | ed -s wp-config.php
chown -R www-data:www-data /var/www/$1
chmod -R 755 /var/www/$1
sed -i -e "s/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
sudo service nginx restart  >> /tmp/tasks
sudo service php7.0-fpm restart  >> /tmp/tasks
sudo service mysql restart  >> /tmp/tasks
elinks http://$1 
