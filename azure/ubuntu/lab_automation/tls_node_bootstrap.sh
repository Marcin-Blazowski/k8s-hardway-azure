#!/bin/bash

HOSTNAME=$(hostname -s)

# Run this on worker[2-x]. Do not run on worker-1
if [ "$HOSTNAME" == "worker-1" ]
then
  echo "This is worker-1. Exiting."
  exit 0
fi

#get cert and bootstrap token generated by master-1 on shared folder
cd /mnt/k8s-share/azure/ubuntu/lab_automation/CA
cp ca.crt $HOME/
cp bootstrap-token.txt $HOME/

# Download and Install Worker Binaries
KUBE_VERSION=`curl -L -s https://dl.k8s.io/release/stable.txt`
echo $KUBE_VERSION
cd /tmp

echo "Downloading kubectl ..."
wget --timestamping https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl 2>&1 --progress=bar:force | grep '%'
echo "Downloading kube-proxy ..."
wget --timestamping https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kube-proxy 2>&1 --progress=bar:force | grep '%'
echo "Downloading kubelet ..."
wget --timestamping https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubelet 2>&1 --progress=bar:force | grep '%'

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

# Configure the Kubelet
{
  cd $HOME
  sudo mv ca.crt /var/lib/kubernetes/
}

# make sure the old kubeconfig is not there
rm -f /var/lib/kubelet/kubeconfig

## Configure Kubelet for TLS bootstrap
. $HOME/bootstrap-token.txt

LOADBALANCER_ADDRESS=$(host loadbalancer | cut -d" " -f4)

cat <<EOF | sudo tee /var/lib/kubelet/bootstrap-kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/lib/kubernetes/ca.crt
    server: https://${LOADBALANCER_ADDRESS}:6443
  name: bootstrap
contexts:
- context:
    cluster: bootstrap
    user: kubelet-bootstrap
  name: bootstrap
current-context: bootstrap
kind: Config
preferences: {}
users:
- name: kubelet-bootstrap
  user:
    token: ${TOKEN_ID}.${TOKEN_SECRET}
EOF

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
  --bootstrap-kubeconfig="/var/lib/kubelet/bootstrap-kubeconfig" \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --cert-dir=/var/lib/kubelet/pki/ \\
  --rotate-certificates=true \\
  --rotate-server-certificates=true \\
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

# This does not work as expected but provides waiting for kubelet to start
# and create certificate signing reqest (csr).
cd
sleep 5
kubectl wait --for=condition=Pending csr --all --timeout=10s

# and approve csr
CSR_ID=`kubectl get csr | grep worker | grep Pending | cut -d" " -f1`
echo "CSR ID = ${CSR_ID}"
if [[ -z "$CSR_ID" ]]
then
  echo "It looks like cert sign req is missing."
  echo "Please approve it manually later by running"
  echo "kubectl certificate approve <CSR_ID>"
else
  kubectl certificate approve ${CSR_ID}
fi