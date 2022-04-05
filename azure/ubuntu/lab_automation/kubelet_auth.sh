#!/bin/bash
HOSTNAME=$(hostname -s)

cp /mnt/k8s-share/azure/ubuntu/lab_automation/cluster_role_nodes.yaml $HOME/
cp /mnt/k8s-share/azure/ubuntu/lab_automation/cluster_role_binding_nodes.yaml $HOME/

kubectl apply -f $HOME/cluster_role_nodes.yaml
kubectl apply -f $HOME/cluster_role_binding_nodes.yaml


