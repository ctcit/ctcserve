FROM php:8.3-apache

ENV LETSENCRYPT_HOME /etc/letsencrypt
ENV DOMAINS ctc.org.nz,www.ctc.org.nz
ENV WEBMASTER_MAIL nickedwrds@gmail.com
ENV STAGING 0

RUN echo deb http://ftp.debian.org/debian bullseye-backports main >> /etc/apt/sources.list && \
    apt-get update -yq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
         libsasl2-modules \
         libzip-dev \
         zip \
         postfix rsyslog \
         libpng-dev \
         libjpeg-dev \
         libicu-dev \
	 libfreetype6-dev && \
    apt-get install -yq python3-certbot-apache -t bullseye-backports && \
    docker-php-ext-configure gd --with-jpeg&& \
    docker-php-ext-install zip mysqli gd intl

COPY ./conf/timezone.ini /usr/local/etc/php/conf.d/timezone.ini
COPY ./conf/php.ini /usr/local/etc/php/php.ini
COPY ./conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./conf/www.ctc.org.nz.conf /etc/apache2/sites-enabled/www.ctc.org.nz.conf
COPY ./conf/postfix/main.cf /etc/postfix/main.cf
COPY ./conf/postfix/master.cf /etc/postfix/master.cf
COPY ./conf/postfix/sasl_passwd /etc/postfix/sasl_passwd
COPY ./conf/crontab /etc/crontab
COPY run_services.sh /opt/ctcserve/run_services.sh
COPY init_letsencrypt.sh /opt/ctcserve/
COPY triphub_post_emails.php /opt/ctcserve/

RUN chmod +x /opt/ctcserve/*.sh

RUN postmap hash:/etc/postfix/sasl_passwd
RUN groupadd -g 5000 postcat && usermod -a -G postcat www-data
RUN a2enmod rewrite

CMD /opt/ctcserve/run_services.sh
