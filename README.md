# personal-aws-devops-playground

My personal project to improve my AWS DevOps tools skills. Main focus lies on running Docker containers in AWS and provisioning infrastructure via Terraform.

## How to run this project

### EC2 Ansible deployment

#### Set up keys and secrets

- Create an SSH key pair and add it to the folder `/ec2-ansible/ssh-keys/`
  - Will be used to SSH into the EC2 control node
- Create file `secrets.env` in the folder `/config/` and add your AWS account ID there
  - Format should be `ACCOUNT_ID="123456"`
  - Will be used on your local machine to login to your ECR and push the flask app image
- Create file `secrets.yml` in the folder `/ec2-ansible/ansible/` and add your AWS account ID there
  - Format should be `account_id=123456`
  - Will be used inside the managed nodes to login to your ECR

#### Set up flask image

- Build and push the flask image
  - From the project root, run the script `/ec2-ansible/docker/build-and-push-image.sh`
  - Make sure the file is executable via `chmod +x`
- Provision the infrastructure
  - From the `/ec2-ansible/terraform/` folder run `terraform apply`
- Set up the control node
  - Run the script `/ec2-ansible/scripts/setup_control_node.sh`
  - This script
    - Fetches EC2 instance IPs
    - Creates an Ansible inventory file,
    - Creates an Ansible config file
    - Copies all necessary files to the EC2 control node

#### Run Ansible playbook

- SSH into EC2 control node
  - Use public IP printed by Terraform
- Use `ssh-keyscan` to register managed nodes with their IP addresses specified in `~/managed_nodes_ips`
- In the `~/ansible/` folder run command `ansible-playbook deploy_container.yaml`
  - All managed nodes should now have a flask container running
- Send an HTTP GET request to the managed nodes and check the message returned

### ECS deployment

#### Set up secrets

- Create file `secrets.env` in the folder `/config/` and add your AWS account ID there
  - Format should be `ACCOUNT_ID="123456"`
  - Will be used on your local machine to login to your ECR and push the flask app image
- (Optional) add your account ID to the `terraform.tfvars` file
  - Or enter it during `terraform apply` later

#### Provision resources

- From the project root run `./eks/docker/build-and-push-image.sh`
  - Builds and pushes the image to ECR
  - Make sure the shell script file is executable via `chmod +x`
- From the `/ec2-ansible/terraform/` folder run `terraform apply`
  - Provisions the whole infrastructure, including the ECS service and an ALB
- Copy the ALB DNS output from Terraform and either open it in a browser or run a `curl` command
  - Repeat this to see different task IDs confirming that load balancing is working

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
- (optional) Add the name of your IAM user to the `terraform.tfars` file
  - IAM user will be authorized to access the cluster via access entry

#### Provision resources

- From the project root run `./eks/docker/build-and-push-image.sh`
  - Builds and pushes the image to ECR
  - Make sure the shell script file is executable via `chmod +x`
- From the `/eks/terraform/` folder run `terraform apply`
  - Provisions the whole infrastructure, including the ECS cluster, access entries and node groups

#### Deploy app

- Update local kubeconfig
  - Run `aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>`
  - Enables interacting with the EKS cluster via `kubectl`
- Deploy helm chart
  - From project source, run `helm install my-flask-app ./eks/helm/`

#### Access service

- SSH into jump host using SSH keys created in the previous steps
  - Public IP is displayed by terraform outputs after `terraform apply`
- Run curl to one of the EC2 instances in the EKS node group
  - Private IP of one of the instances is displayed by terraform outputs
  - Use port `30080`, as that's the NodePort
- You should now see the flask app message with pod and node details

## Roadmap

- [x] Dockerized Flask App
- [x] Provisioned basic EC2 infrastructure with Terraform
- [x] Set up configuration via Ansible to run the app
- [x] Provisioned and set up ECS cluster
- [x] Provisioned and set up EKS cluster
- [x] Wrote Helm charts to package the app
- [ ] Created CI/CD via GitHub Actions
