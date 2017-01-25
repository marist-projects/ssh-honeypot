#!/bin/bash

#################################################################################################
#                         MARIST SSH HONEYPOT MINIBAN INSTALL SCRIPT v0.1                       #
#                             MARIST COLLEGE NETWORKING DEPARTMENT                              #
#################################################################################################


####################################### Global Variables ########################################

STARTING_DIRECTORY=$(pwd)/..
echo $STARTING_DIRECTORY
CURRENT_SSH_PORT=$(grep -Eo 'Port *[0-9]+' /etc/ssh/sshd_config | grep -o '[0-9]*')
MOD_SSH_DIR=
MOD_SSH_22_DIR=
MOD_SSH_2222_DIR=
IS_RUNNING=true
LOG_DIR=

# ASCII Art Variables  
RED='\e[0;31m'
RESET='\e[0m'

################################ Installation Functions ########################################

# Display Title Screen
function display_intro {
	echo -e "

                             /\      /\\
                             |\\\\\____//|
                             (|/    \/)
                             / (    ) \\
                ${RED}|||||||\\\\\\\  )   ${RESET}%)  (%   ${RED}(  ///||||||||
                ||           )  ${RESET}\\\\\  |/  ${RED}(           ||
                ||            )  ${RESET}\\\\\ |/  ${RED}(           ||
                  ||           /-- ${RESET}\@)${RED}--\         ||
                  ||       |              |       ||
                ||         ||            ||         ||
                ||         |||          |||         ||
                ||         ||||        ||||         ||
                |||||||||||||  \|    |/  |||||||||||||${RESET}

                       MARIST SSH HONEYPOT v0.1
            "

}

# Install dependencies 
function install_dependencies {
	echo "Installing dependencies..."
	apt-get update
	apt-get install wget make zlib1g-dev libssl-dev policycoreutils gcc -y
}

# Create directory structure
function create_dir {
	mkdir -p /usr/local/source/openssh
	mkdir /usr/local/source/openssh/openssh-22
	mkdir /usr/local/source/openssh/openssh-2222
	mkdir /var/log/ssh-honeypot
	MOD_SSH_DIR="/usr/local/source/openssh"
	MOD_SSH_22_DIR="/usr/local/source/openssh/openssh-22"
	MOD_SSH_2222_DIR="/usr/local/source/openssh/openssh-2222"
	LOG_DIR="/var/log/ssh-honeypot"
	echo "Created ${MOD_SSH_DIR};${MOD_SSH_22_DIR};${MOD_SSH_2222_DIR}"
	touch "${LOG_DIR}/install-22.log"
	touch "${LOG_DIR}/install-2222.log"
}

# Function to tailor OpenSSH 22
function configure_ssh_22 {
	# Downloading OpenSSH
	wget -P ${MOD_SSH_22_DIR} ftp://ftp4.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.2p1.tar.gz >> "${LOG_DIR}/install-22.log"
	cd ${MOD_SSH_22_DIR}
	tar -xf ${MOD_SSH_22_DIR}/openssh-7.2p1.tar.gz >> "${LOG_DIR}/install-22.log"
	mv ${MOD_SSH_22_DIR}/openssh-7.2p1 ${MOD_SSH_22_DIR}/openssh-7.2p1-22
	
	# Copying original files
	mv ${MOD_SSH_22_DIR}/openssh-7.2p1-22/auth-passwd.c ${MOD_SSH_22_DIR}/openssh-7.2p1-22/auth-passwd.c.orig
	mv ${MOD_SSH_22_DIR}/openssh-7.2p1-22/sshd.c ${MOD_SSH_22_DIR}/openssh-7.2p1-22/sshd.c.orig
	mv ${MOD_SSH_22_DIR}/openssh-7.2p1-22/auth2-pubkey.c ${MOD_SSH_22_DIR}/openssh-7.2p1-22/auth2-pubkey.c.orig
	
	# Tailoring SSH to take down password for Port 22
	echo "Copying SSH files..."
	cp ${STARTING_DIRECTORY}/build/auth-passwd.c ${MOD_SSH_22_DIR}/openssh-7.2p1-22/auth-passwd.c
	cp ${STARTING_DIRECTORY}/build/sshd.c ${MOD_SSH_22_DIR}/openssh-7.2p1-22/sshd.c
	cp ${STARTING_DIRECTORY}/build/auth2-pubkey.c ${MOD_SSH_22_DIR}/openssh-7.2p1-22/auth2-pubkey.c
	cp ${STARTING_DIRECTORY}/build/sshd_config-22 /usr/local/etc/sshd_config-22
	
	echo "Compiling & installing SSH..."
	cd ${MOD_SSH_22_DIR}/openssh-7.2p1-22
	./configure >> "${LOG_DIR}/install-22.log"
	make >> "${LOG_DIR}/install-22.log"
	make install >> "${LOG_DIR}/install-22.log"
	cp sshd /usr/local/sbin/sshd-22
	chmod a+rx sshd /usr/local/sbin/sshd-22
}

