FROM ubuntu
MAINTAINER Woody Gilk <woody@ushahidi.com>
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y upgrade

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
RUN mkdir /var/run/sshd

# Basic Requirements
RUN apt-get -y install memcached mysql-server mysql-client nginx php5-fpm php5-mysql php-apc pwgen python-setuptools curl git unzip openssh-server openssl

# Platform Requirements
RUN apt-get -y install php5-curl php5-mcrypt php5-memcached

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# Supervisor Config
RUN /usr/bin/easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Add system user for Ushahidi Platform
RUN useradd -m -d /home/ushahidi -p $(openssl passwd -1 'temp') -G sudo -s /bin/bash ushahidi
RUN ln -s /usr/share/nginx/www /home/ushahidi/www

# SSH security, turn off root login
RUN sed -i -e "s/PermitRootLogin\syes/PermitRootLogin no/g" /etc/ssh/sshd_config

# Install Ushahidi Platform
ADD ./database.config.php /tmp/database.config.php
ADD https://72c9192a7b87de5fc63a-f9fe2e6be12470a7bff22b7693bc7329.ssl.cf1.rackcdn.com/V3/Ushahidi-Platform-v3.0.0-beta.4.tar.gz /usr/share/nginx/latest.tar.gz
RUN cd /usr/share/nginx/ && tar xvf latest.tar.gz && rm latest.tar.gz
RUN rm -rf /usr/share/nginx/www
RUN mv /usr/share/nginx/platform /usr/share/nginx/www
RUN chown -R ushahidi:www-data /usr/share/nginx/www
RUN chmod -R 775 /usr/share/nginx/www

# Platform Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 80
EXPOSE 22

CMD ["/bin/bash", "/start.sh"]
