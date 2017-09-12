############################################################
# Based on Debian Streaaaaaaaaaaaaaaaaaaåtch
############################################################

# Set the base image to Ubuntu
FROM debian:stretch

# File Author / Maintainer
MAINTAINER Keaton Burleson <keaton.burleson@me.com>

############################################################
# Arguments
############################################################
ENV TZ "America/Chicago"
ENV APP_NAME web-app
ENV DEBIAN_FRONTEND noninteractive
############################################################
# Install Essential Packages
############################################################

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                        supervisor \
                        curl \
                        tzdata \
                        nginx \
                        build-essential \
                        libssl-dev \
                        gnupg \
                        apt-transport-https

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
# Configure and Install Node.js
############################################################

USER root

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs 

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN  apt-get update &&  apt-get install yarn

RUN ln -s /usr/bin/nodejs /usr/bin/node && \
           yarn global add uglifycss uglify-js less

############################################################
# Install nginx
############################################################

RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /etc/nginx/sites-enabled/* && \
    rm -rf /etc/nginx/sites-available/*

COPY conf/nginx.conf /etc/nginx/
COPY conf/$APP_NAME /etc/nginx/sites-available/$APP_NAME.conf

RUN ln -s /etc/nginx/sites-available/$APP_NAME.conf /etc/nginx/sites-enabled/$APP_NAME

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log

# Define default command.
CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

EXPOSE 80
EXPOSE 443
