#!/bin/bash

# Setup a basic cloud system (system update)
echo "=== setup-cloud.sh $(hostname) $(date)"

# Wait for cloud-init to complete
if [ -x /usr/bin/cloud-init ] ; then
   echo "+++ cloud-init: waiting for cloud-init to complete"
   cloud-init status --wait
fi

# upgrade system on deb based systems
if [ -x /usr/bin/apt-get -a -x /usr/bin/sudo ] ; then
    sudo apt-get update
    #sudo unattended-upgrade --verbose # security only updates
    #sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
fi

# upgrade system on rpm based systems.
if [ -x /usr/bin/yum ] ; then
    sudo yum update -y

    if [ -x /usr/bin/amazon-linux-extras ] ; then
	sudo amazon-linux-extras install epel
    else
	sudo yum install -y epel-release
    fi
 
fi
