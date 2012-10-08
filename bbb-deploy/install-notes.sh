#!/bin/bash

sudo apt-get -y install openjdk-6-jdk

# https://github.com/harrah/xsbt/wiki/Setup
mkdir -p ~/tools
cd ~/tools
rm -r xsbt*
wget -O xsbt.tar.gz https://github.com/harrah/xsbt/tarball/v0.11.2
tar xf xsbt.tar.gz
mv -i harrah-xsbt-* xsbt
wget -O sbt-launch.jar http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-tools.sbt/sbt-launch/0.11.2/sbt-launch.jar
echo 'java -Xmx512M -jar `dirname $0`/sbt-launch.jar "$@"' > sbt
chmod a+x sbt
sudo mv sbt-launch.jar sbt /usr/bin/

rm -r live-notes-server*
wget -O live-notes-server.tar.gz https://github.com/mconf/live-notes-server/tarball/master
tar xf live-notes-server.tar.gz
mv -i mconf-live-notes-server-* live-notes-server
touch live-notes-server.sh
echo '#!/bin/bash' >> live-notes-server.sh
CURRENT=`pwd`
echo "cd $CURRENT/live-notes-server" >> live-notes-server.sh
echo "sbt \"run 8095\"" >> live-notes-server.sh
chmod +x live-notes-server.sh
sudo mv live-notes-server.sh /usr/bin/

crontab -l | grep -v "live-notes-server.sh" > cron.jobs
echo "@reboot /usr/bin/live-notes-server.sh > /dev/null 2>&1 &" >> cron.jobs
crontab cron.jobs
rm cron.jobs

echo "The live notes server installation will be concluded when the server restarts"
