#!/bin/bash
# this is wrapper to execute scripts for master node pre-configuration step
echo "Hello from ${HOSTNAME}!">> /mnt/k8s-share/wrapper-hello.txt

#disable IP v6
#/tmp/k8s-hardway-azure/azure/ubuntu/azure/disable-ipv6.sh
