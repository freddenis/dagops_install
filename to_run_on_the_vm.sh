#!/bin/bash
#
# Software installation
sudo su - << AS_ROOT
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
setenforce 0
yum -y update
yum install -y httpd mariadb-server python-pip git yum-utils
pip install j2cli
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi-php73
yum install -y php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd
#
# dagops user
#
groupadd dagops
useradd -m -p dagops123 -s /bin/bash -d /home/dagops -g dagops dagops
#
# Apache conf and privileges
#
mkdir /var/www/html/dagops
groupadd www-pub
usermod -a -G www-pub dagops
chown -R root:www-pub /var/www
chmod -R 2775 /var/www
echo "Listen 8123" >> /etc/httpd/conf/httpd.conf
cat << END > /etc/httpd/conf.d/dagops.conf
<VirtualHost *:8123>
    ServerName dagops
    ServerAlias dagops
    DocumentRoot /var/www/html/dagops
</VirtualHost>
END
#
# Start apache and MariaDB
#
systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb
#
# Secure MariaDB
#
mysql_secure_installation <<EOF

y
rootpwd
rootpwd
y
y
y
y
EOF
#
# Create MariaDB database
#
mysql -u root -prootpwd << END
create database dagops ;
grant all privileges on dagops.* to 'dagops'@'localhost' identified by 'dagops123' ;
END
AS_ROOT
#
# Dagops env
#
sudo su - dagops << AS_DAGOPS
cd
git clone https://github.com/freddenis/dagops.git
mv dagops/html/* /var/www/html/dagops/.
ln -s dagops/ bin
ln -s /var/www/html/dagops/ html
chmod u+x /home/dagops/bin/*.sh
#
# dagops needs to connect with no password
#
cat << END > /home/dagops/.my.cnf
[client]
user=dagops
password=dagops123
host=127.0.0.1
database=dagops
END
#
# Create the MariaDB tables
#
mysql -u dagops << END
source /home/dagops/bin/mysql_cre_dagops_launcher.sql
source /home/dagops/bin/mysql_cre_dagops_logs.sql
source /home/dagops/bin/mysql_cre_dagops_makefiles.sql
source /home/dagops/bin/mysql_cre_run_id.sql
show tables ;
END
#
# Gcloud config
#
mkdir -p ~/.config/gcloud/configurations
cat << END > ~/.config/gcloud/configurations/config_dagops
[core]
account = service-bq-test@bmas-edl-uat-7398.iam.gserviceaccount.com
project = bmas-edl-uat-7398
END
cat << END > ~/.config/gcloud/configurations/config_default
[core]
account = still@pythian.com
END
AS_DAGOPS
