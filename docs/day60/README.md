```markdown
# Day60 DevOps 环境生命周期自动化

日期：2026/08/17

---

# 今日目标

完成 DevOps 环境自动化管理，为第二个月 Cloud Native 平台建设阶段画上句号。

本日重点：

- 创建 DevOps 环境生命周期脚本
- 实现环境一键启动
- 实现环境安全关闭
- 增加健康检查机制
- 增加环境信息采集能力

---

# 背景

经过 Day31-Day60 的学习，项目已经从：

> 学习单个 DevOps 工具

逐渐转变为：

> 构建并管理一个完整的 Cloud Native DevOps 环境

第二个月主要完成：

- Kubernetes
- Harbor
- Helm
- GitHub Actions Runner
- 环境自动化管理

---

# 一、DevOps 自动化脚本

创建目录：

```

scripts/

├── start-devops.sh
├── stop-devops.sh
├── health-check.sh
└── env-info.sh

```

---

# 二、start-devops.sh

## 功能

实现 DevOps 环境一键启动。

启动流程：

```

Docker

↓

Harbor

↓

Minikube

↓

GitHub Actions Runner

↓

健康检查

````

执行：

```bash
./start-devops.sh
````

效果：

* Docker 服务正常
* Harbor 服务启动
* Kubernetes 集群启动
* Runner 服务运行
* 自动执行健康检查

---

# 三、stop-devops.sh

## 功能

实现环境安全关闭。

关闭流程：

```
Minikube

↓

Harbor

↓

GitHub Actions Runner
```

执行：

```bash
./stop-devops.sh
```

---

## docker compose stop 与 down 区别

本项目选择：

```bash
docker compose stop
```

原因：

保留：

* Container
* Volume
* Network

方便下一次快速恢复。

而：

```bash
docker compose down
```

会删除部分运行资源。

适用于环境销毁，而不是日常暂停。

---

# 四、health-check.sh

## 功能

快速检查当前 DevOps 环境状态。

检查：

* Docker
* Harbor
* Minikube
* GitHub Runner
* Helm
* Proxy

示例：

```
[ Docker ]
Status: OK

[ Harbor ]
Status: OK

[ Minikube ]
Status: OK

[ GitHub Runner ]
Status: OK

[ Helm ]
Status: OK
```

---

## 优化点

之前：

Minikube 未启动时：

```
Helm FAILED
```

容易造成误判。

优化后：

```
Helm:
SKIPPED (Kubernetes unavailable)
```

体现服务之间的依赖关系：

```
Kubernetes

↓

Helm
```

---

# 五、env-info.sh

## 功能

采集当前环境信息。

包括：

* 系统版本
* Kernel
* Docker版本
* Git版本
* Kubernetes版本
* Minikube版本
* Helm版本
* Harbor版本
* GitHub Runner状态

当前环境：

| 组件                | 版本       |
| ----------------- | -------- |
| Rocky Linux       | 9.8      |
| Docker            | 29.7.1   |
| Kubernetes Client | v1.31.14 |
| Kubernetes        | v1.31.8  |
| Minikube          | v1.38.1  |
| Helm              | v4.1.1   |
| Harbor            | v2.13.2  |

---

# 六、遇到的问题

## 1. 脚本路径问题

问题：

从不同目录执行脚本时：

```
No such file or directory
```

原因：

脚本依赖当前工作目录。

解决：

统一使用项目绝对路径。

---

## 2. 服务依赖问题

例如：

```
Helm

依赖

Kubernetes
```

所以健康检查需要先判断 Kubernetes 状态。

避免错误报警。

---

## 3. 权限控制问题

GitHub Runner 属于系统服务。

启动/停止需要：

```bash
sudo
```

意义：

普通用户不能随意关闭关键服务。

符合生产环境权限管理思想。

---

# 七、第二个月总结

时间：

```
2026/07/19 - 2026/08/17
```

主题：

```
Cloud Native 平台工程
```

完成内容：

## Kubernetes

完成：

* Minikube 集群部署
* Pod 管理
* Deployment 管理
* Service 管理
* 私有镜像部署

## Harbor

完成：

* Harbor 部署
* 私有镜像仓库管理
* Docker 镜像推送
* Kubernetes 镜像拉取

## Helm

完成：

* Helm Chart 创建
* Helm 部署
* Helm 回滚

## CI/CD

完成：

* GitHub Actions
* Self-hosted Runner

## 自动化

完成：

* 环境启动脚本
* 环境关闭脚本
* 健康检查脚本
* 环境信息采集脚本

---

# 八、阶段里程碑

60天后：

项目已经从：

```
Linux学习环境
```

发展为：

```
个人 DevOps 实验平台
```

能力路线：

```
Linux

↓

Docker

↓

Kubernetes

↓

Cloud Native

↓

Automation
```

---

# 下一阶段

第三阶段：

## CI/CD 与基础设施自动化

计划：

* 完善 CI/CD Pipeline
* Ansible 自动化
* Terraform IaC
* Monitoring
* Logging

---

# 总结

Day60 标志着 Project Shanghai 2027 第二个月正式结束。

第二个月完成了从容器化学习到 Cloud Native 平台建设的跨越。

下一阶段将重点提升：

> 自动交付能力与生产环境实践能力。

```
