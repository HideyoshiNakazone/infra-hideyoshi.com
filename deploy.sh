#!/bin/bash

kubectl apply -f ./portfolio-namespace.yaml

kubectl apply -f ./postgres
kubectl apply -f ./frontend
kubectl apply -f ./backend
kubectl apply -f ./nginx-ingress