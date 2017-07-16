#!/bin/bash -e

# HomeBridge

# Updates
sudo apt-get update
sudo apt-get upgrade
sudo apt-get autoremove

# Install git
sudo apt-get install git make

# Install node
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential

# Install dependencies
sudo apt-get install -y avahi-utils
sudo apt-get install -y build-essential
sudo apt-get install -y chkconfig
sudo apt-get install -y libao-dev
sudo apt-get install -y libavahi-client-dev
sudo apt-get install -y libavahi-compat-libdnssd-dev
sudo apt-get install -y libcrypt-openssl-rsa-perl
sudo apt-get install -y libio-socket-inet6-perl
sudo apt-get install -y libssl-dev
sudo apt-get install -y libwww-perl
sudo apt-get install -y pkg-config

# Install HomeBridge
sudo npm install -g --unsafe-perm homebridge hap-nodejs node-gyp
cd /usr/local/lib/node_modules/homebridge/
sudo npm install --unsafe-perm bignum
cd -
cd /usr/local/lib/node_modules/hap-nodejs/node_modules/mdns
sudo node-gyp BUILDTYPE=Release rebuild
cd -

# Install HomeBridge plugins
sudo npm install -g homebridge-nest

# Install ShairPort
git clone -b 1.0-dev git://github.com/abrasive/shairport.git
cd shairport
sudo ./configure
sudo make
sudo make install
cd -
sudo rm -rf shairport

# HomeBridge daemon options
sudo cat << EOF > /etc/default/homebridge
HOMEBRIDGE_OPTS=-U /var/homebridge
EOF

# AirPlay daemon options
sudo cat << EOF > /etc/default/airplay
AIRPLAY_OPTS=-a 'HomeBridge'
EOF

# HomeBridge daemon
sudo cat << EOF > /etc/systemd/system/homebridge.service
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

# AirPlay daemon
sudo cat << EOF > /etc/systemd/system/airplay.service
[Unit]
Description=AirPlay
After=syslog.target network-online.target

[Service]
Type=simple
User=airplay
EnvironmentFile=/etc/default/airplay
ExecStart=/usr/bin/shairport $AIRPLAY_OPTS
Restart=on-failure
RestartSec=2
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# Add users
useradd --system homebridge
useradd --system airplay
mkdir /var/homebridge
mkdir /var/airplay

username=sudo cat /sys/class/net/eth0/address

# HomeBridge configuration
sudo cat << EOF > /var/homebridge/config.json
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

# And away we go...
sudo systemctl daemon-reload
sudo systemctl enable homebridge
sudo systemctl enable airplay
sudo systemctl start homebridge
sudo systemctl start airplay

exit
