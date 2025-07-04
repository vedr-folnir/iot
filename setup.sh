#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install -y curl git docker.io gnupg2 unzip

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

sudo usermod -aG docker vagrant

curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

k3d cluster create demo --wait

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

kubectl create ns playground

kubectl apply -f /vagrant/argocd/app.yaml
