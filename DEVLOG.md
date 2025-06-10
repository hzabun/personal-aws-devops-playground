## 📅 Jun 10, 2025

#### Done
- [Infra] Added basic ALB to ECS service

#### Learned
- Using target groups with ECS services is quite straightforward
  - Just reference it in the ECS service under the `load_balancer` block
- For manual EC2 instance, target group attachments would be needed
  - Use `for_each` meta argument
  - Also use the `k => v` expression to convert a list of EC2 instances into a map
  - Helps reduce reduntant resource specifications and keep code clean

#### Blockers / Questions
- Nothing today

#### Next steps
- Test ALB by provisioning it in AWS

## 📅 June 09, 2025

#### Done
- [DevOps] Successfully created ECS service and connected to Flask app
- [Infra] Changed container instance type to t3.medium
  - Allows 2 ENIs for ECS tasks (t2.micro allows only one ENI for ECS tasks)
- Updated flask app to print currently running task ID
  - Confirmed it's working
- Refactored project directory structure
  - Each deployment type gets it's own terraform configs, Dockerfile, flask python file etc.

#### Learned
- When provisioning EC2 instances via terraform, public IPs are only added if explicitly specified
  - Creating EC2 instances directly
    - Settings for the EC2 instances can be set directly
    - Argument`associate_public_ip_address = true` is necessary
  - Using launch templates/ASG
    - No setting for public ip, ASGs use the subnet's setting
    - Argument `map_public_ip_on_launch = true` in the subnet resource is necessary
- Configuring Docker networking modes are important
  Context: current ECS tasks are mapping container port 5000 to host port 5000
  - Modes `bridge` and `host`
    - Allow only one container to use that port specific host port
    - Each EC2 instance can run only a single task, as only one can use that port
  - Mode `awsvpc`
    - Each task gets its own ENI with a separate private IP address
    - EC2 instances can run multiple tasks

#### Blockers / Questions
- Container instances are running multiple tasks, but tasks don't have a public IP
  - ~~Cannot connect directly to tasks for debugging purposes as of now~~
  - Fixed: can connect to private IP of tasks by using an EC2 instance as a jump host

#### Next steps
- Set up ALB to connect to multiple tasks across multiple EC2 instances

## 📅 June 08, 2025

#### Done
- [Infra] Created basic ECS task definition and service resources
- [DevOps] Set target capacity of managed ASG to 100%
  - ECS should now try to adjust running instances to fully accomodate resource requests from tasks

#### Learned
- If using Fargate, CPU and memory requests need to be defined at task-level
  - Container-level values only specify for each container separately
  - But Fargate doesn't have isolated EC2 instances running just for these tasks
  - So defining at task level let's Fargate know how much total compute/memory will be needed

#### Blockers / Questions
- CloudWatch agent apparently not pre-installed on Amazon Linux 2023 AMI
  - Container insights should not work properly without the agent
  - Need to install and configure it properly later on, including IAM roles
- Currently I'm adding the cluster name to the ECS agent via the following user data
  - `echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config`
  - What if that line already exists in the `ecs.config` file? Need to SSH into an instance and check

#### Next steps
- Try provisioning the resources with the current configuration and debug, if necessary

## 📅 June 07, 2025

#### Done
- [Infra] Created ECS with EC2 compute terraform files
  - Includes ECS cluster, ASG, VPC and basic instance profile
  - Not finished yet, still WIP

#### Learned
- There's a public SSM parameter which contains the latest ECS optimized AMI ID
  - Path: `/aws/service/ecs/optimized-ami/amazon-linux-2/recommended`
  - Can easily be used with terraform data source or AWS CLI `aws ssm get-parameters`
- ASGs used for ECS clusters need the tag `AmazonECSManaged = true`
  - Enables ECS to manage the scale in and scale out events of the ASG
  - Uses target tracking scaling policies on metrics like *CapacityProviderReservation* => cpu/memory reserved by tasks vs cpu/memory available from running EC2 instances

