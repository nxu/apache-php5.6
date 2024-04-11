# syntax=docker/dockerfile:1
FROM ubuntu:22.04

LABEL org.opencontainers.image.authors="nxu@nxu.hu"

ENV DEBIAN_FRONTEND noninteractive

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl && \
    ln -sf /bin/true /sbin/initctl

# Install gnpug2 (required to add ppa:onderj/php)
RUN apt-get update && apt-get install -y gnupg2

# Install packages
RUN apt-get update && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get upgrade -y && \
    BUILD_PACKAGES="apache2 php5.6 git php5.6-mysql php5.6-zip php5.6-json php5.6-curl php5.6-gd php5.6-intl php5.6-mcrypt php5.6-mbstring php5.6-memcache php5.6-memcached php5.6-sqlite php5.6-tidy php5.6-xmlrpc php5.6-xsl php5.6-xml php5.6-bcmath php5.6-soap php5.6-cli curl memcached" && \
    apt-get -y install $BUILD_PACKAGES && \
    apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_* && \
    curl https://getcomposer.org/download/1.10.27/composer.phar --output /usr/local/bin/composer && chmod a+x /usr/local/bin/composer && \
    # clean temporary files
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure apache modules
RUN a2enmod php5.6 rewrite headers expires

ENV APACHE_CONFDIR /etc/apache2

# Mount files
RUN rm /var/www/html/index.html
RUN rm /etc/apache2/apache2.conf
COPY ./config/apache2.conf /etc/apache2/apache2.conf
COPY ./config/init.sh /init.sh
COPY --chown=www-data:www-data ./docroot/ /var/www/html/

# Fix permissions 
RUN chmod +x /init.sh

# Expose Ports
EXPOSE 80

CMD /init.sh