# =============================================
# 华为云实践：ECS DevOps 参考架构
# 基于容器化 DevOps 参考架构适配
# IaC: Terraform + huaweicloud Provider
# =============================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.60"
    }
  }
}

provider "huaweicloud" {
  region = var.region
}

# =====================
# Variables
# =====================
variable "region" {
  description = "Huawei Cloud region"
  type        = string
  default     = "cn-north-4"
}

variable "stack_name" {
  description = "Resource name prefix"
  type        = string
  default     = "devops-refarch"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

# =====================
# 1. VPC Network
# =====================
resource "huaweicloud_vpc" "main" {
  name = "${var.stack_name}-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "public" {
  name          = "${var.stack_name}-public-subnet"
  vpc_id        = huaweicloud_vpc.main.id
  cidr          = "10.0.1.0/24"
  gateway_ip    = "10.0.1.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

resource "huaweicloud_vpc_subnet" "private" {
  name          = "${var.stack_name}-private-subnet"
  vpc_id        = huaweicloud_vpc.main.id
  cidr          = "10.0.2.0/24"
  gateway_ip    = "10.0.2.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

# =====================
# 2. Security Group
# =====================
resource "huaweicloud_networking_secgroup" "main" {
  name        = "${var.stack_name}-sg"
  description = "DevOps Architecture Security Group"
}

resource "huaweicloud_networking_secgroup_rule" "allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.main.id
  ports             = "80"
  protocol          = "tcp"
}

resource "huaweicloud_networking_secgroup_rule" "allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.main.id
  ports             = "443"
  protocol          = "tcp"
}

resource "huaweicloud_networking_secgroup_rule" "allow_app" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.main.id
  ports             = "8080"
  protocol          = "tcp"
}

resource "huaweicloud_networking_secgroup_rule" "allow_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.main.id
  remote_ip_prefix  = var.vpc_cidr
}

# =====================
# 3. OBS Buckets
# =====================
resource "huaweicloud_obs_bucket" "app" {
  bucket        = "${var.stack_name}-app-${var.region}"
  acl           = "private"
  storage_class = "STANDARD"
}

resource "huaweicloud_obs_bucket" "static" {
  bucket        = "${var.stack_name}-static-${var.region}"
  acl           = "private"
  storage_class = "STANDARD"
}

# =====================
# 4. GeminiDB（宽表数据库场景）
# =====================
# =====================
# 4. GeminiDB（宽表数据库场景）- 需手动配置
# =====================
# 说明：GaussDB 在当前区域可能不支持，请根据控制台实际可选规格调整
# resource "huaweicloud_gaussdb_mysql_instance" "main" {
#   name              = "${var.stack_name}-gemini"
#   flavor            = "gaussdb.mysql.xlarge.x86"
#   password          = "Placeholder-Db-Pass-123!"
#   vpc_id           = huaweicloud_vpc.main.id
#   subnet_id        = huaweicloud_vpc_subnet.private.id
#   security_group_id = huaweicloud_networking_secgroup.main.id
#   volume_size       = 100
#   mode              = "Cluster"
#
#   datastore {
#     engine  = "gaussdb-mysql"
#     version = "8.0"
#   }
# }

# =====================
# 5. CCE Cluster (替代 ECS) - 需手动在控制台配置 IAM 委托
# =====================
# 说明：CCE 集群需要 IAM 委托权限才能创建，请在 IAM 控制台完成以下配置：
# 1. 创建委托，名称如 devops-refarch-access
# 2. 委托服务选择 "云容器引擎 CCE"
# 3. 授权策略选择 "CCE FullAccess"、"VPC FullAccess"、"OBS Operate"
# 4. 完成后再次运行 terraform apply

# resource "huaweicloud_cce_cluster" "main" {
#   name        = "${var.stack_name}-cluster"
#   flavor_id   = "cce.s1.small"
#   vpc_id      = huaweicloud_vpc.main.id
#   subnet_id   = huaweicloud_vpc_subnet.private.id
#   container_network_type = "overlay_l2"
#   cluster_type = "VirtualMachine"
#
#   masters {
#     availability_zone = "cn-north-4"
#   }
# }

# resource "huaweicloud_cce_node_pool" "main" {
#   cluster_id       = huaweicloud_cce_cluster.main.id
#   name             = "${var.stack_name}-nodepool"
#   flavor_id        = "s6.large.2"
#   initial_node_count = 2
#   availability_zone = "cn-north-4"
#   password         = "Placeholder-Db-Pass-123!"
#
#   root_volume {
#     size           = 40
#     volumetype     = "SSD"
#   }
#
#   data_volumes {
#     size           = 100
#     volumetype     = "SSD"
#   }
# }

# =====================
# 6. ELB (替代 ALB) - 需手动配置
# =====================
# 注意：ELB 配置需要根据实际需求调整，以下为基础配置
# 实际部署时需在控制台完成以下配置：
# 1. 购买共享带宽或独享带宽
# 2. 配置 ELB 规格和带宽
# 3. 绑定 EIP（可选）

# 预留资源占位，实际使用请在控制台配置
# resource "huaweicloud_elb_loadbalancer" "public" {
#   name             = "${var.stack_name}-elb-public"
#   availability_zone = ["cn-north-4"]
#   # 需要配置带宽参数，详见控制台
# }

# =====================
# 7. LTS Log Groups (替代 CloudWatch)
# =====================
resource "huaweicloud_lts_group" "main" {
  group_name  = "${var.stack_name}-lts-group"
  ttl_in_days = 7
}

resource "huaweicloud_lts_stream" "app" {
  group_id    = huaweicloud_lts_group.main.id
  stream_name = "${var.stack_name}-app"
}

resource "huaweicloud_lts_stream" "system" {
  group_id    = huaweicloud_lts_group.main.id
  stream_name = "${var.stack_name}-system"
}

# =====================
# 8. IAM Agency (需手动在控制台配置)
# =====================
# 说明：IAM 委托需要根据实际账号配置，以下为基础占位
# 实际部署时请在 IAM 控制台创建委托，授权 CCE/OBS/GaussDB 权限

# =====================
# Outputs
# =====================
output "vpc_id" {
  description = "VPC ID"
  value       = huaweicloud_vpc.main.id
}

# output "cluster_id" {
#   description = "CCE Cluster ID"
#   value       = huaweicloud_cce_cluster.main.id
# }

# output "cluster_name" {
#   description = "CCE Cluster Name"
#   value       = huaweicloud_cce_cluster.main.name
# }

# output "elb_id" {
#   description = "ELB ID"
#   value       = huaweicloud_elb_loadbalancer.public.id
# }

# output "elb_public_ip" {
#   description = "ELB Public IP"
#   value       = huaweicloud_elb_loadbalancer.public.eip_address
# }

# output "gemini_db_id" {
#   description = "GeminiDB Instance ID"
#   value       = huaweicloud_gaussdb_mysql_instance.main.id
# }

output "obs_app_bucket" {
  description = "OBS App Bucket"
  value       = huaweicloud_obs_bucket.app.bucket
}

output "lts_group_id" {
  description = "LTS Log Group ID"
  value       = huaweicloud_lts_group.main.id
}
