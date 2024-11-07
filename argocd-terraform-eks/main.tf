
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "argo-cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argo"
  version          = "5.51.6"
  create_namespace = true
  values = [
    <<-EOT

server: 

  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class : alb
      alb.ingress.kubernetes.io/backend-protocol: HTTPS
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-2:65465444-8499-42fc-bad6-30c0e0b1142e
      alb.ingress.kubernetes.io/vpc-id: vpc-0e320d127b
      alb.ingress.kubernetes.io/subnets: subnet-0a22ad19374a25, subnet-060e773bfe4
      alb.ingress.kubernetes.io/security-groups: sg-0a7f95c8001
  hosts:
    - argocd.yourdomain.com
  ingressGrpc:
    enabled: true
    isAWSALB: true
    awsALB:
      serviceType: NodePort

  redis-ha:
    enabled: true

  controller:
    replicas: 1

  server:
    autoscaling:
      enabled: true
      minReplicas: 2

  repoServer:
    autoscaling:
      enabled: true
      minReplicas: 2

  applicationSet:
    replicas: 2

EOT
  ]
}