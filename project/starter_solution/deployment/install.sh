#/bin/bash
---
# To deploy the database and necessary components
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml

kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f deployment_db.yaml
kubectl apply -f postgresql-service.yaml
---
# Set up port-forwarding to `postgresql-service` and run db files
kubectl port-forward service/postgresql-service 5433:5432 &
apt update
apt install postgresql postgresql-contrib
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql-secret -o jsonpath="{.data.POSTGRES_PASSWORD}" | base64 -d)
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U postgres -d project -p 5433 < ./../db/3_seed_tokens.sql
---
# To view the tables
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U postgres -d project -p 5433
---
# To build and deploy the analytics application locally
docker build -t test-coworking-analytics .
docker run --network="host" --env-file=.env test-coworking-analytics
---
# To create the EKS cluster
eksctl create cluster --name project --region us-east-1 --nodegroup-name project-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2
aws eks --region us-east-1 update-kubeconfig --name project
---
# To delete the EKS cluster
eksctl delete cluster --name project --region us-east-1
---
# To setup cloudwatch container insights
aws iam attach-role-policy --role-name eksctl-project-nodegroup-project-n-NodeInstanceRole-1K1swq368gBj --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy 
aws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name project
