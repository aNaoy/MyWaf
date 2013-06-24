MyWaf
=====

My enterprise open-source Web Application Firewall


0) License
----------

MyWaf is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

MyWaf is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with MyWaf. If not, see http://www.gnu.org/licenses/.

1) Overview
-----------

MyWaf is a set of scripts intended to ease the installation and configuration of a Web Application Firewall on a Linux/Debian Wheezy distribution.

2) Installation
---------------

In a shell:

```bash
$ wget https://raw.github.com/anaoy/mywaf/master/mywafinstall.sh
$ chmod +x mywafinstall.sh
$ sudo ./mywafinstall.sh
```

3) Usage
--------

In order to have a working WAF, you have to:

1. Add a VHOST

2. Start learning mode on this VHOST

3. Make every legit user inputs possible on the site (modifying hosts file, we recommand to publish DNS entry after the whole process)

4. Stop learning mode on the VHOST

5. Understand the rules

6. You're done!

```bash
MyWaf usage:
------------

mywaf [add VHOST IP | del VHOST]       Add/delete selected VHOST
mywaf list                             List enabled VHOST
mywaf [learn VHOST | stoplearn VHOST]  Enable/disable learning mode on VHOST
mywaf understand VHOST                 Process whitelist from logs (CARE if you've 
      		 		       ALREADY been ATTACKED!)
```