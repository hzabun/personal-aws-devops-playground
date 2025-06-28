## 📅 June 28, 2025

#### Done
- [DevOps] Added basic GitHub actions workflow
  - Whole file in comments for now as it's not a valid configuration yet

#### Learned
- Nothing worth mentioning today

#### Blockers / Questions
- Nothing today

#### Next steps
- Expand GitHub actions workflow to make it a valid configuration

## 📅 June 27, 2025

#### Done
- [DevOps] Added NodePort service to helm chart
  - Installing chart now also exposes pods via NodePort
- [Infra] Added jump host to terraform configuration in public subnets
  - No ALB planned for the EKS cluster, so a jump host can be used to access the NodePort service
- [Infra] Added security groups to launch template for EKS nodes
  - Allows jump host to connect to the EKS nodes via port exposed by the NodePort service
- [Refactor] Renamed jump host IP output variable to lowercase letter for better readability
- [Docs] Updated readme with instructions on how to deploy the EKS cluster

#### Learned
- Interesting behaviour when assigning a launch template to EKS node group
  - If security groups are not specified in the launch template EKS automatically creates the necessary ones
  - If at least one security group is specified, EKS doesn't add any => all required ones must be specified manually
- Noticed this when adding a security group which allows the jump host to connect to the nodes via a specific port
  - Nodes were unable to be registered with the EKS cluster, as the necessary ingress/egress blocks were missing

#### Blockers / Questions
- None today

#### Next steps
- EKS deployment done, now continuing with CI/CD

## 📅 June 26, 2025

#### Done
- [Infra] Added launch template with increased HTTP hop limit to 2
  - Can now query EC2 instance ID from within a pod
- [DevOps] Created helm chart to deploy flask app
  - Can now run `helm install` and set image repository to install the flask app
- [Docs] Updated todo.md and roadmap
  - EKS deployment is now done, except for the readme instructions

#### Learned
- When creating a Kubernetes NodePort service it exposes the same port on every node in the cluster
  - Service (and underlying pod) can be accessed via any node in the cluster
  - Only the port has to stay the same
- Pods (and containers) run a separate network namespace than the host (e.g. EC2 instances)
  - When sending a request from within a container to the IMDS it first has to hop to the host namespace
  - Then it has to hop to the IMDS service
  - Hence hop limit of 2 is needed, as opposed to the default of 1

#### Blockers / Questions
- Pondered adding an application load balancer
  - Requires quite a lot of extra resources and permissions
  - Easier (and less error-prone) via terraform EKS module
  - Will skip for now, but revisit in next projects

#### Next steps
- Write instructions for how to deploy the EKS cluster
- Take first notes on how to set up CI/CD

## 📅 June 25, 2025

#### Done
- [App] Added pod and node attributes to the printed message
  - Shows pod name, pod IP, node name and node IP
- [Fix] Fixed wrong folder paths
- [Infra] Fixed networking and add-ons
  - CNI plugins were not working as bootstrapping was turned off
  - Prevented EC2 instances from registering as ready nodes
- [Docs] Updated todo.md

#### Learned
- Following subnet tags are important for EKS
  - (deprecated) `"kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"` and `"kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"`
    - Tells AWS that the subnet is owned/shared by the EKS cluster
  - `"kubernetes.io/role/elb" = "1"`
    - Tells AWS to use this subnet for internet-facing load balancers
    - Only needed if subnets were not explicitly specified within the load balancer configuration
  - `"kubernetes.io/role/internal-elb" = "1"`
    - Same as above, but for private/internal load balancers
- Setting `bootstrap_self_managed_addons` correctly is crucial
  - If set to `false` => all add-ons must be installed manually
    - Actually required if auto mode is on
  - If set to `true` => installs standard unmanaged addons like `aws-cni`, `kube-proxy` and CoreDNS
- Kubernetes as an API called `downward API`
  - Exposes information about a pod through environment variables in the pod definition
  - Can provide pod name, node name, pod IP, pod service account and even container level information
    - All as simple environment variables
- EC2 instance metadata service has specific reserved IP address `169.254.169.254`
  - Only accessible from within an EC2 instance (and the pods/containers running on it)
  - Provides information about the instance, such as ID, IAM role credentials etc.

#### Blockers / Questions
- Provisioned nodes were in a non-ready condition
  - cni plugin was not initialized
  - Likely due to misconfiguration with `bootstrap_self_managed_addons` set to `false`
- Printing pod and node attributes works fine, but not printing the EC2 instance ID
  - Possible reason might be the default IMDS hop limit of 1
  - Setting up launch template with higher hop limit might solve the issue

#### Next steps
- Try out adding launch template to node group and increase IMDS hops
- Write short helm file to deploy flask app

## 📅 June 24, 2025

#### Done
- [Infra] Modfied EKS cluster configuration with auto mode turned off
  - Created security group for EKS cluster
  - Created node group
  - Removed no longer used IAM policy attachments
