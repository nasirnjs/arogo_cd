## What is an Argo CD Project?

An **Argo CD Project** is a logical grouping of applications.  It is useful in **multi-team environments**.  

A project controls what applications can:

- **Be deployed** – restricts which source repositories can be used.  
- **Deploy where** – restricts target clusters and namespaces.  
- **Deploy which resources** – controls deployment of RBAC, CRDs, DaemonSets, NetworkPolicy, etc.

## Default Project

Every application in Argo CD belongs to **one project**.  
If not specified, it belongs to the **default project**.

The default project is the **most permissive**:

```yaml
spec:
  sourceRepos:
    - '*'
  destinations:
    - namespace: '*'
      server: '*'
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
```
- Deploying from any Git repository (sourceRepos: '*')
- Deploying to any cluster and namespace (destinations: namespace '*' & server '*')
- Deploying any cluster-level resources (clusterResourceWhitelist: group '*' & kind '*')