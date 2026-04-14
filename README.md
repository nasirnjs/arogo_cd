## Components of the Argo Project

The Argo Project is a collection of Kubernetes-native tools designed to automate deployments, orchestrate workflows, and enable event-driven and progressive delivery in cloud-native environments.

### 1. Argo CD
A declarative GitOps continuous delivery tool for Kubernetes.

- Synchronizes applications with configurations stored in Git.
- Ensures automated, consistent, and version-controlled deployments.
- Provides a user-friendly web UI and CLI for managing deployments.

### 2. Argo Workflows
A workflow engine for orchestrating parallel and sequential jobs on Kubernetes.

- Ideal for CI/CD pipelines, machine learning, and data processing tasks.
- Executes each step as a container.
- Supports complex workflows with DAGs and dependencies.

### 3. Argo Rollouts
A progressive delivery controller for Kubernetes.

- Enables advanced deployment strategies such as canary and blue-green deployments.
- Supports automated rollbacks and integrates with monitoring tools.
- Enhances reliability and reduces deployment risks.
- Provides real-time deployment insights.

### 4. Argo Events
An event-driven automation framework for Kubernetes.

- Triggers workflows based on events from sources like webhooks, Git, or message queues.
- Integrates seamlessly with Argo Workflows.
- Useful for building reactive and automated systems.
- Supports a wide range of event sources and triggers.


## GitOps Principles

GitOps is an operational framework that uses Git as the single source of truth to manage infrastructure and application deployments. It enables automation, consistency, and reliability in modern cloud-native environments, especially Kubernetes.



## 🔑 Core Principles of GitOps

### 1. Declarative Infrastructure
All systems are defined using declarative configuration files that describe the desired state.

- Infrastructure and applications are managed as code (IaC).
- Eliminates manual configuration and reduces human error.
- Ensures consistency and repeatability across environments.

**Example:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
```

### 2. Version Control as the Single Source of Truth

Git serves as the authoritative source for system configurations.

- All changes are tracked and versioned in Git.
- Provides a complete audit trail.
- Enables easy rollbacks and collaboration through pull requests.

### 3. Automated Synchronization

Automated tools continuously monitor Git repositories and synchronize the desired state with the live environment.

- Reduces manual intervention.
- Ensures continuous deployment.
- Maintains consistency across environments.

### 4. Continuous Reconciliation

GitOps agents continuously compare the actual system state with the desired state stored in Git.

- Detects configuration drift.
- Automatically restores the correct state.
- Enables self-healing infrastructure.

### 5. Pull-Based Deployment Model

Changes are pulled from Git into the target environment rather than pushed from external systems.

- Improves security by minimizing direct access to clusters.
- Aligns with Kubernetes-native practices.
- Ensures controlled and traceable deployments.

### 6. Observability and Auditability

Every change is visible and traceable through Git history and system logs.

- Simplifies compliance and governance.
- Enhances monitoring and troubleshooting.
- Provides transparency and accountability.


## Install ArgoCD from [Here](https://argo-cd.readthedocs.io/en/stable/getting_started/)

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
```bash
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