#### Blockers / Questions
- How does the setting *containerInsights* in the ECS cluster work? What does it do specifically?
- What resources in the ECS cluster need which IAM roles/permissions?

#### Next steps
- Find out and create IAM roles/permissions for remaining ECS resources
- Test create the ECS resources

## 📅 June 06, 2025

#### Done
- [Docs] Refactored structure of devlog for more clarity
  - Added short tags to finished tasks

#### Learned
- Nothing worth mentioning

#### Blockers / Questions
- Nothing worth mentioning

#### Next steps
- Start working on ECS deployment

## 📅 June 05, 2025

#### Done
- [Infra] Updated EC2 instance profile with all required permissions to pull images from ECR
- [App] Fixed issue with the directory structure within flask container
  - Prevents app from crashing due to missing/misplaced files
- [App] Fixed issue with wrong platform architecture of the flask image
  - Avoids runtime incompatibility (e.g. arm64 vs amd64)
- [DevOps] Successfully ran Flask container via Ansible playbook on all managed nodes
  - Website was accessible without issues

#### Learned
- `Docker build` command always builds images for architectures based on the host
  - On Apple Silicon that would be `linux/arm64`
  - But Amazon Linux AMI requires `linux/amd64`
- `Docker buildx build` can be used to build for specific (or multiple) architectures

#### Blockers / Questions
- How can I let Docker use the latest image if it's a new one?
  - If using tag `latest`, things can get messy
  - Docker uses local cache, even if the latest image has changed but the tag name is the same

#### Next steps
- Perform quick cleanup of current codebase and add comments where useful
- Ponder how to run flask container on ECS as next big step

## 📅 June 03, 2025

#### Done
- [Infra] Created instance profile to pull ECR images
  - Grants EC2 instances necessary permissions pull images from ECR

#### Learned
- AWS IAM policy documents are data sources, not resources
  - No infrastructure gets really created in AWS, as they are just computed values

#### Blockers / Questions
- Nothing today

#### Next steps
- Test pulling image with Ansible playbook and new instance profiles

## 📅 June 02, 2025

#### Done
- [Fix] Fixed issue with unexpected characters added to list of managed node IPs
  - Ensures playbook targets correct IPs
- [DevOps] Converted additional relative paths to absolute ones
  - Run scripts from project root to prevent file path issues
- [DevOps] Wrote proper Ansible playbook to install dependencies, pull image and run container
  - Adds virtual environments to prevent dependency issues in the playbook

#### Learned
- Windows automatically adds carriage return characters like `\r` which can lead to file reading issues
- Virtual environments are still very useful in EC2 instances as well
  - Unlike containers, which might prefer "global" package installations
- Ansible module `command` can use args like `creates` for idempotency
  - E.g. runs a task to create a venv only if the venv path hasn't been created yet

#### Blockers / Questions
- Using Git Bash on Windows to connect to Linux is cumbersome
- EC2 instances are still missing IAM permissions to login to ECR/pull images

#### Next steps
- Add new Terraform resource to create instance profiles
  - Keep in mind that instance profiles need to be created separately from IAM roles when using Terraform
- Run playbook again and troubleshoot further, if necessary

## 📅 June 01, 2025

#### Done
- [Refactor] Refactored project structure a bit
- [Refactor] Replaced complex relational paths with absolute ones (from project root)
- [DevOps] Added basic (yet incomplete) Ansible playbook
  - Lays groundwork for automated container deployment

#### Learned
- Terraform has a command called `cidrsubnet` which calculates subnets given a VPC CIDR and subnet bits
- Terraform automatically assigns an index to list elements when doing a `for` expression
  - Python would require the function `enumerate` for this

#### Next steps
- Test project after refactoring again
  - Provision infrastructure, run scripts, check if it still works
- Finish first Ansible playbook