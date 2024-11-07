
# How to setup ArgoCD in AWS EKS with Applications Load balancer

### Ingress Configuration

This section enables the **Ingress** resource for ArgoCD, which allows external HTTP/HTTPS traffic to reach the ArgoCD service.

#### Annotations:
These are special settings specific to **AWS ALB (Application Load Balancer)**.

- **kubernetes.io/ingress.class**: Specifies the use of AWS ALB.
- **alb.ingress.kubernetes.io/backend-protocol**: Configures the backend to use HTTPS.
- **alb.ingress.kubernetes.io/listen-ports**: Configures the ALB to listen on HTTPS (port 443).
- **alb.ingress.kubernetes.io/scheme**: Sets the ALB to be internet-facing.
- **alb.ingress.kubernetes.io/target-type**: Specifies the target type as `ip` for routing.
- **alb.ingress.kubernetes.io/certificate-arn**: The ARN of the ACM certificate for HTTPS.
- **alb.ingress.kubernetes.io/vpc-id**: The VPC ID where the load balancer is created.
- **alb.ingress.kubernetes.io/subnets**: Specifies the subnets where the ALB will be placed.
- **alb.ingress.kubernetes.io/security-groups**: Security group to associate with the ALB.



**Note Change  this only are**

*certificate-arn*,*vpc-id*,*subnets*,*security-groups*,*Domain*

