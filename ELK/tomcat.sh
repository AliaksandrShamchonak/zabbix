#!/bin/bash

#tomcat
 yum -y install java
 mkdir /opt/tomcat
 cd /opt/tomcat/
 wget -q http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
 tar xvf apache-tomcat-9.0.21.tar.gz
 ln -s /opt/tomcat/apache-tomcat-9.0.21 /opt/tomcat/latest
 cp -f /vagrant/TestApp.war /opt/tomcat/latest/webapps/
 /opt/tomcat/latest/bin/startup.sh

# logstash
 rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
 cat << EOF > /etc/yum.repos.d/logstash.repo
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
 yum -y install logstash
 cp -f /vagrant/logtomcat.conf /etc/logstash/conf.d/
 chmod 755 -R  /opt/tomcat/latest/logs/

 systemctl enable logstash.service
 systemctl start logstash.service