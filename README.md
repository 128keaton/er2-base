# ER2-base
Base Docker image for ER2 apps built on Debian Stretch.
Designed for Symfony apps.

## Contents:
* nginx
* nodejs
* yarn
* supervisor

## Generating SSL Cert:
`sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/ssl-cert.key -out certs/ssl-cert.crt`