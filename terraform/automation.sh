#!/bin/bash
# Install necessary packages
sudo apt install git -y
sudo apt install default-jre -y
sudo apt install default-jdk -y
sudo apt install leiningen -y
sudo apt install make -y
# Copy source code from GitHub
cd $HOME
git clone https://github.com/ThoughtWorksInc/infra-problem && cd infra-problem
# Compile
make libs
make clean all
# Install Docker
sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
apt-cache policy docker-ce
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Get Docker Compose File and Dockerfiles
cd $HOME
git clone https://github.com/basti-hen/infra-solution
# Move compiled files
cp $HOME/infra-problem/build/front-end.jar $HOME/infra-solution/frontend/front-end.jar
cp $HOME/infra-problem/build/newsfeed.jar $HOME/infra-solution/newsfeed/newsfeed.jar
cp $HOME/infra-problem/build/quotes.jar $HOME/infra-solution/quotes/quotes.jar
cp -r $HOME/infra-problem/front-end/public $HOME/infra-solution/static/public
# Build Containers
cd $HOME/infra-solution/
sudo -E docker-compose build
sudo -E docker-compose up -d 