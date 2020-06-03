#!/bin/bash

az resource create --resource-type Microsoft.OperationalInsights/workspaces \
        --name $WORKSPACE \
        --resource-group $RESOURCE_GROUP \
        --location $REGION_NAME \
        --properties '{}' -o table

WORKSPACE_ID=$(az resource show --resource-type Microsoft.OperationalInsights/workspaces \
    --resource-group $RESOURCE_GROUP \
    --name $WORKSPACE \
    --query "id" -o tsv)

az aks enable-addons \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --addons monitoring \
    --workspace-resource-id $WORKSPACE_ID

cat << EOF > logreader-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
    name: containerHealth-log-reader
rules:
- apiGroups: ["", "metrics.k8s.io", "extensions", "apps"]
  resources:
  - "pods/log"
  - "events"
  - "nodes"
  - "pods"
  - "deployments"
  - "replicasets"
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
    name: containerHealth-read-logs-global
roleRef:
    kind: ClusterRole
    name: containerHealth-log-reader
    apiGroup: rbac.authorization.k8s.io
subjects:
- kind: User
  name: clusterUser
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply \
    -f logreader-rbac.yaml