#!/bin/bash
#
# Mysql IP, user, password and DB name
#
    host="35.201.22.71"
    user="dagops"
    pass="dagops123"
database="dagops"
#
# Software installation
#
sudo su - << AS_ROOT
apt-get -y update && sudo apt-get -y upgrade && sudo apt -y autoremove
sudo apt-get -y install apache2 python-pip git wget gcc php php-mysqlnd mysql-client expect
pip install j2cli
add-apt-repository -y ppa:neurobin/ppa
apt-get update
apt-get install shc
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
sed -i '/Listen 8123/d' /etc/apache2/ports.conf
echo "Listen 8123" >> /etc/apache2/ports.conf
cat << END > /etc/apache2/sites-available/001-dagops.conf
<VirtualHost *:8123>
    ServerName dagops
    ServerAlias dagops
    DocumentRoot /var/www/html/dagops
</VirtualHost>
END
ln -s /etc/apache2/sites-available/001-dagops.conf /etc/apache2/sites-enabled/001-dagops.conf
#
# Start apache 
#
systemctl enable apache2
systemctl restart apache2
#
# Encrypt MySQL password
#
unbuffer expect -c "
spawn mysql_config_editor set --host=$host --user=$user --skip-warn --password
expect -nocase \"Enter password:\" {send \"$pass\r\"; interact}
"
#
# Create MariaDB database -- this should be done already
#
#mysql -u root -prootpwd << END
#create database dagops ;
#grant all privileges on dagops.* to 'dagops'@'localhost' identified by 'dagops123' ;
#END
#AS_ROOT
#
# Get the dagops code
#
sudo su - dagops << AS_DAGOPS
git clone https://github.com/freddenis/dagops.git
mv dagops/html/* /var/www/html/dagops/.
ln -s dagops/ bin
ln -s /var/www/html/dagops/ html
AS_DAGOPS
#
# Encrypt the shells
#
sudo su - dagops bash -c '
for F in `ls /home/dagops/bin/*.sh`
do
   shc -f ${F}
   rm ${F}.x.c
   rm ${F}
   mv ${F}.x ${F}
   chmod u+x ${F}
done
'
#
sudo su - dagops << AS_DAGOPS
#
# dagops needs to connect with no password
#
cat << END > /home/dagops/.my.cnf
[client]
user=$user
host=$host
database=$database
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
