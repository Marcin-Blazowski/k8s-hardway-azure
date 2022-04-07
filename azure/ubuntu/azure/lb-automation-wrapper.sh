#!/bin/bash
# this is wrapper to execute scripts for loadbalancer node pre-configuration step
# nothing is needed for master node on azure
echo "Hello from ${HOSTNAME}!">> /mnt/k8s-share/automation-wrapper-hello.txt

#disable IP v6
#/tmp/k8s-hardway-azure/azure/ubuntu/azure/disable-ipv6.sh

/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/lb_bootstrap.sh
