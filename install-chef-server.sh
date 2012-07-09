# install chef server v -.10 on ubuntu 10.04
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list
sudo mkdir -p /etc/apt/trusted.gpg.d
gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null
sudo apt-get update
sudo apt-get install opscode-keyring
sudo apt-get upgrade -y
sudo apt-get install chef chef-server -y

mkdir -p ~/.chef
sudo cp /etc/chef/validation.pem /etc/chef/webui.pem ~/.chef
sudo chown -R $USER ~/.chef -v

#configure knife 
knife configure -i

sudo cp /etc/chef/validation.pem ~/
sudo chmod 777 ~/validation.pem
