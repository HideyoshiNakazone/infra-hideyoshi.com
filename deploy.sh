#!/bin/bash

kubectl apply -f ./postgres
kubectl apply -f ./frontend
kubectl apply -f ./backend
kubectl apply -f ./nginx-ingress