- [Infra] Set instance types to `t3.medium`
  - Hopefully it will work this time

#### Learned
- Kubernetes services use by default ports 30000 - 32767
- Kube-apiserver uses port 10250 to communicate with kubelet running on nodes

#### Blockers / Questions
- Terraform might show drift when autoscaling changes the `desired` value of running nodes in the node group
  - One workaround might be using Terraform `lifecycle` blocks
  - Ignoring for now, but will revisit this if it becomes an issue later on

#### Next steps
- Provision new cluster with auto mode turned off
- Run pod with flask app
- Check if nodes with correct instance type are provisioned

## 📅 June 23, 2025

#### Done
- [Fix] Tried fixing error with custom Karpenter node pools, albeit to no avail
  - Lots of issues with Terraform, might be easier with CloudFormation/CDK
  - Or maybe using EKS module

#### Learned
- When disabling default node pools `system` and `general-purpose`, custom node classes have to be defined
  - Additionally, access entry for the node pool needs to be specified as well

#### Blockers / Questions
- Trying to set custom node pools for EKS auto mode via Terraform kept producing errors
  - Either cluster not ready yet or invalid credentials or simply no nodes being provisioned
  - Will try auto mode with custom Karpenter node pools in the future again, but with EKS module instead of from scratch

#### Next steps
- Switch to managed node groups without auto mode for now

## 📅 June 22, 2025

#### Done
- [Infra] Added node pool to Karpenter to restrict EC2 instance types
  - Was causing issues with AWS cloud playground, as only selectec instance types are allowed
- [Infra] Added security groups for the nodes
  - Allows all traffic between nodes
  - Allows egress from the nodes

#### Learned
- Following Kubernetes and Karpenter label are very useful
  - `karpenter.sh/capacity-type` => type of instances, e.g. `on-demand` or `spot`
  - `node.kubernetes.io/instance-type` => instance type populated by kubelet, e.g. `t3.medium`
  - `kubernetes.io/arch` => architecture of the machine, e.g. `amd64` and `arm64`
- Used Claude Sonnet 4 for pair programming
  - Really good advices and helpful when debugging
  - But needs cross-checking every code snippet it delivers
  - Hallucinated multiple times today and used an outdated Karpenter API version

#### Blockers / Questions
- Getting error with no client config, when trying to run `terraform apply`
  - Dependency issue, terraform is creating the EKS cluster and at the same time trying to create the kubernetes manifests

#### Next steps
- Fix dependency issue when provisioning cluster
- Deploy app and check that Karpenter is using correct node pool

## 📅 June 21, 2025

#### Done
- [Infra] Added access entry and access policy for given user
  - User has full admin permissions for testing purposes
- [DevOps] Successfully created sample nginx pod in the EKS cluster via kubectl
  - Karpenter automatically provisioned EC2 instance as node

#### Learned
- EKS managed roles can be sufficient for quick testing purposes
  - Kubernetes based RBAC is still possible by setting kubernetes groups in the access entry
- Claude Sonnet 4 is very impressive when it comes to code generation
  - A simple prompt asking about how to provision an EKS cluster via Terraform delivers a full list of tf files
  - Those include AWS VPC, IAM roles, EKS cluster resource, data sources, outputs, variables etc.

#### Blockers / Questions
- What are some best practices when deciding between using EKS managed roles and RBAC via kubernetes groups?
- EC2 types automatically created by Karpenter turned out to be problematic
  - Currently using an AWS cloud playground service to provision resources via Terraform
  - Running a basic flask container seems to have triggered Karpenter to provision an EC2 instance with a non-allowed instance type
  - Solution would be one of the following:
    - Limit what EC2 instance types Karpenter can provision by using Kubernetes manifests
    - Don't use EKS Auto Mode for now and specify nodepools directly in Terraform

#### Next steps
- Add Karpenter Kubernetes manifests to limit EC2 instance types
- Create pod with the flask image and test run it

## 📅 June 19, 2025

#### Done
- [Infra] added NAT gateways to the private subnets
  - Needed for the pods to be able to pull images
- [DevOps] deployed barebones version of the EKS cluster for testing purposes
  - Deployment was successful
- [Refactor] renamed a couple variables and the EKS cluster for more clarity

#### Learned
- EKS with auto mode differentiates node pools between `general-purpose` and `system`
  -`system` has taint which allows critical addons only
  - `general-purpose` is, as the name suggest, for general purpose workloads

#### Blockers / Questions
- Access entry resource still needs to be created
  - Needed for authenticating IAM roles with the EKS cluster and using kubectl
- Curios what use cases there might be to use node pool `system` in the cluster

#### Next steps
- Create access entry resource
- Test if kubectl works

## 📅 June 18, 2025

#### Done
- [Infra] Added two private subnets
  - Aim is to deploy EKS nodes in private subnets and the ALB in the public ones

