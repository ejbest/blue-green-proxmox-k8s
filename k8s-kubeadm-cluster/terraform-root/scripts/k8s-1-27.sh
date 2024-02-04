CONTROL_PLANE="$(ip -4 addr show $IFNAME | grep eth0 |grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"

echo "step1- install kubectl,kubeadm and kubelet 1.27.1"


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "kubeadm install"
sudo apt update -y
sudo apt -y install curl wget kubelet=1.27.1-00 kubeadm=1.27.1-00 kubectl=1.27.1-00

echo "Disable memory swapoff"
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sudo modprobe overlay
sudo modprobe br_netfilter

echo "Containerd setup"
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y
echo -ne '\n' | sudo apt-get -y install containerd
sudo -E bash <<EOF
sudo mkdir -p /etc/containerd
sudo containerd config default > /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable kubelet
EOF

echo "image pull and cluster setup"
echo "To be executed only on Controlplane node"
sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock --kubernetes-version v1.27.1
sudo kubeadm init   --pod-network-cidr=10.1.1.0/24   --upload-certs --kubernetes-version=v1.27.1  --control-plane-endpoint=$CONTROL_PLANE --ignore-preflight-errors=all  --cri-socket unix:///run/containerd/containerd.sock
mkdir -p $HOME/.kube
echo "y" | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#export KUBECONFIG=/etc/kubernetes/admin.conf

#echo "Apply flannel as CNI plugin"
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

echo "Install Cilium as CNI Plugin"

echo "Install Helm as prerequisite"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "Install Cilium using Helm"
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.13.4 --namespace kube-system
