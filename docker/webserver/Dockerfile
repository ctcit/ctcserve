FROM php:5.6-apache

ENV LETSENCRYPT_HOME /etc/letsencrypt
ENV DOMAINS ctc.05081986.xyz
ENV WEBMASTER_MAIL nickedwrds@gmail.com
ENV STAGING 0

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN echo deb http://ftp.debian.org/debian stretch-backports main >> /etc/apt/sources.list && \
    #add-apt-repository ppa:certbot/certbot && \
    apt-get update -yq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
         libsasl2-modules \
         zlib1g-dev postfix rsyslog \
         && docker-php-ext-install zip && \
    apt-get install -yq python-certbot-apache -t stretch-backports

COPY ./conf/timezone.ini /usr/local/etc/php/conf.d/timezone.ini
COPY ./conf/php.ini /usr/local/etc/php/php.ini
COPY ./conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./conf/postfix/main.cf /etc/postfix/main.cf
COPY ./conf/postfix/master.cf /etc/postfix/master.cf
COPY ./conf/postfix/sasl_passwd /etc/postfix/sasl_passwd
COPY ./conf/crontab /etc/crontab
COPY run_services.sh /opt/ctcserve/run_services.sh
COPY init_letsencrypt.sh /opt/ctcserve/

RUN chmod +x /opt/ctcserve/*.sh

RUN postmap hash:/etc/postfix/sasl_passwd

#RUN certbot --apache  --test-cert -n --domains ctc.05081986.xyz --agree-tos --email nickedwrds@gmail.com

CMD /opt/ctcserve/run_services.sh
