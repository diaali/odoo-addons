#!/bin/bash
# Mit diesem Skript installiert Odoo unter /opt/odoo und bindet es in den Autostart ein
# Skript muss mit root-Rechten ausgeführt werden
##############################################################################
#
#    Shell Script for Odoo, Open Source Management Solution
#    Copyright (C) 2014-now Equitania Software GmbH(<http://www.equitania.de>).
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

myscriptpath="$PWD"
mybasepath="/opt/odoo"
mysourcepath=$mybasepath"/odoo"
myserverpath=$mybasepath"/odoo-server"
myaddpath=$mybasepath"/odoo-addons"

echo "Basepath: "$mybasepath
echo "Sourcepath: "$mysourcepath
echo "Serverpath: "$myserverpath
echo "odoo-addons path: "$myaddpath

echo "Prepare PostgreSQL"
adduser odoo --home /opt/odoo

echo "Geben Sie das Passwort für den User odoo innerhalb der PostgreSQL an:"
read myodoopwd

if [ "$myodoopwd" != "" ]; then
  echo "PostgreSQL Passwort odoo wird gesetzt..."
  su postgres -c "psql --command \"CREATE USER odoo WITH PASSWORD '$myodoopwd'\""
  su postgres -c "psql --command \"ALTER USER odoo CREATEDB\""
fi

echo "Geben Sie das Passwort für den User postgres innerhalb der PostgreSQL an:"
read mypsqlpwd

if [ "$mypsqlpwd" != "" ]; then
  echo "PostgreSQL Passwort postgres wird gesetzt..."
  su postgres -c "psql --command \"ALTER USER postgres WITH PASSWORD '$mypsqlpwd'\""
fi



mkdir $myserverpath
echo "Create odoo-server"

cp -r $mysourcepath/addons $myserverpath
echo "Copy addons..."
#cp -r $mysourcepath/debian $myserverpath
#echo "Copy debian..."
cp -r $mysourcepath/doc $myserverpath
echo "Copy doc..."
cp -r $mysourcepath/openerp $myserverpath
echo "Copy openerp..."
#cp -r $mysourcepath/setup $myserverpath
#echo "Copy setup..."
cp  $mysourcepath/odoo.py $myserverpath
echo "Copy files..."
cp  $mysourcepath/openerp-gevent $myserverpath
cp  $mysourcepath/openerp-server $myserverpath
cp  $mysourcepath/openerp-wsgi.py $myserverpath
#cp  $mysourcepath/setup.py $myserverpath
#cp  $mysourcepath/setup.cfg $myserverpath

echo "Copy equitania addons"
# odoo-addons
cp -r $myaddpath/eq_no_ad $myserverpath/addons
cp -r $myaddpath/equitania $myserverpath/addons
cp -r $myaddpath/eq_mail_extension $myserverpath/addons

echo "Insert the password for the databasemanager | Geben Sie das Passwort für den Databasemanager ein:"
read myadminpwd

old="'admin_passwd': 'admin'"
new="'admin_passwd': '$myadminpwd'"

echo "Changing databasemanager password.."
cp  $myserverpath/openerp/tools/config.py $mybasepath/config.py
sed -i "s/$old/$new/g" $mybasepath/config.py
cp  $mybasepath/config.py $myserverpath/openerp/tools

echo "Preparing favicon for later exchange.."
cp  $myserverpath/addons/web/static/src/img/favicon.ico $mybasepath/ 

echo "Changing rights.."
chown -R odoo:odoo $myserverpath 
chown -R odoo:odoo $mysourcepath 
chown -R odoo:odoo $mybasepath 

cp $myscriptpath/server-install-helpers/odoo-server.conf /etc/odoo-server.conf
chown odoo:odoo /etc/odoo-server.conf
chmod 640 /etc/odoo-server.conf
mkdir /var/log/odoo
chown odoo:root /var/log/odoo
cp $myscriptpath/server-install-helpers/logrotate /etc/logrotate.d/odoo-server
chmod 755 /etc/logrotate.d/odoo-server
cp $myscriptpath/server-install-helpers/odoo.init.d /etc/init.d/odoo-server
chmod +x /etc/init.d/odoo-server
update-rc.d odoo-server defaults

echo "Do you want to use standard port 80 against 8069 and install nginx | Wollen Sie eine Port-Umleitung auf Standard Port 80 und nginx installieren [Y/n]:"
read myport

if [ "$myport" = "Y" ]; then
  echo "nginx will be install..."
  apt-get install nginx  
  cp $myscriptpath/server-install-helpers/odoo.nginx /etc/nginx/sites-available/odoo.nginx
  rm /etc/nginx/sites-enabled/default 
  ln -s /etc/nginx/sites-available/odoo.nginx /etc/nginx/sites-enabled/odoo.nginx
  mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
  cp $myscriptpath/server-install-helpers/nginx.conf /etc/nginx/nginx.conf
else
  echo "nginx is not installed!"
fi

echo "Finished!"
