# Scaling Workloads with the Big Savings Quartet: EKS, Fargate, Karpenter, and Keda

## Introduction

This project aims to deploy Metabase, an open-source business intelligence tool, using EKS, Fargate, Karpenter, and Keda to achieve efficient scaling and cost savings. The setup includes Terraform for infrastructure management, Istio for service mesh, Prometheus and Grafana for monitoring, and Keda for autoscaling.

## Tools Used

- **Terraform**: Infrastructure as code
- **EKS**: Managed Kubernetes on AWS
- **Fargate**: Serverless compute for Kubernetes
- **Karpenter**: Autoscaling Kubernetes clusters
- **Metabase**: Business intelligence and analytics
- **GitHub Actions**: CI/CD
- **Docker**: Local development and testing
- **Istio**: Service mesh and traffic metrics
- **Prometheus and Grafana**: Metrics scraping and observability
- **Keda**: Autoscaling based on traffic metrics and memory usage

## Project Structure

```bash
.
├── README.md
├── annotations.md
├── assets
│   ├── ekfk-arch.drawio.png
│   ├── keda-dashboard.png
│   └── stack-workflow.png
├── environments
│   ├── dev
│   └── lab
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── s3-dynamodb
│       │   └── main.tf
│       └── variables.tf
├── infra
│   ├── backend
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── eks-fargate-karpenter
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── scripts
│   └── calculate_cluster_size.sh
└── stack
    ├── istio
    │   ├── istiod-values.yaml
    │   ├── pod-monitor.yaml
    │   └── service-monitor.yaml
    ├── keda
    │   └── values.yaml
    ├── metabase
    │   ├── metabase-hpa.yaml
    │   ├── metabase-scaling-dashboard.yaml
    │   └── values.yaml
    └── monitoring
        └── values.yaml
```

## Step 1: Local Environment Setup

1. Clone the [devenv repository](https://github.com/kaiohenricunha/devenv) and set permissions:

    ```bash
    chmod +x *.sh
    ./main.sh
    ```

2. Alternatively, install prerequisites manually:
    - Terraform CLI
    - AWS CLI
    - kubectl
    - kubectx

## Step 2: AWS Credentials and Terraform Backend

1. Run `aws configure` to set up AWS credentials.
2. Store AWS credentials in GitHub repository secrets.
3. Navigate to `environments/lab/s3-dynamodb` and initialize Terraform:

    ```bash
    terraform init
    terraform apply
    ```

## Step 3: AWS Infrastructure

Run the appropriate GitHub Actions workflows to set up the VPC, EKS cluster, and other infrastructure components: `plan-workflow.yaml` and `apply-workflow`.

## Step 4: Metabase Deployment + cluster stack

Run the `stack-workflow.yaml` workflow.

## Step 5: Accessing Services

1. Get service IP addresses:

    ```bash
    kubectl get svc -A
    ```

2. Access services using their external IPs:
    - Metabase: `xxxxx.elb.us-east-1.amazonaws.com`
    - Grafana: `xxxxx.elb.us-east-1.amazonaws.com`
    - Prometheus: `xxxxx.elb.us-east-1.amazonaws.com:9090/graph`

## Step 6: Destroy

- Destroy the cluster stack: `uninstall-stack-workflow.yaml`
- Destroy AWS infra: `destroy-workflow.yaml`

---

For detailed instructions and code, refer to the respective files and directories in the repository. Also, please refer to this [medium article](https://medium.com/@kaiohsdc/scaling-workloads-with-the-big-savings-quartet-eks-fargate-karpenter-and-keda-1d43d2bb5f72) for a deeper dive.
