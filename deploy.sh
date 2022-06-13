#!/bin/bash

function start_cert_manager {

    /usr/bin/kubectl apply -f ./cert-manager/cert-manager.yaml;
    /usr/bin/kubectl wait --for=condition=available \
        --timeout=600s \
        deployment.apps/cert-manager \
        deployment.apps/cert-manager-cainjector \
        deployment.apps/cert-manager-webhook \
        -n cert-manager;

}

function application_deploy {

    /usr/bin/kubectl apply -f ./portfolio-namespace.yaml;

    /usr/bin/kubectl apply -f \
        ./cert-manager/cert-manager-certificate.yaml;

    /usr/bin/kubectl apply -f ./postgres;
    /usr/bin/kubectl wait --for=condition=available \
        --timeout=600s \
        deployment.apps/postgres-deployment \
        -n portfolio;

    /usr/bin/kubectl apply -f ./frontend;
    /usr/bin/kubectl wait --for=condition=available \
        --timeout=600s \
        deployment.apps/frontend-deployment \
        -n portfolio;

    /usr/bin/kubectl apply -f ./backend;
    /usr/bin/kubectl wait --for=condition=available \
        --timeout=600s \
        deployment.apps/backend-deployment \
        -n portfolio;

    /usr/bin/kubectl apply -f \
        ./nginx-ingress/nginx-ingress-root.yaml;
    /usr/bin/kubectl apply -f \
        ./nginx-ingress/nginx-ingress-api.yaml;

}

function main {

    if [[ $1 == "--test" || $1 == "-t" ]]; then

        /usr/bin/minikube start --driver kvm2;
        /usr/bin/minikube addons enable ingress;
        
        start_cert_manager

        /usr/bin/kubectl apply -f \
            ./cert-manager/cert-manager-issuer-dev.yaml;
        
        application_deploy

        /usr/bin/minikube ip;

    else

        export INSTALL_K3S_EXEC="--no-deploy traefik";
        curl -sfL https://get.k3s.io | sh -s -;
        sudo chmod 644 /etc/rancher/k3s/k3s.yaml;

        /usr/bin/kubectl apply -f ./nginx-ingress/nginx-ingress.yaml;
        /usr/bin/kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=120s;

        start_cert_manager
        /usr/bin/kubectl apply -f ./cert-manager/cert-manager-issuer.yaml;

        application_deploy

    fi

    exit 0;

}

main $1