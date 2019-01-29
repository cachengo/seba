#! /bin/bash
# SEBA installer
# Copyright 2019, Cachengo, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install base system dev dependencies
sudo apt update
sudo apt install -y curl \
	apt-transport-https \
    ca-certificates \
    software-properties-common \
    build-essential


# Install docker dependencies
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker ${USER}


# Getting ready to install K8S dependencies
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >>/etc/apt/sources.list.d/kubernetes.list' | sudo -s
sudo apt update
sudo apt install -y kubelet \
    kubeadm \
    kubectl
sudo swapoff -a

# Start Kubernetes
sudo kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=7.32.0.0/12"
kubectl taint nodes --all node-role.kubernetes.io/master-

