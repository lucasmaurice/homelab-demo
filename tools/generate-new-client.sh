#!/usr/bin/env bash

export BASE_PATH=./talos_config/base.yaml

# Requirements:
# - 1password CLI (brew install 1password-cli)
# - jq
# - yq

# Get the CA_CRT from config file
yq eval .machine.ca.crt $BASE_PATH | base64 -d > ca.crt

# Get the CA Key from 1password
op item get TalosKubeSecrets --vault "HomeLab" --format json | jq -r '.fields[] | select(.label == "/machine/ca/key") | .value' | base64 -d > ca.key

# Generate the admin key, csr, and crt
talosctl gen key --name admin
talosctl gen csr --key admin.key --ip 127.0.0.1
talosctl gen crt --ca ca --csr admin.csr --name admin --hours 24

# generate Talosconfig file
tee <<EOF > ~/.talos/config
context: DJLS-Lab
contexts:
  DJLS-Lab:
    endpoints:
      - kube.lab.djls.space
    nodes:
      - kube.lab.djls.space
    ca: $(yq eval .machine.ca.crt $BASE_PATH)
    crt: $(cat admin.crt | base64)
    key: $(cat admin.key | base64)
EOF

# clean up
rm ca.crt ca.key admin.key admin.csr admin.crt
