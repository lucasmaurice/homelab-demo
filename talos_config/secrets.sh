#!/usr/bin/env bash

TalosKubeSecrets=$(op item get TalosKubeSecrets --format json)

jq -r '.fields[] | select(.section.label == "Base") | "- op: add\n  path: \(.label)\n  value: \(.value)"' <<< $TalosKubeSecrets

if [ "$1" == "--controlplane" ]; then
  jq -r '.fields[] | select(.section.label == "ControlPlane") | "- op: add\n  path: \(.label)\n  value: \(.value)"' <<< $TalosKubeSecrets
fi
