#!/bin/bash
set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 | awk '{print $2}' | cut -d/ -f1)"
# put the data into shared folder
echo "${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local" >> /mnt/k8s-share/k8s-hosts.txt
# and we can add this to /etc/hosts later after the data is put by all nodes/VMs
