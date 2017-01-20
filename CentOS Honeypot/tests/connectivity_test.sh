#!/bin/bash

function verify_honeypot() {
	local LOG_PATH=$1
	local HP_IP=$2
	local SSH_PORT=$3

	set timeout 30
	ssh -p ${SSH_PORT} testing@${HP_IP}
	expect "testing@${HP_IP}'s password" 
	send "testing\r"
	expect "refused"
	send "^" 
	interact

	my_string=$?
	substring=refused
	if [ "${my_string/$substring}" = "$my_string" ] ; then
	  echo "${substring} is not in ${my_string}"
	else
	  echo "${substring} was found in ${my_string}"
	fi
}