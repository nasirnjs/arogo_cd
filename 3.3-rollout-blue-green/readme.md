Blue/Green deployment with Argo Rollouts is one of the cleanest ways to do zero-downtime releases in Kubernetes using Argo’s progressive delivery controller.

It works by running two versions of your app at the same time:

- Blue = current stable version
- Green = new version

Traffic is switched from Blue → Green only after validation

This is managed by Argo Rollouts, which extends Kubernetes Deployments.

**How Blue/Green works in Argo Rollouts**

Flow:
- Current version (Blue) is serving traffic
- New version (Green) is deployed as a ReplicaSet
- You manually or automatically promote Green
- Service switches traffic to Green
- Blue is scaled down after success