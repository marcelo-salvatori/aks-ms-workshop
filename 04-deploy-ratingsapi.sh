#!/bin/bash

rm -rf ratings-api-deployment.yaml

cat <<  EOF > ratings-api-deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ratings-api
spec:
  selector:
    matchLabels:
      app: ratings-api
  template:
    metadata:
      labels:
        app: ratings-api # the label for the pods and the deployments
    spec:
      containers:
      - name: ratings-api
        image: <acrname>.azurecr.io/ratings-api:v1 # IMPORTANT: update with your own repository
        imagePullPolicy: Always
        ports:
        - containerPort: 3000 # the application listens to this port
        env:
        - name: MONGODB_URI # the application expects to find the MongoDB connection details in this environment variable
          valueFrom:
            secretKeyRef:
              name: mongosecret # the name of the Kubernetes secret containing the data
              key: MONGOCONNECTION # the key inside the Kubernetes secret containing the data
        resources:
          requests: # minimum resources required
            cpu: 250m
            memory: 64Mi
          limits: # maximum resources allocated
            cpu: 500m
            memory: 256Mi
        readinessProbe: # is the container ready to receive traffic?
          httpGet:
            port: 3000
            path: /healthz
        livenessProbe: # is the container healthy?
          httpGet:
            port: 3000
            path: /healthz
EOF

sed -i "s/<acrname>/$ACR_NAME/g" ratings-api-deployment.yaml

kubectl apply \
    --namespace ratingsapp \
    -f ratings-api-deployment.yaml

rm -rf ratings-api-service.yaml

cat <<  EOF > ratings-api-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ratings-api
spec:
  selector:
    app: ratings-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP
EOF

kubectl apply \
    --namespace ratingsapp \
    -f ratings-api-service.yaml
