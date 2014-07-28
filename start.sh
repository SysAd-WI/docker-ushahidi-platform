#!/bin/bash
if [ ! -d /usr/share/nginx/www/application/config/environments/development ]; then
  #mysql has to be started this way as it doesn't work to call from /etc/init.d
  /usr/bin/mysqld_safe &
  sleep 8

  # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
  USHAHIDI_DB="ushahidi"
  MYSQL_PASSWORD=`pwgen -c -n -1 12`
  USHAHIDI_PASSWORD=`pwgen -c -n -1 12`
  SSH_PASSWORD=`pwgen -c -n -1 12`
  COOKIE_SALT=`pwgen -c -n -1 32`

  #This is so the passwords show up in logs.
  echo mysql root password: $MYSQL_PASSWORD
  echo mysql ushahidi password: $USHAHIDI_PASSWORD
  echo ssh password: $SSH_PASSWORD
  echo $MYSQL_PASSWORD > /mysql-root-pw.txt
  echo $USHAHIDI_PASSWORD > /ushahidi-db-pw.txt

  #Update linux user password to the new random one
  usermod -p $(openssl passwd -1 $SSH_PASSWORD) ushahidi

  # Create the database configuration with the generated password
  mkdir -p -m 0755 /usr/share/nginx/www/application/config/environments/development
  sed -e "s/SET PASSWORD HERE/$USHAHIDI_PASSWORD/" /tmp/database.config.php > /usr/share/nginx/www/application/config/environments/development/database.php

  # Reset the default cookie salt to something unique
  sed -i -e "s/Cookie::\$salt = '.*';/Cookie::\$salt = '$COOKIE_SALT';/" /usr/share/nginx/www/application/bootstrap.php

  # Change the root password
  mysqladmin -u root password $MYSQL_PASSWORD

  # Create the Ushahidi Platform database
  mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE ushahidi; GRANT ALL PRIVILEGES ON ushahidi.* TO 'ushahidi'@'localhost' IDENTIFIED BY '$USHAHIDI_PASSWORD'; FLUSH PRIVILEGES;"
  killall mysqld
fi

# start all the services
service memcached start
/usr/local/bin/supervisord -n
