#!/bin/bash

# Install mysql server
yum -y install mariadb mariadb-server mysql-devel
#libxml2-devel curl-devel net-snmp-devel libevent-devel # libssh2-devel libcurl-devel pcre*
# Mysql Initial configuration
/usr/bin/mysql_install_db --user=mysql
# Starting and enabling mysqld service
systemctl enable mariadb
systemctl start mariadb
# Creating initial database
mysql -uroot -e "
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
quit;"


# Install Zabbix repository
rpm -Uvh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
yum clean all
#echo "exclude=de-proxy.cl-mirror.net" >> /etc/yum/pluginconf.d/fastestmirror.conf

## Install Zabbix server, frontend, agent
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-get
#wget https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/4.2.4/zabbix-4.2.4.tar.gz
#tar -zxvf zabbix-4.2.4.tar.gz
#cd zabbix-4.2.4
#./configure --enable-server --with-mysql --with-net-snmp --with-libcurl --with-libxml2
#make install

# Import initial schema and data
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbix zabbix

# Database configuration for Zabbix server
# vi /etc/zabbix/zabbix_server.conf
# 91  # DBHost=localhost
sed -i 's/^# DBHost/DBHost/' /etc/zabbix/zabbix_server.conf
# 100 # DBName=zabbix
# 116 # DBUser=zabbix
# 124 # DBPassword=zabbix
sed -i 's/^# DBPassword=/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf

# Starting Zabbix server process
systemctl enable zabbix-server
systemctl start zabbix-server

# Configuring PHP settings
# vi /etc/httpd/conf.d/zabbix.conf
# php_value max_execution_time 300
# php_value memory_limit 128M
# php_value post_max_size 16M
# php_value upload_max_filesize 2M
# php_value max_input_time 300
# php_value always_populate_raw_post_data -1
# 20 # php_value date.timezone Europe/Minsk
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Europe\/Minsk/' /etc/httpd/conf.d/zabbix.conf

# go to http://{{ server_ip }}/zabbix for further configuration
sed -i '4a\ \n<VirtualHost *:80>\n        ServerName 127.0.0.1\n        DocumentRoot "/usr/share/zabbix"\n' /etc/httpd/conf.d/zabbix.conf
sed -i -e '$a\</VirtualHost>' /etc/httpd/conf.d/zabbix.conf

# Starting Front-end
systemctl enable httpd
systemctl start httpd




#Configure PHP for Zabbix frontend
#Edit file /etc/httpd/conf.d/zabbix.conf, uncomment and set the right timezone for you.
# php_value date.timezone Europe/Riga
#f. Start Zabbix server and agent processes
#Start Zabbix server and agent processes and make it start at system boot:

# systemctl restart zabbix-server zabbix-agent httpd
# systemctl enable zabbix-server zabbix-agent httpd
