#!/bin/bash

chmod +x install-ruby.sh
./install-ruby.sh

# Add the BigBlueButton key
wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | sudo apt-key add -

# Add the BigBlueButton repository URL and ensure the multiverse is enabled
echo "deb http://ubuntu.bigbluebutton.org/lucid_dev_08/ bigbluebutton-lucid main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ lucid multiverse" | sudo tee -a /etc/apt/sources.list

echo "Updating the Ubuntu package repository"
sudo apt-get update > /dev/null
sudo apt-get -y dist-upgrade
sudo apt-get -y install bigbluebutton bbb-demo
