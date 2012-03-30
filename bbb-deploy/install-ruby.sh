#!/bin/bash

if [ `ruby -v | grep 'ruby 1.9.2p290' | wc -l` -eq 1 ]
then
    exit 0
fi

sudo aptitude -y install zlib1g-dev libssl-dev libreadline5-dev libyaml-dev build-essential bison checkinstall libffi5 gcc checkinstall libreadline5 libyaml-0-2

cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
tar xvzf ruby-1.9.2-p290.tar.gz
cd ruby-1.9.2-p290
./configure --prefix=/usr\
            --program-suffix=1.9.2\
            --with-ruby-version=1.9.2\
            --disable-install-doc
make
sudo checkinstall -D -y\
                  --fstrans=no\
                  --nodoc\
                  --pkgname='ruby1.9.2'\
                  --pkgversion='1.9.2-p290'\
                  --provides='ruby'\
                  --requires='libc6,libffi5,libgdbm3,libncurses5,libreadline5,openssl,libyaml-0-2,zlib1g'\
                  --maintainer=brendan.ribera@gmail.com
sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.2 500\
                        --slave   /usr/bin/ri   ri   /usr/bin/ri1.9.2\
                        --slave   /usr/bin/irb  irb  /usr/bin/irb1.9.2\
                        --slave   /usr/bin/gem  gem  /usr/bin/gem1.9.2\
                        --slave   /usr/bin/erb  erb  /usr/bin/erb1.9.2\
                        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.2
