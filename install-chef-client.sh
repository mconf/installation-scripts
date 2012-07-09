# install chef client v -.10 on ubuntu server 10.04

#define server ip:
SERVER_IP=REPLACE_BY_CHEF_SERVER_IP

sudo apt-get update
sudo apt-get upgrade -y
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list

sudo mkdir -p /etc/apt/trusted.gpg.d
gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null

sudo apt-get update
sudo apt-get install opscode-keyring -y --force-yes
sudo apt-get upgrade -y

#create dir to copy server key
sudo mkdir -p /etc/chef

#copy validation.pem from server to client
#TODO replace by a method that does not require password from the server side
sudo scp mconf@$SERVER_IP:~/validation.pem /etc/chef/validation.pem

#install chef client via package passing server url
echo "chef chef/chef_server_url string http://$SERVER_IP:4000" | sudo debconf-set-selections && sudo apt-get install chef -y

