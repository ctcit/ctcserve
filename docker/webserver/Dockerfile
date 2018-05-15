FROM php:5.6-apache

#RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN apt-get update && \
     apt-get install -y \
         zlib1g-dev \
         && docker-php-ext-install zip
