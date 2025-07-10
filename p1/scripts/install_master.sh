#!/bin/bash
set -ex
IP_MASTER="192.168.56.110"
echo "===== [MASTER] Installation de K3s... ====="
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=${IP_MASTER} --flannel-iface=eth1" sh -
echo "===== [MASTER] Attente du démarrage de K3s (25s)... ====="
sleep 25
echo "===== [MASTER] Configuration de kubectl... ====="
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant -R /home/vagrant/.kube
chmod 600 /home/vagrant/.kube/config
echo "===== [MASTER] Installation de Python3... ====="
apt-get update -y && apt-get install -y python3
echo "===== [MASTER] Récupération du token... ====="
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
echo "===== [MASTER] Préparation du serveur de token... ====="
mkdir -p /tmp/share
echo "${TOKEN}" > /tmp/share/node-token
echo "===== [MASTER] Lancement du serveur de token... ====="
nohup bash -c "cd /tmp/share && python3 -m http.server 8000 --bind 0.0.0.0 &" > /tmp/server.log 2>&1 &
echo "===== [MASTER] Le master est prêt. ====="