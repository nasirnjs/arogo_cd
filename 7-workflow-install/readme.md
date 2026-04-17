## Argo Workflow 
Argo Workflows is an open-source, Kubernetes-native workflow engine used to orchestrate complex jobs and pipelines. It allows you to define workflows as Kubernetes resources and run them as containers inside your cluster.

Traditional CI/CD tools (like Jenkins) run pipelines outside Kubernetes. Argo Workflows runs inside Kubernetes, which means:

- Native container execution
- Better scalability
- Easier cloud-native integration
- Declarative workflow definitions (YAML)

## 🔑 Key Features

✅ Kubernetes Native
- Built on Kubernetes CRDs
- Fully container-based execution

✅ Container-Based Execution
- Each step runs inside a container

✅ Parallel Execution (DAG)
- Supports complex workflows with dependencies

✅ Scalability
- Scales with Kubernetes cluster resources

✅ Retry & Error Handling
- Automatic retries
- Conditional execution on failure/success

✅ Artifact Management
- Supports external storage (S3, GCS, MinIO)

✅ Web UI
- Visual workflow monitoring
- Easy debugging

✅ Cron Workflows
- Schedule workflows like cron jobs

✅ GitOps Friendly
- Works seamlessly with Argo CD
- Store workflows in Git repositories

✅ Extensible
- Integrates with CI/CD, ML, and data pipelines


## Install Argo Workflows GitHub link is [Here](https://github.com/argoproj/argo-workflows/releases) and [Here](https://argo-workflows.readthedocs.io/en/latest/quick-start/)


Login Argo Workflows Web UI
```bash
kubectl -n argo port-forward svc/argo-server 2746:2746
```

or  patch service as LoadBalancer

```bash
kubectl -n argo patch svc argo-server -p '{"spec": {"type": "LoadBalancer"}}'
```

## 📦 Argo Workflow Template Types (Explained)

In **:contentReference[oaicite:0]{index=0}**, a *template* defines a unit of work (a step).  
Different template types define **how that step is executed inside Kubernetes**.


1. 🐳 Container Template

🧠 What it is ?\
Runs a **single container inside a Kubernetes Pod**. This is the most common and foundational template type in Argo.

💡 When to use it
- Run this container exactly as a Kubernetes Pod
- CI/CD tasks (build, test, deploy)
- Running CLI tools (kubectl, curl, etc.)
- Any containerized job

📄 Example

```yaml
templates:
- name: hello
  container:
    image: alpine
    command: ["echo"]
    args: ["Hello Argo"]
```
2. 📜 Script Template

🧠 What it is?\
Runs a script inside a container without needing a custom image. Argo injects the script into the container at runtime.

💡 When to use it
- Run inline code inside a container
- Quick Python/Bash scripts
- Data transformation
- Testing logic without building Docker images

📄 Example

```yaml
templates:
- name: script-demo
  script:
    image: python:3.11
    command: [python]
    source: |
      print("Hello from Script Template")
```