# Function to tailor OpenSSH 2222
function configure_ssh_2222 {
	# Downloading OpenSSH
	wget -P ${MOD_SSH_2222_DIR} ftp://ftp4.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.2p1.tar.gz >> "${LOG_DIR}/install-2222.log"
	cd ${MOD_SSH_2222_DIR}
	tar -xf ${MOD_SSH_2222_DIR}/openssh-7.2p1.tar.gz >> "${LOG_DIR}/install-2222.log"
	mv ${MOD_SSH_2222_DIR}/openssh-7.2p1 ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222
	
	# Copying original files
	mv ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/auth-passwd.c ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/auth-passwd.c.orig
	mv ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/sshd.c ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/sshd.c.orig
	mv ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/auth2-pubkey.c ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/auth2-pubkey.c.orig
	
	# Tailoring SSH to take down password for Port 2222
	echo "Copying SSH-2222 files..."
	echo "${STARTING_DIRECTORY} "
	cp ${STARTING_DIRECTORY}/build/auth-passwd-2222.c ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/auth-passwd.c
	cp ${STARTING_DIRECTORY}/build/sshd.c ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/sshd.c
	cp ${STARTING_DIRECTORY}/build/auth2-pubkey-2222.c ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222/auth2-pubkey.c
	cp ${STARTING_DIRECTORY}/build/sshd_config-2222 /usr/local/etc/sshd_config-2222
	
	echo "Compiling & installing SSH-2222..."
	cd ${MOD_SSH_2222_DIR}/openssh-7.2p1-2222
	./configure >> "${LOG_DIR}/install-2222.log"
	make >> "${LOG_DIR}/install-2222.log"
	cp sshd /usr/local/sbin/sshd-2222
	chmod a+rx sshd /usr/local/sbin/sshd-2222
}

# Finalizing configurations
function finalize_configuration {
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
	echo "/usr/local/sbin/sshd-22 -f /usr/local/etc/sshd_config-22 " >> /etc/rc.local
	echo "/usr/local/sbin/sshd-2222 -f /usr/local/etc/sshd_config-2222 " >> /etc/rc.local
	echo "exit 0" >> /etc/rc.local
	/usr/local/sbin/sshd-22 -f /usr/local/etc/sshd_config-22
	/usr/local/sbin/sshd-2222 -f /usr/local/etc/sshd_config-2222
	
	cd $STARTING_DIRECTORY
}

# Configure RSYSLOG
function configure_rsyslog {
	SYSLOG = $1
	DISK_SPACE = $2
	
	echo "Configuring RSYSLOG..."
	
	# Check Inputs
	if [ -z "$2" ]
	then
		DISK_SPACE = "1"
	fi
	if [ -z "$1" ]
	then
		SYSLOG = ""
	else
		sed -i '/#$ModLoad .*/ c\$ModLoad imtcp' /etc/rsyslog.conf
		sed -i '/#$InputTCPServerRun .*/ c\$InputTCPServerRun 514' /etc/rsyslog.conf
		echo "$WorkDirectory /var/lib/rsyslog" >> /etc/rsyslog.conf
		echo "*.* @@${SYSLOG}:514" > /etc/rsyslog.d/00-honeypot.confecho "$ActionQueueFileName fwdRule1" >> /etc/rsyslog.conf
		echo "$ActionQueueMaxDiskSpace ${DISK_SPACE}g" >> /etc/rsyslog.conf
		echo "$ActionQueueSaveOnShutdown on" >> /etc/rsyslog.conf
		echo "$ActionQueueType LinkedList" >> /etc/rsyslog.conf
		echo "$ActionResumeRetryCount -1" >> /etc/rsyslog.conf
		service rsyslog restart
	fi
}

#################################################################################################

# Check if user is root
if [ "$EUID" -ne 0 ]
then 
	echo -e "${RED}Please run as root${RESET}"
	exit 1
fi

# Running the script 
display_intro
while [ $IS_RUNNING ]
do
	echo -n "Please specify the port that SSH should be changed to [we recommend 48000-65535]:"
	read SSH_PORT
	sed -i "0,/RE/s/Port .*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
	CURRENT_SSH_PORT=$SSH_PORT
	
	echo -n "Please specify the ip that rsyslog should send logs to [press enter for none]:"
	read SYSLOG_SERV
	echo -n "Please specifiy the maximum number of GB to store for message queue[enter for 1GB]:"
	read MAX_SPACE
	configure_rsyslog $SYSLOG_SERV $MAX_SPACE
	
	if [ "$CURRENT_SSH_PORT" -ne 22 ] || [ "$CURRENT_SSH_PORT" -ne 2222 ]
	then
		service ssh restart
		
		install_dependencies
		create_dir
		configure_ssh_22
		configure_ssh_2222
		finalize_configuration
		IS_RUNNING=false
		break
	fi
done

#################################################################################################

exit
