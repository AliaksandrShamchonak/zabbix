#!/bin/bash

#elasticsearch
# wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.2.0-x86_64.rpm
# wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.2.0-x86_64.rpm.sha512
# shasum -a 512 -c elasticsearch-7.2.0-x86_64.rpm.sha512
# rpm --install elasticsearch-7.2.0-x86_64.rpm
 rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
 cat << EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

 yum -y install elasticsearch
 cat << EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: "elasticcluster"
network.host: "0.0.0.0"
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
discovery.zen.minimum_master_nodes: 1
discovery.type: single-node
EOF

 cat << EOF >> /etc/kibana/kibana.yml
server.host: "0.0.0.0"
EOF

 systemctl enable elasticsearch.service
 systemctl start elasticsearch.service
#kibana
 cat << EOF > /etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
 yum -y install kibana
 systemctl enable kibana.service
 systemctl start kibana.service
