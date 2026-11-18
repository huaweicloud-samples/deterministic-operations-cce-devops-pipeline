# ECS DevOps Reference Architecture: Huawei Cloud Best Practices

![License](https://img.shields.io/badge/license-MIT--0-blue.svg)

[中文版](./README.cn.md)
![Huawei Cloud](https://img.shields.io/badge/Huawei%20Cloud-Best%20Practice-ff4d00.svg)
![Terraform](https://img.shields.io/badge/Terraform->=1.5-7B42BC.svg)

> Huawei Cloud Best Practice (Architecture-equivalent Replica, Not Code Translation)

---

## Introduction

DevOps reference architecture built on Huawei Cloud CCE + ELB + SWR + LTS. Containerized microservices architecture with automated CI/CD pipeline support, suitable for teams building modern DevOps practices.

---

## Table of Contents

- [Architecture Diagram](#architecture-diagram)
- [Key Features](#key-features)
- [Cloud Services](#cloud-services)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Step-by-Step Deployment](#step-by-step-deployment)
- [Usage](#usage)
- [Cleanup](#cleanup)
- [Detailed Explanation](#detailed-explanation)
- [Dependencies](#dependencies)
- [FAQ](#faq)
- [License](#license)
- [Contact](#contact)

---

## Architecture Diagram

```
Code Commit (GitHub)
      │
      ▼
GitHub Actions (CI/CD)
      │
      ├─► Unit Tests
      │
      ▼
Docker Image Build
      │
      ▼
SWR (Image Registry)
      │
      ▼
CCE (Container Engine)
      │
      ├─► Deployment
      ├─► Scaling
      └─► Service Mesh
      │
      ▼
ELB (Load Balancer)
      │
      ▼
User Access
```

---

## Key Features

- **Container Orchestration**: CCE-managed Kubernetes clusters
- **Automated CI/CD**: GitHub Actions integration with SWR
- **Service Mesh**: Istio-based traffic management
- **Observability**: LTS log aggregation and analysis
- **Storage**: OBS for artifact and static asset storage
- **Database**: RDS MySQL (DynamoDB-compatible) for application data

---

## Cloud Services

| Reference Service | Huawei Cloud | Status |
|-------------|--------------|--------|
| ECS | CCE (Cloud Container Engine) | 🟢 |
| ECR | SWR (Software Repository for Container) | 🟢 |
| ALB | ELB (Elastic Load Balancer) | 🟡 Manual |
| Log & Monitoring | LTS (Log Tank Service) | 🟢 |
| Managed Database | RDS MySQL | 🟡 Manual |
| Object Storage | OBS (Object Storage Service) | 🟢 |
| IAM | IAM (Identity and Access Management) | 🟢 |
| VPC | VPC (Virtual Private Cloud) | 🟢 |

---

## Prerequisites

- Huawei Cloud account with valid AK/SK
- Terraform >= 1.5.0
- kubectl (for CCE interaction)
- Docker (for image building)

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/huaweicloud-samples/aws-ecs-devops-using-aws-cdk.git
cd aws-ecs-devops-using-aws-cdk/infra

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

---

## Step-by-Step Deployment

### 1. Configure Credentials

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION="cn-north-4"
```

### 2. Initialize

```bash
terraform init
```

### 3. Plan

```bash
terraform plan
```

### 4. Apply

```bash
terraform apply
```

---

## Usage

### Accessing CCE Cluster

```bash
# Configure kubeconfig
CCE_CLUSTER_ID=$(terraform output -raw cluster_id)
CCE_CLUSTER_NAME=$(terraform output -raw cluster_name)

# Get credentials from CCE console or use kubectl with token
```

### OBS Buckets

```bash
# App bucket
APP_BUCKET=$(terraform output -raw obs_app_bucket)

# Upload artifacts
obsutil cp app.jar obs://${APP_BUCKET}/
```

### Log Viewing

```bash
# Access LTS console or use API
LTS_GROUP_ID=$(terraform output -raw lts_group_id)
```

---

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

**Note**: Ensure all data is backed up before destruction.

---

## Detailed Explanation

### Infrastructure Components

1. **VPC**: 10.0.0.0/16 with public (10.0.1.0/24) and private (10.0.2.0/24) subnets
2. **CCE**: Kubernetes cluster with node pool (s6.large.2)
3. **OBS**: Two buckets for app and static assets
4. **LTS**: Log group with 7-day retention
5. **Security Group**: Ports 80, 443, 8080, and internal access

---

## Dependencies

- [huaweicloud terraform-provider](https://registry.terraform.io/providers/huaweicloud/huaweicloud) >= 1.60
- Huawei Cloud CCE, OBS, LTS, SWR services

---

## FAQ

### Q: Why is CCE cluster creation failing?

A: CCE requires IAM agency configuration. Please create an agency in IAM console with CCE FullAccess permissions.

### Q: Why is RDS MySQL not created?

A: Some GaussDB specifications may not be available in all regions. Please verify availability in your region.

### Q: How to configure ELB?

A: ELB configuration requires manual setup due to complex bandwidth requirements. Please configure in console.

---

## License

MIT License

---

## Contact

For issues or questions, please open an issue in the repository.
