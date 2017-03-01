#!/bin/bash

#################################################################################################
#                         MARIST SSH HONEYPOT CENTOS UNINSTALLER v0.1                           #
#                            MARIST COLLEGE NETWORKING DEPARTMENT                               #
#################################################################################################

####################################### Files to Remove #########################################

echo "Deleting SSH Configs....."
rm -r /usr/local/source/openssh
rm -r /var/log/ssh-honeypot
rm /usr/local/sbin/sshd-new
sed -i "0,/RE/s/Port .*/Port 22/g" /etc/ssh/sshd_config

echo "Removing Rsyslog Configs......"
if [[ $(ls /etc/rsyslog.d/00-honeypot) ]]
then
	rm /etc/rsyslog.d/00-honeypot.conf
fi
sed -i '/#HONEYPOT CONFIGURATION START/ c\' /etc/rsyslog.conf
sed -i '/\$WorkDirectory \/var\/lib\/rsyslog/ c\' /etc/rsyslog.conf
sed -i '/\$ActionQueueFileName fwdRule1/ c\' /etc/rsyslog.conf
sed -i '/\$ActionQueueMaxDiskSpace .*/ c\' /etc/rsyslog.conf
sed -i '/\$ActionQueueSaveOnShutdown on/ c\' /etc/rsyslog.conf
sed -i '/\$ActionQueueType LinkedList/ c\' /etc/rsyslog.conf
sed -i '/\$ActionResumeRetryCount -1/ c\' /etc/rsyslog.conf
sed -i '/#HONEYPOT CONFIGURATION END/ c\' /etc/rsyslog.conf

ACTIVE_HP_PORTS=$(cat /usr/local/etc/active_ports.txt | tail -1)

# killing current processes
for i in $(echo $ACTIVE_HP_PORTS | sed "s/,/ /g")
do
	echo sshd_config-${i} | sed -e 's/sshd_config-*//g'
	ps axf | grep "/usr/local/sbin/sshd-new -f /usr/local/etc/sshd_config-${i}" | grep -v grep | awk '{print "kill -9 " $1}' | sh
done

echo "Restarting Rsyslog....."
service rsyslog restart

if [[ $(head -1 /etc/os-release) == *"CentOS"* || $(head -1 /etc/os-release) == *"CentOS"* ]]
then
	echo "Restarting SSH....."
	service sshd restart
else
	echo "Restarting SSH....."
	service ssh restart
fi

echo "#!/bin/sh -e" > /etc/rc.local
echo "#" >> /etc/rc.local
echo "# rc.local" >> /etc/rc.local
echo "#" >> /etc/rc.local
echo "# This script is executed at the end of each multiuser runlevel." >> /etc/rc.local
echo "# Make sure that the script will 'exit 0' on success or any other" >> /etc/rc.local
echo "# value on error." >> /etc/rc.local
echo "#" >> /etc/rc.local
echo "# In order to enable or disable this script just change the execution" >> /etc/rc.local
echo "# bits." >> /etc/rc.local
echo "#" >> /etc/rc.local
echo "# By default this script does nothing." >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

rm /usr/local/etc/active_ports.txt
