#!/bin/bash
kubectl create namespace ingress

helm repo add stable https://kubernetes-charts.storage.googleapis.com/

helm install nginx-ingress stable/nginx-ingress \
    --namespace ingress \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

rm -rf ratings-web-service.yaml

cat <<  EOF > ratings-web-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ratings-web
spec:
  selector:
    app: ratings-web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
EOF

kubectl delete service \
    --namespace ratingsapp \
    ratings-web

kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-service.yaml

rm -rf ratings-web-ingress.yaml

cat <<  EOF > ratings-web-ingress.yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ratings-web-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: frontend.<ingress ip>.nip.io # IMPORTANT: update <ingress ip> with the dashed public IP of your ingress, for example frontend.13-68-177-68.nip.io
    http:
      paths:
      - backend:
          serviceName: ratings-web
          servicePort: 80
        path: /
EOF

PIP=$(kubectl get service nginx-ingress-controller --namespace ingress | awk 'FNR == 2 {print $4}' | sed 's/\./-/g')

sed -i "s/<ingress ip>/$PIP/g" ratings-web-ingress.yaml

kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-ingress.yaml