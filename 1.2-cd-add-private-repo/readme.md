# Argo CD: Adding Private Git Repositories via CLI

## Adding a Private Repo via HTTPS

**Scenario:**

- Repo: `https://github.com/my-org/private-app.git`
- GitHub username: `myuser`
- Personal Access Token (PAT) as password: `ghp_ABC123XYZ`
- Project: `kinder-app-project`

**Command:**
```bash
argocd repo add https://github.com/nasirnjs/kinder-ci-k8s.git \
  --username nasirnjs \
  --password ghp_xxxxxxxxxxxxxx \
  --project kinder-app-project
```

**Verify the repo:**
```bash
argocd repo list
```


## Adding a Private Repo via SSH

### Step 1: Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "nasirnjs@gmail.com" -f ~/.ssh/id_ed25519_argocd
```

```bash
~/.ssh/id_ed25519_argocd       (private key)
~/.ssh/id_ed25519_argocd.pub   (public key)
```

### Step 2: Add Public Key to Git Repo
- GitHub: **Settings → Deploy keys → Add deploy key**
- GitLab: **Settings → Repository → Deploy keys → Add key**
- Paste contents of `~/.ssh/id_ed25519_argocd.pub`


### Step 3: Add Repo to Argo CD

**Verify the repo:**
```bash
argocd proj list
```

```bash
argocd repo add git@github.com:nasirnjs/kinder-ci-k8s.git \
  --ssh-private-key-path ~/.ssh/id_ed25519_argocd \
  --project kinder-app-project
```

## Create Application

```bash
argocd app create kinder-app \
  --repo git@github.com:nasirnjs/kinder-ci-k8s.git \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace kinder \
  --project kinder-app-project
```

Sync Your Application
```bash
argocd app sync kinder-app
```
ArgoCD application kinder-app is deployed or not !
```bash
argocd app get kinder-app
```