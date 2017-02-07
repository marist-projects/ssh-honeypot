#!/bin/bash

#################################################################################################
#                         MARIST SSH HONEYPOT UBUNTU INSTALL SCRIPT v0.1                        #
#                             MARIST COLLEGE NETWORKING DEPARTMENT                              #
#################################################################################################


####################################### Global Variables ########################################

STARTING_DIRECTORY=$(pwd)
echo $STARTING_DIRECTORY
CURRENT_SSH_PORT=$(grep -Eo 'Port *[0-9]+' /etc/ssh/sshd_config | grep -o '[0-9]*')
MOD_SSH_DIR=
MOD_SSH_22_DIR=
MOD_SSH_2222_DIR=
IS_RUNNING=true
LOG_DIR=
SYSLOG_SERV=
OS_DETECT=

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

function detect_os {
	if [[ $(head -1 /etc/os-release) == *"Debian"* ]]
	then
		OS_DETECT="Debian"
		echo $OS_DETECT
	elif [[ $(head -1 /etc/os-release) == *"Ubuntu"* ]]
	then
		OS_DETECT="Ubuntu"
		echo $OS_DETECT
	elif [[ $(head -1 /etc/os-release) == *"CentOS"* ]]
	then
		OS_DETECT="CentOS"
		echo $OS_DETECT
	elif [[ $(head -1 /etc/os-release) == *"Raspbian"* ]]
	then
		OS_DETECT="Minibian"
		echo $OS_DETECT
	fi
}

# Detect the OS to prevent redundancy
function install_dependencies {
	if [[ $OS_DETECT == "Debian" ]]
	then
		echo "Installing Debian dependencies..."
		apt-get update
		apt-get install wget make zlib1g-dev libssl-dev policycoreutils gcc -y
	elif [[ $OS_DETECT == "Ubuntu" ]]
	then
		echo "Installing Ubuntu dependencies..."
		apt-get update
		apt-get install wget make zlib1g-dev libssl-dev policycoreutils gcc -y
	elif [[ $OS_DETECT == "CentOS" ]]
	then
		echo "Installing CentOS dependencies..."
		yum update
		yum groupinstall ‘Development Tools’
		yum install wget zlib zlib-devel openssl-devel libssh-devel -y
	elif [[ $OS_DETECT == "Minibian" ]]
	then
		echo "Installing Minibian dependencies..."
		apt-get update
		apt-get install wget make zlib1g-dev libssl-dev policycoreutils gcc -y
	fi
}

# Create directory structure
function create_dir {
	mkdir -p /usr/local/source/openssh
	mkdir /var/log/ssh-honeypot
	MOD_SSH_DIR="/usr/local/source/openssh"
	echo "Created ${MOD_SSH_DIR}"
	touch "${LOG_DIR}/install.log"
}

# Function to tailor OpenSSH
function configure_new_ssh {
	# Downloading OpenSSH
	wget -P ${MOD_SSH_DIR} ftp://ftp4.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.2p1.tar.gz >> "${LOG_DIR}/install.log"
	cd ${MOD_SSH_DIR}
	tar -xf ${MOD_SSH_DIR}/openssh-7.2p1.tar.gz >> "${LOG_DIR}/install.log"
	
	# Copying original files
	mv ${MOD_SSH_DIR}/openssh-7.2p1/auth-passwd.c ${MOD_SSH_DIR}/openssh-7.2p1/auth-passwd.c.orig
	mv ${MOD_SSH_DIR}/openssh-7.2p1/sshd.c ${MOD_SSH_DIR}/openssh-7.2p1/sshd.c.orig
	mv ${MOD_SSH_DIR}/openssh-7.2p1/auth2-pubkey.c ${MOD_SSH_DIR}/openssh-7.2p1/auth2-pubkey.c.orig
	
	# Tailoring SSH to take down password 
	echo "Copying SSH files..."
	cp ${STARTING_DIRECTORY}/build/auth-passwd.c ${MOD_SSH_DIR}/openssh-7.2p1/auth-passwd.c
	cp ${STARTING_DIRECTORY}/build/sshd.c ${MOD_SSH_DIR}/openssh-7.2p1/sshd.c
	cp ${STARTING_DIRECTORY}/build/auth2-pubkey.c ${MOD_SSH_DIR}/openssh-7.2p1/auth2-pubkey.c
	
	echo "Compiling & installing SSH..."
	cd ${MOD_SSH_DIR}/openssh-7.2p1
	./configure >> "${LOG_DIR}/install.log"
	make >> "${LOG_DIR}/install.log"
	make install >> "${LOG_DIR}/install.log"
	cp sshd /usr/local/sbin/sshd-new
	chmod a+rx sshd /usr/local/sbin/sshd-new
}

