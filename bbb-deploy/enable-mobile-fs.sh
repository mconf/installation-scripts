#!/bin/bash

# It will enable the direct voice connection between the Android client and the FreeSWITCH server
HOST=$(ifconfig | grep -v '127.0.0.1' | grep -E "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | head -1 | cut -d: -f2 | awk '{ print $1}')
sudo sed -i "s:sip\.server\.host=.*:sip.server.host=$HOST:g" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
# http://code.google.com/p/bigbluebutton/issues/detail?id=1133
sudo sed -i "s:\([ ]*\)<\(X-PRE-PROCESS.*local_ip_v4=[^>]*\)>:\1<\!--\2-->:g" /opt/freeswitch/conf/vars.xml
#sudo sed -i "s:\([ ]*\)<\(param.*name=\"ext-rtp-ip\"[^\"]*\"\)\([^\"]*\)\([^>]*\)>:\1<\!--\2\3\4-->\n\1<\2auto-nat\4>:g" /opt/freeswitch/conf/sip_profiles/external.xml
sudo sed -i "s:\([ ]*\)<\(.*name=\"ext-rtp-ip\"[^\"]*\"\)\([^\"]*\)\([^>]*\)>:\1<\2auto-nat\4>:g" /opt/freeswitch/conf/sip_profiles/external.xml
#sudo sed -i "s:\([ ]*\)<\(param.*name=\"ext-sip-ip\"[^\"]*\"\)\([^\"]*\)\([^>]*\)>:\1<\!--\2\3\4-->\n\1<\2auto-nat\4>:g" /opt/freeswitch/conf/sip_profiles/external.xml
sudo sed -i "s:\([ ]*\)<\(.*name=\"ext-sip-ip\"[^\"]*\"\)\([^\"]*\)\([^>]*\)>:\1<\2auto-nat\4>:g" /opt/freeswitch/conf/sip_profiles/external.xml

