#!/bin/bash
# this is wrapper to execute scripts for master node pre-configuration step
echo "Hello from ${HOSTNAME}!">> /mnt/k8s-share/wrapper-hello.txt

# install docker
/tmp/k8s-hardway-azure/azure/ubuntu/install-docker-2.sh

#disable IP v6
#/tmp/k8s-hardway-azure/azure/ubuntu/azure/disable-ipv6.sh

# allow-bridge-nf-traffic
/tmp/k8s-hardway-azure/azure/ubuntu/allow-bridge-nf-traffic.sh
