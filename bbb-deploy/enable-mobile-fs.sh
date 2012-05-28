#!/bin/bash

# enable the straight voice connection between the Android client (or any other external caller) and the FreeSWITCH server
# http://code.google.com/p/bigbluebutton/issues/detail?id=1133
HOST=$(ifconfig | grep -v '127.0.0.1' | grep -E "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | head -1 | cut -d: -f2 | awk '{ print $1}')
sudo sed -i "s:sip\.server\.host=.*:sip.server.host=$HOST:g" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
sudo sed -i "s:\([ ]*\)<\(X-PRE-PROCESS.*local_ip_v4=[^>]*\)>:\1<\!--\2-->:g" /opt/freeswitch/conf/vars.xml
sudo sed -i "s:\([ ]*\)<\(param.*name=\"ext-rtp-ip\"[^\"]*\"\)\([^\"]*\)\([^>]*\)>:\1<\2auto-nat\4>:g" /opt/freeswitch/conf/sip_profiles/external.xml
sudo sed -i "s:\([ ]*\)<\(param.*name=\"ext-sip-ip\"[^\"]*\"\)\([^\"]*\)\([^>]*\)>:\1<\2auto-nat\4>:g" /opt/freeswitch/conf/sip_profiles/external.xml

# disable the comfort noise
sudo sed -i "s:\([ ]*\)<\(param.*name=\"comfort-noise\"[^\"]*\"\)\([^\"]*\)\([^>]*\)>:\1<\2false\4>:g" /opt/freeswitch/conf/autoload_configs/conference.conf.xml

