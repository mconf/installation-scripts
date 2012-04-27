#!/bin/bash

sudo cp mconf-default.pdf /var/www/bigbluebutton-default/
sudo sed -i 's:\(beans.presentationService.defaultUploadedPresentation\).*:\1=${bigbluebutton.web.serverURL}/mconf-default.pdf:g' /var/lib/tomcat6/webapps/bigbluebutton/WEB-INF/classes/bigbluebutton.properties
sudo service tomcat6 restart
