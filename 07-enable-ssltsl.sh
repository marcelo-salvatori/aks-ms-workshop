#!/bin/bash

kubectl create namespace cert-manager

helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml

helm install cert-manager \
    --namespace cert-manager \
    --version v0.14.0 \
    jetstack/cert-manager

cat << EOF > cluster-issuer.yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: <your email> # IMPORTANT: Replace with a valid email from your organization
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# the variable email was set as an environment variable in .profile
sed -i "s/<your email>/$email/g" cluster-issuer.yaml

kubectl apply \
    --namespace ratingsapp \
    -f cluster-issuer.yaml

cat << EOF > ratings-web-ingress.yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ratings-web-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt
spec:
  tls:
    - hosts:
      - frontend.<ingress ip>.nip.io # IMPORTANT: update <ingress ip> with the dashed public IP of your ingress, for example frontend.13-68-177-68.nip.io
      secretName: ratings-web-cert
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