<h2> Sync Hooks, Sync Phases and Sync Waves in Argo CD </h2>

**Sync Hooks, Sync Phases, and Sync Waves** are three complementary mechanisms in Argo CD that provide fine-grained control over **when** and **in what order** resources are applied during a synchronization process.

[References](https://argo-cd.readthedocs.io/en/release-2.9/user-guide/resource_hooks/)

They address real-world challenges where Kubernetes' default parallel or near-parallel deployment model may fail due to dependencies, timing issues, or external side effects—such as CRD registration, database readiness, or operator reconciliation.

Git Repository Structure
```yaml
k8s-app/
├── deployment.yaml
├── service.yaml
├── hpa.yaml
├── configmap.yaml
├── db-migration-job.yaml   # 👈 Sync Hook
├── smoke-test-job.yaml     # 👈 Sync Hook
```

## 1. Argo CD Sync Hooks
Argo CD Sync Hooks allow you to execute custom tasks at specific stages of the application deployment lifecycle. They are commonly used for database migrations, validations, notifications, and cleanup operations.

They are commonly used for:
- Database migrations
- Smoke tests
- Notifications
- Cleanup tasks
- Rollback alerts

## 2. Sync Phases
- Sync Phases control WHEN a resource runs in the overall sync lifecycle, not the order inside a phase. Argo CD has 3 main phases.

1. PreSync   → DB migration job
2. Sync      → App Deployment
3. PostSync  → Smoke tests / validation


| Phase       | Hook Annotation                              | When it executes                                      | Typical Use Cases                                      | Waits for previous phase? | Health check required? |
|-------------|----------------------------------------------|-------------------------------------------------------|--------------------------------------------------------|----------------------------|------------------------|
| **PreSync** | `argocd.argoproj.io/hook: PreSync`           | Before any main (Sync) resources are applied          | Database migrations, schema init, backups, validation  | —                          | Yes (for hooks)        |
| **Sync**    | `argocd.argoproj.io/hook: Sync` <br>*(or no hook annotation = default)* | Main apply phase – together with normal manifests     | Deployments, Services, ConfigMaps, StatefulSets, etc.  | Yes (after PreSync)        | Yes (for progression)  |
| **PostSync**| `argocd.argoproj.io/hook: PostSync`          | After **all** Sync resources are applied **and healthy** | Smoke tests, integration tests, notifications, cleanup | Yes (after Sync healthy)   | Yes                    |
| **Skip**    | `argocd.argoproj.io/hook: Skip`              | Never applied                                         | Temporarily disable broken/blocking resources          | —                          | —                      |
| **SyncFail**| `argocd.argoproj.io/hook: SyncFail`          | If the overall sync fails                             | Failure alerts, rollback cleanup, notifications        | Only on failure            | —                      |


Example: PostSync Phase (Run after deployment)
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: smoke-test
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: test
          image: curlimages/curl
          command: ["sh", "-c", "echo Testing application..."]
```
**Note of this Job**

- Run AFTER all Sync resources are deployed
- Run only when deployment is successful
- Delete Job automatically after successful execution
- Keep cluster clean (no leftover test Jobs)

**Key rules about phases:**
- Executed **sequentially**: PreSync → Sync → PostSync
- Argo CD **waits** for a phase to complete successfully before starting the next
- Hooks are usually Jobs (must exit 0 to succeed)
- Normal resources without hook annotation → **Sync** phase
- Phases control **lifecycle hooks**, not fine-grained resource ordering

## 3. Argo CD Sync Waves

- Sync Waves control the order of resource application within the same Sync Phase.
- They provide intra-phase ordering, meaning you can decide which resources should be applied first, even if they are in the same Sync phase.

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-10"   # any integer: negative, zero, positive
```

**You use negative waves like -10 when something must exist before everything else, such as:**

- Namespace
- CRDs (Custom Resource Definitions)
- Cluster-level prerequisites

## Argo CD Sync Waves – Numbering & Priority Explained

Argo CD treats sync wave numbers **purely as ordering values**:

- **Lower number** → applied **earlier**  
- **Higher number** → applied **later**

### Core Rule (most important thing to remember)

- Argo CD always processes waves **from lowest number to highest number** (ascending order).  
- **Negative numbers** come **before** zero.  
- **Positive numbers** come **after** zero.

### Wave Number Examples & Conventions

| Wave number example | When it runs (in the same phase) | Typical use case (common convention)                          | Why people choose this number                              |
|----------------------|----------------------------------|----------------------------------------------------------------|------------------------------------------------------------|
| -20, -15, -10       | Very early                       | Super foundational things:<br>• CRDs<br>• Namespaces<br>• RBAC / ClusterRoles<br>• StorageClasses<br>• Operators | Negative = "before everything else" — gives maximum breathing room |
| -5, -1              | Early                            | • Databases / StatefulSets<br>• PVCs<br>• Early init / migration Jobs | Still before default (0) but after ultra-low infrastructure |
| **0**               | Default / middle                 | • ConfigMaps<br>• Secrets<br>• Services<br>• Core infrastructure | No annotation = automatically 0 — most people start here   |
| 5, 10, 15           | Later                            | • Deployments<br>• StatefulSets (the actual application pods) | After configs & services exist                             |
| 20, 30, 50, 100     | Very late                        | • Ingress<br>• HPA / HorizontalPodAutoscaler<br>• Monitoring resources (ServiceMonitor, PrometheusRule)<br>• Canary steps<br>• Tests / notifications | Only after app is running & healthy                        |


## Complete Example: Backend First → Frontend Later

- Wave 0 (or low positive): Backend API (Deployment + Service)
- Wave 10–20: Frontend UI (Deployment + Service, Ingress if any)