function finalize_configurations {
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

	echo "Ports:" > /usr/local/etc/active_ports.txt
	if [[ $1 ]]
	then
		if [[ $1 == *","* ]]
		then
			for i in $(echo $1 | sed "s/,/ /g")
			do
				setup_configs $i
				echo "/usr/local/sbin/sshd-new -f /usr/local/etc/sshd_config-${i} " >> /etc/rc.local
				/usr/local/sbin/sshd-new -f /usr/local/etc/sshd_config-${i}
				echo -n "${i}," >> /usr/local/etc/active_ports.txt	
			done
		elif [[ $1 == *"-"* ]]
		then
			FIRST=$(($(cut -d "-" -f 1 <<< $1)))
			LAST=$(($(cut -d "-" -f 2 <<< $1)))
			for  ((i=$FIRST; i <= $LAST; i++))
			do
				echo ${i}	
				echo "Testing Range"
				setup_configs $i
				echo "/usr/local/sbin/sshd-new -f /usr/local/etc/sshd_config-${i} " >> /etc/rc.local
				/usr/local/sbin/sshd-new -f /usr/local/etc/sshd_config-${i}
				echo -n "${i}," >> /usr/local/etc/active_ports.txt	
			done
		else
			setup_configs $1
			echo "/usr/local/sbin/sshd-new -f /usr/local/etc/sshd_config-${1}" >> /etc/rc.local
			/usr/local/sbin/sshd-new -f /usr/local/etc/sshd_config-${1}
			echo -n "${1}," >> /usr/local/etc/active_ports.txt
		fi
	fi
	
	echo "exit 0" >> /etc/rc.local
	cd $STARTING_DIRECTORY
}

function setup_configs {
	cp ${STARTING_DIRECTORY}/build/sshd_config-template /usr/local/etc/sshd_config-${1}
	sed -i "0,/RE/s/Port .*/Port ${1}/g" /usr/local/etc/sshd_config-${1}
}

# Configure RSYSLOG
function configure_rsyslog {
	
	echo "Configuring RSYSLOG..."
	
	if [[ $1 && $2 ]]
	then
		if [[ $3 == "UDP" ]]
		then
			sed -i '/#$ModLoad imtcp/ c\$ModLoad imtcp' /etc/rsyslog.conf
			sed -i '/#$InputTCPServerRun .*/ c\$InputTCPServerRun 514' /etc/rsyslog.conf
		elif [[ $3 == "TCP" ]]
		then
			sed -i '/#$ModLoad imudp/ c\$ModLoad imudp' /etc/rsyslog.conf
			sed -i '/#$InputUDPServerRun .*/ c\$InputUDPServerRun 514' /etc/rsyslog.conf
		fi
		echo "#HONEYPOT CONFIGURATION START" >> /etc/rsyslog.conf
		echo "\$WorkDirectory /var/lib/rsyslog" >> /etc/rsyslog.conf
		echo "\$ActionQueueFileName fwdRule1" >> /etc/rsyslog.conf
		echo "\$ActionQueueMaxDiskSpace ${2}g" >> /etc/rsyslog.conf
		echo "\$ActionQueueSaveOnShutdown on" >> /etc/rsyslog.conf
		echo "\$ActionQueueType LinkedList" >> /etc/rsyslog.conf
		echo "\$ActionResumeRetryCount -1" >> /etc/rsyslog.conf
		echo "#HONEYPOT CONFIGURATION END" >> /etc/rsyslog.conf
		echo "*.* @@${1};RSYSLOG_SyslogProtocol23Format" > /etc/rsyslog.d/00-honeypot.conf
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
detect_os
while [ $IS_RUNNING ]
do
	echo -n "Please specify the port that SSH should be changed to (we recommend 48000-65535):"
	read SSH_PORT
	if [[ $OS_DETECT == "CentOS" ]]
	then 
		sed -i "0,/RE/s/#Port .*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
	else
		sed -i "0,/RE/s/Port .*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
	fi
	CURRENT_SSH_PORT=$SSH_PORT
	
	echo -n "Specify a port range or comma-separated ports to install honeypots on [22-30 or 22,2222,30]:"
	read FLAG_PORT

	echo -n "Please specify the ip that rsyslog should send logs to [press enter for none | format: 0.0.0.0:Port]:"
	read SYSLOG_SERV
	echo -n "Which protocol would you like to use for SYSLOG (UDP or TCP):"
	read PROTO
	echo -n "Please specifiy the maximum number of GB to store for message queue[enter for 1GB]:"
	read MAX_SPACE
	if [[ -z $MAX_SPACE ]]
	then
		TEMP="0"
		configure_rsyslog $SYSLOG_SERV $TEMP $PROTO
	else
		configure_rsyslog $SYSLOG_SERV $MAX_SPACE $PROTO
	fi
	
	if [ "$CURRENT_SSH_PORT" -ne 22 ] || [ "$CURRENT_SSH_PORT" -ne 2222 ]
	then
		if [[ $OS_DETECT == "CentOS" ]]
		then 
			service sshd restart
		else 
			service ssh restart
		fi
		
		install_dependencies
		create_dir
		configure_new_ssh
		finalize_configurations $FLAG_PORT
		IS_RUNNING=false
		break
	fi
done

#################################################################################################

exit
