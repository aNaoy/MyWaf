#!/bin/bash

function usage {
    echo "$0 [add VHOST IP] [del VHOST]"
}

function addVhost {
    sed s/VHOST/$1 /usr/local/mywaf/vhost.tpl > /etc/nginx/sites-available/$1
    sed -i s/IP/$2 /etc/nginx/sites-available/$1
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
	/etc/init.d/nginx reload
    fi
}

function delVhost {
    rm /etc/nginx/sites-available/$1
    /etc/init.d/nginx configtest
    if [ $? -eq 0 ]; then
	/etc/init.d/nginx reload
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
      *)
        usage
        ;;
esac