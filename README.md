# personal-aws-devops-playground

My personal project to improve my AWS DevOps tools skills. Main focus lies on running Docker containers in AWS and provisioning infrastructure via Terraform.

This project consists of:

- EC2 Ansible deployment
- ECS deployment
- EKS deployment
- CI/CD via GitHub Actions and ECS

Each deployment is isolated in its own folder and deploys the same flask app in a container. Only the message displayed by the Flask app varies a bit between each deployment

## How to run this project

### EC2 Ansible deployment

- Provisions EC2 instances (1 control node, `n` managed nodes)
- Sets up Ansible for the nodes
- Instructs each managed node to pull flask image from ECR and to run it

#### Set up keys and secrets

- Create an SSH key pair and add it to the folder `/ec2-ansible/ssh-keys/`
  - Will be used to SSH into the EC2 control node
- Create file `secrets.env` in the folder `/config/` and add your AWS account ID there
  - Format should be `ACCOUNT_ID="123456"`
  - Will be used on your local machine to login to your ECR and push the flask app image
- Create file `secrets.yml` in the folder `/ec2-ansible/ansible/` and add your AWS account ID there
  - Format should be `account_id=123456`
  - Will be used inside the managed nodes to login to your ECR and pull the flask app image

#### Set up flask image

- Build and push the flask image
  - From the project root, run `/ec2-ansible/docker/build-and-push-image.sh`
  - Make sure the file is executable via `chmod +x`
- Provision the infrastructure
  - From the `/ec2-ansible/terraform/` folder run `terraform apply`
- Set up the control node
  - From the project root, run the script `/ec2-ansible/scripts/setup_control_node.sh <ssh-keypair-name>`
  - **Note:** Make sure to replace `<ssh-keypair-name>` with your keypair name created in the previous steps
  - This script
    - Fetches EC2 instance IPs
    - Creates an Ansible inventory file,
    - Creates an Ansible config file
    - Copies all necessary files to the EC2 control node

#### Run Ansible playbook

- SSH into EC2 control node
  - Use public IP printed after running `terraform apply`
- Register managedes nodes with their IP addresses
  - Use `ssh-keyscan` with the command `ssh-keyscan -f ~/managed_node_ips`
- Run the playbook
  - In the `~/ansible/` folder run command `ansible-playbook deploy_container.yaml`
  - All managed nodes should now have a flask container running

#### Query flask app

- Send a HTTP GET request to the managed nodes
  - Use curl command `curl <managed-node-ip>:5000`

### ECS deployment (without CI/CD)

#### Set up secrets

- Create file `secrets.env` in the folder `/config/` and add your AWS account ID there
  - Format should be `ACCOUNT_ID="123456"`
  - Will be used on your local machine to login to your ECR and push the flask app image
- (Optional) add your account ID to the `terraform.tfvars` file
  - Or enter it during `terraform apply` later
  - Will be used to specify the image for the ECS tasks

#### Disable CI/CD

- Comment everything in the file `/.github/workflows/ecs-cicd.yaml`
  - Removes the GitHub Action workflow
- Comment the S3 backend configuration in the file `/ecs/terraform/main.tf`
  - Leaves the terraform state locally

#### Provision resources

- Build and push the image to ECR
  - From the project root run `./eks/docker/build-and-push-image.sh`
  - Make sure the shell script file is executable via `chmod +x`
- Provision the AWS infrastructure
  - From the `/ec2-ansible/terraform/` folder run `terraform apply`
  - Also sets up ECS service and an ALB

#### Query flask app

- Send a HTTP get request to the ECS service
  - Copy the ALB DNS output from Terraform
  - Either open the URL in a browser or run a `curl <alb-url>` command
- Resend the requests to see different task IDs confirming that load balancing is working

### ECS deployment (with CI/CD)

#### Basic setup

- Follow all steps from _ECS deployment (without CI/CD)_
  - **Skip** the _disable CI/CD_ part
- Once done, you should have the same ECS cluster but with a remote terraform state stored in S3 and a GitHub Action workflow

#### Trigger CI/CD pipeline

- CI/CD pipeline gets automatically triggered in the following cases:
  - Files in `/ecs/app/` get modified
  - Dockerfile in `/ecs/docker` gets modified
- Quick test
  - Change the message in the `/ecs/app/hello.py` file and commit it
- GitHub Actions automatically rebuild the docker image, update the ECS task definition and deploy the run container

#### Query flask app

- Same as above, send a HTTP get request to the ECS service via the ALB DNS

### EKS deployment

#### Set up secrets

- Create an SSH key pair and add it to the folder `/eks/ssh-keys/`
  - Will be used to SSH into the EC2 jump host
- Create file `secrets.env` in the folder `/config/` and add your AWS account ID there
  - Format should be `ACCOUNT_ID="123456"`
  - Will be used on your local machine to login to your ECR and push the flask app image
- Update image repository in the Helm values
  - Values are located at `/eks/helm/values.yaml`
  - Replace the placeholder with your account ID
- (Optional) Add the name of your IAM user to the `terraform.tfvars` file
  - IAM user will be authorized to access the cluster via access entry

#### Provision resources

- Build and push the image to ECR
  - From the project root run `./eks/docker/build-and-push-image.sh`
  - Make sure the shell script file is executable via `chmod +x`
- Provision the AWS infrastructure
  - From the `/eks/terraform/` folder run `terraform apply`
  - Also sets up access entries and node groups

#### Deploy app

- Update local kubeconfig
  - Run `aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>`
  - Enables interacting with the EKS cluster via `kubectl`
- Deploy helm chart
  - From project source, run `helm install my-flask-app ./eks/helm/`
  - Sets up pods and exposes them via a service

#### Query flask app

- SSH into jump host using SSH keys created in the previous steps
  - Public IP is displayed by terraform outputs after `terraform apply`
  - Jump host is required as there's no ALB provisioned right now
- Run curl to one of the EC2 instances in the EKS node group
  - Private IP of one of the instances is displayed by terraform outputs during `terraform apply`
  - Use port `30080`, as that's the NodePort
- You should now see the flask app message with pod and node details

## Roadmap

- [x] Dockerized Flask App
- [x] Provisioned basic EC2 infrastructure with Terraform
- [x] Set up configuration via Ansible to run the app
- [x] Provisioned and set up ECS cluster
- [x] Provisioned and set up EKS cluster
- [x] Wrote Helm charts to package the app
- [x] Created CI/CD via GitHub Actions
