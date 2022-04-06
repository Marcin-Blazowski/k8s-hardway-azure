#!/bin/bash
# this is wrapper to execute scripts for master node pre-configuration step
echo "Hello from ${HOSTNAME}!">> /mnt/k8s-share/automation-wrapper-hello.txt

#disable IP v6
/tmp/k8s-hardway-azure/azure/ubuntu/azure/disable-ipv6.sh

/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/grant_ssh.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/install_kubectl.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/create_CA.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/create_kube_configs.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/create_encryption_config.sh

/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/etcd_bootstrap.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/control_plane_bootstrap.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/configure_admin_kubectl.sh
/tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/tls_master_config.sh