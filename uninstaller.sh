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
rm /etc/rsyslog.d/00-honeypot.conf
sed -i '/#HONEYPOT CONFIGURATION START/ c\' /etc/rsyslog.conf
sed -i '/\$WorkDirectory \/var\/lib\/rsyslog/ c\' /etc/rsyslog.conf
sed -i '/\$ActionQueueFileName fwdRule1/ c\' /etc/rsyslog.conf
sed -i '/\$ActionQueueMaxDiskSpace .*/ c\' /etc/rsyslog.conf
sed -i '/\$ActionQueueSaveOnShutdown on/ c\' /etc/rsyslog.conf
sed -i '/\$ActionQueueType LinkedList/ c\' /etc/rsyslog.conf
sed -i '/\$ActionResumeRetryCount -1/ c\' /etc/rsyslog.conf
sed -i '/#HONEYPOT CONFIGURATION END/ c\' /etc/rsyslog.conf

# killing current processes
for i in $(echo $ACTIVE_HP_PORTS | sed "s/,/ /g")
do
	for f in /usr/local/etc/*
	do
		if [[ "$f" == "sshd_config-*" ]]
		then
			echo sshd_config-${i} | sed -e 's/sshd_config-*//g'
			ps axf | grep "/usr/local/sbin/sshd-new -f /usr/local/etc/sshd_config-${i}" | grep -v grep | awk '{print "kill -9 " $1}' | sh
		fi
	done
done
ACTIVE_HP_PORTS=

echo "Restarting Rsyslog....."
service rsyslog restart

if [[ $(head -1 /etc/os-release) == *"Debian"* ]] || [[ $(head -1 /etc/os-release) == *"Ubuntu"* ]] || [[ $(head -1 /etc/os-release) == *"Raspbian"* ]]
then
	echo "Restarting SSH....."
	service ssh restart
elif [[ $(head -1 /etc/os-release) == *"CentOS"* ]]
then
	echo "Restarting SSH....."
	service sshd restart
fi
