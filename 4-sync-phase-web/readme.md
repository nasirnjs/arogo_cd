<h2> Sync Phases and Sync Waves in Argo CD </h2>

Sync Phases and Sync Waves are two complementary mechanisms in Argo CD that give you fine-grained control over when and in what order resources (including hooks) are applied during a sync operation. They solve real-world problems where Kubernetes' default parallel/near-parallel apply fails due to dependencies, timing races, or external side-effects (e.g., CRD registration, database readiness, operator reconciliation).

# Argo CD Sync Phases & Sync Waves – Complete Overview

Sync Phases and Sync Waves are the two main mechanisms Argo CD uses to control **ordering**, **timing**, and **dependencies** during application synchronization.

## 1. Sync Phases

Phases define the **major stages** of a sync operation.  
They are mainly used for **resource hooks** (Jobs/Pods that run before, during, or after the main apply), but normal resources can also be assigned to phases.

| Phase       | Hook Annotation                              | When it executes                                      | Typical Use Cases                                      | Waits for previous phase? | Health check required? |
|-------------|----------------------------------------------|-------------------------------------------------------|--------------------------------------------------------|----------------------------|------------------------|
| **PreSync** | `argocd.argoproj.io/hook: PreSync`           | Before any main (Sync) resources are applied          | Database migrations, schema init, backups, validation  | —                          | Yes (for hooks)        |
| **Sync**    | `argocd.argoproj.io/hook: Sync` <br>*(or no hook annotation = default)* | Main apply phase – together with normal manifests     | Deployments, Services, ConfigMaps, StatefulSets, etc.  | Yes (after PreSync)        | Yes (for progression)  |
| **PostSync**| `argocd.argoproj.io/hook: PostSync`          | After **all** Sync resources are applied **and healthy** | Smoke tests, integration tests, notifications, cleanup | Yes (after Sync healthy)   | Yes                    |
| **Skip**    | `argocd.argoproj.io/hook: Skip`              | Never applied                                         | Temporarily disable broken/blocking resources          | —                          | —                      |
| **SyncFail**| `argocd.argoproj.io/hook: SyncFail`          | If the overall sync fails                             | Failure alerts, rollback cleanup, notifications        | Only on failure            | —                      |

**Key rules about phases:**
- Executed **sequentially**: PreSync → Sync → PostSync
- Argo CD **waits** for a phase to complete successfully before starting the next
- Hooks are usually Jobs (must exit 0 to succeed)
- Normal resources without hook annotation → **Sync** phase
- Phases control **lifecycle hooks**, not fine-grained resource ordering

## 2. Sync Waves

Waves provide **intra-phase ordering** — they let you control the sequence **inside** a phase (most commonly inside **Sync** phase).

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-10"   # any integer: negative, zero, positive
```

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