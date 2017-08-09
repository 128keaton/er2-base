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
ENV TZ "America/Chicago"

ENV DEBIAN_FRONTEND noninteractive
############################################################
# Install Essential Packages
############################################################

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                        supervisor \
                        nodejs \
                        npm \
                        curl \
                        git \ 
                        tzdata \
                        nginx

COPY conf/supervisord.conf /etc/supervisord.conf

# Define default command.
CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

############################################################
# Update Timezone
############################################################

RUN echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

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
RUN ln -s /usr/bin/nodejs /usr/bin/node && \
           npm install -g uglifycss uglify-js less

############################################################
# Install nginx
############################################################

RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /etc/nginx/sites-enabled/*

# Define mountable directories.
VOLUME ["/var/www/html"]

ADD conf/nginx.conf /etc/nginx/
ADD conf/symfony /etc/nginx/sites-available/

RUN echo "upstream php-upstream { server php:9000; }" > /etc/nginx/conf.d/upstream.conf
CMD ["nginx"]

# Expose ports.
EXPOSE 80 443

