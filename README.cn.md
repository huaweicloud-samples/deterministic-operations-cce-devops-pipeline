# ECS DevOps 参考架构：华为云最佳实践

![License](https://img.shields.io/badge/license-MIT--0-blue.svg)

[English](./README.md)
![Huawei Cloud](https://img.shields.io/badge/华为云-最佳实践-ff4d00.svg)
![Terraform](https://img.shields.io/badge/Terraform->=1.5-7B42BC.svg)

> 华为云最佳实践（同构架构，非代码平移）

---

## 简介

基于华为云CCE + ELB + SWR + LTS构建的DevOps参考架构。采用容器化微服务架构，支持自动化CI/CD流水线，适用于需要构建现代DevOps实践的团队。

---

## 目录

- [架构图](#架构图)
- [方案亮点](#方案亮点)
- [涉及云服务](#涉及云服务)
- [前置条件](#前置条件)
- [快速开始](#快速开始)
- [分步部署](#分步部署)
- [使用方法](#使用方法)
- [清理资源](#清理资源)
- [详细说明](#详细说明)
- [参考实现](#参考实现)
- [FAQ](#faq)
- [许可证](#许可证)
- [联系方式](#联系方式)

---

## 架构图

```
代码提交 (GitHub)
      │
      ▼
GitHub Actions (CI/CD)
      │
      ├─► 单元测试
      │
      ▼
Docker 镜像构建
      │
      ▼
SWR (镜像仓库)
      │
      ▼
CCE (部署)
      │
      ▼
ELB → 微服务
      │
      ▼
RDS MySQL / OBS / LTS
```

---

## 方案亮点

- **容器化微服务**：基于CCE Kubernetes，成熟稳定
- **自动化CI/CD**：GitHub Actions流水线
- **高可用**：CCE多节点 + ELB负载均衡 + RDS MySQL副本集
- **Terraform IaC**：基础设施即代码，版本化管理
- **全栈监控**：LTS日志指标一体化

---

## 涉及云服务

| 服务 | 用途 |
|------|------|
| CCE | Kubernetes容器服务 |
| SWR | 容器镜像仓库 |
| ELB | 负载均衡 |
| VPC | 虚拟私有云 |
| OBS | 对象存储 |
| RDS MySQL | MySQL兼容数据库 |
| LTS | 日志监控 |
| IAM | 身份访问管理 |

---

## 前置条件

### 账号与权限
- 华为云账号（已实名认证）
- 具有CCE/SWR/ELB/OBS/RDS MySQL/LTS服务权限

### 工具
- Terraform >= 1.5
- kubectl（可选，用于CCE管理）
- Docker（可选，用于构建镜像）

### 环境变量
```bash
export HW_ACCESS_KEY="<your Access Key>"
export HW_SECRET_KEY="<your Secret Key>"
export HW_REGION="cn-north-4"
```

---

## 快速开始

```bash
# 1. 克隆仓库
git clone <repo-url>
cd aws-ecs-devops-using-aws-cdk

# 2. 配置凭证
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"

# 3. 初始化
cd infra
terraform init

# 4. 预览
terraform plan

# 5. 部署
terraform apply
```

---

## 分步部署

### 1. 部署基础设施

```bash
cd infra
terraform init
terraform apply
```

### 2. 配置CCE

部署完成后，使用kubectl连接CCE集群：

```bash
terraform output cluster_master_url
```

### 3. 配置GitHub Actions

在GitHub仓库中创建`.github/workflows/deploy.yml`：

```yaml
name: Deploy to CCE

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and push to SWR
        run: |
          docker build -t app:${{ github.sha }} .
          docker push swr.${{ secrets.REGION }}.myhuaweicloud.com/app:${{ github.sha }}
      - name: Deploy to CCE
        run: |
          kubectl set image deployment/app app=swr.${{ secrets.REGION }}.myhuaweicloud.com/app:${{ github.sha }}
```

---

## 使用方法

### 访问服务

```bash
# 通过ELB公网IP访问
curl http://<elb-public-ip>/health
```

### 查看日志

```bash
# 通过LTS查看日志
terraform output lts_group_id
```

---

## 清理资源

```bash
cd infra
terraform destroy
```

---

## 详细说明

### CI/CD流程

```
1. 开发者提交代码到GitHub
2. GitHub Actions自动触发构建
3. Docker镜像构建并推送到SWR
4. 更新CCE Deployment
5. LTS收集日志和指标
```

### 微服务架构

- 后端服务：Python FastAPI
- 前端服务：Python Flask
- 数据库：RDS MySQL

---

## 参考实现

主要依赖：
- huaweicloud Terraform Provider
- Kubernetes
- Docker
- GitHub Actions

---

## FAQ

**Q: CCE集群创建失败？**

A: 检查账号权限，确保有CCE服务权限。

**Q: 无法连接RDS MySQL？**

A: 检查安全组规则，确保入方向已放通3306端口。

---

## 许可证

本项目基于MIT-0许可证开源。

---

## 联系方式

- 维护者：华为云架构团队
- Issue反馈：欢迎提交Issue或Pull Request
