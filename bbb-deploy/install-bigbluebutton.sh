#!/bin/bash

# Add the BigBlueButton key
wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | sudo apt-key add -

# Add the BigBlueButton repository URL and ensure the multiverse is enabled
echo "deb http://ubuntu.bigbluebutton.org/lucid_dev_08/ bigbluebutton-lucid main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ lucid multiverse" | sudo tee -a /etc/apt/sources.list

sudo aptitude update
sudo aptitude -y full-upgrade
sudo aptitude -y install htop iftop

chmod +x install-ruby.sh
./install-ruby.sh

sudo aptitude install -y bigbluebutton bbb-demo

chmod +x enable-mobile-fs.sh
./enable-mobile-fs.sh

sudo bbb-conf --clean
sudo bbb-conf --check

chmod +x install-notes.sh
./install-notes.sh

echo "Starting the live notes server for the first time. It may take a while"
echo "When it's compiled and running, use Ctrl + C to quit"
live-notes-server.sh


