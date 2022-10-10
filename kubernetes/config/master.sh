# Set current version
VERSION=${VERSION:-"1.25.2"}

# Useful alias
echo 'alias k="kubectl"' >> $HOME/.bashrc

# Usefull libs
sudo snap install yq

# Cleanup first
rm -rf $HOME/.kube
sudo kubeadm reset -f || true
sudo apt-mark unhold kubelet kubeadm kubectl || true
sudo apt-get remove -y containerd kubelet kubeadm kubectl kubernetes-cni || true
sudo apt-get autoremove -y
sudo systemctl daemon-reload

# Couples of prerequisites
sudo apt-get update
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo modprobe overlay
sudo modprobe br_netfilter

# NFS client
sudo apt-get install -y nfs-common

# Installing packages
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update
sudo apt-get install -y kubelet=${VERSION}-00 kubeadm=${VERSION}-00 kubectl=${VERSION}-00 kubernetes-cni

# Installing Containerd
sudo apt-get install containerd -y
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml  
sudo service containerd restart
sudo service kubelet restart  

# Installing Helm client
sudo snap install helm --classic

# Configure crictl to use Containerd (it uses Docker by default)
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF

# Install etcdctl (linux amd64 or arm64)
ARCH=$(dpkg --print-architecture)
ETCDCTL_VERSION=v3.5.2
ETCDCTL_VERSION_FULL=etcd-${ETCDCTL_VERSION}-linux-$ARCH
wget https://github.com/etcd-io/etcd/releases/download/${ETCDCTL_VERSION}/${ETCDCTL_VERSION_FULL}.tar.gz
tar xzf ${ETCDCTL_VERSION_FULL}.tar.gz
sudo mv ${ETCDCTL_VERSION_FULL}/etcdctl /usr/bin/
rm -rf ${ETCDCTL_VERSION_FULL} ${ETCDCTL_VERSION_FULL}.tar.gz

# Install nerdctl
NERDCTL_VERSION=0.17.0
wget https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-${ARCH}.tar.gz
sudo tar Cxzvvf /usr/local/bin nerdctl-${NERDCTL_VERSION}-linux-${ARCH}.tar.gz
rm nerdctl-${NERDCTL_VERSION}-linux-${ARCH}.tar.gz

# Install useful kubectl aliases
curl -sSLO https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases
echo '[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases' >> .bashrc
