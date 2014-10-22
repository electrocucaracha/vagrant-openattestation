#!/bin/bash

#proxy_host=proxy.com
#proxy_port=8080

if [ -z "$proxy_host" ]; then 
  sed -i "s/10.0.2.3/8.8.8.8/g" /etc/resolv.conf

  apt-get update
  apt-get install -y git maven openjdk-7-jdk zip make g++ makeself
else
  echo "Acquire::http::Proxy \"http://${proxy_host}:${proxy_port}\";"  >>  /etc/apt/apt.conf
  echo "Acquire::https::Proxy \"http://${proxy_host}:${proxy_port}\";"  >>  /etc/apt/apt.conf

  export http_proxy=http://${proxy_host}:${proxy_port}
  export https_proxy=http://${proxy_host}:${proxy_port}

  apt-get update
  apt-get install -y git maven openjdk-7-jdk zip make g++ makeself
  
  sed -i "s/<\/proxies>/\t<proxy>\n\t<active>true<\/active>\n\t<protocol>http<\/protocol>\n\t<host>${proxy_host}<\/host>\n\t<port>${proxy_port}<\/port>\n\t<\/proxy>\n<\/proxies>/g" /etc/maven/settings.xml
fi


git clone https://github.com/OpenAttestation/OpenAttestation/
cd OpenAttestation/
git checkout v2.2

# Build Source Code
mvn clean install -DskipTests=true

# Attestation Server Installation
apt-get install -y openjdk-7-jdk openssl libssl-dev gcc unzip
debconf-set-selections <<< 'mysql-server mysql-server/root_password password secure'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password secure'
apt-get install -y mariadb-server
apt-get install -y tomcat6

cd deploy/
bash deploy_ubuntu.sh --mysql secure --ip 127.0.0.1
