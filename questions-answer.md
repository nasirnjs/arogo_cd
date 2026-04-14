# Argo Complete Interview Questions & Answers
## Comprehensive Guide from Basic to Expert Level

## Argo Overview & GitOps

Q1: What is Argo?

**Answer:** Argo is a set of Kubernetes-native open-source tools designed for application deployment and workflow management. It includes:

- **Argo CD** - GitOps continuous delivery
- **Argo Rollouts** - Advanced deployment strategies (canary, blue-green)
- **Argo Workflows** - Container-native workflow engine
- **Argo Events** - Event-driven automation

Q2: What is GitOps?

**Answer:** GitOps is a practice where Git serves as the single source of truth for infrastructure and application deployment. Key principles:

- **Declarative configuration** stored in Git
- **Pull-based deployment** (operator pulls from Git)
- **Drift detection** and automatic correction
- **Auditability** through Git history

Q3: What is Progressive Delivery?

**Answer:** Progressive delivery is an evolution of continuous delivery where new features are gradually released to users with monitoring and rollback capabilities. It includes:

- Canary deployments
- A/B testing
- Feature flags
- Traffic shadowing
- Automated rollback based on metrics


## Argo CD

Q4: How does Argo CD work?

**Answer:** Argo CD works by:

1. **Watching** a Git repository for changes
2. **Comparing** desired state (Git) vs live state (Kubernetes)
3. **Synchronizing** when differences are detected
4. **Automatically correcting** drift
5. **Providing** UI/CLI for visibility and control

Q5: Argo CD vs Traditional CI/CD?

| Aspect | Traditional CI/CD | Argo CD (GitOps) |
|--------|-------------------|------------------|
| Deployment | Push-based | Pull-based |
| Source of Truth | CI server | Git repository |
| Drift Detection | Limited | Continuous |
| Rollback | Manual | Git revert |
| Security | CI credentials | Kubernetes RBAC |


## Argo Rollouts - Basic

Q6: What is a Rollout?

**Answer:** A Rollout is a Kubernetes Custom Resource Definition (CRD) that provides advanced deployment strategies beyond Kubernetes native Deployments. It supports:
- Canary deployments with traffic splitting
- Blue-Green deployments
- Analysis and automated rollback
- Integration with service meshes (Istio, Linkerd)

Q7: Deployment vs Rollout

| Feature | Deployment | Rollout |
|---------|------------|---------|
| Update Strategy | Rolling update only | Canary, Blue-Green, Rolling |
| Traffic Control | Pod count based | Percentage based (with mesh) |
| Rollback | Instant | Controlled with analysis |
| Pause/Resume | Limited | Full control |
| Analysis | No | Yes (metrics, testing) |

Q8: What is Canary Deployment?

**Answer:** Canary deployment is a strategy where a new version is released to a small percentage of users first, then gradually increased. Process:
1. Deploy new version (canary) with 10-20% traffic
2. Monitor metrics and errors
3. Gradually increase traffic (20% → 50% → 100%)
4. If issues detected, automatically rollback

Q9: What is Blue-Green Deployment?

**Answer:** Blue-Green deployment uses two identical environments:
- **Blue**: Current stable version (live)
- **Green**: New version (staged)
- Traffic switches instantly from Blue to Green when ready
- Quick rollback by switching back to Blue


## Argo Rollouts - Intermediate

Q10: How does Argo Rollouts implement Canary?

**Answer:** Using steps with traffic routing:
```yaml
steps:
  - setWeight: 20
  - pause: {duration: 2m}
  - setWeight: 50
  - pause: {duration: 2m}
  - setWeight: 100
```
Q11. Why traffic routing?

**Answer:** Traffic routing provides:
- Exact control over traffic percentage (not just pod count)
- Independent scaling of pods vs traffic
- Fine-grained canary analysis
- Integration with service meshes like Istio, Linkerd, NGINX

Q12. What are canary steps?

**Answer:** Canary steps define rollout progression:
- setWeight: Assign traffic percentage
- pause: Wait (manual or timed)
- setCanaryScale: Control pod count independent of traffic
- analysis: Run metric checks
  
Q13. What is setCanaryScale?

**Answer:** Controls canary pod count independent of traffic.

Use cases:
- More pods than traffic % (load testing)
- Prepare for scaling
- Separate scaling from traffic routing
```yaml
- setCanaryScale:
    weight: 20
- setWeight: 20
```

Q14. What is AnalysisTemplate and AnalysisRun?

Answer:
- AnalysisTemplate → reusable metric checks
- AnalysisRun → execution of those checks

Q15: prePromotionAnalysis vs postPromotionAnalysis

| Type                  | Purpose                        | Timing             |
| --------------------- | ------------------------------ | ------------------ |
| prePromotionAnalysis  | Validate BEFORE traffic switch | Before `setWeight` |
| postPromotionAnalysis | Validate AFTER rollout         | After 100% traffic |

Q16: What is trafficRouting in Argo Rollouts?

**Answer:** Defines integration with traffic tools:
```yaml
trafficRouting:
  istio:
    virtualService:
      name: demo-app-vs
      routes:
      - primary
    destinationRule:
      name: demo-app-dr
      stableSubsetName: stable
      canarySubsetName: canary
```
Q19: Why use Argo Rollouts instead of Deployment?

**Answer:**
- Gradual traffic shifting
- Automated rollback
- Manual approval gates
- Service mesh integration
- Metrics-based analysis
- Zero downtime
  
Q22: What is dynamicStableScale?

dynamicStableScale is an Argo Rollouts feature that automatically scales down stable pods as canary traffic increases, maintaining the total desired replica count throughout the deployment.

Q24: What is Argo Workflows?
**Answer:** A Kubernetes-native workflow engine for pipelines.

Features:
- DAG support
- Step execution
- Container-native
- Retry handling
- UI monitoring

Q25: What are the key components of an Argo Workflow?

- Workflow: The main resource defining the entire workflow
- Templates: Reusable building blocks (container, DAG, steps, resource)
- Steps: Sequential or parallel execution units
- Artifacts: Data passed between steps (S3, GCS, HTTP)
- Parameters: Input values for templates
- Entrypoint: Starting point of the workflow

Q25: How does Argo Workflows handle failure?

**Answer:** Multiple mechanisms:

- retryStrategy: Automatic retry with backoff
- DAG dependencies: Tasks only run if dependencies succeed
- onExit: Always executes for cleanup
- exit handler: Conditional execution on failure/success
- failureCondition: Custom failure criteria
  


