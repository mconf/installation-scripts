#!/bin/bash

function print_usage
{
	echo "Usage:"
	echo "    $0 <nagios_address> <bigbluebutton|freeswitch|nagios> <interval>"
	exit 1
}

function get_hostname
{
    if [ `which bbb-conf | wc -l` -eq 0 ]
    then
        echo `ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{print $1}'`
    else
        echo `bbb-conf --salt | grep 'URL' | tr -d ' ' | sed 's:URL\:http\://\([^:/]*\).*:\1:g'`
    fi
}

if [ $# -ne 3 ]
then
	print_usage
fi

if [ $2 != "bigbluebutton" ] && [ $2 != "freeswitch" ] && [ $2 != "nagios" ]
then
	print_usage
fi

if [ $2 == "nagios" ]
then
    HOST="localhost"
else
    HOST=`get_hostname`
fi
NAGIOS_ADDRESS=$1
INSTANCE_TYPE=$2
INTERVAL=$3

sudo aptitude update
sudo aptitude -y install git-core python-dev python-argparse subversion
sudo killall performance_report.py

mkdir -p ~/tools
cd ~/tools
if [ -d "nagios-etc" ]
then
    cd nagios-etc
    git pull origin master
    cd ..
else
    git clone git://github.com/mconf/nagios-etc.git
fi

mkdir -p ~/downloads
cd ~/downloads

# we are using the svn trunk instead of the lastest stable tag because of this:
# http://code.google.com/p/psutil/issues/detail?id=248
svn checkout http://psutil.googlecode.com/svn/trunk psutil-read-only
cd psutil-read-only/
python setup.py build
sudo python setup.py install
cd ..
rm -rf psutil-read-only/

wget -nc http://prdownloads.sourceforge.net/sourceforge/nagios/nsca-2.7.2.tar.gz
tar xzf nsca-2.7.2.tar.gz
cd nsca-2.7.2
./configure
make
make install

if [ $2 == "nagios" ]
then
    sudo cp src/nsca /usr/local/nagios/bin/
    sudo cp sample-config/nsca.cfg /usr/local/nagios/etc/
    sudo chmod a+r /usr/local/nagios/etc/nsca.cfg
    # install as XINETD service
    sudo cp ~/downloads/nsca-2.7.2/sample-config/nsca.xinetd /etc/xinetd.d/nsca
    sudo sed -i "s:\tonly_from.*:#\0:g" /etc/xinetd.d/nsca
    sudo chmod a+r /etc/xinetd.d/nsca
    sudo service xinetd restart
else
    sudo mkdir -p /usr/local/nagios/bin/ /usr/local/nagios/etc/
    USER=`whoami`
    sudo chown $USER:$USER -R /usr/local/nagios
fi

sudo cp src/send_nsca /usr/local/nagios/bin/
sudo cp sample-config/send_nsca.cfg /usr/local/nagios/etc/
sudo chmod a+r /usr/local/nagios/etc/send_nsca.cfg
cd ..

if [ $2 != "nagios" ]
then
    ~/tools/nagios-etc/cli/server_up.sh $NAGIOS_ADDRESS $INSTANCE_TYPE
fi 

crontab -l | grep -v "performance_report.py" > cron.jobs
echo "@reboot ~/tools/nagios-etc/cli/performance_report.py start --server $NAGIOS_ADDRESS --hostname $HOST --send_rate $INTERVAL > /dev/null 2>&1" >> cron.jobs
crontab cron.jobs
rm cron.jobs
