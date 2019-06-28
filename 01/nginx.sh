#!/bin/bash

rpm -Uvh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
yum -y install epel-release nginx java zabbix-agent
systemctl enable nginx

  mkdir /opt/tomcat
  cd /opt/tomcat/
  wget -q http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
  tar xvf apache-tomcat-9.0.21.tar.gz
  ln -s /opt/tomcat/apache-tomcat-9.0.21 /opt/tomcat/latest
  cp -f /vagrant/TestApp.war /opt/tomcat/latest/webapps/
  /opt/tomcat/latest/bin/startup.sh



#Configuration (/etc/zabbix/zabbix_agentd.conf):
# 13 # PidFile=/var/run/zabbix/zabbix_agentd.pid
# 32 # LogFile=/var/log/zabbix/zabbix_agentd.log
# 57 # DebugLevel=3
sed -i 's/^# DebugLevel=3/DebugLevel=3/' /etc/zabbix/zabbix_agentd.conf

# Passive checks related
# 98 # Server=zabbix_server_ip
sed -i 's/^Server=127.0.0.1/Server=192.168.219.90/' /etc/zabbix/zabbix_agentd.conf
# 106 # ListenPort=10050
sed -i 's/^# ListenPort=/ListenPort=/' /etc/zabbix/zabbix_agentd.conf
# 114 # ListenIP=0.0.0.0
sed -i 's/^# ListenIP=/ListenIP=/' /etc/zabbix/zabbix_agentd.conf
# 123 # StartAgents=3
sed -i 's/^# StartAgents=3/StartAgents=3/' /etc/zabbix/zabbix_agentd.conf

# Active checks related
# 139 #ServerActive=zabbix_server_ip
sed -i 's/^ServerActive=127.0.0.1/Server=192.168.219.90/' /etc/zabbix/zabbix_agentd.conf
#ServerPort=10051
# NONE in v4.2.4#
# 150 # Hostname=Zabbix server
sed -i 's/^Hostname=Zabbix server/Hostname=nginx/' /etc/zabbix/zabbix_agentd.conf
# 158 # HostnameItem=system.hostname
sed -i 's/^# HostnameItem=/HostnameItem=/' /etc/zabbix/zabbix_agentd.conf

systemctl enable zabbix-agent
systemctl restart zabbix-agent
