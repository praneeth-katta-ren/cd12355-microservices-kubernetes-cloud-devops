#/bin/bash

# Update the local package index with the latest packages from the repositories
apt update

# Install a couple of packages to successfully install postgresql server locally
apt install build-essential libpq-dev

# Update python modules to successfully build the required modules
pip install --upgrade pip setuptools wheel

pip install -r requirements.txt

export DB_USERNAME=myuser
export DB_PASSWORD=${POSTGRES_PASSWORD}
export DB_HOST=127.0.0.1
export DB_PORT=5433
export DB_NAME=mydatabase

# Set up port forwarding
kubectl port-forward --namespace default svc/postgresql-service-postgresql 5433:5432 &
# Export the password. Replace 
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql-service-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)


curl <BASE_URL>/api/reports/daily_usage
curl <BASE_URL>/api/reports/user_visits