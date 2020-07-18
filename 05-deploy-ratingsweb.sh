#!/bin/bash

rm -rf ratings-web-deployment.yaml

cat <<  EOF > ratings-web-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ratings-web
spec:
  selector:
    matchLabels:
      app: ratings-web
  template:
    metadata:
      labels:
        app: ratings-web # the label for the pods and the deployments
    spec:
      containers:
      - name: ratings-web
        image: <acrname>.azurecr.io/ratings-web:v1 # IMPORTANT: update with your own repository
        imagePullPolicy: Always
        ports:
        - containerPort: 8080 # the application listens to this port
        env:
        - name: API # the application expects to connect to the API at this endpoint
          value: http://ratings-api.ratingsapp.svc.cluster.local
        resources:
          requests: # minimum resources required
            cpu: 250m
            memory: 64Mi
          limits: # maximum resources allocated
            cpu: 500m
            memory: 512Mi
EOF
sed -i "s/<acrname>/$ACR_NAME/g" ratings-web-deployment.yaml

kubectl apply \
--namespace ratingsapp \
-f ratings-web-deployment.yaml