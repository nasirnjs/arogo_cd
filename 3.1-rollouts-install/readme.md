## Introduction to Argo Rollouts

Argo Rollouts is a Kubernetes controller and set of CRDs which provide advanced deployment capabilities such as blue-green, canary, canary analysis, experimentation, and progressive delivery features to Kubernetes.

Argo Rollouts (optionally) integrates with ingress controllers and service meshes, leveraging their traffic shaping abilities to gradually shift traffic to the new version during an update. Additionally, Rollouts can query and interpret metrics from various providers to verify key KPIs and drive automated promotion or rollback during an update.

## Why use Argo Rollouts?

### Default Kubernetes Deployment
- Simple rolling updates  
- Limited control over rollout process  
- No built-in traffic shifting or analysis  

### Argo Rollouts Adds
- Safer, progressive deployments  
- Fine-grained traffic control  
- Automated rollback based on metrics  

## Key Features

### Canary Deployments
- Release to a **small percentage of users first**  
- Gradually increase traffic  

**Example:**  
`10% → 30% → 50% → 100%`

### Blue-Green Deployments
- Two environments:
  - **Blue** → current (live)
  - **Green** → new version  
- Switch traffic instantly after validation  

### Automated Analysis
- Integrates with tools like Prometheus  
- Monitors metrics (error rate, latency, etc.)  
- Automatically rolls back on failure  

### Manual Pause
- Pause rollout at any step  
- Resume after verification or approval  

### Traffic Shifting
- Works with:
  - Istio  
  - NGINX Ingress  
  - AWS ALB  
- Precisely control traffic distribution  

### Rollback & History
- Quick rollback to previous stable version  
- Maintains deployment revision history  

## Summary

**Note:** Argo Rollouts enables progressive delivery using canary and blue-green strategies, ensuring safer and more controlled deployments in Kubernetes.

## Installation

```yaml
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

## Argo Rollouts and Recreate

**In Argo Rollouts, Rolling ensures zero-downtime gradual replacement, while Recreate ensures a clean restart by shutting down all old pods before starting new ones.**


