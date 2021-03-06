#!/bin/bash

cd ~/dev/bigbluebutton

cd bbb-api-demo
gradle resolveDeps build
sudo rm -rf /var/lib/tomcat6/webapps/demo*
sudo cp build/libs/demo.war /var/lib/tomcat6/webapps/
sudo service tomcat6 restart
cd ..

cd bbb-video
gradle resolveDeps build deploy
cd ..

cd bbb-voice
gradle resolveDependencies war deploy
cd ..

cd bigbluebutton-apps
gradle resolveDeps war deploy
cd ..

cd deskshare
gradle resolveDeps
cd applet
gradle jar
rm -r ~/.secret/
ant create-signing-key sign-jar
cp build/libs/bbb-deskshare-applet-0.71.jar ~/dev/bigbluebutton/bigbluebutton-client/resources/prod/
cd ../app
gradle war deploy
cd ../..

cd bigbluebutton-client
ant locales
ant clean-build-all
cd ..

cd bigbluebutton-web
gradle resolveDeps
ant war
cd ..


