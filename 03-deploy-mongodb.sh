#!/bin/bash
export mongodbUsername=dbadmin
export mongodbPassword=POirotolodfgj#

#helm repo add bitnami https://charts.bitnami.com/bitnami
#helm search repo bitnami

helm install ratings bitnami/mongodb \
    --namespace ratingsapp \
    --set mongodbUsername=$mongodbUsername,mongodbPassword=$mongodbPassword,mongodbDatabase=ratingsdb

kubectl create secret generic mongosecret \
    --namespace ratingsapp \
    --from-literal=MONGOCONNECTION="mongodb://$mongodbUsername:$mongodbPassword@ratings-mongodb.ratingsapp:27017/ratingsdb"

kubectl describe secret mongosecret1 --namespace ratingsapp
