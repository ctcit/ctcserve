FROM php:8.3-apache

ENV LETSENCRYPT_HOME=/etc/letsencrypt \
    DOMAINS=ctc.org.nz,www.ctc.org.nz \
    WEBMASTER_MAIL=nickedwrds@gmail.com \
    STAGING=0

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libsasl2-modules \
      libzip-dev \
      zip \
      zlib1g-dev \
      openssl \
      postfix rsyslog \
      pkg-config \
      libpng-dev \
      libjpeg-dev \
      libicu-dev \
      libfreetype6-dev \
      cron \
      python3-certbot-apache; \
    docker-php-ext-configure gd --with-jpeg --with-freetype; \
    docker-php-ext-install -j"$(nproc)" zip mysqli gd intl; \
    a2enmod rewrite ssl; \
    groupadd -g 5000 postcat; \
    usermod -a -G postcat www-data; \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/timezone.ini /usr/local/etc/php/conf.d/timezone.ini
COPY ./conf/php.ini /usr/local/etc/php/php.ini
COPY ./conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./conf/www.ctc.org.nz.conf /etc/apache2/sites-enabled/www.ctc.org.nz.conf
COPY ./conf/postfix/main.cf /etc/postfix/main.cf
COPY ./conf/postfix/master.cf /etc/postfix/master.cf
COPY ./conf/postfix/sasl_passwd /etc/postfix/sasl_passwd
COPY ./conf/crontab /etc/crontab
COPY --chmod=755 run_services.sh /opt/ctcserve/run_services.sh
COPY init_letsencrypt.sh /opt/ctcserve/
COPY triphub_post_emails.php /opt/ctcserve/

RUN set -eux; \
  sed -i 's/\r$//' /opt/ctcserve/run_services.sh /opt/ctcserve/init_letsencrypt.sh; \
  postmap hash:/etc/postfix/sasl_passwd

CMD ["bash", "/opt/ctcserve/run_services.sh"]

