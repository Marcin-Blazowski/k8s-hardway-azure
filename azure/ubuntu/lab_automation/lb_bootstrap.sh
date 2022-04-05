#!/bin/bash

# Provision a Network Load Balancer
sudo apt-get update && sudo apt-get install -y haproxy

LOADBALANCER_ADDRESS=$(host loadbalancer | cut -d" " -f4)
MASTER-1_ADDRESS=$(host master-1 | cut -d" " -f4)
MASTER-2_ADDRESS=$(host master-2 | cut -d" " -f4)

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg 
frontend kubernetes
    bind ${LOADBALANCER_ADDRESS}:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server master-1 ${MASTER-1_ADDRESS}:6443 check fall 3 rise 2
    server master-2 ${MASTER-2_ADDRESS}:6443 check fall 3 rise 2
EOF

sudo service haproxy restart
