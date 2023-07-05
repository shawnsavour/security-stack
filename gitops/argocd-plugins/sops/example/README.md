# Example step

## 0. Pre-requisites

### Install helm

### Install argocd

Argocd will be deployed using helm with the configuration file `argo-values.yaml`

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd -n argocd argo/argo-cd -f argo-values.yaml
```

This include the init container to install the plugin on repo-server to decrypt secrets

### Install sops local to encrypt

```bash
wget https://github.com/getsops/sops/releases/download/v3.7.3/sops-v3.7.3.linux
sudo mv sops-v3.7.3.linux /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops
```

### Install helm secrets
    
```bash
# install helm secrets
helm plugin install https://github.com/jkroepke/helm-secrets
```

### AWS credentials to using kms

In this demo, we will use AWS KMS to encrypt secrets. So we need to configure the credentials to access to AWS.

We use ACCESS KEY to access to AWS. In production, we should use IAM role to access to AWS.


## 1. Prepare the KMS

### Create a KMS key

Configure AWS profile and run the terraform script to create a KMS key

```bash
# gitops/argocd-plugins/sops/example
terraform init
terraform apply --auto-approve
```

2 outputs will be generated:

### Pass the KMS key to .sops.yaml

Example sops.yaml

```yaml
creation_rules:
- path_regex: 'environment/secrets/dev/(.*).yaml'
  kms: 'arn:aws:kms:us-east-2:123456789:key/d17c0152-aea9-41ba-a36d-f6e640b2ba97'
- path_regex: 'environment/secrets/stg/(.*).yaml'
  kms: 'arn:aws:kms:us-east-2:123456789:key/ce2cc4c7-7034-402a-9ba0-61c69b69efe4'
```

## 2. Encrypt secrets

### Using helm secrets (need sops installed)

```bash
# encrypt secrets
helm secrets encrypt environment/secrets/dev/values.yaml > environment/secrets/dev/values-enc.yaml
# these values-env.yaml will be used, dont commit the values.yaml
```

### Commit the encrypted secrets to git

Commit the values-enc.yaml to git repo and prepare application in argocd to be created

Don't commit the values.yaml, in this example, we put it because it is a demo for you to encrypt the secrets

## 3. Create application in argocd

```bash
# gitops/argocd-plugins/sops/example
kubectl apply -f application.yaml
```

## 4. Check the application

Application will have the secret decrypted when argocd sync the application


