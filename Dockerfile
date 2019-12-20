FROM debian:buster

# GET LATEST VERSION
RUN apt-get update
RUN apt-get upgrade -y

# NGINX
RUN apt-get -y install nginx
COPY ./srcs/nginx.conf /etc/nginx/sites-available/localhost
# SYMLINK
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost 

# SSL 
WORKDIR /var/cert
COPY ./srcs/localhost.pem /var/cert/
COPY ./srcs/localhost-key.pem /var/cert/

RUN mkdir -p /var/www/localhost
COPY /srcs/index.html /var/www/localhost

# WORDPRESS
COPY ./srcs/wordpress.tar.gz .
RUN tar xf ./wordpress.tar.gz && rm -rf wordpress.tar.gz
RUN chmod -R 755 wordpress
COPY /srcs/wp-config.php .
RUN mv wordpress /var/www/localhost/
RUN mv wp-config.php /var/www/localhost/wordpress/

# MYSQL
RUN apt-get -y install mariadb-server
RUN service mysql start; \
    mysql -uroot mysql; \
    mysqladmin password "guest"; \
	echo "CREATE DATABASE wordpress;" | mysql --user=root;
RUN chown -R www-data:www-data *
RUN chmod 755 -R *

# PHPMYADMIN
WORKDIR var/www/html
RUN apt-get -y install php7.3 php-mysql php-fpm php-cli php-mbstring
COPY ./srcs/phpmyadmin.tar.gz .
RUN tar xf phpmyadmin.tar.gz && rm -rf phpmyadmin.tar.gz
RUN mv phpMyAdmin-4.9.1-english phpmyadmin
COPY ./srcs/config.inc.php phpmyadmin
RUN chmod -R 755 phpmyadmin
RUN mv phpmyadmin /var/www/localhost/

#RUN 
COPY ./srcs/runprogram.sh /root/
CMD bash /root/runprogram.sh

EXPOSE 80 443
