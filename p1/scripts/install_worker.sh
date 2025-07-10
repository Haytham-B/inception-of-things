#!/bin/bash
set -ex
IP_MASTER=$1
IP_WORKER=$2
echo "===== [WORKER] Récupération du token depuis ${IP_MASTER}... ====="
TOKEN=$(curl --retry 15 --retry-connrefused --retry-delay 5 --fail --silent --show-error http://${IP_MASTER}:8000/node-token)
echo "===== [WORKER] Token récupéré ! Installation de K3s... ====="
curl -sfL https://get.k3s.io | K3S_URL="https://""${IP_MASTER}"":6443" K3S_TOKEN="${TOKEN}" INSTALL_K3S_EXEC="--node-ip=${IP_WORKER} --flannel-iface=eth1" sh -
echo "===== [WORKER] Installation terminée ! ====="cat 