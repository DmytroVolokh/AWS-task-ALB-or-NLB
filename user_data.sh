#!/bin/bash
yum -y update
yum -y install httpd
PrivatIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "Web Server with $PrivatIP" > /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
