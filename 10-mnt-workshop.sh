#!/bin/bash

sh 01-deploy-aks-cluster.sh
sh 02-deploy-acr.sh 
sh 03-deploy-mongodb.sh
sh 04-deploy-ratingsapi.sh
sh 05-deploy-ratingsweb.sh
sh 06-deploy-ingress.sh
sh 07-enable-ssltsl.sh
sh 08-deploy-monitoring.sh
sh 09-depoly-autoscaler.sh
