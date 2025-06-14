
### Dockerize Flask App
- [x] Write basic python Flask app
- [x] Build image via Docker
- [x] Push the image to ECR

### Infrastructure with Terraform
- [x] Use Terraform to provision:
    - Three EC2 instances (Amazon Linux 2)
    - Security groups allowing SSH and HTTP
- [x] Fix unreachable managed nodes issue
- [x] Create EC2 instance profile to access ECR

### Configuration via Ansible
- [x] Write bash script to set up control node
- [x] Use Ansible to:
    - SSH into each EC2 instance
    - Install Docker and run containerized app

### ECS deployment
- [x] Use Terraform to provision an ECS cluster
- [x] Deploy app via tasks and services
- [x] Deploy ALB for the ECS service

### EKS deployment
- [ ] Use Terraform to provision an EKS cluster
- [ ] Use kubectl to deploy the same app to the cluster

### Helm automation
- [ ] Package app into a Helm chart and deploy it

### CI/CD via GitHub Actions
- [ ] Set up a GitHub repo for the app
- [ ] Create GitHub Actions workflow to
    - On push: build the Docker image, push to ECR
    - On success: deploy updated image to EKS (kubectl or Helm)