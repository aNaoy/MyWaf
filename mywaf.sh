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
    echo "$0 [add VHOST IP | del VHOST]"
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