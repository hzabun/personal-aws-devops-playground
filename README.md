# personal-aws-devops-playground
My personal project to improve my AWS DevOps tools skills. Main focus lies on running Docker containers in AWS and provisioning infrastructure via Terraform.

## How to run this project
### EC2 Ansible deployment
#### Set up keys and secrets
- Create an SSH key pair and add it to the folder `/ssh-keys/`
  - Will be used to SSH into the EC2 control node
- Create file `secrets.env` in the folder `/config/` and add your AWS account ID there
  - Format should be `ACCOUNT_ID="123456"`
  - Will be used on your local machine to login to your ECR and push the flask app image
- Create file `secrets.yml` in the folder `/ec2-ansible/ansible/` and add your AWS account ID there
  - Format should be `account_id=123456`
  - Will be used inside the managed nodes to login to your ECR

#### Set up flask image
- Build and push the flask image
  - From the project root, run the script `./ec2-ansible/docker/build-and-push-image.sh`
  - Make sure the file is executable via `chmod +x`
- Provision the infrastructure
  - From the `./ec2-ansible/terraform/` folder run `terraform apply`
- Set up the control node
  - Run the script `./ec2-ansible/scripts/setup_control_node.sh`
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
- TODO

### EKS deployment
- TODO


## Roadmap
- [x] Dockerized Flask App
- [x] Provisioned basic EC2 infrastructure with Terraform
- [x] Set up configuration via Ansible to run the app
- [ ] Provisioned and set up ECS cluster
- [ ] Provisioned and set up EKS cluster
- [ ] Wrote Helm charts to package the app
- [ ] Created CI/CD via GitHub Actions
