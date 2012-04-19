#!/bin/bash

function print_usage
{
	echo "Usage:"
	echo "    $0 <nagios_address> <bigbluebutton|freeswitch> <interval>"
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

if [ $2 != "bigbluebutton" ] && [ $2 != "freeswitch" ]
then
	print_usage
fi

HOST=`get_hostname`
NAGIOS_ADDRESS=$1
INSTANCE_TYPE=$2
INTERVAL=$3

mkdir -p ~/tools
cd ~/tools

sudo aptitude update
sudo aptitude -y install git-core python-dev python-argparse subversion

# we are using the svn trunk instead of the lastest stable tag because of this:
# http://code.google.com/p/psutil/issues/detail?id=248
svn checkout http://psutil.googlecode.com/svn/trunk psutil-read-only
cd psutil-read-only/
python setup.py build
sudo python setup.py install
cd ..
rm -rf psutil-read-only/

wget http://prdownloads.sourceforge.net/sourceforge/nagios/nsca-2.7.2.tar.gz
tar xzf nsca-2.7.2.tar.gz
cd nsca-2.7.2
./configure
make
make install
sudo mkdir -p /usr/local/nagios/bin/ /usr/local/nagios/etc/
USER=`whoami`
sudo chown $USER:$USER -R /usr/local/nagios
cp src/send_nsca /usr/local/nagios/bin/
cp sample-config/send_nsca.cfg /usr/local/nagios/etc/
cd ..
rm -rf nsca-2.7.2.tar.gz nsca-2.7.2

git clone git://github.com/mconf/nagios-etc.git
nagios-etc/cli/server_up.sh $NAGIOS_ADDRESS $INSTANCE_TYPE

crontab -l | grep -v "performance_report.py" > cron.jobs
echo "@reboot ~/tools/nagios-etc/cli/performance_report.py start --server $NAGIOS_ADDRESS --hostname $HOST --send_rate $INTERVAL > /dev/null 2>&1" >> cron.jobs
crontab cron.jobs

