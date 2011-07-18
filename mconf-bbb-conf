#!/bin/bash

BBB_SOURCE=~/dev/source/bigbluebutton
MCONF_REPOS=git://github.com/mconf/bigbluebutton.git

## http://stackoverflow.com/questions/59838/how-to-check-if-a-directory-exists-in-a-bash-shell-script
#if [ ! -d "$BBB_SOURCE" ]; then
if [ true ]; then
    echo '#########################################################'
    echo '# Installing and configuring Mconf BigBlueButton server #'
    echo '#########################################################'

    sudo apt-get -y install python-software-properties 
    sudo add-apt-repository ppa:freeswitch-drivers/freeswitch-nightly-drivers
    sudo apt-get update
    sudo apt-get -y install bbb-freeswitch-config

# \todo uncomment this two lines!!!
#    echo '## Clone the mconf repository'
#    bbb-conf --checkout $MCONF_REPOS

    ## http://bash.cyberciti.biz/misc-shell/read-local-ip-address/
    IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;
#    echo '## Set IP on BigBlueButton'
#    sudo bbb-conf --setip $IP

    echo '## Setup development environment for the client'
    bbb-conf --setup-dev client
    cd $BBB_SOURCE/bigbluebutton-client

    echo '## Configure the config.xml on the client'
    cp resources/config.xml.template src/conf/config.xml
    sed -i "s/HOST/$IP/g" src/conf/config.xml
    sed -i "s/VERSION/3818/g" src/conf/config.xml
    ## compile the client
    ant

    echo '## Setup development environment for the apps'
    bbb-conf --setup-dev apps
    echo '## Stop red5'
    sudo service red5 stop
    echo '## Add FLAT_REPO variable'
    if [ `grep 'export FLAT_REPO' ~/.profile | wc -l` -eq 0 ]; then
	echo 'export FLAT_REPO=~/dev/repo' >> ~/.profile
	source ~/.profile
    fi
    cd $BBB_SOURCE/bigbluebutton-apps
    echo '## Compile bigbluebutton-apps'
    gradle war deploy
#    sudo service red5 start

    cd $BBB_SOURCE/bbb-voice
    echo '## Compile bbb-voice'
    gradle war deploy

    sudo sed -i "s/global_codec_prefs=PCMU,G722,PCMA,GSM/global_codec_prefs=speex@16000h@20i/g" /opt/freeswitch/conf/vars.xml
    sudo sed -i "s/outbound_codec_prefs=PCMU,G722,PCMA,GSM/outbound_codec_prefs=speex@16000h@20i/g" /opt/freeswitch/conf/vars.xml

    sudo bbb-conf --clean

    return 0
else
    echo '#######################################'
    echo '# Updating Mconf BigBlueButton server #'
    echo '#######################################'

    if [ `grep $MCONF_REPOS $BBB_SOURCE/.git/config | wc -l` -eq 0 ]; then
	echo '# Error: this is not a Mconf BigBlueButton installation'
	return -1
    fi

    echo 'OK'
    
    return 0
fi
