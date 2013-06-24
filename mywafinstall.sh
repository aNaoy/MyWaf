#!/bin/bash

# (c) Yoan AGOSTINI <yoan {DOT IS HERE} agostini {AT IS HERE} gmail {DOT IS HERE} com>
# (c) Ronan LEBON <ronan {DOT IS HERE} lebon {AT IS HERE} gmail {DOT IS HERE} com>
# (c) Ingesup

# MyWaf is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
# MyWaf is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with MyWaf.
# If not, see http://www.gnu.org/licenses/.

function installMyWaf {
	echo "[*********************]"
	echo "[*]   WAF installation"
	echo "[*********************]"
        # packages
	echo "[*********************]"
	echo "[*] - Packages install"
	echo "[*********************]"
	apt-get update && apt-get -y purge exim4-base exim4-config exim4-daemon-light && apt-get install -y tcpdump portmap \
	    && apt-get -y install python-dev python-pip && pip install glances
        # optimisations
	echo "[******************]"
	echo "[*] - System tweaks" 
	echo "[******************]"
	echo "* - nofile 65536" > /etc/security/limits.conf
        # Nginx + Naxsi
	echo "[**************************]"
	echo "[*] - Nginx & Naxsi install"
	echo "[**************************]"
	echo "deb http://ftp.debian.org/debian/ wheezy-backports main" >> /etc/apt/sources.list
	apt-get update  
	apt-get -y --force-yes -t wheezy-backports install nginx-naxsi
	echo "[**************************]"
	echo "[*] - MyWaf command install"
	echo "[**************************]"
	if [ ! -d /usr/local/mywaf ]; then
		mkdir -p /usr/local/mywaf
	fi
	wget -P /usr/local/mywaf https://raw.github.com/aNaoy/MyWaf/master/mywaf.sh
	wget -P /usr/local/mywaf https://raw.github.com/aNaoy/MyWaf/master/sysctl.conf
	wget -P /usr/local/mywaf https://raw.github.com/aNaoy/MyWaf/master/vhost.tpl
	wget -P /usr/local/mywaf https://raw.github.com/aNaoy/MyWaf/master/README.md
	wget -P /usr/local/mywaf https://raw.github.com/aNaoy/MyWaf/master/naxsi_core.rules
	wget -P /usr/local/mywaf https://raw.github.com/aNaoy/MyWaf/master/LICENSE
	cp /usr/local/mywaf/naxsi_core.rules /etc/nginx/naxsi_core.rules
	chmod +x /usr/local/mywaf/mywaf.sh
	ln -s /usr/local/mywaf/mywaf.sh /usr/local/bin/mywaf
	wget -P /usr/local/mywaf https://naxsi.googlecode.com/files/nx_util-1.0.tgz
	tar xvzf /usr/local/mywaf/nx_util-1.0.tgz -C /usr/local/mywaf
	mv /usr/local/mywaf/nx_util-1.0/nx_util/* /usr/local/mywaf/
	chmod +x /usr/local/mywaf/nx_util.py
	ln -s /usr/local/mywaf/nx_util.py /usr/local/bin/nx_util
	wget -O /usr/local/mywaf/nx_util.conf https://raw.github.com/anaoy/mywaf/master/nx_util.conf
	echo "[***************************]"
	echo "[*] - Configuration & tuning"
	echo "[***************************]"
	# Optimisation de nginx
	echo 'ULIMIT="-n 65536"' >> /etc/default/nginx
        # No DNS
	update-rc.d bind9 remove
        # Hostname
	hostname MyWaf
	echo "127.0.0.1 mywaf" >> /etc/hosts
	hostname > /etc/hostname
 	# Configuration d'Nginx
	sed -i '10 a\
	include /etc/nginx/naxsi_core.rules;' /etc/nginx/nginx.conf
	sed -i '10 a\
	proxy_cache_path /var/cache/nginx/ levels=1:2 keys_zone=big:10m max_size=2G;' /etc/nginx/nginx.conf
	/etc/init.d/nginx start
}

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

installMyWaf