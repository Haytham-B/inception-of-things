#!/bin/bash
set -ex

CLUSTER_NAME="iot-cluster"

echo "===== Création du cluster K3d : ${CLUSTER_NAME} ====="
# k3d cluster create : La commande pour créer un cluster.
# --api-port 6443 : Spécifie le port pour l'API Kubernetes.
# -p "8080:80@loadbalancer" : C'est la redirection de port de K3d.
#   Elle redirige le port 8080 de notre `iot-vm` vers le port 80 de
#   l'Ingress Controller qui tourne dans le cluster.
#   Le '@loadbalancer' signifie que la redirection se fait sur le
#   load balancer interne de K3d, qui distribue le trafic aux nœuds.
# --agents 1 : On demande un cluster avec 1 master et 1 worker.
k3d cluster create ${CLUSTER_NAME} --api-port 6443 -p "8080:80@loadbalancer" --agents 1

echo "===== Installation d'Argo CD dans le cluster ====="

# 1. On crée un "namespace" (un quartier) dédié à Argo CD.
kubectl create namespace argocd

# 2. On applique le manifeste d'installation officiel d'Argo CD.
#    Ce manifeste contient toutes les déclarations (Deployments, Services, etc.)
#    nécessaires pour faire tourner Argo CD.
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "===== Attente du démarrage des services Argo CD... ====="
# On attend que tous les Pods d'Argo CD soient prêts.
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s

echo "===== Cluster K3d et Argo CD sont prêts ! ====="
echo "Pour interagir : export KUBECONFIG=$(k3d kubeconfig get ${CLUSTER_NAME})"