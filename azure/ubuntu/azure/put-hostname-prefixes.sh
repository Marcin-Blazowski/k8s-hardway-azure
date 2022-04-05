#!/bin/bash
MasterPrefix=$1
WorkerPrefix=$2
MasterCount=$3
WorkerCount=$4
# mkdir -p /mnt/k8s-share
cd /mnt/k8s-share
# if this is master-1 VM
if [ "$HOSTNAME" == "master-1" ]
then
  echo master-prefix $MasterPrefix >> /mnt/k8s-share/k8s-hostname-prefixes.txt
  echo worker-prefix $WorkerPrefix >> /mnt/k8s-share/k8s-hostname-prefixes.txt
  echo master-count $MasterCount >> /mnt/k8s-share/k8s-hostname-prefixes.txt
  echo worker-count $WorkerCount >> /mnt/k8s-share/k8s-hostname-prefixes.txt
fi