# Scaling Metabase with EKS on Fargate and Karpenter

```bash
.
|-- README.md
|-- .github
|   |-- workflows
|       |-- plan_infra.yml
|       |-- deploy_infra.yml
|       |-- destroy_infra.yml
|-- infra
|   |-- main.tf
|   `-- state-backend
|       |-- main.tf
|       `-- state.tf
`-- trimmed.Dockerfile
```

## Step 1: Project Setup

### Local Docker Environment Setup

This phase involves setting up a local Docker environment tailored for SRE/DevOps tasks. The environment includes necessary tools and configurations for infrastructure management and development.

#### Docker Image Configuration

- **Base Image:** Ubuntu latest version.
- **Included Tools:**
  - Kubernetes command-line tools (`kubectl`, `kubectx`, `kubens`).
  - Helm for Kubernetes package management.
  - Terraform and Terragrunt for infrastructure as code.
  - AWS CLI for interacting with Amazon Web Services.
  - `k6` from Load Impact for performance testing.
  - Basic utilities like `curl`, `git`, `wget`, `bash-completion`, `software-properties-common`, `groff`, `unzip`, and `tree`.

#### User Setup

- A non-root user `sre` is created to ensure safer operations within the container.
- The working directory is set to `/home/sre`.

#### File Permissions

- Proper file permissions are set to ensure that the `sre` user.

### Terraform S3 Backend Configuration

The first infrastructure management task involves setting up an S3 bucket to securely store Terraform state files.

#### Key Steps:

1. **S3 Bucket Creation:** 
   - A secure S3 bucket named `kaio-lab-terraform-state` was manually created using the AWS CLI. This bucket is intended for storing Terraform state files.
   - The bucket is configured with versioning to keep a history of state changes and is set to private to enhance security.

2. **Terraform Backend Setup:**
   - Terraform is configured to use this S3 bucket as a backend for state storage.
   - The backend configuration is defined in the Terraform scripts, pointing to the `kaio-lab-terraform-state` bucket in the `us-west-2` region.

### GitHub Workflows Configuration

This step finished with the configuration of GitHub workflows to automate the testing and deployment of the AWS infrastructure.

1. **Terraform Plan Workflow:**
   - A GitHub workflow is created to run `terraform plan` on every pull request to the `main` branch.
   - Useful for catching errors before merging changes to the main branch.
2. **Terraform Apply Workflow:**
   - A GitHub workflow is created to run `terraform apply` on every push to the `main` branch.
3. **Terraform Destroy Workflow:**
   - A GitHub workflow is created to run `terraform destroy` when manually triggered only.
   - It can be later scripted to run based on parameters like `destroyDirs` or `destroyAll`.

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

## Step 4: Metabase Scaling with Keda

WIP

## Step 5: Infrastructure and Metabase Monitoring with kube-prometheus-stack

WIP
