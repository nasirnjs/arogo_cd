
- [Argo Workflow](#argo-workflow)
- [🔑 Key Features](#-key-features)
- [Install Argo Workflows GitHub link is Here and Here](#install-argo-workflows-github-link-is-here-and-here)
- [📦 Argo Workflow Template Types (Explained)](#-argo-workflow-template-types-explained)
- [🔧 Argo Workflow Parameters (with Examples) References](#-argo-workflow-parameters-with-examples-references)
- [What is a DAG in Argo Workflows?](#what-is-a-dag-in-argo-workflows)


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
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: cowsay-container-
  namespace: argo
spec:
  entrypoint: cowsay-template

  templates:
  - name: cowsay-template
    container:
      image: rancher/cowsay
      command: ["cowsay"]
      args: ["Hello from Container Template 🐄"]
```
**`Note:`** the workflow has a single container template where the `rancher/cowsay` image runs directly and prints a message without any dependencies or steps.



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
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: cowsay-script-
  namespace: argo
spec:
  entrypoint: cowsay-script

  templates:
  - name: cowsay-script
    script:
      image: rancher/cowsay
      command: [sh]
      source: |
        cowsay "Hello from Script Template 🐄"
```
**`Note:`** the workflow uses a script template where a shell script runs inside the `rancher/cowsay` container, and the script executes the `cowsay` command to print a message.


3. 🪜 Steps Template
🧠 What it is?\
Defines a sequential workflow (step-by-step execution). Each step runs one after another.

💡 When to use it
- Run tasks one after another (like Jenkins pipeline
- CI pipelines (build → test → deploy)
- Simple linear workflows
- Easy-to-read pipelines

📄 Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: cowsay-steps-parallel-
  namespace: argo
spec:
  entrypoint: cowsay-steps

  templates:
  - name: cowsay-steps
    steps:
    - - name: step1
        template: cowsay
        arguments:
          parameters:
          - name: message
            value: "Step 1 - Start 🐄"

    - - name: step2
        template: cowsay
        arguments:
          parameters:
          - name: message
            value: "Step 2 - Runs in parallel 🐄"

      - name: step3
        template: cowsay
        arguments:
          parameters:
          - name: message
            value: "Step 3 - Runs in parallel 🐄"

  - name: cowsay
    inputs:
      parameters:
      - name: message
    container:
      image: rancher/cowsay
      command: ["cowsay"]
      args: ["{{inputs.parameters.message}}"]
```

**`Note:`** step1 runs first, and after it completes, step2 and step3 run in parallel using the same `cowsay` template with different messages.

4. ContainerSet Template
🧠 What it is?\
A ContainerSet template allows you to run multiple containers inside the SAME Pod.

💡 When to use it
- Share filesystem (same volume)
- Communicate via localhost
- Run tightly coupled tasks
- Avoid creating multiple Pods
  

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: cowsay-containerset-
  namespace: argo
spec:
  entrypoint: cowsay-containerset

  templates:
  - name: cowsay-containerset
    containerSet:
      containers:
      - name: step1
        image: rancher/cowsay
        command: ["cowsay"]
        args: ["Step 1 - Start 🐄"]

      - name: step2
        image: rancher/cowsay
        command: ["cowsay"]
        args: ["Step 2 - Runs in parallel 🐄"]

      - name: step3
        image: rancher/cowsay
        command: ["cowsay"]
        args: ["Step 3 - Runs in parallel 🐄"]
```
**`Note:`** all containers inside the ContainerSet run in parallel within the same pod, so step1, step2, and step3 execute simultaneously using the `rancher/cowsay` image.


5. 🕸️ DAG Template (Directed Acyclic Graph)
🧠 What it is?\
Runs tasks based on dependencies + parallel execution. This is where Argo becomes very powerful.

💡 When to use it
- Run tasks in parallel + control dependencies
- Parallel CI jobs (lint, build, test together)
- Microservices pipelines
- ML workflows
- Complex dependencies

📄 Example

Here is your updated **DAG Workflow using `rancher/cowsay` image** instead of `alpine echo`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-demo-
  namespace: argo
spec:
  entrypoint: dag-template

  templates:
  - name: dag-template
    dag:
      tasks:
      - name: step1
        template: cowsay

      - name: step2
        template: cowsay
        dependencies: [step1]

      - name: step3
        template: cowsay
        dependencies: [step1]

  - name: cowsay
    container:
      image: rancher/cowsay
      command: ["cowsay"]
      args: ["Step executed successfully 🐄"]
```
**`Note:`** step1 runs first, then step2 and step3 depend on step1; after step1 completes, step2 and step3 run in parallel, and each task executes the `rancher/cowsay` container independently.


6. 🔁 Resource Template
🧠 What it is.?\
Lets Argo directly create/update/delete Kubernetes resources.

💡 When to use it
- Argo directly manages Kubernetes objects
- Deploy applications
- Create ConfigMaps/Secrets
- GitOps-like automation
- Infrastructure changes

📄 Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: cowsay-resource-
  namespace: argo
spec:
  entrypoint: cowsay-resource

  templates:
  - name: cowsay-resource
    resource:
      action: create
      manifest: |
        apiVersion: v1
        kind: Pod
        metadata:
          generateName: cowsay-pod-
        spec:
          restartPolicy: Never
          containers:
          - name: cowsay
            image: rancher/cowsay
            command: ["cowsay"]
            args: ["Hello from Resource Template 🐄"]
```
**`Note:`** the Resource Template directly creates a Kubernetes Pod from within the workflow, and that Pod runs the `rancher/cowsay` container to execute the task independently of Argo’s normal container execution templates.


7. Suspend Template
🧠 What it is?\
Pauses workflow execution until manual approval or condition is met.

💡 When to use it
- Stop workflow until someone approves or resumes it
- Production approvals
- Manual QA checks
- Safety gates in deployment
  
📄 Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  name: suspend-cowsay-demo
spec:
  entrypoint: main
  templates:

  - name: main
    steps:
    - - name: say-hello
        template: cowsay

    - - name: pause-for-approval
        template: wait-for-approval

    - - name: say-again
        template: cowsay

  # 1st template: cowsay container
  - name: cowsay
    container:
      image: rancher/cowsay
      command: ["cowsay"]
      args: ["Hello from Argo Workflow! 🐄"]

  # 2nd template: suspend step
  - name: wait-for-approval
    suspend: {}
```

**`Note:`** step1 runs first and executes the `cowsay` container, then the workflow pauses at the `suspend` step until it is manually resumed; after resuming, step2 runs and executes the `cowsay` container again.


8. 🔗 Template Reuse (Template Ref Concept)

🧠 What it is?\
Allows reusing templates across workflows.

💡 When to use it
- Write once, reuse everywhere
- Avoid duplication
- Modular pipelines
- Shared CI/CD logic

📄 Example

```yaml
templates:
- name: workflow-a
  steps:
  - - name: run
      template: shared-task

- name: shared-task
  container:
    image: alpine
    command: ["echo"]
    args: ["Reusable template"]
```

## 🔧 Argo Workflow Parameters (with Examples) [References](https://argo-workflows.readthedocs.io/en/latest/walk-through/parameters/)

In **parameters** allow you to pass **dynamic values** into workflows and templates.

👉 Instead of hardcoding values, you can make workflows **reusable and flexible**.

```shell
vim parameters.yaml
```
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: param-demo-
spec:
  entrypoint: main

  arguments:
    parameters:
    - name: message
      value: "Hello from Argo"

  templates:
  - name: main
    inputs:
      parameters:
      - name: message
    container:
      image: alpine
      command: ["echo"]
      args: ["{{inputs.parameters.message}}"]
```

```shell
argo submit -n argo workflow.yaml -p message="Hello DevOps"
```

**`Note:`** this workflow demonstrates input parameters in Argo Workflows where a default value is defined in the YAML, but it can be overridden at runtime using the `-p` flag in `argo submit`, allowing dynamic input without changing the workflow definition.


## What is a DAG in Argo Workflows?

A DAG (Directed Acyclic Graph) means:
- Directed → Tasks have a defined order (A → B → C)
- Acyclic → No loops (you can’t go back to a previous task)
- Graph → Tasks are connected based on dependencies

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-example-
spec:
  entrypoint: dag-main
  templates:
  - name: dag-main
    dag:
      tasks:
      - name: A
        template: echo
      - name: B
        template: echo
        dependencies: [A]
      - name: C
        template: echo
        dependencies: [A]
      - name: D
        template: echo
        dependencies: [B, C]

  - name: echo
    container:
      image: alpine:latest
      command: [echo]
      args: ["Hello from Argo"]
```

**`Note:`** this DAG in Argo Workflows shows dependency-based execution where B and C run in parallel after A, and D runs after both complete.



**Note: in Argo Workflows, fan-out creates multiple parallel tasks from one step, and fan-in waits for all those tasks to complete before continuing.**

