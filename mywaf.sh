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

function usage {
	echo "[*] MyWaf usage:"
    echo "[*] $0 [add VHOST IP | del VHOST]   Add/delete selected VHOST"
	echo "[*] $0 list                         List enabled VHOST"
	echo "[*] $0 learn VHOST				  Set the VHOST in learning mode"
}

function addVhost {
	if [ ! -f /etc/nginx/$1.whitelist ]; then
		> /etc/nginx/$1.whitelist
	fi
    sed s/VHOST/$1/ /usr/local/mywaf/vhost.tpl > /etc/nginx/sites-available/$1.mywaf
    sed -i s/IP/$2/ /etc/nginx/sites-available/$1.mywaf
	ln -s /etc/nginx/sites-available/$1.mywaf /etc/nginx/sites-enabled/$1.mywaf
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
		/etc/init.d/nginx reload
    fi
}

function delVhost {
	if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
		echo "This VHOST does not exist."
		exit 1
	fi
    rm /etc/nginx/sites-available/$1.mywaf
    rm /etc/nginx/sites-enabled/$1.mywaf
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
		/etc/init.d/nginx reload
    fi
}

function startLearn {
	if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
		echo "This VHOST does not exist."
		exit 1
	fi
	sed '12 s/#//' /etc/nginx/sites-available/$1.mywaf
	sed '41 s/return 444/proxy_pass http:\/\/$1.nginx_backend/' /etc/nginx/sites-available/$1.mywaf
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
		/etc/init.d/nginx reload
    fi
}

function stopLearn {
	if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
		echo "This VHOST does not exist."
		exit 1
	fi
	sed '12 s/Lea/#Lea/' /etc/nginx/sites-available/$1.mywaf
	sed '41 s/proxy_pass http:\/\/$1.nginx_backend/return 444/' /etc/nginx/sites-available/$1.mywaf
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
		/etc/init.d/nginx reload
    fi
}

function listVhost {
	if [ -f /etc/nginx/sites-available/*.mywaf ]; then
		echo "[*] VHOST list:"
		for f in /etc/nginx/sites-available/*.mywaf; do
			echo $f | cut -d/ -f5 | cut -d. -f1
		done
	else
		echo "[*] No VHOST configured on this WAF"
	fi
}

case "$1" in
    'add')
		if [ $# -eq 3 ]; then
			addVhost $2 $3
		else
			usage
		fi
        ;;
    'del')
		if [ $# -eq 2 ]; then
				delVhost $2
		else
			usage
		fi
		;;
	'list')
		if [ $# -gt 1 ]; then
			usage
		else
			listVhost
		fi
		;;
	'learn')
		if [ $# -eq 2 ]; then
			startLearn $2
		else
			usage
		fi
		;;
	*)
        usage
        ;;
esac