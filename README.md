
GitOps is a DevOps practice where Git is used as the single source of truth to manage infrastructure and application deployments. In GitOps, everything about your system (infrastructure, Kubernetes manifests, configs, policies) is stored in a Git repository, and changes are applied to the system automatically through Git commits. 🚀

GitOps = Using Git + automation to manage infrastructure and deployments.


## ArgoCD CLI for Mac

```bash
curl -sSL -o argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-darwin-arm64

chmod +x argocd
sudo mv argocd /usr/local/bin/
```

```bash
argocd version
```

## ArgoCD CLI for Linux
```bash
curl -sSL -o argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

chmod +x argocd
sudo mv argocd /usr/local/bin/
```

```bash
argocd version
```

## Get the Admin Password and login into ArgoCD

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

```bash
argocd login 172.17.18.233 --insecure
```

Verify Login
```bash
argocd account get-user-info
```

To retrieve a list of existing applications in ArgoCD using the CLI.\
```
argocd app list
```


# Argo Workflows

Argo Workflows is an open-source, Kubernetes-native workflow engine designed to run and manage multi-step, container-based pipelines (also called workflows) on Kubernetes clusters.

- You define a sequence of tasks (or a complex graph of tasks).
- Each task runs inside its own container (like a Docker/OCI image).
- Kubernetes handles running these containers as Pods.
- Argo orchestrates everything: order, parallelism, dependencies, retries, failures, passing data between steps, etc.

**One-line summary**: Argo Workflows is an open source container-native workflow engine for orchestrating parallel jobs on Kubernetes.

## Key Components

1. Workflow = the main object (kind: Workflow)
Defines what to run, Stores the execution state (running, succeeded, failed…)
2. Templates = reusable task definitions (like functions)
You write many templates inside one Workflow. Two big categories **What to execute** and **How to orchestrate**

2.1 What to execute (leaf tasks – do real work)
- container: run any image (most used)
- script: run inline code (bash/python/…) without building image
- resource: create/delete K8s objects (e.g. create a Job or ConfigMap)
- suspend: pause for manual approval or timer
- http: call APIs (newer, very useful)
- Others: containerSet (multi-container pod), plugin, data…

2.2 How to orchestrate (control flow – call other templates)
- steps: simple sequential + limited parallel blocks
- dag: full directed acyclic graph (dependencies, parallelism, conditionals)

3.  Entrypoint: name of the first template to run (usually a steps or dag template)
4.  Parameters: pass strings/numbers (like variables)
5.  Artifacts: pass files/folders between steps (very powerful for ML/data)


### Simple Example (Hello World style)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
spec:
  entrypoint: whalesay
  templates:
  - name: whalesay
    container:
      image: docker/whalesay:latest
      command: [cowsay]
      args: ["hello world"]
```

# Directed Acyclic Graph (DAG)

**What is it?**

A Directed Acyclic Graph (DAG) is a visual model representing a sequence of tasks where:
- Directed: Relationships flow one way (A → B means A must run before B).
- Acyclic: No circular dependencies (you cannot loop back to a previous task).
- Graph: Tasks are nodes; dependencies are the lines connecting them.

**Why is it useful?**

DAGs power modern orchestration tools (like Airflow or Argo Workflows) because they solve three big problems:
- Order: Automatically ensures tasks run in the correct sequence based on dependencies.
- Speed: Runs independent tasks in parallel automatically.
- Resilience: If a task fails, you can retry only that task—not the whole pipeline.

## Key Characteristics of DAG-based Workflows 

- Directed: Tasks flow one way (A → B means A runs before B).
- Acyclic: No loops or circular dependencies—workflow always ends.
- Dependency-driven: Tasks only run when all upstream dependencies succeed.
- Parallel execution: Independent tasks run simultaneously.
- Deterministic: Same input always produces same execution order.
- Fault isolation: Failures affect only specific tasks (retry without restarting whole pipeline).
- Observability: Visual graph shows status of every task.
- Topological order: Tasks execute in mathematically correct sequence.