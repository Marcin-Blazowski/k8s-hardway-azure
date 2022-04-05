#!/bin/bash
# this is wrapper to execute scripts for master node pre-configuration step
echo "Hello from ${HOSTNAME}!">> /mnt/k8s-share/automation-wrapper-hello.txt

# install docker
/tmp/k8s-hardway-azure/azure/ubuntu/install-docker-2.sh

# allow-bridge-nf-traffic
/tmp/k8s-hardway-azure/azure/ubuntu/allow-bridge-nf-traffic.sh

/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/grant_ssh.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/install_kubectl.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/create_kube_configs.sh

/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/configure_admin_kubectl.sh

/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/node_bootstrap.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/tls_node_bootstrap.sh
        
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/pod_networking.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/coredns_deploy.sh
        
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/kubelet_auth.sh

/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/smoke_tests.sh