# Traefik + Ngnix static site on Kubernetes

A sample deployment of nginx static site with traefik proxy on local kubernetes (eg: Minikube).


## Setup with Self Signed Certificate

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
To deploy prod in the `prod` namespace, repeat steps 7 while referencing the prod values file and chart name.

eg:

```sh
helm upgrade --install nginx-prod ./charts/nginx-site -n prod -f ./charts/nginx-site/prod-values.yaml
```


## Setup with Lets-encrypt

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
