#!/bin/bash
HOSTNAME=$(hostname -s)
export HOME=~
# generate key pair if on master-1 VM and copy to the shared folder
if [ "$HOSTNAME" = "master-1" ]
then
  rm -f $HOME/.ssh/id_rsa*
  ssh-keygen -f $HOME/.ssh/id_rsa -q -N ""
  mkdir -p /mnt/k8s-share/ssh
  cat $HOME/.ssh/id_rsa.pub >> /mnt/k8s-share/ssh/authorized_keys
fi

# authorize SSH access on all other nodes and master-1 itself
cat /mnt/k8s-share/ssh/authorized_keys >> ~/.ssh/authorized_keys
