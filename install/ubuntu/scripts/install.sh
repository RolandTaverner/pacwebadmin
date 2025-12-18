#!/bin/bash

adduser --system --no-create-home --disabled-login --group pacwebadmin

# Copy executable
cp pacwebadmin /usr/bin/
echo "Copied pacwebadmin to /usr/bin/pacwebadmin"

# Create data directories and write initial config
baseDataDir="/var/lib/pacwebadmin"
mkdir -p "${baseDataDir}"
mkdir -p "${baseDataDir}/data"
mkdir -p "${baseDataDir}/save"
mkdir -p "${baseDataDir}/servecache"
echo "Created data dir at ${baseDataDir}"

cat << 'EOF' > "${baseDataDir}/data/data.json"
{
    "category": [
    ],
    "condition": [
    ],
    "pac": [
    ],
    "proxy": [
        {
            "id": 1,
            "value": {
                "address": "",
                "description": "Connect to the destination server without using a proxy",
                "type": "DIRECT"
            }
        },
        {
            "id": 2,
            "value": {
                "address": "127.0.0.1:0",
                "description": "Ban (invalid proxy address)",
                "type": "HTTP"
            }
        }		
    ],
    "proxyRule": [
    ]
}
EOF
chown pacwebadmin:pacwebadmin -R "${baseDataDir}/"
echo "Created initial data file at ${baseDataDir}/data/data.json"

# Create log dir
logDir="/var/log/pacwebadmin"
mkdir -p "${logDir}"
chown pacwebadmin:pacwebadmin "${logDir}"
echo "Created log dir at ${logDir}"

# Create directory for www content and copy files there
wwwDir="/var/www/pacwebadmin"
mkdir -p "${wwwDir}"
echo "Created www dir at ${wwwDir}"

cp -R dist/* "${wwwDir}/"
chown pacwebadmin:pacwebadmin -R "${wwwDir}"
echo "Copied www files to to ${wwwDir}"

# Create config dir
confDir="/etc/pacwebadmin"
mkdir -p "${confDir}"
chown pacwebadmin:pacwebadmin "${confDir}"
echo "Created configuration dir at ${confDir}"

# Create config file (attention: must be executed after all variables initialized)
cat << EOF > "${confDir}/pacwebadmin.conf"
bindAddresses = ::,0.0.0.0
port = 80
servePath = "/pac/"
dataDir = "${baseDataDir}/data"
saveDir = "${baseDataDir}/save"
serveCacheDir = "${baseDataDir}/servecache"
logDir = "${logDir}"
accessLogToConsole = false
wwwDir = "${wwwDir}"
authEnable = true
authUsersFile = "${confDir}/users"
EOF

chown pacwebadmin:pacwebadmin "${confDir}/pacwebadmin.conf"
echo "Created config file at ${confDir}/pacwebadmin.conf"

cat << EOF > "${confDir}/users"
admin:8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918:rw
user:04f8996da763b7a969b1028ee3007569eaf3a635486ddab211d512c85b9df8fb:r
EOF

chown pacwebadmin:pacwebadmin "${confDir}/users"
echo "Created users file at ${confDir}/users"

cat << EOF > /etc/systemd/system/pacwebadmin.service
[Unit]
Description=PAC web admin
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/pacwebadmin --config ${confDir}/pacwebadmin.conf
User=pacwebadmin
Group=pacwebadmin
ExecStop=killall -w -q pacwebadmin
# Other service options like WorkingDirectory, Environment, etc.

[Install]
WantedBy=multi-user.target
EOF

echo "Created systemd unit at /etc/systemd/system/pacwebadmin.service"

systemctl daemon-reload
systemctl enable pacwebadmin
systemctl start pacwebadmin

systemctl status pacwebadmin
