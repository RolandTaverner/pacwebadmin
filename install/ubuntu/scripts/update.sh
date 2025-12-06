#!/bin/bash

systemctl stop pacwebadmin

wwwDir="/var/www/pacwebadmin"
rm -rf "${wwwDir}/*"

cp -R ./dist/* "${wwwDir}/"
chown pacwebadmin:pacwebadmin -R "${wwwDir}"

rm -f /usr/bin/pacwebadmin
cp pacwebadmin /usr/bin/

systemctl start pacwebadmin
systemctl status pacwebadmin
