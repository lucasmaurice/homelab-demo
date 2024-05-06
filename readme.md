# Kubernetes Stack Parts

This is a list of the core parts of the stack. It is not *supposed* to be exhaustive, but it is a good starting point

This should also be a good place to document the upgrade process, and the commands to check the versions of the OS and the extensions.

## Summary

Here is a summary of the parts of the stack, and the versions that are currently installed.

Follow order of the table to upgrade the stack. Ensure the compatibility of the versions before upgrading.

| Part                     | Last checked Version | Get version                                                                                                              | Releases                                                                 | Upgrade process                                                                                                                 |
| ------------------------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| Cert Manager             | v1.14.4              | `cmctl version`                                                                                                          | <https://cert-manager.io/docs/releases/release-notes/release-notes-1.14> | helm upgrade                                                                                                                    |
| MetalLB                  | v0.14.3              | `kubectl get daemonsets,deployments -n metallb-system -o custom-columns=NAME:.metadata.name,KIND:.kind,IMAGES:{..image}` | <https://metallb.universe.tf/installation/#upgrade>                      | helm upgrade                                                                                                                    |
| Kubernetes Ingress Nginx | v1.10.0              | `kubectl get deployments -n ingress-nginx -o custom-columns=NAME:.metadata.name,KIND:.kind,IMAGES:{..image}`             | <https://github.com/kubernetes/ingress-nginx/releases/latest>            | helm upgrade                                                                                                                    |
| Democratic CSI           | v1.8.4 - v0.5.6      | `kubectl get daemonsets,deployments -n democratic-csi -o custom-columns=NAME:.metadata.name,KIND:.kind,IMAGES:{..image}` | <https://github.com/democratic-csi/democratic-csi/tags>                  | Bump the version in the `democratic-csi` values file - check the driver AND the csi-grpc-proxy                                  |
| Teleport                 | 15.1.7               | `tsh version`                                                                                                            | <https://github.com/gravitational/teleport/releases/latest>              | helm upgrade                                                                                                                    |
| Talos Linux              | v1.6.7               | `talosctl get members`                                                                                                   | <https://github.com/siderolabs/talos/releases/latest>                    | Follow the [Upgrade OS Process](./config.md#upgrade-os)                                                                         |
| Calico CNI               | v3.27.3              | `kubectl calico version`                                                                                                 | <https://github.com/projectcalico/calico/releases/latest>                | <https://docs.tigera.io/calico/latest/operations/upgrading/kubernetes-upgrade#upgrading-an-installation-that-uses-the-operator> |
| Kubernetes               | v1.29.4              | `kubectl version`                                                                                                        | <https://kubernetes.io/releases/>                                        | <https://www.talos.dev/v1.6/kubernetes-guides/upgrading-kubernetes/>                                                            |
| Sealed Secrets           |  | `TBD` | <> | <> |

## List of parts

### Talos Linux

Talos is the operating system that runs on the nodes. It is a minimal Linux distribution that is designed to run Kubernetes.

### Calico CNI

Calico is the network plugin that is used to provide networking for the Kubernetes cluster.

### MetalLB

MetalLB is a load balancer that is used to provide external access to services in the cluster.

### Democractic CSI

Democratic CSI is a CSI driver that is used to provide persistent storage for the cluster.

### Cert Manager

Cert Manager is a tool that is used to manage certificates in the cluster.

### Kubernetes Ingress Nginx

Kubernetes Ingress Nginx is a tool that is used to provide ingress for the cluster.

### Teleport

Teleport is a tool that is used to provide access to the cluster.

### Bitnami Sealed Secrets

Bitnami Sealed Secrets is a tool that is used to store encrypted secrets in the git repository and automatically decrypt them in the cluster to Secrets objects.

#### Example of creating a sealed secret

> Note: Beware as the secret can only be decrypted if the name and namespace match the one which is created with. 
> You need to encrypt the secret with the correct namespace and name.

```bash
echo -n "Token: " ; read -s token ; echo
echo -n "User Key: " ; read -s userkey ; echo
kubectl create secret generic dns-updater-pushover-secret --namespace dns-updater --dry-run=client --from-literal=userkey=$userkey --from-literal=token=$token -o json | kubeseal -o yaml
```
