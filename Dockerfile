FROM php:7.4-fpm

COPY . /var/www

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    supervisor

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#RUN cp /var/www/docker/workers/php.ini /usr/local/etc/php/php.ini

# extensions
RUN docker-php-ext-configure pdo_mysql
RUN docker-php-ext-configure mysqli
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip mbstring

RUN cp /var/www/docker/workers/laravel-worker.conf /etc/supervisor/conf.d/laravel-worker.conf
#RUN cp /var/www/docker/workers/supervisord.conf /etc/supervisord.conf

RUN curl -L http://download.newrelic.com/php_agent/archive/9.9.0.260/newrelic-php5-9.9.0.260-linux.tar.gz | tar -C /tmp -zx && \
  export NR_INSTALL_USE_CP_NOT_LN=1 && \
  export NR_INSTALL_SILENT=1 && \
  /tmp/newrelic-php5-*/newrelic-install install && \
  rm -rf /tmp/newrelic-php5-* /tmp/nrinstall* && \
  sed -i \
  -e 's/"REPLACE_WITH_REAL_KEY"/"${NEW_RELIC_KEY}"/' \
  -e 's/newrelic.appname = "Share Link Application"/newrelic.appname = "${NEW_RELIC_APP_NAME}"/' \
  -e 's/;newrelic.daemon.app_connect_timeout =.*/newrelic.daemon.app_connect_timeout=15s/' \
  -e 's/;newrelic.daemon.start_timeout =.*/newrelic.daemon.start_timeout=5s/' \
  /usr/local/etc/php/conf.d/newrelic.ini \


WORKDIR /var/www

RUN composer install
