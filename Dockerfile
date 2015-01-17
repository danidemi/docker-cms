# Create an image with:
#    
#    $ docker build --tag="cms:0.1" .
#
# Run a container with:
#
#    $ docker run -p 10100:10100 -p 10101:10101 -p 80:80 -p 21:21 --rm cms:0.1 
#
# Inspired by: 
# - https://github.com/lgreeff/docker-ftp
# - https://github.com/jbfink/docker-wordpress
FROM ubuntu:14.04
MAINTAINER Daniele Demichelis <demichelis@danidemi.com>





# System
# =========================
RUN apt-get install -y python-setuptools wget
RUN ["easy_install", "supervisor"]
COPY supervisord.conf /etc/




# MySQL Installation, Setup
# =========================
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password password cms'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password cms'"]
RUN apt-get install -y mysql-server
RUN mysql_install_db





# Apache, Php
# =========================
RUN apt-get install -y \
 apache2 \
 libapache2-mod-auth-mysql \
 libapache2-mod-php5 \
 php5 \
 php5-mysql \
 python-setuptools \
 vsftpd \
 wget
COPY foreground.sh /etc/apache2/
RUN ["chmod", "ugo+x", "/etc/apache2/foreground.sh"]





# Vsftpd
# =========================
RUN apt-get install -y \
 vsftpd
COPY vsftpd.conf /etc/

# creates ftp user cms/cms in group root that can access http dir
RUN adduser --disabled-password --gecos "" cms; \
 usermod -d /var/www/html cms; \
 usermod -g root cms; \
 mkdir -p /var/run/vsftpd/empty; \
 chmod -R ugo+rw /var/www
RUN ["/bin/bash", "-c", "echo -e \"cms\\ncms\" > tmp/pwd; passwd cms < tmp/pwd; rm /tmp/pwd"]



# Wordpress
# =========================

# wp-cli
RUN mkdir -p /tmp/install/wordpress; \
 cd /tmp/install/wordpress; \
 wget https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
 chmod +x wp-cli.phar; \
 mv wp-cli.phar /usr/local/bin/wp; \
 rm -Rf /tmp/install

# wordpress-db
RUN ["/etc/init.d/mysql start; echo \"CREATE DATABASE wordpress;\" > /tmp/sql; mysql -u root --password=cms < /tmp/sql; rm /tmp/sql"]

# wordpress
RUN ["mkdir /var/www/html/wordpress; cd /var/www/html/wordpress; wp core download --allow-root"]
RUN ["cd /var/www/html/wordpress; /etc/init.d/mysql start;  wp core config --allow-root --dbname=wordpress --dbuser=root --dbpass=cms; wp core install --allow-root --url=\"http://127.0.0.1/wordpress\" --title=\"docker-cms-wordpress\" --admin_user=cms --admin_password=cms --admin_email=\"cms@cms.cms\""]





# Starts all services
CMD ["supervisord", "-n"]




# Ports exposed
# =========================
# Http
EXPOSE 80     

# FTP
EXPOSE 20     
EXPOSE 10100
EXPOSE 10101

# MySQL
EXPOSE 3306   

# Next to be provided
# ========================
# http://www.joomla.org/
# https://www.impresspages.org/
# http://www.silverstripe.org/
# http://typo3.org/
# http://www.oscommerce.com

