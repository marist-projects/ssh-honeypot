# SSH-Honeypot
##General Automatic Install Documentation
- [ ] Pre-Install Commands
	- [ ] Update and Upgrade Packages 
		- [ ] apt-get update && apt-get upgrade/yum update && yum upgrade
	- [ ] Download Source Files
		- [ ] apt-get install git/yum install git
		- [ ] git clone https://github.com/marist-projects/ssh-honeypot.git
- [ ] Install Commands
	- [ ] Change file permissions
		- [ ] chmod +x install.sh uninstall.sh
	- [ ] Run install script
		- [ ] ./install.sh
	- [ ] Install Options
		- [ ] Please specify the port that SSH should be changed to (we recommend 48000-65535)
			- [ ] Enter any port atleast 48000 or above
		- [ ] Specify a port range or comma-separated ports to install honeypots on [22-30 or 22,2222,30]
			- [ ] You can manually enter ports seperated by a comma or enter a port range
		- [ ] Please specify the ip that rsyslog should send logs to [press enter for none | format: 0.0.0.0:Port]
			- [ ] You can enter your Syslog server ip here, followed by the port. If you do not want the logs to be send anywhere just hit enter
		- [ ] Which protocol would you like to use for SYSLOG (UDP or TCP)
			- [ ] Specify UDP or TCP for sending your logs
		- [ ] Please specifiy the maximum number of GB to store for message queue[enter for 1GB]
			- [ ] Please enter a numberic value for the amount of GBs you want to decicate to the message queue

##General Automatic Uninstall Documentation
- [ ] Uninstalling
	- [ ] Run uninstall script
		- [ ] ./uninstall.sh
		- [ ] ONLY run if you would like to revert your server back
		
##FAQ
1. Where do I find manual install/uninstall instructions?
..* You can find manual install/uninstall instructions in the documentation folder
2. Why do you recommend putting the real SSH port above 48000?
..* Most scripts do not bother to scan that high. If you want to further protect yourself please use SSH keys.
	

# License
This is a minimal-interaction SSH-Honeypot and can be used as a "Brute-Force" Analysis Tool.

Copyright (C) 2016 Marist College IT Department

Some code used by SSH Honeypots is directly based off of Eric Wedaa's work at Marist College.
Files and code will be especially accredited to him and his contributors in each 
source file. Some functionality of the SSH Honeypot is directly based off of Eric Wedaa's
Longtail project. 

A copy of the Apache License is available in this repository in the [LICENSE](LICENSE) file.