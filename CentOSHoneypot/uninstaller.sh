#!/bin/bash

#################################################################################################
#                         MARIST SSH HONEYPOT CENTOS UNINSTALLER v0.1                           #
#                            MARIST COLLEGE NETWORKING DEPARTMENT                               #
#################################################################################################

####################################### Files to Remove #########################################
echo "Deleting SSH Configs....."
rm -r /usr/local/source/openssh
rm -r /var/log/ssh-honeypot
rm /usr/local/etc/sshd_config-22
rm /usr/local/etc/sshd_config-2222
rm /usr/local/sbin/sshd-22
rm /usr/local/sbin/sshd-2222
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
ps axf | grep "/usr/local/sbin/sshd-22 -f /usr/local/etc/sshd_config-22" | grep -v grep | awk '{print "kill -9 " $1}' | sh
ps axf | grep "/usr/local/sbin/sshd-2222 -f /usr/local/etc/sshd_config-2222" | grep -v grep | awk '{print "kill -9 " $1}' | sh

echo "Restarting Rsyslog....."
service rsyslog restart
echo "Restarting SSH....."
service sshd restart
