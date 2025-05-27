# Makefile for local Kubernetes development with Minikube

ENVIRONMENT ?= "dev"
NAMESPACES := dev traefik
IMAGE_NAME := kenec/nginx
SECRET := dev-secret

.PHONY: all start docker-env build namespaces secret traefik deploy

all: start docker-env build namespaces secret traefik deploy

start:
	minikube start

docker-env:
	@echo "Setting Docker environment to Minikube..."
	@eval $$(minikube docker-env)

build: docker-env
	docker build -t $(IMAGE_NAME) .

namespaces:
	echo "$(NAMESPACES)" | xargs -n1 kubectl create namespace --dry-run=client -o yaml | kubectl apply -f -

secret:
	kubectl create secret generic $(SECRET) --from-literal=message="${ENVIRONMENT}-secret" -n ${ENVIRONMENT} --dry-run=client -o yaml | kubectl apply -f -

traefik:
	helm upgrade --install traefik traefik/traefik -f traefik/values.yaml --namespace traefik

deploy:
	helm upgrade --install nginx-${ENVIRONMENT} ./charts/nginx-site -n ${ENVIRONMENT} -f ./charts/nginx-site/${ENVIRONMENT}-values.yaml

