#!/bin/bash -e

# HomeBridge.

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git make

curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential

sudo apt-get install libavahi-compat-libdnssd-dev

sudo npm install -g --unsafe-perm homebridge hap-nodejs node-gyp
cd /usr/lib/node_modules/homebridge/
sudo npm install --unsafe-perm bignum
cd /usr/lib/node_modules/hap-nodejs/node_modules/mdns
sudo node-gyp BUILDTYPE=Release rebuild

Sudo nom install -g homebridge-nest

cat << EOF > /etc/default/homebridge
HOMEBRIDGE_OPTS=-U /var/homebridge
EOF

cat << EOF > /etc/default/homebridge
[Unit]
Description=HomeBridge
After=syslog.target network-online.target

[Service]
Type=simple
User=homebridge
EnvironmentFile=/etc/default/homebridge
ExecStart=/usr/local/bin/homebridge $HOMEBRIDGE_OPTS
Restart=on-failure
RestartSec=2
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

useradd --system homebridge
mkdir /var/homebridge

username=cat /sys/class/net/eth0/address

Cat << EOF > /var/homebridge/config.json
{
	"bridge": {
		"name": "HomeBridge",
		"username": "$username",
		"port": 51826,
		"pin": "466-32-743"
	},
	"accessories": [],
	"platforms": []
}
EOF

systemctl daemon-reload
systemctl enable homebridge
systemctl start homebridge