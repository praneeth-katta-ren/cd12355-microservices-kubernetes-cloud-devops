#/bin/bash

#change to script directory
cd lesson-3-microservices/exercises/2_simultaneous-containers/starter/
docker build -f db/Dockerfile  --build-arg DB_PASSWORD=starter --build-arg DB_USERNAME=starter -t db:latest db/
docker build -f user/Dockerfile -t user:latest user/
docker build -f admin/Dockerfile -t admin:latest admin/

docker run  -p 5433:5432 db -d

docker run --env-file user/.env --name user -d user:latest
docker run --env-file admin/.env --name admin -d admin:latest

