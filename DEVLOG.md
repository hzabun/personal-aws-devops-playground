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