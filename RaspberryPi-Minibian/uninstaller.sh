#!/bin/bash

#################################################################################################
#                         MARIST SSH HONEYPOT MINIBIAN UNINSTALLER v0.1                         #
#                            MARIST COLLEGE NETWORKING DEPARTMENT                               #
#################################################################################################

####################################### Files to Remove #########################################
rm -r /usr/local/source/openssh
rm -r /var/log/ssh-honeypot
rm /usr/local/etc/sshd_config-22
rm /usr/local/etc/sshd_config-2222
rm /usr/local/sbin/sshd-22
rm /usr/local/sbin/sshd-2222
sed -i "0,/RE/s/Port .*/Port 22/g" /etc/ssh/sshd_config
service ssh restart
