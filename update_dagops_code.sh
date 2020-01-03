#!/bin/bash
# Update the dagops code -- copy and execute this file on a dagops VM
#
TAR=/tmp/dagopsbackup$$.tgz
sudo su - dagops << AS_DAGOPS
# We want to keep the logs and tmp files
tar czfP ${TAR} /home/dagops/dagops/logs /home/dagops/dagops/tmp
# Get the dagops code
#
rm -fr /home/dagops/dagops
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
   /tmp/shc-3.8.7/shc -f ${F}
   rm ${F}.x.c
   rm ${F}
   mv ${F}.x ${F}
   chmod u+x ${F}
done
'
# Restore logs and tmp files
sudo su - dagops << AS_DAGOPS
mkdir /home/dagops/dagops/tmp
mkdir /home/dagops/dagops/logs
tar zxfP ${TAR}
AS_DAGOPS
