## Project Setup: Step 1

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

- Proper file permissions are set to ensure that the `sre` user has full access to necessary directories and files.

### Terraform S3 Backend Configuration

The first infrastructure management task involves setting up an S3 bucket to securely store Terraform state files.

#### Key Steps:

1. **S3 Bucket Creation:** 
   - A secure S3 bucket named `kaio-lab-terraform-state` was manually created using the AWS CLI. This bucket is intended for storing Terraform state files.
   - The bucket is configured with versioning to keep a history of state changes and is set to private to enhance security.

2. **Terraform Backend Setup:**
   - Terraform is configured to use this S3 bucket as a backend for state storage.
   - The backend configuration is defined in the Terraform scripts, pointing to the `kaio-lab-terraform-state` bucket in the `us-west-2` region.

3. **Security Adjustments:**
   - The ACL setting in the Terraform configuration for the S3 bucket was removed. This aligns with AWS best security practices, ensuring the bucket remains private and resolves compatibility issues with AWS Block Public Access settings.

#### Outcome

- The local Docker environment is successfully set up with all necessary tools for DevOps tasks.
- The Terraform S3 backend is configured, tested, and ready for further infrastructure provisioning, starting with the creation of an EKS cluster in upcoming phases.
