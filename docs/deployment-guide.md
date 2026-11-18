# 部署指南：ECS DevOps 参考架构

## 前置条件

### 1. 账号准备
- 华为云账号（已完成实名认证）
- 创建AK/SK：https://console.huaweicloud.com/iam/

### 2. 权限要求
需要以下服务权限：
- CCE FullAccess
- SWR FullAccess
- VPC FullAccess
- ELB FullAccess
- OBS FullAccess
- RDS MySQL FullAccess
- LTS FullAccess
- IAM FullAccess

### 3. 工具安装
```bash
# Terraform
brew install terraform  # macOS

# 验证
terraform version
```

## 部署步骤

### 步骤 1: 克隆仓库
```bash
git clone <repo-url>
cd deterministic-operations-cce-devops-pipeline
```

### 步骤 2: 配置环境变量
```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION="cn-north-4"
```

### 步骤 3: 初始化Terraform
```bash
cd infra
terraform init
```

### 步骤 4: 预览资源
```bash
terraform plan
```

### 步骤 5: 部署基础设施
```bash
terraform apply
```

### 步骤 6: 获取部署输出
```bash
terraform output
```

## 部署后配置

### 1. 连接CCE集群
```bash
# 获取集群凭证
CCE_CONFIG=$(terraform output cluster_config)
echo $CCE_CONFIG > /tmp/kubeconfig
export KUBECONFIG=/tmp/kubeconfig

# 验证连接
kubectl get nodes
```

### 2. 配置GitHub Actions
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
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to SWR
        uses: huaweicloud/actions/login@v1
        with:
          region: ${{ secrets.REGION }}
          access_key: ${{ secrets.ACCESS_KEY }}
          secret_key: ${{ secrets.SECRET_KEY }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            swr.${{ secrets.REGION }}.myhuaweicloud.com/app:${{ github.sha }}
      
      - name: Deploy to CCE
        uses: azure/k8s-set-context@v1
        with:
          kubeconfig: ${{ secrets.KUBECONFIG }}
      
      - name: Update image
        run: |
          kubectl set image deployment/app app=swr.${{ secrets.REGION }}.myhuaweicloud.com/app:${{ github.sha }}
```

### 3. 配置SWR仓库
1. 登录华为云控制台
2. 进入SWR服务
3. 创建组织（如果需要）
4. 创建镜像仓库

## 验证部署

### 1. 健康检查
```bash
# ELB健康检查
curl http://<elb-public-ip>/health

# CCE Pod状态
kubectl get pods -A
```

### 2. 查看日志
```bash
# 通过LTS控制台查看
terraform output lts_group_id
```

## 清理资源

### 重要提示
清理前请确保：
1. 已备份所有数据
2. 已通知所有用户

### 清理步骤
```bash
cd infra
terraform destroy
```

## 常见问题

### Q: terraform apply失败
A: 检查：
1. AK/SK是否正确
2. 账号是否有足够权限
3. 区域资源是否充足

### Q: CCE节点创建失败
A: 检查：
1. CCE配额是否足够
2. VPC子网是否冲突

### Q: 无法连接数据库
A: 检查：
1. 安全组是否放通3306端口
2. 子网是否正确配置
