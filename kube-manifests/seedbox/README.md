# Extra

## Create secrets

### NordVPN

First go on the [NordVPN website](https://my.nordaccount.com/fr/dashboard/nordvpn/manual-configuration/) and get the service credentials".

Then create the secret with the following commands:

```bash
echo -n "NordVPN Service Username (Hidden)": ; read -s _USERNAME
echo -n "\nNordVPN Service Password (Hidden)": ; read -s _PASSWORD
echo -n "\n"
kubectl create secret generic nordvpn-credentials --from-literal username=$_USERNAME --from-literal  password=$_PASSWORD -n servarr-seedbox
unset _USERNAME ; unset _PASSWORD
```

### Transmission

Setup the required transmission credentials.

```bash
echo -n "Transmission Username (Hidden)": ; read -s _USERNAME
echo -n "\nTransmission Password (Hidden)": ; read -s _PASSWORD
echo -n "\n"
kubectl create secret generic transmission-credentials --from-literal username=$_USERNAME --from-literal  password=$_PASSWORD -n servarr-seedbox
unset _USERNAME ; unset _PASSWORD
```
