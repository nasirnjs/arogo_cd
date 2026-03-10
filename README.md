
GitOps is a DevOps practice where Git is used as the single source of truth to manage infrastructure and application deployments. In GitOps, everything about your system (infrastructure, Kubernetes manifests, configs, policies) is stored in a Git repository, and changes are applied to the system automatically through Git commits. 🚀

GitOps = Using Git + automation to manage infrastructure and deployments.


## ArgoCD CLI for Mac

```bash
curl -sSL -o argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-darwin-arm64

chmod +x argocd
sudo mv argocd /usr/local/bin/
```

```bash
argocd version
```

## ArgoCD CLI for Linux
```bash
curl -sSL -o argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

chmod +x argocd
sudo mv argocd /usr/local/bin/
```

```bash
argocd version
```

## Get the Admin Password and login into ArgoCD

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

```bash
argocd login 172.17.18.233 --insecure
```

Verify Login
```bash
argocd account get-user-info
```

To retrieve a list of existing applications in ArgoCD using the CLI.\
```
argocd app list
```




