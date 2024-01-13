# Scaling Metabase with EKS on Fargate and Karpenter

```bash
.
|-- .github
|   `-- workflows
|       |-- apply.yaml
|       `-- plan.yaml
|-- README.md
|-- environments
|   |-- dev
|   `-- lab
|       |-- backend.tf
|       |-- main.tf
|       |-- s3-dynamodb
|       |   |-- main.tf
|       `-- variables.tf
|-- helm
|   |-- keda
|   |   `-- values.yaml
|   |-- kube-prometheus-stack
|   |   `-- values.yaml
|   `-- metabase
|       `-- values.yaml
|-- infra
|   |-- backend
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- eks-fargate
|   |   |-- main.tf
|   |   `-- outputs.tf
|   |   `-- variables.tf
|   |-- karpenter
|   |   `-- main.tf
|   |   `-- outputs.tf
|   |   `-- variables.tf
|   |-- rds
|   |   `-- main.tf
|   |   `-- outputs.tf
|   |   `-- variables.tf
|   `-- vpc
|       |-- main.tf
|       |-- outputs.tf
|       `-- variables.tf
|-- providers.tf
|-- versions.tf
|-- trimmed.Dockerfile
```

# Step 1: Project Setup

## Local Docker Environment Setup

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

## Terraform Backend Module

This module sets up an S3 bucket and a DynamoDB table to be used as a Terraform backend.

### Usage

```hcl
module "backend" {
  source              = "./path/to/terraform-backend"
  region              = "us-east-1"
  bucket_name         = "my-terraform-state-bucket"
  dynamodb_table_name = "my-terraform-state-lock"
}
```

### Outputs

- `bucket_name`: The name of the created S3 bucket.
- `dynamodb_table_name`: The name of the created DynamoDB table.

## GitHub Workflows Configuration

This step involves the configuration of GitHub workflows to automate the testing and deployment of the AWS infrastructure.

### Terraform Plan Workflow

- A GitHub workflow is created to run `terraform plan` on every pull request to the `main` branch, useful for catching errors before merging changes.

### Terraform Apply Workflow

- A GitHub workflow is created to run `terraform apply` on every push to the `main` branch.

## Initial Terraform and AWS Configuration Steps

1. **Create a Terraform user with access keys** in AWS IAM.
2. **Run `terraform init` in the root folder** to install the required plugins.
3. **Execute `aws configure`** to set up the AWS CLI to use the access keys locally. Add the AWS Access Key ID and AWS Secret Access Key to Github Secrets in the repository settings.
4. **Navigate to `environments/lab/s3-dynamodb` and run `terraform init`** to initialize the terraform state.
5. **Execute `terraform plan`** to review what resources will be created.
6. **Run `terraform apply`** to create the resources, including the s3 bucket and dynamodb table. Ensure the bucket name is unique to avoid errors. If working in a docker environment without live file system sync, rebuild the container to reflect new files.

## Step 2: AWS Core Infrastructure

### AWS Infrastructure Configuration with Terraform

Following the setup of the local Docker environment and S3 backend, the next step involved configuring AWS infrastructure using Terraform.

#### VPC and EKS on Fargate Configuration

1. **VPC Creation:** 
   - A VPC named `lab-vpc` with a CIDR block of `10.0.0.0/16` was created, providing isolated network space.
   - Subnets were established across three Availability Zones for high availability and fault tolerance.

2. **EKS Cluster Setup on Fargate:**
   - An EKS cluster named `eks-lab` was created, leveraging the latest Kubernetes version for enhanced features and security.
   - Fargate was used for the Kubernetes nodes, offering serverless compute for Kubernetes, eliminating the need to manage servers and scaling.
   - Fargate provides a flexible, right-sized compute, automatically scaling compute capacity to meet the demands of the application.

#### Karpenter Autoscaling Configuration

Karpenter was deployed to manage the scaling of the EKS cluster. It dynamically provisions the right types and quantities of instances to meet application demands.

   ```bash
   kubectl get pods -A
   NAMESPACE     NAME                         READY   STATUS    RESTARTS   AGE
   karpenter     karpenter-6bc76db9dc-6hthc   1/1     Running   0          3h27m
   karpenter     karpenter-6bc76db9dc-wjctv   1/1     Running   0          3h27m
   kube-system   coredns-f7465cdb6-m6cp4      1/1     Running   0          3h23m
   kube-system   coredns-f7465cdb6-zqc6l      1/1     Running   0          3h23m
   ```

   ```bash
   kubectl get nodes
   NAME                                                 STATUS   ROLES    AGE     VERSION
   fargate-ip-10-0-143-34.us-west-2.compute.internal    Ready    <none>   3h22m   v1.28.3-eks-4f4795d
   fargate-ip-10-0-149-233.us-west-2.compute.internal   Ready    <none>   3h22m   v1.28.3-eks-4f4795d
   fargate-ip-10-0-17-170.us-west-2.compute.internal    Ready    <none>   3h26m   v1.28.3-eks-4f4795d
   fargate-ip-10-0-53-167.us-west-2.compute.internal    Ready    <none>   3h26m   v1.28.3-eks-4f4795d
   ```

1. **Karpenter Setup:**
   - Karpenter was configured to create EC2 instances as needed, based on application load, ensuring cost-effective scaling.
   - The Karpenter module in Terraform was used for seamless integration with the AWS EKS cluster.

2. **Node Pool and Node Class:**
   - Node Pool and EC2 Node Class resources were declared to define instance types and requirements for workload deployment.

This way, when the cluster needs to scale, Karpenter can choose to either spin up traditional EC2 instances(`t2.micro` and `t3.micro`) or use Fargate pods, depending on the configuration and needs.

#### Deployment Example

An example deployment using the Kubernetes pause image was included to demonstrate Karpenter's scaling capabilities. This deployment initially started with zero replicas, scaling up as needed.

#### Future Considerations for `infra/main.tf`

- The `infra/main.tf` file will eventually need to be broken down into smaller, more manageable modules.
- In case I need  to destroy the infrastructure, it would be ideal to do it in a decoupled manner, destroying the EKS cluster first, then the VPC, and finally the S3 bucket and the state.

## Step 3: Metabase Deployment

WIP

## Step 4: Metabase Access Externalization with ALB Ingress Controller

WIP

## Step 5: Metabase Autoscaling with KEDA(HPA)

WIP
