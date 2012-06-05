#!/bin/bash

function print_usage
{
	echo "Usage:"
	echo "    $0 <nagios_address> <host_name> <interval>"
	exit 1
}

if [ $# -ne 3 ]
then
	print_usage
fi

NAGIOS_ADDRESS=$1
HOST=$2
INTERVAL=$3

~/tools/nagios-etc/cli/performance_report.py stop
CMD="~/tools/nagios-etc/cli/performance_report.py start --server $NAGIOS_ADDRESS --hostname $HOST --send_rate $INTERVAL | tee /tmp/output_performance_report.txt 2>&1"
eval $CMD
crontab -l | grep -v "performance_report.py" > cron.jobs
echo "@reboot $CMD" >> cron.jobs
crontab cron.jobs
rm cron.jobs
