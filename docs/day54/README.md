---

# Day54 - Helm Chart 接入 ArgoCD GitOps

日期：2026-08-13

## 今日目标

完成 Helm Chart 与 ArgoCD 的集成，实现：

```
Git Repository
        |
        |
     ArgoCD
        |
        |
  Helm Renderer
        |
        |
 Kubernetes
        |
        |
 Deployment
        |
        |
     Pods
```

目标：

* 使用 Helm 管理 Kubernetes 应用
* 使用 ArgoCD 自动同步 Helm Application
* 验证 Helm 模板渲染结果
* 完成 GitOps 工作流闭环

---

# 1. Day53 环境继承

前置状态：

Day53 已完成：

* ingress-nginx 部署
* day51-demo Ingress 暴露
* ArgoCD 接管 Kubernetes Deployment

当前：

```
ArgoCD
 |
 └── day51-demo
        |
        └── Deployment
```

Day54 将进一步升级：

```
ArgoCD
 |
 └── Helm Application
          |
          └── Helm Chart
                 |
                 ├── Deployment
                 ├── Service
                 └── Ingress
```

---

# 2. 创建 Helm Chart

目录结构：

```
day54/
└── day51-demo/
    |
    ├── Chart.yaml
    ├── values.yaml
    |
    └── templates/
        |
        ├── deployment.yaml
        ├── service.yaml
        └── ingress.yaml
```

---

## Chart.yaml

定义 Helm Chart 信息：

```yaml
apiVersion: v2

name: day51-demo

description: Day54 Helm Demo

type: application

version: 0.1.0

appVersion: "v1"
```

---

# 3. Helm 模板检查

第一次执行：

```bash
helm lint .
```

遇到：

```
nil pointer evaluating interface {}.enabled
```

原因：

values.yaml 被清空后：

模板仍引用：

```yaml
.Values.autoscaling.enabled
```

以及：

```yaml
.Values.httpRoute.enabled
```

解决：

重新规范 values.yaml：

保证模板引用字段存在：

```yaml
autoscaling:
  enabled: false


httpRoute:
  enabled: false
```

重新检查：

```bash
helm lint .
```

结果：

```
1 chart(s) linted, 0 chart(s) failed
```

---

# 4. Helm Template 渲染验证

执行：

```bash
helm template . > rendered.yaml
```

生成：

```
rendered.yaml
```

验证 Helm 渲染结果。

---

# 5. Kubernetes 部署测试

创建 namespace：

```bash
kubectl create namespace helm-demo
```

安装 Helm Chart：

```bash
helm install day54-helm-demo . \
-n helm-demo
```

检查：

```bash
kubectl get svc -n helm-demo

kubectl get pods -n helm-demo
```

结果：

```
NAME                          READY
day54-helm-demo-xxx            1/1
day54-helm-demo-xxx            1/1
```

---

# 6. 应用测试

进入 Pod：

```bash
kubectl exec \
-n helm-demo \
$(kubectl get pod -n helm-demo -o name | head -1) \
-- curl localhost
```

返回：

```html
<h1>
Day50 GitHub Actions CI Demo
</h1>

Day51 Version
```

说明：

Helm 部署成功。

---

# 7. 创建 ArgoCD Helm Application

创建：

```
argocd/day54-helm-demo.yaml
```

核心配置：

```yaml
spec:

  source:

    repoURL:
      https://github.com/HuAN-ME/Project-Shanghai-2027.git

    targetRevision:
      master

    path:
      k8s/labs/day54/day51-demo

    helm:
      releaseName:
        day54-helm-demo


  destination:

    namespace:
      helm-demo
```

应用：

```bash
kubectl apply \
-f day54-helm-demo.yaml
```

---

# 8. ArgoCD 同步验证

查看：

```bash
kubectl get application \
-n argocd
```

结果：

```
NAME              SYNC STATUS

day54-helm-demo   Synced
```

资源：

```text
Service
Deployment
Ingress
```

均：

```
Synced
```

---

# 9. 遇到的问题

## 问题1：ArgoCD Health 长时间 Progressing

状态：

```
SYNC STATUS:
Synced


HEALTH STATUS:
Progressing
```

检查：

```bash
kubectl describe ingress \
day54-helm-demo \
-n helm-demo
```

发现：

```yaml
status:
  loadBalancer: {}
```

原因：

minikube 使用：

```
NodePort ingress-nginx
```

不是云环境 LoadBalancer。

Ingress 不会生成：

```yaml
status:
  loadBalancer:
    ingress:
    - ip: xxx
```

因此：

ArgoCD 无法判断 Ingress Healthy。

---

# 10. 问题分析

生产环境：

```
Ingress Controller
        |
        |
 Cloud LoadBalancer
        |
        |
 External IP
```

ArgoCD：

```
Ingress status.loadBalancer.ingress
              |
              |
          Healthy
```

本地 minikube：

```
Ingress Controller
        |
        |
 NodePort
        |
        |
 无 LoadBalancer IP
```

结果：

```
Progressing
```

---

# 11. ArgoCD Controller 状态异常排查

发现：

```
SYNC STATUS: Unknown
```

排查：

错误：

```bash
kubectl logs deploy/argocd-application-controller
```

原因：

application-controller 实际为：

```text
statefulset.apps/argocd-application-controller
```

不是 Deployment。

检查：

```bash
kubectl get deploy,statefulset \
-n argocd
```

正确：

```
statefulset.apps/
argocd-application-controller
```

---

# 12. 最终状态

ArgoCD：

```
day51-demo
    Synced Healthy


day54-helm-demo
    Synced Progressing
```

资源：

```
Deployment
    Running


Service
    Created


Ingress
    Created
```

核心 GitOps 链路完成。

---

# Day54 总结

今天完成：

✅ Helm Chart 创建

✅ values.yaml 参数规范化

✅ helm lint

✅ helm template

✅ Helm 部署 Kubernetes

✅ ArgoCD Helm Application

✅ Git → ArgoCD → Helm → Kubernetes 自动同步

同时掌握：

* Helm Chart 生命周期
* ArgoCD Helm Source
* Application Controller 工作模式
* Ingress Health 判断机制

---

# 今日收获

Day51：

```
Directory Manifest
        |
        |
      ArgoCD
```

Day54：

```
Helm Chart
        |
        |
      ArgoCD
        |
        |
 Kubernetes
```

从：

```
手写 YAML GitOps
```

升级到：

```
模板化 Kubernetes GitOps
```

这一步是进入生产级 DevOps 的重要节点。
