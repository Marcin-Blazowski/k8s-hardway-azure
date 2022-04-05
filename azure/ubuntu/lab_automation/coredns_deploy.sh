#!/bin/bash
HOSTNAME=$(hostname -s)

# Run this only on worker-2. This is to enforce delay
if [ "$HOSTNAME" != "worker-2" ]
then
  echo "This is not worker-2. Exiting."
  exit 0
fi

cp /mnt/k8s-share/azure/ubuntu/lab_automation/coredns.yaml $HOME/

kubectl apply -f $HOME/coredns.yaml