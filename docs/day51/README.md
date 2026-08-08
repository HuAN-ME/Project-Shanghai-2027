```md
# Day51 Kubernetes 部署 Harbor 私有镜像

## 今日目标

完成 Kubernetes 拉取 Harbor 私有镜像，并实现镜像版本更新部署。

流程：

```

Harbor
↓
Kubernetes Secret
↓
Deployment
↓
Pod
↓
Rolling Update

````

---

# 1. 创建 Kubernetes Namespace

创建独立实验环境：

```bash
kubectl create namespace harbor-demo
````

查看：

```bash
kubectl get ns
```

---

# 2. 配置 Harbor 镜像拉取认证

由于 Harbor 为私有仓库，Kubernetes 需要认证信息。

创建 Secret：

```bash
kubectl create secret docker-registry harbor-secret \
-n harbor-demo \
--docker-server=harbor.local \
--docker-username=admin \
--docker-password=<password>
```

查看：

```bash
kubectl get secret -n harbor-demo
```

结果：

```
harbor-secret
```

---

# 3. Deployment 部署 Harbor 镜像

配置：

```yaml
spec:
  template:
    spec:

      imagePullSecrets:
      - name: harbor-secret

      containers:

      - name: demo
        image: harbor.local/project-shanghai/day50-demo:v1
```

应用：

```bash
kubectl apply -f deployment.yaml
```

查看：

```bash
kubectl get pods -n harbor-demo
```

Pod 状态：

```
Running
```

说明：

* Kubernetes 可以访问 Harbor
* Secret 配置成功
* HTTPS 证书信任正常

---

# 4. 镜像版本升级测试

模拟新版本发布：

```
v1 → v2
```

---

## 构建新镜像

```bash
docker build \
-t harbor.local/project-shanghai/day50-demo:v2 \
.
```

---

## 推送 Harbor

```bash
docker push \
harbor.local/project-shanghai/day50-demo:v2
```

Harbor 中：

```
project-shanghai

└── day50-demo

    ├── v1
    └── v2
```

---

# 5. Kubernetes 滚动更新

修改 Deployment：

```yaml
image:
  harbor.local/project-shanghai/day50-demo:v2
```

重新部署：

```bash
kubectl apply -f deployment.yaml
```

查看更新：

```bash
kubectl get pods -n harbor-demo -w
```

查看发布状态：

```bash
kubectl rollout status \
deployment/day51-demo \
-n harbor-demo
```

成功：

```
deployment successfully rolled out
```

---

# 6. 今日知识点

| 技术               | 作用             |
| ---------------- | -------------- |
| Secret           | 保存 Harbor 登录凭证 |
| imagePullSecrets | Pod 拉取私有镜像     |
| Deployment       | 管理应用生命周期       |
| Rolling Update   | 无停机版本升级        |
| Harbor           | 私有镜像仓库         |
| Kubernetes       | 容器运行平台         |

---

# CI/CD 链路进展

Day50：

```
GitHub
   ↓
GitHub Actions
   ↓
Docker Build
   ↓
Harbor
```

Day51：

```
GitHub
   ↓
GitHub Actions
   ↓
Harbor
   ↓
Kubernetes
   ↓
Deployment
   ↓
Pod
```

---

# 遇到问题

## 1. Harbor HTTPS 证书问题

错误：

```
x509: certificate signed by unknown authority
```

原因：

Docker/Kubernetes 不信任自签 CA。

解决：

配置：

```
/etc/docker/certs.d/harbor.local/ca.crt
```

---

## 2. 私有仓库认证失败

错误：

```
unauthorized: authentication required
```

原因：

缺少 imagePullSecret。

解决：

Deployment 添加：

```yaml
imagePullSecrets:
- name: harbor-secret
```

---
