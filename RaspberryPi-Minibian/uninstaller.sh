#!/bin/bash

#################################################################################################
#                         MARIST SSH HONEYPOT MINIBIAN UNINSTALLER v0.1                         #
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
echo "Removing Rsyslog Configs......1"
sed -i '/#HONEYPOT CONFIGURATION START/ c\' /etc/rsyslog.conf
echo "Removing Rsyslog Configs......2"
sed -i '/\$WorkDirectory /var/lib/rsyslog/ c\' /etc/rsyslog.conf
echo "Removing Rsyslog Configs......3"
sed -i '/\$ActionQueueFileName fwdRule1/ c\' /etc/rsyslog.conf
echo "Removing Rsyslog Configs......4"
sed -i '/\$ActionQueueMaxDiskSpace .*/ c\' /etc/rsyslog.conf
echo "Removing Rsyslog Configs......5"
sed -i '/\$ActionQueueSaveOnShutdown on/ c\' /etc/rsyslog.conf
echo "Removing Rsyslog Configs......6"
sed -i '/\$ActionQueueType LinkedList/ c\' /etc/rsyslog.conf
echo "Removing Rsyslog Configs......7"
sed -i '/\$ActionResumeRetryCount -1/ c\' /etc/rsyslog.conf
echo "Removing Rsyslog Configs......8"
sed -i '/#HONEYPOT CONFIGURATION END/ c\' /etc/rsyslog.conf

echo "Restarting Rsyslog....."
service rsyslog restart
echo "Restarting SSH....."
service ssh restart
