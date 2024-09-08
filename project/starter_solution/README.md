## Project Microservices at Scale using AWS and Kubernetes

### Databse Creation and Integration

- EKS cluster is created and necessary role permissions are granted
- Add CloudWatch plugin and necessary role permissions are granted
- Database is created using base image of postgres along with config files such as deployment, configmap, secret 
- Service is created using config files which receives the request from any applications
- Data is populated into the DB using port forward and running sql files using psql
- Application code is pushed to "project" branch
- Using the Docker file and build_spec, AWS Code triggers the build, builds the image and pushes to ECR
- Application is deployed by chaning the configmap to new IP address of the DB service
- This will make sure that Application is connected to the database
- For commands, visit `install.sh` and use commands manually

### Application Development Lifecycle

- Pushing an updated version of the application into `project` branch will trigger the AWS Code Build Service
- AWS Code Build Service uses `build_spec.yaml` for the set of instructions and builds the image to the specified ECR
- Deployment directory consists of Kubernetes config files needed to deploy the application to the EKS cluster connecting to same ECR
- Connect the EKS cluster to local PC using AWS CLI 
- Deploy the application with updated image tag which will pull the image and deploy the new version.

### Standout Suggestions

- Memory and CPU allocation requests are 256m CPU core and 1GB of memory with limits upto 1 CPU cores and 2GB of memory.
- I have chosen this as reasonable resource allocation based on factors such as
    - This application offers only 3 API endpoints retrieving data from 2 tables
    - Considering the API endpoints, usage of these endpoints could be quite low
    - Since the data retrieve is not large, providing a large amount of memory will be a overkill
    - I measured the memory usage and CPU usage during the testing process which shows the usage of less than half CPU and less than half GB of memory
- Since I am choosing a small CPU and memory allocation, best AWS instance type will be 
    - t3.small which has 2 cores and 2 GB of memory
    - This ensures smooth operation of application and database even at the limits specified.
    - With this instance type, horizontal pod scaling can also be done at peak usage with additional node scaling
- Costs can be saved by 
    - Creating Automatic node scaling configuration with smaller instance type in the node group
    - By creating pod with as small configuration as possible with pod scaling configuration
    - Since automatic scaling and pod scaling will be in place, costs of bigger instance can be avoided and nodegroup scaling is done only when needed
    - Also we can reserve one node with AWS to reduce the cost.
    - For peak usage which could be for very limited time, spot instances can be used.
    - If there is a continous usage of the application, more than one node can be reserved