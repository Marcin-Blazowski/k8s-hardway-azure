#!/bin/bash
echo "Tony Halik tu bylem i git clone odpalilem"
uri=$1
mkdir -p /mnt/k8s-share/repo
cd /mnt/k8s-share/repo
echo $HOSTNAME $uri >> /mnt/k8s-share/repo/uri.txt
# if this is master-1 VM
if [ "$HOSTNAME" == "master-1" ]
then
  git clone $uri
fi