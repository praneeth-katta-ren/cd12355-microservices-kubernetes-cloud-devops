#/bin/bash

kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml

kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f deployment_db.yaml


kubectl exec -it postgresql-6889d46b98-bd84h -- bash
psql -U postgres -d project

kubectl apply -f postgresql-service.yaml

# List the services
kubectl get svc

# Set up port-forwarding to `postgresql-service`
kubectl port-forward service/postgresql-service 5433:5432 &

apt update
apt install postgresql postgresql-contrib

export DB_PASSWORD=postgres
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U postgres -d project -p 5433 < ./../db/3_seed_tokens.sql

PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U postgres -d project -p 5433
---
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql-secret -o jsonpath="{.data.POSTGRES_PASSWORD}" | base64 -d)
export DB_USERNAME=postgres
export DB_PASSWORD=${POSTGRES_PASSWORD}
export DB_HOST=127.0.0.1
export DB_PORT=5433
export DB_NAME=project
---
#inside analytics
docker build -t test-coworking-analytics .
docker run --network="host" --env-file=.env test-coworking-analytics
---
eksctl create cluster --name project --region us-east-1 --nodegroup-name project-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2
aws eks --region us-east-1 update-kubeconfig --name project
eksctl delete cluster --name project--region us-east-1

---
#cloudwatch container insights
aws iam attach-role-policy --role-name eksctl-project-nodegroup-project-n-NodeInstanceRole-1K1swq368gBj --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy 
aws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name project
