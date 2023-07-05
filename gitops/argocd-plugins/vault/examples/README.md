

```
helm repo add argo https://argoproj.github.io/argo-helm

helm install argocd -n argocd argo/argo-cd --create-namespace
```