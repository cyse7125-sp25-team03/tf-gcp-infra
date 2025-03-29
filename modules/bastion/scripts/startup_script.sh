#!/bin/bash
apt-get update
apt-get install -y apt-transport-https ca-certificates gnupg curl

# Add Google Cloud SDK repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Add Kubernetes repository
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

# Install components
apt-get update
apt-get install -y google-cloud-sdk kubectl google-cloud-sdk-gke-gcloud-auth-plugin

# Configure environment variables
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' | sudo tee /etc/profile.d/gke_auth.sh
echo 'export PATH=$PATH:/usr/lib/google-cloud-sdk/bin' | sudo tee -a /etc/profile.d/gke_auth.sh
source /etc/profile.d/gke_auth.sh

# Ensure gcloud components are up-to-date
gcloud components update -q

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install Helm Secrets plugin
helm plugin install https://github.com/jkroepke/helm-secrets

# Install SOPS for secrets encryption
curl -LO https://github.com/getsops/sops/releases/download/v3.9.4/sops-v3.9.4.linux.amd64
sudo mv sops-v3.9.4.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops
