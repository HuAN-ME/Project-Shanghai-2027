```md
# Day56 - ArgoCD GitOps 部署实践

## 今日目标

使用 ArgoCD 管理 Helm 应用，实现：

GitHub Repository  
↓  
ArgoCD Application  
↓  
Helm Chart Render  
↓  
Kubernetes Namespace Deployment


---

## 1. Day55 Helm Chart 接入 ArgoCD

基于 Day55 的 Helm Chart：

目录：

```

k8s/labs/day56/day56-demo
├── Chart.yaml
├── values.yaml
├── environments
│   ├── dev
│   │   └── values.yaml
│   ├── staging
│   └── prod
└── templates

````

通过 ArgoCD Application 指定：

```yaml
source:
  repoURL: https://github.com/HuAN-ME/Project-Shanghai-2027.git
  path: k8s/labs/day56/day56-demo
  targetRevision: master
  helm:
    valueFiles:
      - environments/dev/values.yaml
````

---

## 2. 创建 ArgoCD Application

查看 Application：

```bash
kubectl get application -n argocd
```

结果：

```
NAME
day51-demo
day54-helm-demo
day56-dev
```

查看详情：

```bash
kubectl describe application day56-dev -n argocd
```

确认：

* Repository 正确
* Helm Chart 路径正确
* Namespace 正确

---

## 3. ArgoCD 同步状态

最终：

```bash
kubectl get application -n argocd
```

状态：

```
day56-dev   Synced
```

说明：

Git Repository
→ ArgoCD
→ Kubernetes

链路正常。

---

## 4. Kubernetes 部署验证

查看 namespace：

```bash
kubectl get all -n day56-dev
```

资源：

```
Deployment
Service
Ingress
Pod
```

均由 ArgoCD 创建。

---

## 5. 遇到问题

### 问题1：ArgoCD Repository Timeout

现象：

```
Failed to load target state

context deadline exceeded
```

排查：

检查 ArgoCD Pod：

```bash
kubectl get pod -n argocd
```

确认：

* argocd-server 正常
* argocd-repo-server 正常
* CoreDNS 正常

测试发现：

Kubernetes Pod 出网存在问题：

```
Failed to pull image:
registry-1.docker.io
context deadline exceeded
```

说明：

不是 GitHub 问题，而是 Kubernetes 网络访问外部 Registry 不稳定。

---

## 6. Harbor 镜像问题

Application 同步成功后：

Pod 状态：

```
ImagePullBackOff
```

原因：

镜像：

```
harbor.local/project-shanghai/day50-demo:dev
```

无法拉取。

错误：

```
dial tcp 192.168.157.129:443:
connect: connection refused
```

检查 Harbor：

```bash
docker compose ps
```

发现：

```
harbor-log Restarting
```

导致：

```
1514 syslog port unavailable
```

进一步确认：

Harbor 服务异常，与 Kubernetes/ArgoCD 无关。

---

## 7. 今日总结

完成：

✅ Helm Chart 接入 ArgoCD
✅ 创建 ArgoCD Application
✅ Git → ArgoCD → Kubernetes 自动同步验证
✅ 多环境 values 管理继续沿用 Day55 设计

遗留：

⚠️ Harbor Registry 服务异常
⚠️ 私有镜像拉取失败

计划：

Day57 单独处理：

* Harbor 修复
* Kubernetes 私有 Registry
* imagePullSecrets
* CI/CD 镜像发布流程

---
