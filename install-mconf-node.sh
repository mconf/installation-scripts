#!/bin/bash

# THIS SCRIPT IS DEPRECIATED, SEE http://code.google.com/p/mconf/wiki/MconfLive

function print_usage
{
	echo "Usage:"
	echo "    $0 <domain_name>"
	exit 1
}

if [ `lsb_release --description | grep 'Ubuntu 10.04' | wc -l` -eq 0 ]
then
    echo "A Mconf node MUST BE a fresh installation of Ubuntu 10.04 Server"
    exit 1
fi

if [ `whoami` == "root" ]
then
    echo "This script shouldn't be executed as root"
    exit 1
fi

if [ $# -ne 1 ]
then
	print_usage
fi

echo "Updating the Ubuntu package repository"
sudo apt-get update > /dev/null
sudo apt-get -y install git-core htop iftop ant curl

mkdir -p ~/tools
cd ~/tools
if [ -d "installation-scripts" ]
then
    cd installation-scripts
    git pull origin master
    cd ..
else
    git clone git://github.com/mconf/installation-scripts.git
fi
cd installation-scripts/bbb-deploy/

chmod +x install-bigbluebutton.sh
./install-bigbluebutton.sh
sudo bbb-conf --setip $1

chmod +x install-notes.sh
./install-notes.sh

VERSION=$(curl http://mconf.org:8888/mconf-node/current.txt)
wget -O bigbluebutton.zip "http://mconf.org:8888/mconf-node/$VERSION"
sudo ant -f deploy_target.xml deploy

chmod +x mconf-presentation.sh
./mconf-presentation.sh

chmod +x enable-mobile-fs.sh
./enable-mobile-fs.sh

echo "Restart the server to finish the installation"
echo "It will take a while to start the live notes server, please be patient"
