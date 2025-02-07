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