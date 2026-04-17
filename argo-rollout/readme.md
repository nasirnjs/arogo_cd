

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



## Argo Rollouts Canary with NGINX Ingress + HPA

This guide provides a complete, production-style Canary Rollout using **Argo Rollouts**, **NGINX Ingress** for precise traffic splitting, and **Horizontal Pod Autoscaler (HPA)**.

### Traffic Shift Strategy
- Start with **20%** traffic to the new version (canary)
- Increase to **50%** traffic to the new version
- Finally promote to **100%** (full rollout)


### Why Two Services?

Even though both services (`demo-app-stable` and `demo-app-canary`) use the **same selector** (`app: demo-app`), Argo Rollouts makes them intelligent by dynamically managing the underlying ReplicaSets.

- The Rollout creates **two ReplicaSets**:
  - **Stable ReplicaSet** → runs the old (previous successful) version.
  - **Canary ReplicaSet** → runs the new version.

- Argo **automatically adds** a special label called `rollouts-pod-template-hash` to the pods of each ReplicaSet.  
  This label is **different** for stable and canary pods.

- Argo then **dynamically updates** the Service selectors behind the scenes:
  - `demo-app-stable` Service only selects **stable pods**.
  - `demo-app-canary` Service only selects **canary pods**.

This smart behavior is handled automatically by the **Argo Rollouts controller** — you don’t need to manage it manually.

### How Traffic Shifting Actually Works (with NGINX)

1. Your main **Ingress** (`demo-app-ingress`) always points to the **stable Service**.

2. When a canary rollout starts (e.g., `setWeight: 20`):
   - Argo **automatically creates** a second Ingress (usually named `demo-app-ingress-canary`).
   - Argo adds NGINX-specific annotations to this canary Ingress:
```yaml
     nginx.ingress.kubernetes.io/canary: "true"
     nginx.ingress.kubernetes.io/canary-weight: "20"
```

NGINX Ingress Controller reads both Ingresses and splits traffic:
- 80% of traffic → demo-app-stable Service → old pods
- 20% of traffic → demo-app-canary Service → new pods

3. When you do setWeight: 50:
- Argo updates the canary Ingress annotation to canary-weight: "50".
- NGINX now splits traffic 50% / 50%.

4. When you do setWeight: 100:
Argo promotes the canary → the new version becomes the stable ReplicaSet.
- The old stable ReplicaSet is scaled down.
- The canary Ingress is automatically cleaned up.
- All traffic now goes through the stable Service (which now serves the new version).


### Key Intelligent Things Argo Does for You

- **Dynamic pod selection**  
  Argo adds/removes the hash label and updates Service endpoints automatically.

- **Automatic canary Ingress management**  
  Creates, updates, and deletes the canary Ingress with correct weights.

- **`dynamicStableScale: true` (recommended)**  
  Keeps the stable ReplicaSet scaled properly so it can handle the remaining traffic percentage without overload.

- **Background analysis**  
  Continuously checks metrics while traffic is being shifted.

- **Pause steps**  
  Gives you safe windows to observe before increasing traffic.


```bash
kubectl argo rollouts get rollout blue-green-app
```

```bash
kubectl argo rollouts set image blue-green-app blue-green-container=nginx
kubectl argo rollouts get rollout blue-green-app --watch
kubectl argo rollouts promote blue-green-app  # if manual promotion
```

```yaml
# Add Istio repo and update
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# Install Istio base CRDs
helm install istio-base istio/base --namespace istio-system --create-namespace

# Install Istio control plane
helm install istiod istio/istiod \
  --namespace istio-system \
  --wait --timeout 10m

# Install Istio Ingress Gateway
kubectl create namespace istio-ingress

helm install istio-ingressgateway istio/gateway \
  --namespace istio-ingress \
  --wait --timeout 10m

# Check pods & services
kubectl get pods,svc -n istio-system
kubectl get pods,svc -n istio-ingress
```
