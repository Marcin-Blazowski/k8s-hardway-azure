#!/bin/bash
# this is wrapper to execute scripts for master node pre-configuration step

# update hosts file
/tmp/k8s-hardway-azure/azure/ubuntu/azure/setup-hosts.sh

# install docker
/tmp/k8s-hardway-azure/azure/ubuntu/install-docker-2.sh

# allow-bridge-nf-traffic
/tmp/k8s-hardway-azure/azure/ubuntu/allow-bridge-nf-traffic.sh

