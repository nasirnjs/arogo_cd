## To add an external Kubernetes cluster to Argo CD

`argocd login localhost:8085 --username admin --password 4R89HMM9xY0QwVxO  --insecure`

`argocd cluster list`

To see the available contexts in your kubeconfig file.\
`kubectl config get-contexts`

`minikube update-context`

`kubectl config use-context context-name`

`create serviceaccount kubead-cluster-sa`

`kubectl get clusterrole cluster-admin`

`kubectl create clusterrolebinding argocd-admin-binding --clusterrole=cluster-admin --serviceaccount=default:kubead-cluster-sa`

`kubectl auth can-i create pod --as system:serviceaccount:default:kubead-cluster-sa`

`kubectl auth can-i delete pod --as system:serviceaccount:default:kubead-cluster-sa`

`kubectl create token kubead-cluster-sa`

Get cluster Certificate.\
`grep 'certificate-authority-data' ~/.kube/config | awk '{print $2}' | base64 --decode > ca.crt`

Encoding the contents of ca.crt into a single line of Base64.\
`cat ca.crt | base64 | tr -d '\n'`

`kubectl apply -f add-cluster.yaml`

`argocd cluster list`


## To add an external Kubernetes cluster to Argo CD

Log in to your Argo CD instance using the CLI or the UI.\
`argocd login localhost:8085 --username admin --password 4R89HMM9xY0QwVxO  --insecure`

Add the external cluster.\
`kubectl config get-contexts`

`kubectl config use-context <context-name>`

For example, if you have an external cluster context called external-cluster-context.\
`argocd cluster add kubernetes-admin@kubernetes`

`argocd cluster list`