#### Learned
- EKS uses a karpenter-based system to provision nodes (EC2 instances)
  - Provisioning and deprovisioning happens in response to pod requests

#### Blockers / Questions
- Nothing today

#### Next steps
- Add remaining EKS resources to terraform
- Run a sample deployment to test for missing configuration

## 📅 June 17, 2025

#### Done
- [Infra] Added first version of EKS cluster

#### Learned
- EKS Auto Mode handles scaling of EC2 instance nodes
  - Uses a Karpenter-based system
  - No need for a cluster autoscaler anymore

#### Blockers / Questions
- Nothing today

#### Next steps
- Expand EKS cluster infrastructure and test run it

## 📅 June 16, 2025

#### Done
- [Infra] Created IAM ECS task execution role for the ECS tasks
  - Previously, tasks were using the ECS container instance role
  - However, best practice is to separate those and assign the tasks their own specific execution role
- [DevOps] Added functionality to send container logs to CloudWatch logs
  - Specified the `awslogs` driver in the container definitions
  - Tasks now create the log group if necessary and send log streams of the flask app

#### Learned
- Fargate explicitly requires creating a task execution role
  - There's no container instance role as Fargate is serverless

#### Blockers / Questions
- Nothing today

#### Next steps
- Continue with EKS deployment

## 📅 June 15, 2025

#### Done
- [Docs] Added steps to perform ECS deployment

#### Learned
- Nothing worth mentioning today

#### Blockers / Questions
- Nothing today

#### Next steps
- Continue with EKS deployment

## 📅 June 14, 2025

#### Done
- [DevOps] Modified image build and push script to reuse previous builder
  - Solves issue with same script recreating all images every time
  - Now, cache persists and layers are reused
- [Infra] Added second subnet for ALB to work properly
  - ALBs require at least two subnets in different AZs
- [Infra] Provisioned ALB and confirmed it's working
  - Properly distributes requests between all tasks

#### Learned
- When using `awsvpc` as the network mode for ECS task definitions, target groups should use type `ip`
  - By setting `awsvpc`, each task gets its own ENI and private IP address
  - So the target group has to target the ECS tasks via IP
  - The default setting with `instance` would use the EC2 primary ENI as opposed to the tasks ENI => not clear where to forward traffic
- When using `&>/dev/null` it suppresses all stdout and stderror
  - But the exit code still exists, so conditional expressions still work flawlessly, 
  - This can be seen in the build and push script, when checking of existing docker builders
- Claude Sonnet 3.5 is better suited for coding/debugging, wherease GPT4.1 better for explanations
  - Had an issue with health checks in the target group
  - Claude Sonnet 3.5 found the issue with a single prompt (GPT4.1 failed after many prompts)
  - On the other hand, GPT4.1 excels at explaining concepts (if it doesn't hallucinate)

#### Blockers / Questions
- All blockers fixed
  - Target groups health checks were failing
  - ALB was responding with 504 gateway error
  - ALBs needed to be deployed in distinct AZs explicitly

#### Next steps
- Start reading into how to deploy flask app in EKS

## 📅 June 13, 2025

#### Done
- [Docs] Filled section on how to deploy flask in EC2 with Ansible
- [Refactor] Moved ECR login command to build and push script

#### Learned
- Nothing worth mentioning today

#### Blockers / Questions
- Nothing today

#### Next steps
- Provision ECS infrastructure with ALB

## 📅 June 12, 2025

#### Done
- [Docs] added basic placeholder section to the README for how to run this project

#### Learned
- Nothing worth mentioning today

#### Blockers / Questions
- Nothing today

#### Next steps
- Provision infrastructure and test new ALB

## 📅 June 11, 2025

#### Done
- [DevOps] Removed wrong container agent variable name
  - Wrote *TASK* instead of *CONTAINER*
  - Apparently, the whole setting is set to true by default with my current agent version

#### Learned
- AWS ECS provides two ways to analyze task metadata
  - Metadata endpoint
    - Used in the current flask app
    - Retrieves URI of metadata from environment variables, queries task ARN and extracts task ID
  - Metadata file
    - File gets created in the host container instance
    - Afterwards, mounted in the container as a Docker volume
    - Result => file can be accessed from the host container instance and from within containers
    - As it gets mounted as a Docker volume, it's not availabe with Fargate

#### Blockers / Questions
- Looks like there's a typo in the container agent variable I specified
  - What I wrote: `ECS_ENABLE_TASK_METADATA=true`
  - What it should be: `ECS_ENABLE_CONTAINER_METADATA=true`
  - It's still working, though, as container metadata is enabled by default for new agent versions

#### Next steps
- Provision infrastructure and test new ALB

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
- [App] Updated flask app to print currently running task ID
  - Confirmed it's working
- [Refactor] Refactored project directory structure
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
