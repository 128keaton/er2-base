############################################################
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu:16.04

# File Author / Maintainer
MAINTAINER Keaton Burleson <keaton.burleson@me.com>

############################################################
# Arguments
############################################################

ARG PHP_VERSION=7.0
ENV DEBIAN_FRONTEND noninteractive
ENV XDEBUGINI_PATH=/usr/local/etc/php/conf.d/xdebug.ini

############################################################
# Install Essential Packages
############################################################

RUN apt-get update
RUN apt-get install -y software-properties-common

RUN add-apt-repository ppa:saiarcot895/myppa
RUN apt-get update
RUN apt-get install -y apt-fast

RUN apt-fast install -y --no-install-recommends php$PHP_VERSION \
                        cups \
                        supervisor \
                        nodejs \
                        npm \
                        zip \
                        unzip \
                        sudo \
                        curl \
                        git

############################################################
# Install PHP Extensions
############################################################

RUN apt-fast install -y php-xml \
                       php$PHP_VERSION-mbstring \
                       php$PHP_VERSION-fpm \
                       php$PHP_VERSION-zip \
                       phpmyadmin \
                       php$PHP_VERSION-cli \
                       php$PHP_VERSION-dev

############################################################
# Create 'ducky' user
############################################################

RUN useradd -ms /bin/bash ducky
USER ducky
WORKDIR /home/ducky

RUN echo 'export PATH=$HOME/.config/composer/vendor/bin/:$PATH' >> .bash_profile

############################################################
# Configure Node.js
############################################################

USER root
RUN sudo ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g uglifycss uglify-js less

############################################################
# Install Composer
############################################################

USER root
RUN curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer

# Create composer folder
USER ducky
RUN mkdir -p /home/ducky/.composer/

# Add the default composer.json
COPY docker-config/composer.json /home/ducky/.composer/composer.json

# Update Composer
RUN composer config --global github-protocols https
RUN composer global update

# Switch to ducky
WORKDIR /home/ducky

# Add Composer to the path
RUN echo 'export PATH=$PATH:/home/ducky/.composer/vendor/bin' >> .bash_profile

# Update the phpcs coding standard
RUN /home/ducky/.composer/vendor/bin/phpcs --config-set installed_paths /home/ducky/.composer/vendor/escapestudios/symfony2-coding-standard


############################################################
# Install nginx
############################################################
USER root
RUN apt-fast -y install nginx
