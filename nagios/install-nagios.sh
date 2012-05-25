#!/bin/bash

# git clone git://github.com/mconf/installation-scripts.git

# Installing Nagios on Ubuntu Server 10.04.3 64 bits
# http://nagios.sourceforge.net/docs/3_0/quickstart-ubuntu.html
# http://www.vivaolinux.com.br/artigo/Monitorando-redes-e-servidores-com-Nagios/

sudo apt-get update
sudo apt-get -y install apache2 libapache2-mod-php5 build-essential libgd2-xpm-dev subversion git-core xinetd rrdtool librrds-perl

mkdir -p ~/downloads
cd ~/downloads
wget -nc http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.4.0.tar.gz
wget -nc http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.15.tar.gz
wget -nc http://sourceforge.net/projects/nagiosgraph/files/nagiosgraph/1.4.4/nagiosgraph-1.4.4.tar.gz
tar xzf nagios-3.4.0.tar.gz
tar xzf nagios-plugins-1.4.15.tar.gz
tar xzf nagiosgraph-1.4.4.tar.gz

sudo useradd -m -s /bin/bash nagios
echo 'Enter the password for the new user nagios'
sudo passwd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagcmd www-data

cd ~/downloads/nagios
./configure --with-command-group=nagcmd
make all
sudo make install
sudo make install-init
sudo make install-config
sudo make install-commandmode
sudo make install-webconf
echo 'Enter the password for the user nagiosadmin'
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
sudo service apache2 reload

cd ~/downloads/nagios-plugins-1.4.15
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
sudo make install

# install PyNag
cd ~/downloads
svn checkout http://pynag.googlecode.com/svn/ pynag-read-only
cd pynag-read-only/trunk/
sudo python setup.py install

# install Mconf stuff
sudo apt-get -y install python-argparse
mkdir -p ~/tools
cd ~/tools
git clone git://github.com/mconf/nagios-etc.git
sudo cp -r ~/tools/nagios-etc/libexec/nagios-hosts/ /usr/local/nagios/libexec/
sudo cp -r ~/tools/nagios-etc/libexec/bigbluebutton/ /usr/local/nagios/libexec/
sudo cp -r ~/tools/nagios-etc/etc/objects/mconf/ /usr/local/nagios/etc/objects/
sudo cp /usr/local/nagios/etc/nagios.cfg /usr/local/nagios/etc/nagios.cfg.original
# done on bbb-deploy/install-monitor.sh
# sudo cp /usr/local/nagios/etc/nsca.cfg /usr/local/nagios/etc/nsca.cfg.backup
sudo cp ~/tools/nagios-etc/etc/nagios.cfg ~/tools/nagios-etc/etc/nsca.cfg /usr/local/nagios/etc/

sudo crontab -l | grep -v "nagios-hosts.py" > cron.jobs
echo "*/1 * * * * /usr/bin/python /usr/local/nagios/libexec/nagios-hosts/nagios-hosts.py reload" >> cron.jobs
sudo crontab cron.jobs
rm cron.jobs

# configuring the central server
sudo sed -i "s:nagios@localhost:mconf.prav@gmail.com:g" /usr/local/nagios/etc/objects/contacts.cfg
sudo sed -i "s:.*enable_notifications=.*:enable_notifications=1:g" /usr/local/nagios/etc/nagios.cfg
sudo sed -i "s:.*execute_service_checks=.*:execute_service_checks=1:g" /usr/local/nagios/etc/nagios.cfg
sudo sed -i "s:.*check_external_commands=.*:check_external_commands=1:g" /usr/local/nagios/etc/nagios.cfg
sudo sed -i "s:.*accept_passive_service_checks=.*:accept_passive_service_checks=1:g" /usr/local/nagios/etc/nagios.cfg

# configuring status-json
cd ~/downloads/nagios/cgi
# http://exchange.nagios.org/directory/Addons/APIs/JSON/status-2Djson/details
wget -O status-json.c "http://exchange.nagios.org/components/com_mtree/attachment.php?link_id=2498&cf_id=24"
cp status-json.c status-json.c.original
cp Makefile Makefile.original
patch -R Makefile < ~/tools/installation-scripts/nagios/Makefile.patch
patch -R status-json.c < ~/tools/installation-scripts/nagios/status-json.c.patch
make all
sudo make install

cd ~/downloads/nagiosgraph-1.4.4
cp etc/ngshared.pm etc/ngshared.pm.original
patch etc/ngshared.pm < ~/tools/installation-scripts/nagios/ngshared.pm.patch
sudo ./install.pl --layout debian
echo "include /etc/nagiosgraph/nagiosgraph-apache.conf" | sudo tee -a /etc/apache2/httpd.conf
sudo cp -r /etc/nagiosgraph /etc/nagiosgraph.backup
sudo cp ~/tools/nagios-etc/nagiosgraph/* /etc/nagiosgraph/
sudo sed -i "s:.*process_performance_data=.*:process_performance_data=1:g" /usr/local/nagios/etc/nagios.cfg
sudo sed -i "s:.*service_perfdata_command=.*:service_perfdata_command=ng-process-service-perfdata-immediate:g" /usr/local/nagios/etc/nagios.cfg
sudo sed -i "s:.*host_perfdata_command=.*:host_perfdata_command=ng-process-host-perfdata-immediate:g" /usr/local/nagios/etc/nagios.cfg
sudo sed -i "s:^service_perfdata_file.*:#\0:g" /usr/local/nagios/etc/nagios.cfg
sudo sed -i "s:^host_perfdata_file.*:#\0:g" /usr/local/nagios/etc/nagios.cfg

sudo ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios
sudo mkdir -p /usr/local/nagios/var/spool/checkresults
sudo mkdir -p /usr/local/nagios/var/archives
sudo chown -R nagios:nagios /usr/local/nagios

sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo service nagios start

