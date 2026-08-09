```md
# Day52 GitOps + ArgoCD 自动部署

## 今日目标

将 Day51 手动 Kubernetes 部署流程升级为 GitOps 自动化部署。

之前：

```

kubectl apply
|
↓
Kubernetes
|
↓
Pod

```

升级：

```

Git Repository
|
↓
ArgoCD
|
↓
Kubernetes
|
↓
Deployment
|
↓
Pod

````

---

# 1. 安装 ArgoCD

## 创建 namespace

```bash
kubectl create namespace argocd
````

查看：

```bash
kubectl get ns
```

---

## 安装 ArgoCD

由于网络原因无法直接访问：

```
raw.githubusercontent.com
```

下载官方安装文件：

```bash
install.yaml
```

安装：

```bash
kubectl create -n argocd -f install.yaml
```

注意：

使用：

```bash
kubectl create
```

而不是：

```bash
kubectl apply
```

原因：

ArgoCD CRD 文件较大，apply 会保存：

```
kubectl.kubernetes.io/last-applied-configuration
```

导致：

```
metadata.annotations: Too long
```

---

# 2. 验证 ArgoCD

查看 Pod：

```bash
kubectl get pods -n argocd
```

正常：

```
argocd-server                         Running
argocd-repo-server                    Running
argocd-application-controller         Running
argocd-applicationset-controller      Running
argocd-redis                          Running
```

---

# 3. 获取 ArgoCD 登录密码

默认账号：

```
admin
```

获取密码：

```bash
kubectl get secret argocd-initial-admin-secret \
-n argocd \
-o jsonpath="{.data.password}" | base64 -d
```

---

# 4. 登录 ArgoCD UI

暴露服务：

```bash
kubectl port-forward svc/argocd-server \
-n argocd \
8080:443
```

访问：

```
https://localhost:8080
```

登录：

```
username:
admin

password:
获取的密码
```

---

# 5. 创建 GitOps Repository

目录：

```
day52/

├── gitops/
│   └── manifests/
│       └── deployment.yaml
│
└── application.yaml
```

---

# 6. 创建 Kubernetes Manifest

复制 Day51 Deployment：

```
gitops/manifests/deployment.yaml
```

配置：

```yaml
metadata:

  namespace:
    harbor-demo
```

镜像：

```yaml
image:
  harbor.local/project-shanghai/day50-demo:v2
```

Harbor 私有镜像：

```yaml
imagePullSecrets:

- name:
    harbor-secret
```

---

# 7. 提交 Git

添加：

```bash
git add k8s/labs/day52
```

提交：

```bash
git commit -m "Day52 add GitOps manifest"
```

推送：

```bash
git push
```

Git 成为 Kubernetes 配置源。

---

# 8. 创建 ArgoCD Application

文件：

```
application.yaml
```

内容：

```yaml
apiVersion: argoproj.io/v1alpha1

kind: Application


metadata:

  name:
    day51-demo

  namespace:
    argocd



spec:

  project:
    default


  source:

    repoURL:
      https://github.com/HuAN-ME/Project-Shanghai-2027.git

    targetRevision:
      master

    path:
      k8s/labs/day52/gitops/manifests



  destination:

    server:
      https://kubernetes.default.svc

    namespace:
      harbor-demo



  syncPolicy:

    automated:

      prune:
        true

      selfHeal:
        true
```

---

# 9. 创建 Application

执行：

```bash
kubectl apply -f application.yaml
```

查看：

```bash
kubectl get application -n argocd
```

结果：

```
NAME          SYNC STATUS   HEALTH STATUS

day51-demo    Synced        Healthy
```

---

# 10. GitOps 工作流程

现在流程：

```
Developer

    |
    ↓

 Git Push

    |
    ↓

GitHub Repository

    |
    ↓

  ArgoCD

    |
    ↓

Kubernetes API

    |
    ↓

Deployment

    |
    ↓

Pod
```

---

# 11. ArgoCD 自动化能力

## Sync 自动同步

Git 修改：

```
commit
 ↓
push
 ↓
ArgoCD检测
 ↓
同步 Kubernetes
```

---

## Self Heal 自动修复

配置：

```yaml
syncPolicy:

  automated:

    selfHeal: true
```

效果：

如果 Kubernetes 状态被手动修改：

```
Cluster 状态

!=

Git 状态
```

ArgoCD 会自动恢复。

---

## Prune 自动清理

配置：

```yaml
prune: true
```

效果：

Git 删除资源：

```
Manifest 删除

↓

ArgoCD同步

↓

Kubernetes删除资源
```

---

# Day52 问题记录

## 1. GitHub Raw 访问失败

错误：

```
The connection to the server raw.githubusercontent.com was refused
```

原因：

网络无法访问 GitHub Raw。

解决：

下载 YAML 文件后本地安装。

---

## 2. ArgoCD CRD annotation 超限

错误：

```
metadata.annotations:
Too long: must have at most 262144 bytes
```

原因：

kubectl apply 保存完整配置导致 annotation 超限。

解决：

使用：

```bash
kubectl create -f install.yaml
```

---

# Day52 成果

完成：

✅ ArgoCD 安装
✅ ArgoCD UI 登录
✅ GitOps Repository 创建
✅ Application 创建
✅ Kubernetes 接入 ArgoCD
✅ 自动同步
✅ Self Heal
✅ Prune

---

# Project Shanghai 2027 当前架构

```
             GitHub

                |
                ↓

        GitHub Actions

                |
                ↓

             Harbor

                |
                ↓

             ArgoCD

                |
                ↓

          Kubernetes

                |
                ↓

              Pod
```

---

关键词：

```
GitOps
ArgoCD
Application
Sync
Self Heal
Prune
Continuous Deployment
```
