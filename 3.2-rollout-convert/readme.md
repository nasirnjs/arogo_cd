**Note:** using workloadRef in Argo Rollouts allows you to convert an existing Deployment into a Rollout by safely transferring control without downtime.

**Migration Flow:**
- Rollout detects the existing Deployment
- It copies the pod template from Deployment
- Rollout starts managing new ReplicaSets
- Deployment is gradually scaled down
- Rollout becomes the main controller