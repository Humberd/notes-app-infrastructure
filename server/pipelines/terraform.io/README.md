# How to use?

Apply:

1. service-account.yml
2. roles.yml
3. Run
```bash
TOKEN=`kubectl get serviceaccounts/terraform.io -n kube-system -o=jsonpath="{.secrets[0].name}"`
kubectl get secret $TOKEN -n kube-system -o json
```
4. In the kubernetes provider paste the values:

data['ca.crt'] is cluster_ca_certificate
data.token is token

