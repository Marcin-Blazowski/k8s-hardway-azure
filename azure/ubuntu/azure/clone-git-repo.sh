#!/bin/bash
echo "Tony Halik tu bylem i git clone odpalilem"
uri=$1
branch=$2
mkdir -p /mnt/k8s-share/repo
cd /tmp
echo $HOSTNAME $uri >> /mnt/k8s-share/repo/uri.txt
git clone --branch $branch $uri
