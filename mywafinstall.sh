#!/bin/bash

# (c) Yoan AGOSTINI <yoan {DOT IS HERE} agostini {AT IS HERE} gmail {DOT IS HERE} com>
# (c) Ronan LEBON
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
        echo "[*] Installation du WAF :"
        # packages
        echo "[*] - Installation des packages"
        apt-get -y purge exim4-base exim4-config exim4-daemon-light
        apt-get install -y tcpdump portmap nfs-server
        apt-get install -y libfile-tail-perl
        apt-get -y install python-dev python-pip
        pip install glances
        # optimisations
        echo "[*] - Optimisations systeme"
        echo "* - nofile 65536" > /etc/security/limits.conf
        # Nginx + Naxsi
        echo "[*] - Installation de nginx & naxsi"
        echo "deb http://ftp.debian.org/debian/ wheezy-backports main" >> /etc/apt/sources.list
        apt-get update  
        apt-get -y --force-yes -t wheezy-backports install nginx-naxsi
		echo "[*] - Installation de MyWaf"
		if [ ! -d /usr/local/mywaf]; then
			mkdir -p /usr/local/mywaf
		fi
		apwd=`pwd`
		cd /usr/local/mywaf
		wget https://raw.github.com/aNaoy/MyWaf/master/mywaf.sh
		wget https://raw.github.com/aNaoy/MyWaf/master/sysctl.conf
		wget https://raw.github.com/aNaoy/MyWaf/master/vhost.tpl
		wget https://raw.github.com/aNaoy/MyWaf/master/README.md
		chmod +x mywaf.sh
		ln -s mywaf.sh /usr/local/bin/
		cd apwd
		echo "[*] - Configuration et optimisation"
		# Optimisation de nginx
        echo 'ULIMIT="-n 65536"' >> /etc/default/nginx
        ## Netfilter / FW / iptables
        apt-get -y install iptables module-assistant xtables-addons-common;
        module-assistant --verbose --text-mode auto-install xtables-addons;
        # No DNS
        update-rc.d bind9 remove
        # Hostname
        hostname MyWaf
        echo "127.0.0.1 mywaf" >> /etc/hosts
        hostname > /etc/hostname
        ## Ajout de la whitelist WAF
        echo "127.0.0.1" > /usr/local/etc/waf_whitelist.txt
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

installMyWaf