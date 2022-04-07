#!/bin/bash

HOSTNAME=$(hostname -s)
export HOME=~

# Run this only on worker-1
if [ "$HOSTNAME" != "worker-1" ]
then
  echo "This is not worker-1. Exiting."
  exit 0
fi

#get certs and config generated by master-1 on shared folder
cd /mnt/k8s-share/azure/ubuntu/lab_automation/CA
cp ca.crt ${HOSTNAME}.crt ${HOSTNAME}.key $HOME/
cd /mnt/k8s-share/azure/ubuntu/lab_automation/kube_configs
cp ${HOSTNAME}.kubeconfig $HOME/

# Download and Install Worker Binaries
KUBE_VERSION=`curl -L -s https://dl.k8s.io/release/stable.txt`
echo $KUBE_VERSION
cd /tmp

#wget -q --show-progress --https-only --timestamping \
echo "Downloading kubectl ..."
curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /tmp/kubectl
echo "Downloading kube-proxy ..."
curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kube-proxy -o /tmp/kube-proxy
echo "Downloading kubelet ..."
curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubelet -o /tmp/kubelet

# Create the installation directories:
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

# Install the worker binaries:
{
  chmod +x kubectl kube-proxy kubelet
  sudo mv kubectl kube-proxy kubelet /usr/local/bin/
}

#Configure the Kubelet
{
  cd $HOME
  sudo mv ${HOSTNAME}.key ${HOSTNAME}.crt /var/lib/kubelet/
  sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
  sudo mv ca.crt /var/lib/kubernetes/
}

## Create the kubelet-config.yaml configuration file:
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
EOF

## Create the kubelet.service systemd unit file:
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --tls-cert-file=/var/lib/kubelet/${HOSTNAME}.crt \\
  --tls-private-key-file=/var/lib/kubelet/${HOSTNAME}.key \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Configure the Kubernetes Proxy
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig

#Create the kube-proxy-config.yaml configuration file:
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.0.0.0/25"
EOF

#Create the kube-proxy.service systemd unit file:
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start the Worker Services
{
  sudo systemctl daemon-reload
  sudo systemctl enable kubelet kube-proxy
  sudo systemctl start kubelet kube-proxy
}