#!/bin/bash

echo -n "Enter new user name:"
read newusername

adduser $newusername --gecos ""
usermod -aG sudo $newusername
echo $newusername' ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

su $newusername

apt-get update
apt-get --yes --force-yes install iftop htop iotop traceroute git openssh-server vim curl wget lynx 

bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --prefix=/usr/local --unattended
touch ~/.hushlogin

# tasksel install desktop
apt --yes --force-yes install gnome-tweak-tool font-manager xsel aspell-en firefox-esr 
