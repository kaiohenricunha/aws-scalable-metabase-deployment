# Scaling Metabase with EKS on Fargate and Karpenter and Keda

The goal of this project is to demonstrate the use of Kubernetes on AWS to scale Metabase, an open-source business intelligence tool. The project uses the following tools:

- **Terraform:** For infrastructure as code.
- **EKS:** For managed Kubernetes on AWS.
- **Fargate:** For serverless compute on Kubernetes.
- **Karpenter:** For autoscaling Kubernetes clusters.
- **Metabase:** For business intelligence and analytics.
- **GitHub Actions:** For CI/CD.
- **Docker:** For local development and testing.
- **Istio:** For service mesh.
- **Prometheus and Grafana:** For monitoring and observability.
- **Keda:** For scaling Metabase based on requests per second and memory usage.

Here is the project tree overview:

```bash
.
|-- .github
|   `-- workflows
|       |-- apply-workflow.yaml
|       |-- destroy-workflow.yaml
|       |-- helm-workflow.yaml
|       `-- plan-workflow.yaml
|-- assets
|-- README.md
|-- environments
|   |-- dev
|   `-- lab
|       |-- backend.tf
|       |-- main.tf
|       |-- outputs.tf
|       |-- providers.tf
|       |-- s3-dynamodb
|       |   `-- main.tf
|       `-- variables.tf
|-- helm
|   |-- istio
|   |   |-- gateway.yaml
|   |   |-- istiod-values.yaml
|   |   |-- podmonitor.yaml
|   |   |-- scaledobject.yaml
|   |   |-- servicemonitor.yaml
|   |   `-- virtualservice.yaml
|   |-- keda
|   |   |-- keda-dashboard.yaml
|   |   `-- values.yaml
|   |-- kube-prometheus-stack
|   |   `-- values.yaml
|   `-- metabase
|       |-- scaledobject.yaml
|       `-- values.yaml
|-- infra
|   |-- backend
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- eks-fargate-karpenter
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- rds
|   |   |-- main.tf
|   |   `-- variables.tf
|   `-- vpc
|       |-- main.tf
|       |-- outputs.tf
|       `-- variables.tf
|-- .gitignore
|-- .dockerignore
`-- trimmed.Dockerfile
```

## Step 1: Project Setup

This phase involves setting up a local Docker environment tailored for SRE/DevOps tasks. The environment includes necessary tools and configurations for infrastructure management and development.

### Docker Image Configuration

- **Base Image:** Ubuntu latest version.
- **Included Tools:**
  - Kubernetes command-line tools (`kubectl`, `kubectx`, `kubens`).
  - Helm for Kubernetes package management.
  - Terraform and Terragrunt for infrastructure as code.
  - AWS CLI for interacting with Amazon Web Services.
  - `k6` from Load Impact for performance testing.
  - Basic utilities like `curl`, `git`, `wget`, `bash-completion`, `software-properties-common`, `groff`, `unzip`, and `tree`.

### User Setup

- A non-root user `sre` is created to ensure safer operations within the container.
- The working directory is set to `/home/sre`.

### File Permissions

- Proper file permissions are set to ensure that the `sre` user can operate effectively.

A more complete version of this local environment can be found [here](https://github.com/kaiohenricunha/devops-sre-environment).

### Terraform Backend Module

This module sets up an S3 bucket and a DynamoDB table to be used as a Terraform backend.


```hcl
module "backend" {
  source              = "./path/to/terraform-backend"
  region              = "us-east-1"
  bucket_name         = "my-terraform-state-bucket"
  dynamodb_table_name = "my-terraform-state-lock"
}
```

### GitHub Workflows Configuration

The following workflows were created to automate the CI/CD process:

- **plan-workflow.yaml:** Runs `terraform plan` to review the changes that will be applied to the infrastructure. It triggers on pull requests to the `main` branch.
- **apply-workflow.yaml:** Runs `terraform apply` to apply the changes to the infrastructure in a specific order using the `target` parameter. It triggers on pushes to the `main` branch. To avoid triggering this workflow, like when only documentation changes are made, add `[skip ci]` to the commit message.
- **destroy-workflow.yaml:** Runs `terraform destroy` to destroy the infrastructure. It can only be triggered manually from the GitHub Actions page.
- **helm-workflow.yaml:** Runs `helm upgrade --install` or `helm uninstall` on all the addons as well as Metabase. It can only be triggered manually from the GitHub Actions page of the `helm-stack` branch. You can also select which addon or workload to upgrade or uninstall by adding their names as inputs to the workflow:

![helm-workflow](./assets/helm-workflow.png)

### Initial Terraform and AWS Configuration Steps

1. **Create a Terraform user with access keys** in AWS IAM.
2. **Run `terraform init` in the root folder** to install the required plugins.
3. **Execute `aws configure`** to set up the AWS CLI to use the access keys locally. Add the AWS Access Key ID and AWS Secret Access Key to Github Secrets in the repository settings.
4. **Navigate to `environments/lab/s3-dynamodb` and run `terraform init`** to initialize the terraform state.
5. **Execute `terraform plan`** to review what resources will be created.
6. **Run `terraform apply`** to create the resources, including the s3 bucket and dynamodb table. Ensure the bucket name is unique to avoid errors. If working in a docker environment without live file system sync, rebuild the container to reflect new files.

## Step 2: AWS Core Infrastructure with EKS on Fargate and Karpenter

### AWS Infrastructure Configuration with Terraform

Following the setup of the local Docker environment and S3 backend, the next step involved configuring the core AWS infrastructure using Terraform.

1. **VPC Creation:** 
   - A VPC named `lab-vpc` was created, providing isolated network space. The lab environment used the infra/vpc module to do this.
   - Subnets were established across 2 Availability Zones for high availability and fault tolerance.

2. **EKS Cluster Setup on Fargate and Karpenter:**
   - An EKS cluster named `eks-lab` was created, leveraging the latest Kubernetes version for enhanced features and security.
   - Fargate was used as an option for the Kubernetes nodes, offering serverless compute for Kubernetes. It can be useful to run pods that require less than the minimum EC2 instance size of the smallest available instance type.
   - Karpeneter was deployed to manage the autoscaling of the EKS cluster with a NodePool consisting of free-tier EC2 instances and Fargate pods only.

With this configuration, when the cluster needs to scale, Karpenter can choose to either spin up traditional EC2 instances(`t2.micro` and `t3.micro`) defined in the NodePool or use Fargate pods, depending on the configuration and needs.

### Deployment Example

An example deployment using the Kubernetes pause image was included to demonstrate Karpenter's scaling capabilities. This deployment initially start with zero replicas, scaling up as needed.
