In this repo,

We install a Kind cluster on Mac using Terraform 
After that , we install ArgoCD automatically b bootstrapping the installation 
as soon as the cluster is ready.

After the deployment , to get the ArgoCD GUI on localhost:8080 :

Run the command : 
kubectl port-forward svc/argocd-server -n argocd 8080:443

Initial User Account is : admin

To get the password , run the command : 

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D ; echo


