#!/bin/bash

export INSTALL_K3S_EXEC="--no-deploy traefik"
curl -sfL https://get.k3s.io | sh -s -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

kubectl apply -f ./nginx-ingress/nginx-ingress.yaml

kubectl apply -f ./cert-manager/cert-manager.yaml
kubectl apply -f ./cert-manager/cert-manager-issuer.yaml
kubectl apply -f ./cert-manager/cert-manager-certificate.yaml

kubectl apply -f ./portfolio-namespace.yaml

kubectl apply -f ./postgres
kubectl apply -f ./frontend
kubectl apply -f ./backend

kubectl apply -f ./nginx-ingress/nginx-ingress-root.yaml
kubectl apply -f ./nginx-ingress/nginx-ingress-api.yaml