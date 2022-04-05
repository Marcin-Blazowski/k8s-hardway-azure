#!/bin/bash
# $1 = Azure storage account name
# $2 = Azure storage account key
# $3 = Azure file share name
# $4 = storageAccount suffix

# For more details refer to https://azure.microsoft.com/en-us/documentation/articles/storage-how-to-use-files-linux/

# update package lists
apt-get -y update

# install cifs-utils and mount file share
apt-get install cifs-utils

# set mount point path and create folder if missing
mountPointPath=/mnt/k8s-share
mkdir -p $mountPointPath

echo "mount -t cifs //$1.file.$4/$3 $mountPointPath -o vers=3.0,username=$1,password=$2,dir_mode=0755,file_mode=0664" >> /tmp/azure-mount-log.txt
mount -t cifs //$1.file.$4/$3 $mountPointPath -o vers=3.0,username=$1,password=$2,dir_mode=0755,file_mode=0664 >> /tmp/azure-mount-log.txt

# create marker files for testing
echo "hello from $HOSTNAME" > $mountPointPath/$HOSTNAME.txt