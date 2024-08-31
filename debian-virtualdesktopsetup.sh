#!/bin/bash


# Create new user
echo -n "Enter new user name:"
read newusername
adduser $newusername --gecos ""
usermod -aG sudo $newusername
echo $newusername' ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Install stuff
apt-get update
apt-get upgrade
apt-get --yes --force-yes install htop git vim curl wget firefox-esr
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --prefix=/usr/local --unattended
su -c 'touch ~/.hushlogin' $newusername

# Uncomment to install desktop envrionment
# tasksel install desktop
