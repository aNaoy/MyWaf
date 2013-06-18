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
    echo "[*] $0 [add VHOST IP | del VHOST]       Add/delete selected VHOST"
    echo "[*] $0 list                             List enabled VHOST"
    echo "[*] $0 [learn VHOST | stoplearn VHOST]  Enable/disable learning mode on VHOST"
    echo "[*] $0 understand VHOST                 Process whitelist from logs (CARE if you've ALREADY been ATTACKED!)"
    echo "[*] $0 [strictlearn VHOST | stopstrictlearn VHOST]"
    echo "[*]                                     Enable/disable strict learning mode on VHOST"
    echo "[*] $0 [strict VHOST | unstrict VHOST]  Enable/disable strict mode on VHOST"
}

function addVhost {
    if [ -f /etc/nginx/sites-available/$1.mywaf ]; then
	echo "[*] This VHOST already exists."
	exit 1
    fi
    if [ ! -f /etc/nginx/$1.whitelist ]; then
	> /etc/nginx/$1.whitelist
    fi
    sed s/VHOST/$1/ /usr/local/mywaf/vhost.tpl > /etc/nginx/sites-available/$1.mywaf
    sed -i s/IP/$2/ /etc/nginx/sites-available/$1.mywaf
    ln -s /etc/nginx/sites-available/$1.mywaf /etc/nginx/sites-enabled/$1.mywaf
    echo "[*] VHOST $1 added in basic mode."
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
	/etc/init.d/nginx reload
    fi
}

function delVhost {
    if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
	echo "[*] This VHOST does not exist."
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
	echo "[*] This VHOST does not exist."
	exit 1
    fi
    sed -i '12 s/#//' /etc/nginx/sites-available/$1.mywaf
    sed -i '45 s/return 444/proxy_pass http:\/\/$1.nginx_backend/' /etc/nginx/sites-available/$1.mywaf
    echo "[*] Learning mode enabled."
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
	/etc/init.d/nginx reload
    fi
}

function stopLearn {
    if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
	echo "[*] This VHOST does not exist."
	exit 1
    fi
    sed -i '12 s/Lea/#Lea/' /etc/nginx/sites-available/$1.mywaf
    sed -i '45 s/proxy_pass http:\/\/$1.nginx_backend/return 444/' /etc/nginx/sites-available/$1.mywaf
    echo "[*] Basic mode enabled."
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
	/etc/init.d/nginx reload
    fi
}

function startStrictLearn {
    if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
	echo "[*] This VHOST does not exist."
        exit 1
    fi
    sed -i '12 s/#//' /etc/nginx/sites-available/$1.mywaf
    sed -i '45 s/return 444/proxy_pass http:\/\/$1.nginx_backend/' /etc/nginx/sites-available/$1.mywaf
    sed -i '12 s/inc/#inc/' /etc/nginx/nginx.conf
    echo "[*] Strict learning mode enabled."
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
        /etc/init.d/nginx reload
    fi
}

function stopStrictLearn {
    if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
        echo "[*] This VHOST does not exist."
        exit 1
    fi
    sed -i '12 s/Lea/#Lea/' /etc/nginx/sites-available/$1.mywaf
    sed -i '45 s/proxy_pass http:\/\/$1.nginx_backend/return 444/' /etc/nginx/sites-available/$1.mywaf
    sed-i '12 s/#inc/inc/' /etc/nginx/nginx.conf
    echo "[*] Basic mode enabled."
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
        /etc/init.d/nginx reload
    fi
}

function strictMode {
    if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
        echo "[*] This VHOST does not exist."
        exit 1
    fi
    sed -i '13 s/Sec/#Sec/' /etc/nginx/sites-available/$1.mywaf
    sed -i '14 s/#Sec/Sec/' /etc/nginx/sites-available/$1.mywaf
    echo "[*] Strict mode enabled."
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
        /etc/init.d/nginx reload
    fi
}

function basicMode {
    if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
        echo "[*] This VHOST does not exist."
        exit 1
    fi
    sed -i '13 s/#Sec/Sec/' /etc/nginx/sites-available/$1.mywaf
    sed -i '14 s/Sec/#Sec/' /etc/nginx/sites-available/$1.mywaf
    echo "[*] Basic mode enabled."
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
        /etc/init.d/nginx reload
    fi
}

function underStand {
    if [ ! -f /etc/nginx/sites-available/$1.mywaf ]; then
	echo "[*] This VHOST does not exist."
        exit 1
    fi
    nx_util -o -l /var/log/nginx/$1.error.log -c /usr/local/mywaf/nx_util.conf -d $1.db >> /etc/nginx/$1.whitelist
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
        /etc/init.d/nginx reload
    fi
}

function listVhost {
    if [ -f /etc/nginx/sites-available/*.mywaf ]; then
	echo "[*] VHOST list:"
	for f in /etc/nginx/sites-available/*.mywaf; do
	    temp=`echo $f | cut -d/ -f5`
	    echo ${temp%.mywaf}
	done
    else
	echo "[*] No VHOST configured on this WAF."
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
	if [ $# -ne 1 ]; then
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
    'stoplearn')
        if [ $# -eq 2 ]; then
            stopLearn $2
        else
            usage
        fi
        ;;
    'understand')
	if [ $# -eq 2 ]; then
	    underStand $2
	else
	    usage
	fi
	;;
    'strictlearn')
        if [ $# -eq 2 ]; then
            startStrictLearn $2
        else
            usage
        fi
        ;;
    'stopstrictlearn')
	if [ $# -eq 2 ]; then
            stopStrictLearn $2
        else
            usage
        fi
        ;;
    'strict')
        if [ $# -eq 2 ]; then
            strictMode $2
	else
            usage
	fi
        ;;
    'unstrict')
	if [ $# -eq 2 ]; then
            basicMode $2
        else
            usage
        fi
        ;;
    *)
        usage
        ;;
esac