

## Argo Rollouts

Argo Rollouts is a Kubernetes controller that enhances deployment capabilities by providing advanced strategies beyond what native Kubernetes Deployments support. It is designed for progressive delivery, enabling safer, more controlled updates of applications.

## Why Use Argo Rollouts?

While standard Kubernetes Deployments only support basic strategies:

- RollingUpdate → Gradually updates pods, replacing old pods with new ones.
- Recreate → Deletes all old pods first, then creates new ones.

Argo Rollouts introduces advanced deployment strategies with automation and metric-based promotion, making it ideal for minimizing downtime and reducing risk during updates.


## Key Features

1. Progressive Delivery Strategies
- Blue-Green and Canary deployments.
- Gradual rollout with traffic splitting.
- Automated promotion or rollback based on metrics.

2. Advanced Metrics Integration
- Supports automated analysis using metrics from tools like Prometheus, Datadog, or New Relic.
- Decisions to promote or rollback can be automated based on real-time data.

3. Seamless Kubernetes Integration
- Works with existing Deployment manifests.
- Supports standard Kubernetes resources alongside Argo Rollouts resources.

## Deployment Strategies

### 1. Rolling Update

**Native Kubernetes & Argo Rollouts**

- Gradually replaces old pods with new pods in a controlled manner.
- All pods exist within a **single** Deployment/Rollout.
- **No native traffic splitting** — as new pods become ready, they immediately start serving traffic alongside remaining old pods.
- **Key characteristics**:
  - Controlled by `maxSurge` and `maxUnavailable` parameters.
  - Simple to configure but offers limited visibility into the new version's health before full rollout.
  - Cannot pause and resume natively (Argo Rollouts adds this capability).
- **Best for**: Low-risk applications, stateless workloads, or when minimal infrastructure complexity is desired.


### 2. Blue-Green Deployment

**Argo Rollouts Only**

- Maintains **two separate environments** simultaneously:
  - **Active (Blue)** → Currently serving production traffic.
  - **Preview (Green)** → New version being validated before promotion.

- **Traffic switching**:
  - Traffic shifts from old to new version **all at once** (or via automated promotion after analysis).
  - No gradual traffic ramping — users are switched completely when conditions are met.

- **Rollback capability**:
  - Instant rollback by simply redirecting traffic back to the previous version.
  - Old version remains ready and available until the new version is verified stable.

- **Key variations**:
  - **Auto-promotion**: Automatically switches traffic after successful analysis (e.g., metrics pass).
  - **Manual promotion**: Requires human approval before traffic cutover.
  - **Preview service**: Optional separate endpoint for testing the new version without exposing to production traffic.

- **Best for**: Applications requiring zero-downtime deployments with absolute separation between versions, or when you need to fully validate before public release.


### 3. Canary Deployment

**Argo Rollouts Only**

- Releases the new version to a **small subset of users** initially (e.g., 5-10% of traffic).
- **Progressive traffic shifting**:
  - Traffic is incrementally increased through defined steps (e.g., 10% → 25% → 50% → 100%).
  - Each step can be gated by manual approval, automated metrics, or time-based pauses.

- **Observability & automation**:
  - Real-time metrics (latency, error rates, custom business KPIs) determine whether to proceed or rollback.
  - If metrics degrade at any step, Argo Rollouts **automatically aborts** and rolls back.
  - Analysis can run continuously in the background throughout the rollout.

- **Fine-grained control**:
  - **Step-based weights**: Define exact traffic percentages per step.
  - **Manual gates**: Pause for human verification (e.g., QA sign-off, executive approval).
  - **Duration pauses**: Wait a specified time between steps for smoke testing.
  - **Traffic router flexibility**: Works with service meshes (Istio, Linkerd), ingress controllers (NGINX), or multiple Kubernetes Services.

- **Best for**: High-risk applications, microservices with complex dependencies, or when you need to validate with real production traffic before full exposure.

---

## Strategy Comparison

| Aspect | Rolling Update | Blue-Green | Canary |
|--------|---------------|------------|--------|
| **Traffic transition** | Gradual per pod | All-at-once | Progressive steps |
| **Old version availability** | Replaced gradually | Fully available until promotion | Fully available until 100% |
| **Rollback speed** | Moderate (pods roll back) | Instant (traffic flip) | Instant (traffic flip) |
| **Production validation** | None | Full pre-validation | Incremental with real traffic |
| **Infrastructure cost** | Low (single environment) | Higher (dual environments) | Moderate (traffic router overhead) |
| **Complexity** | Low | Medium | High |
| **Automation capability** | Minimal | Analysis-based promotion | Step-wise analysis & promotion |

---

## Key Implementation Notes

- **Rolling Update** in Argo Rollouts adds capabilities not available in native Deployments: pause/resume, analysis hooks, and rollback to any previous revision.
- **Blue-Green** requires either:
  - Two distinct Kubernetes Services (active + preview) with traffic switched externally, or
  - A single Service with label selectors flipped atomically.
- **Canary** typically requires a **traffic router** (service mesh or ingress) for true weighted traffic splitting — Kubernetes Services alone don't support percentage-based routing.



```bash
kubectl argo rollouts get rollout blue-green-app
```

```bash
kubectl argo rollouts set image blue-green-app blue-green-container=nginx
kubectl argo rollouts get rollout blue-green-app --watch
kubectl argo rollouts promote blue-green-app  # if manual promotion
```