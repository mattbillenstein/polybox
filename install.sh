#!/bin/bash

set -eo pipefail

PAAS_USERNAME="polybox"
REPO="mardix/polybox"
BRANCH="master"

echo "Polybox installer"

sudo apt-get update
sudo apt-get install -y \
   bc \
   curl \
   software-properties-common \
   cron \
   build-essential \
   certbot \
   git \
   incron \
   libjpeg-dev \
   libxml2-dev \
   libxslt1-dev \
   zlib1g-dev \
   nginx-full \
   python3 \
   python3-certbot-nginx \
   python3-dev \
   python3-pip \
   python3-click \
   python3-virtualenv \
   python-yaml \
   uwsgi \
   uwsgi-plugin-asyncio-python3 \
   uwsgi-plugin-gevent-python3 \
   uwsgi-plugin-python3 \
   uwsgi-plugin-tornado-python3 \
   php-fpm \
   nodejs \
   npm \
   nodeenv

# Create user
id -u $PAAS_USERNAME &>/dev/null || \
sudo adduser --disabled-password --gecos 'PaaS access' --ingroup www-data $PAAS_USERNAME

# copy your public key to /tmp (assuming it's the first entry in authorized_keys)
head -1 ~/.ssh/authorized_keys > /tmp/pubkey
# install polybox and have it set up SSH keys and default files
sudo su - $PAAS_USERNAME -c "curl -s https://raw.githubusercontent.com/$REPO/$BRANCH/polybox.py > polybox.py && python3 ~/polybox.py init && python3 ~/polybox.py set-ssh /tmp/pubkey"
rm /tmp/pubkey

sudo rm -f /etc/uwsgi/apps-enabled/polybox.ini
sudo ln /home/$PAAS_USERNAME/.polybox/uwsgi/uwsgi.ini /etc/uwsgi/apps-enabled/polybox.ini
sudo systemctl restart uwsgi

cd /tmp
curl -s https://raw.githubusercontent.com/$REPO/$BRANCH/incron.conf > incron.conf
curl -s https://raw.githubusercontent.com/$REPO/$BRANCH/nginx.conf > nginx.conf
curl -s https://raw.githubusercontent.com/$REPO/$BRANCH/master/index.polybox.html > index.polybox.html
sudo cp /tmp/nginx.conf /etc/nginx/sites-available/default
sudo cp /tmp/incron.conf /etc/incron.d/polybox
sudo cp /tmp/index.polybox.html /var/www/html
sudo systemctl restart nginx

echo ""
echo "Polybox installation complete!"
