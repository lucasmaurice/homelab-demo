# Configuration documentation

```bash
ControlPlane="10.250.11.21"
Workers="10.250.11.22,10.250.11.23,10.250.11.24,10.250.11.25"
AllNodes="$ControlPlane,$Workers"

talosctl gen secrets -o secrets.yaml
talosctl gen config --with-secrets secrets.yaml djls-lab https://$ControlPlane:6443
talosctl --talosconfig=./talosconfig config endpoint $ControlPlane

talosctl apply-config --talosconfig talosconfig -i -f base.yaml -p @patches/controlplane.patch -p @patches/sv1.patch -n 10.250.11.21
talosctl bootstrap -n 10.250.11.21 --talosconfig ./talosconfig

talosctl apply-config --insecure --nodes 10.250.11.22 --file worker.yaml
talosctl apply-config --insecure --nodes 10.250.11.23 --file worker.yaml
talosctl apply-config --insecure --nodes 10.250.11.24 --file worker.yaml
talosctl apply-config --insecure --nodes 10.250.11.25 --file worker.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/master/manifests/custom-resources.yaml -O
```

## Cluster initialization

1. Ensure that the shared hostname point to the first node
2. Apply the controlplane configuration to the first node
3. Bootstrap the cluster `talosctl bootstrap -n sv1.lab.djls.space`
4. Wait until the shared IP is responding
5. Move the DNS to the shared IP
6. Run apply-config on the rest of the nodes

> Ensure that you have cd into the talos_config directory

talosctl apply-config -m reboot -f base.yaml -p @patches/controlplane.yaml -p @patches/sv1.yaml -p @<(./secrets.sh --controlplane) -n sv1.lab.djls.space --insecure
talosctl apply-config -m reboot -f base.yaml -p @patches/controlplane.yaml -p @patches/sv2.yaml -p @<(./secrets.sh --controlplane) -n sv2.lab.djls.space --insecure
talosctl apply-config -m reboot -f base.yaml -p @patches/controlplane.yaml -p @patches/sv3.yaml -p @<(./secrets.sh --controlplane) -n sv3.lab.djls.space --insecure
talosctl apply-config -m reboot -f base.yaml -p @patches/sv4.yaml -p @<(./secrets.sh) -n sv4.lab.djls.space --insecure
talosctl apply-config -m reboot -f base.yaml -p @patches/sv5.yaml -p @<(./secrets.sh) -n sv5.lab.djls.space --insecure

## Upgrade OS

1. Go to <https://factory.talos.dev/>
2. Select the version
3. Select the following extensions:
   - `siderolabs/intel-ucode`
   - `siderolabs/iscsi-tools`
4. Validate the configuration
5. Get the installer url and replace it in the following commands:

talosctl -n sv1.lab.djls.space upgrade --wait --image factory.talos.dev/installer/22a73b21ea2e27057f17a22b56fdf89e09868979c10d22f10a9b7e9c1e988a60:v1.6.7
talosctl -n sv2.lab.djls.space upgrade --wait --image factory.talos.dev/installer/22a73b21ea2e27057f17a22b56fdf89e09868979c10d22f10a9b7e9c1e988a60:v1.6.7
talosctl -n sv3.lab.djls.space upgrade --wait --image factory.talos.dev/installer/22a73b21ea2e27057f17a22b56fdf89e09868979c10d22f10a9b7e9c1e988a60:v1.6.7
talosctl -n sv4.lab.djls.space upgrade --wait --image factory.talos.dev/installer/22a73b21ea2e27057f17a22b56fdf89e09868979c10d22f10a9b7e9c1e988a60:v1.6.7
talosctl -n sv5.lab.djls.space upgrade --wait --image factory.talos.dev/installer/22a73b21ea2e27057f17a22b56fdf89e09868979c10d22f10a9b7e9c1e988a60:v1.6.7

## Other commands

- Generate the kubeconfig context: `talosctl kubeconfig --talosconfig talosconfig -n 10.250.11.21`
- Check cluster members and OS versions: `talosctl get members`

talosctl get extensions -n sv4.lab.djls.space
talosctl get extensions -n sv5.lab.djls.space

talosctl -n sv1.lab.djls.space images ; echo "---"
talosctl -n sv2.lab.djls.space images ; echo "---"
talosctl -n sv3.lab.djls.space images ; echo "---"
talosctl -n sv4.lab.djls.space images ; echo "---"
talosctl -n sv5.lab.djls.space images ; echo "---"

## Build custom Talos image

```bash
mkdir /tmp/talos-out
docker run --rm -t -v /tmp/talos-out:/out ghcr.io/siderolabs/imager:v1.6.2 installer --arch amd64 --system-extension-image ghcr.io/siderolabs/iscsi-tools:v0.1.4
crane push /tmp/talos-out/installer-amd64.tar ghcr.io/justereseau/talos-installer:v1.6.2-worker
rm -rf /tmp/talos-out
```

## Check up nodes

```bash
fping --timeout=50 --file - <<EOF
sv1.lab.djls.space
sv2.lab.djls.space
sv3.lab.djls.space
sv4.lab.djls.space
sv5.lab.djls.space
EOF
```
