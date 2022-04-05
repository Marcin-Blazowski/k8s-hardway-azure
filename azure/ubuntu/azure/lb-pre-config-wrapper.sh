#!/bin/bash
# this is wrapper to execute scripts for loadbalancer node pre-configuration step
# nothing is needed for master node on azure
echo "Hello from ${HOSTNAME}!">> /mnt/k8s-share/wrapper-hello.txt