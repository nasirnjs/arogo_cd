# Argo CD: Adding Private Git Repositories via CLI

## Adding a Private Repo via HTTPS

**Scenario:**

- Repo: `https://github.com/my-org/private-app.git`
- GitHub username: `myuser`
- Personal Access Token (PAT) as password: `ghp_ABC123XYZ`
- Project: `my-specific-project`

**Command:**
```bash
argocd repo add https://github.com/my-org/private-app.git \
  --username myuser \
  --password ghp_ABC123XYZ \
  --project my-specific-project
```

**Verify the repo:**
```bash
argocd repo list
```

**Example Output:**
```
REPO URL                                    TYPE    PROJECT
https://github.com/my-org/private-app.git   git     my-specific-project
```

> ✅ Only apps in `my-specific-project` can use this repo.


## 2️⃣ Adding a Private Repo via SSH

### Step 1: Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "argocd@company" -f ~/.ssh/id_ed25519_argocd
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
```bash
argocd repo add git@github.com:my-org/private-app.git \
  --ssh-private-key-path ~/.ssh/id_ed25519_argocd \
  --project my-specific-project
```

**Verify the repo:**
```bash
argocd repo list
```

**Example Output:**
```
REPO URL                               TYPE    PROJECT
git@github.com:my-org/private-app.git  git     my-specific-project
```

> ✅ Only apps in `my-specific-project` can use this repo.
