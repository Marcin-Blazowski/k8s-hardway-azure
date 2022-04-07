#!/bin/bash
HOSTNAME=$(hostname -s)
export HOME=~

# if this is master-1 then generate and share
if [ "$HOSTNAME" == "master-1" ]
then
  mkdir -p $HOME/CA
  rm -f $HOME/CA/*
  cd $HOME/CA

  # Create private key for CA
  openssl genrsa -out ca.key 2048

  # tune openssl
  openssl rand -writerand $HOME/.rnd

  # Create CSR using the private key
  openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr

  # Self sign the csr using its own private key
  openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial -out ca.crt -days 1000

  # Generate private key for admin user
  openssl genrsa -out admin.key 2048

  # Generate CSR for admin user. Note the OU.
  openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr

  # Sign certificate for admin user using CA servers private key
  openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out admin.crt -days 1000

  # Generate the kube-controller-manager client certificate and private key
  openssl genrsa -out kube-controller-manager.key 2048
  openssl req -new -key kube-controller-manager.key \
    -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr
  openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out kube-controller-manager.crt -days 1000

  #Generate the kube-proxy client certificate and private key
  openssl genrsa -out kube-proxy.key 2048
  openssl req -new -key kube-proxy.key \
    -subj "/CN=system:kube-proxy" -out kube-proxy.csr
  openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out kube-proxy.crt -days 1000

  # Generate the kube-scheduler client certificate and private key:
  openssl genrsa -out kube-scheduler.key 2048
  openssl req -new -key kube-scheduler.key \
    -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
  openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial  -out kube-scheduler.crt -days 1000

  # Put IP addresses into $HOME/CA/openssl.cnf file.
  MASTER_1_ADDRESS=$(host master-1 | cut -d" " -f4)
  MASTER_2_ADDRESS=$(host master-2 | cut -d" " -f4)
  LOADBALANCER_ADDRESS=$(host loadbalancer | cut -d" " -f4)

  cat <<EOF | sudo tee $HOME/CA/openssl.cnf.ips
IP.1 = 10.96.0.1
IP.2 = ${MASTER_1_ADDRESS}
IP.3 = ${MASTER_2_ADDRESS}
IP.4 = ${LOADBALANCER_ADDRESS}
IP.5 = 127.0.0.1
EOF
  
  cp /tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/openssl.cnf $HOME/CA/
  cat $HOME/CA/openssl.cnf.ips >> $HOME/CA/openssl.cnf

  # Generate certs for api-server
  openssl genrsa -out kube-apiserver.key 2048
  openssl req -new -key kube-apiserver.key -subj "/CN=kube-apiserver" \
    -out kube-apiserver.csr -config $HOME/CA/openssl.cnf
  openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out kube-apiserver.crt -extensions v3_req \
    -extfile openssl.cnf -days 1000

  # Put IP addresses into $HOME/CA/openssl-etcd.cnf file.
  cat <<EOF | sudo tee $HOME/CA/openssl-etcd.cnf.ips
IP.1 = ${MASTER_1_ADDRESS}
IP.2 = ${MASTER_2_ADDRESS}
IP.3 = 127.0.0.1
EOF
  
  cp /tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/openssl-etcd.cnf $HOME/CA/
  cat $HOME/CA/openssl-etcd.cnf.ips >> $HOME/CA/openssl-etcd.cnf

  # Generate certs for ETCD
  openssl genrsa -out etcd-server.key 2048
  openssl req -new -key etcd-server.key -subj "/CN=etcd-server" \
    -out etcd-server.csr -config $HOME/CA/openssl-etcd.cnf
  openssl x509 -req -in etcd-server.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial  -out etcd-server.crt -extensions v3_req \
    -extfile openssl-etcd.cnf -days 1000

  # Generate the service-account certificate and private key:
  openssl genrsa -out service-account.key 2048
  openssl req -new -key service-account.key -subj "/CN=service-accounts" \
    -out service-account.csr
  openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out service-account.crt -days 1000

  # Put IP addresses into $HOME/CA/openssl-worker-x.cnf file.
  WORKER_1_ADDRESS=$(host worker-1 | cut -d" " -f4)
  WORKER_2_ADDRESS=$(host worker-2 | cut -d" " -f4)
  cat <<EOF | sudo tee $HOME/CA/openssl-worker-1.cnf.ips
IP.1 = ${WORKER_1_ADDRESS}
EOF

  cat <<EOF | sudo tee $HOME/CA/openssl-worker-2.cnf.ips
IP.1 = ${WORKER_2_ADDRESS}
EOF
  
  cp /tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/openssl-worker-1.cnf $HOME/CA/
  cat $HOME/CA/openssl-worker-1.cnf.ips >> $HOME/CA/openssl-worker-1.cnf
  cp /tmp/k8s-hardway-azure/azure/ubuntu/lab_automation/openssl-worker-2.cnf $HOME/CA/
  cat $HOME/CA/openssl-worker-2.cnf.ips >> $HOME/CA/openssl-worker-2.cnf

  # Generate a certificate and private key for worker-1 node:
  openssl genrsa -out worker-1.key 2048
  openssl req -new -key worker-1.key -subj "/CN=system:node:worker-1/O=system:nodes" \
    -out worker-1.csr -config $HOME/CA/openssl-worker-1.cnf
  openssl x509 -req -in worker-1.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out worker-1.crt -extensions v3_req \
    -extfile $HOME/CA/openssl-worker-1.cnf -days 1000

  # Generate a certificate and private key for worker-2 node:
  openssl genrsa -out worker-2.key 2048
  openssl req -new -key worker-2.key -subj "/CN=system:node:worker-2/O=system:nodes" \
    -out worker-2.csr -config $HOME/CA/openssl-worker-2.cnf
  openssl x509 -req -in worker-2.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out worker-2.crt -extensions v3_req \
    -extfile $HOME/CA/openssl-worker-2.cnf -days 1000

  # copy to HOME dir
  cp $HOME/CA/*.crt $HOME/
  cp $HOME/CA/*.key $HOME/
  
  # copy to shared folder
  mkdir -p /mnt/k8s-share/azure/ubuntu/lab_automation/CA
  cp $HOME/CA/*.crt /mnt/k8s-share/azure/ubuntu/lab_automation/CA/
  cp $HOME/CA/*.key /mnt/k8s-share/azure/ubuntu/lab_automation/CA/

fi

# Copy the appropriate certificates and private keys to each controller instance:
cp /mnt/k8s-share/azure/ubuntu/lab_automation/CA/*.crt $HOME/
cp /mnt/k8s-share/azure/ubuntu/lab_automation/CA/*.key $HOME/