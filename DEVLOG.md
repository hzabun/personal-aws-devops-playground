## 📅 June 02, 2025

#### Done
- Fixed issue with unexpected characters added to list of managed node IPs
- Converted additional relative paths to absolute ones
- Wrote proper Ansible playbook to install dependencies, pull image and run container
  - Fixed dependency issues in the playbook by using virtual environments

#### Learned
- Windows automatically adds carriage return characters like `\r` which can lead to file reading issues
- Virtual environments are still very useful in EC2 instances as well
  - Unlike containers, which might prefer "global" package installations
- Ansible module `command` can use args like `creates` for idempotency
  - E.g. runs a task to create a venv only if the venv path hasn't been created yet

#### Blockers / Questions
- Using Git Bash on Windows to connect to Linux is cumbersome
  - VS Code SSH extensions might be worth a shot
- EC2 instances are still missing IAM permissions to login to ECR/pull images

#### Next steps
- Add new Terraform resource to create instance profiles
  - Keep in mind that instance profiles need to be created separately from IAM roles when using Terraform
- Run playbook again and troubleshoot further, if necessary

## 📅 June 01, 2025

#### Done
- Refactored project structure a bit
- Replaced complex relational paths with absolute ones (from project root)
- Added basic (yet incomplete) Ansible playbook

#### Learned
- Terraform has a command called `cidrsubnet` which calculates subnets given a VPC CIDR and subnet bits
- Terraform automatically assigns an index to list elements when doing a for expression (in python: list comprehension)
  - Python would require the function `enumerate` for this

#### Next steps
- Test project after refactoring again
  - Provision infrastructure, run scripts, check if it still works
- Finish first Ansible playbook