# Traefik + Ngnix static site on Kubernetes

A sample deployment of nginx static site with traefik proxy on local kubernetes (eg: Minikube).


## Setup
You can setup this locally on your minikube by running:
```sh
make all ENVIRONMENT=dev
```

NB: To be able able to access the static site with the domain `dev.example.com`, you are required to add the domain to your `/etc/hosts` files and then turn on `minikube tunnel`. 

## Manual Setup

### 1. Setup minikube
```sh
minikube start
```

### 2. Point shell to Minikube's Docker daemon
```sh
eval $(minikube docker-env)
```

### 3. Build Image

```sh
docker build -t kenec/nginx .
```

### 4. Create namesapces (dev, prod, traefik)
```sh
echo "dev prod traefik" | xargs -n1 kubectl create namespace
```

### 5. Create application secret
```sh
kubectl create secret generic dev-secret --from-literal=message="dev-secret" -n dev
```

### 6. Deploy traefik
```sh
helm upgrade --install traefik traefik/traefik -f traefik/values.yaml --namespace traefik
```

### 7. Deploy Nginx static site for dev environment
```sh
helm upgrade --install nginx-dev ./charts/nginx-site -n dev -f ./charts/nginx-site/dev-values.yaml
```

### 8. Edit /etc/host and add the following record
```sh
127.0.0.1 dev.example.com
127.0.0.1 prod.example.com
```

### 9. Open an new shell and create minikube tunnel
```sh
minikube tunnel
```

### 10. Access the deployed static site
```sh
curl -k https://dev.example.com
```

### 10. Deploy Prod  
To deploy prod in the `prod` namespace, repeat steps 5 and 7 while referencing the prod values file and chart name.

eg:

```sh
helm upgrade --install nginx-prod ./charts/nginx-site -n prod -f ./charts/nginx-site/prod-values.yaml
```


## Use Lets-encrypt

To deploy the setup with an ACME provider like Let's Encrypt for automatic certificate generation



Traefik value file has already been configured with a certificate resolver to point to the staging let's encrypt server.

```yaml
certificatesResolvers:
  myresolver:
    acme:
      email: nnamani.kenechukwu@gmail.com
      storage: /data/acme.json
      httpChallenge:
        entryPoint: web
      caServer: https://acme-staging-v02.api.letsencrypt.org/directory
```

To allow ingressRoute make use of this certificateResolver, use the following tls setting instead

```yaml
  tls:
    certResolver: myresolver
```

## Boostrapping using Terraform

### 1. Traefik 

```hcl
resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "34.3.0"
  namespace  = "traefik"

  values = [
    "traefik/values.yaml"
  ]
}
```

### 2. Ngnix static site


```hcl
resource "helm_release" "nginx" {
  name       = "nginx-site"
  chart      = "./charts/nginx-site"
  namespace  = "dev"

  values = [
    "dev-values.yaml"
  ]
}
```

### 3. Setup GKE cluster

We can use the official GKE terraform module to boostrap the kubernetes cluster  
https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest
