## 📅 May 31, 2025

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