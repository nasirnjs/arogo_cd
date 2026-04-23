

To set the Argo CD reconciliation interval to 5 minutes using a single-line.
```yaml
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"timeout.reconciliation":"5m"}}'
```

erify the Configuration.
```yaml
kubectl get configmap argocd-cm -n argocd -o jsonpath='{.data.timeout\.reconciliation}'
```

## 🔧 Argo CD: Automated Sync, Self-Heal, and Auto-Prune

### 🔄 Automated Sync
**Definition:**
Automatically applies changes from the Git repository to the Kubernetes cluster without manual intervention.

**Example:**
- You update a Deployment image version in Git.
- The change is committed and merged into the main branch.
- Argo CD detects the update and deploys it automatically to the cluster.

**Summary:**
> **Automated Sync ensures continuous deployment by keeping the cluster aligned with Git.**

### ♻️ Self-Heal
**Definition:**
If a resource is deleted or modified directly in the Kubernetes cluster but still exists in Git, Argo CD will automatically recreate or restore it.

**Example:**
- You manually delete a Deployment from the cluster.
- The Deployment configuration still exists in Git.
- Argo CD detects the drift and recreates the resource.


### 🧹 Auto-Prune
**Definition:**
If a resource is removed from Git, Argo CD will automatically delete it from the Kubernetes cluster.

**Example:**
- You remove a Service or Deployment from the Git repository.
- Argo CD detects that it is no longer defined.
- Argo CD deletes the resource from the cluster.

**Summary:**
> **Auto-Prune ensures that obsolete resources are removed from the cluster.**

## ⚙️ Ignoring Replica Differences in Argo CD

In environments where scaling is managed dynamically by tools such as the Horizontal Pod Autoscaler (HPA), Argo CD may detect replica count changes as drift. To prevent unnecessary resynchronization, you can configure Argo CD to ignore differences in the `replicas` field.