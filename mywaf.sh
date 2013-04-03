#!/bin/bash

function addVhost {
    sed s/VHOST/$1 /usr/local/mywaf/vhost.tpl > /etc/nginx/sites-available/$1
    sed -i s/IP/$2 /etc/nginx/sites-available/$1
    if [[ /etc/init.d/nginx configtest ]]; then
        /etc/init.d/nginx reload
    fi
}
