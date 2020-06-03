#!/bin/bash

cat << EOF > ratings-api-hpa.yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: ratings-api
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ratings-api
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 30
EOF

kubectl apply \
    --namespace ratingsapp \
    -f ratings-api-hpa.yaml


#the commands below should be ran in order to test the HPA configured above

#LOADTEST_API_ENDPOINT=https://frontend.$PIP.nip.io/api/loadtest

#az container create \
#    -g $RESOURCE_GROUP \
#    -n loadtest \
#    --cpu 4 \
#    --memory 1 \
#    --image azch/artillery \
#    --restart-policy Never \
#    --command-line "artillery quick -r 500 -d 120 $LOADTEST_API_ENDPOINT"
#
#kubectl get hpa \
#  --namespace ratingsapp -w

az aks update \
--resource-group $RESOURCE_GROUP \
--name $AKS_CLUSTER_NAME  \
--enable-cluster-autoscaler \
--min-count 1 \
--max-count 2

# kubectl get nodes -w