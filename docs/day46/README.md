```markdown
# Day46 - Helm 应用发布、版本升级与 CI/CD 初探

## 一、实验目标

学习 Helm 在 Kubernetes 应用生命周期管理中的作用。

本日目标：

- 使用 Helm Chart 部署应用
- 理解 values.yaml 参数化配置
- 理解 Helm template 渲染机制
- 使用本地镜像部署 Kubernetes 应用
- 模拟应用版本升级
- 使用 helm upgrade 完成滚动更新
- 理解 Helm 在企业 CI/CD 中的位置
- 处理 GitHub 大文件提交问题


---

# 二、Helm Chart 部署应用


## 1. Chart 结构

项目结构：

```

day46/
├── app
│   ├── Dockerfile
│   └── index.html
│
└── demo-chart
├── Chart.yaml
├── values.yaml
└── templates
├── deployment.yaml
└── service.yaml

````


---

## 2. Helm 安装应用


执行：

```bash
helm install day46-demo ./demo-chart
````

查看 Release：

```bash
helm list
```

结果：

```
NAME          STATUS
day46-demo    deployed
```

查看 Pod：

```bash
kubectl get pods
```

---

# 三、本地镜像部署问题

## 1. ErrImagePull 问题

Pod 状态：

```
ErrImagePull
ImagePullBackOff
```

查看：

```bash
kubectl describe pod <pod-name>
```

发现：

```
Failed to pull image "day46-demo:v1"
```

原因：

Kubernetes 默认认为：

```
day46-demo:v1
=
docker.io/day46-demo:v1
```

但是镜像只存在本地 Podman。

---

# 四、Minikube 加载本地镜像

## 1. 构建镜像

进入：

```bash
cd app
```

构建：

```bash
podman build -t day46-demo:v1 .
```

生成：

```
day46-demo:v1
```

---

## 2. 导入 Minikube

由于 Minikube 使用独立运行环境：

```
宿主机 Podman

        ↓

Minikube Node 镜像缓存
```

导出：

```bash
podman save localhost/day46-demo:v1 -o day46-demo.tar
```

加载：

```bash
minikube image load day46-demo.tar
```

删除失败 Pod：

```bash
kubectl delete pod <pod-name>
```

Deployment 自动创建新 Pod。

最终：

```
day46-demo-xxxx   Running
```

---

# 五、Helm Template 渲染

查看最终 Kubernetes YAML：

```bash
helm template day46-demo .
```

输出：

```yaml
image: "localhost/day46-demo:v1"
```

流程：

```
values.yaml

      ↓

templates/deployment.yaml

      ↓

Kubernetes Manifest
```

---

# 六、模拟应用升级

## 1. 修改代码

修改：

```
app/index.html
```

原：

```
Hello Day46 Helm CI/CD
```

修改：

```
Hello Day46 Helm CI/CD Version 2
```

---

# 七、构建 v2 镜像

执行：

```bash
podman build -t day46-demo:v2 .
```

生成：

```
day46-demo:v2
```

---

## 2. 加载新镜像

导出：

```bash
podman save localhost/day46-demo:v2 -o day46-demo-v2.tar
```

加载：

```bash
minikube image load day46-demo-v2.tar
```

注意：

tar 文件只是实验过程中的临时产物。

不应该进入 Git 仓库。

---

# 八、修改 Helm values

修改：

```
values.yaml
```

原：

```yaml
image:
  repository: localhost/day46-demo
  tag: "v1"
```

修改：

```yaml
image:
  repository: localhost/day46-demo
  tag: "v2"
```

---

# 九、Helm Upgrade 发布

执行：

```bash
helm upgrade day46-demo .
```

查看：

```bash
helm list
```

Revision：

```
REVISION 2
```

---

# 十、Kubernetes 滚动更新

查看：

```bash
kubectl get pods -w
```

更新过程：

```
旧 Pod Running

        ↓

创建新的 ReplicaSet

        ↓

新 Pod Running

        ↓

删除旧 Pod
```

最终：

```
day46-demo-xxxx   Running
```

---

# 十一、Helm Release 历史

查看：

```bash
helm history day46-demo
```

结果：

```
REVISION   STATUS

1          superseded

2          deployed
```

说明：

Helm 保存应用发布历史。

---

# 十二、Helm 在 CI/CD 中的位置

当前实验流程：

```
代码修改

 ↓

Podman build

 ↓

Minikube image load

 ↓

helm upgrade

 ↓

Kubernetes RollingUpdate
```

企业流程：

```
Git Push

 ↓

CI Pipeline

 ↓

Docker Build

 ↓

Harbor Registry

 ↓

Helm Upgrade

 ↓

Kubernetes Deployment
```

---

# 十三、GitHub 大文件问题处理

## 1. 问题

提交：

```
day46-demo-v2.tar
```

大小：

```
157.34 MB
```

GitHub 限制：

```
100 MB
```

push：

```bash
git push
```

失败：

```
GH001: Large files detected
```

---

# 十四、问题原因

文件来源：

```bash
podman save
```

用途：

```
Podman

 ↓

镜像 tar

 ↓

Minikube image load
```

属于：

* 临时文件
* 构建产物
* 镜像文件

不属于源码。

---

# 十五、清理 Git 历史

普通删除：

```bash
rm day46-demo-v2.tar
```

无法解决。

原因：

Git 历史仍保存 blob。

使用：

```bash
git filter-repo \
--path k8s/labs/day46/helm-cicd-demo/app/day46-demo-v2.tar \
--invert-paths \
--force
```

重新生成 Git 历史。

---

# 十六、防止再次提交

添加：

`.gitignore`

```gitignore
*.tar
*.tar.gz
```

---

# 十七、重新推送

执行：

```bash
git push origin master --force
```

成功：

```
master -> master (forced update)
```

检查仓库：

```bash
git count-objects -vH
```

结果：

```
size-pack: 843 KiB
```

说明大文件已经清除。

---

# 十八、今日核心总结

Day46 完成 Kubernetes 应用发布闭环：

✅ Helm Chart 部署

✅ values 参数管理

✅ Helm template 渲染

✅ 本地镜像加载

✅ 镜像版本升级

✅ helm upgrade

✅ Kubernetes Rolling Update

✅ Helm Release 历史管理

✅ Git 大文件问题处理

---

# 今日关键理解

Helm 的价值：

不是替代 Kubernetes。

而是：

```
Kubernetes YAML

        ↓

Helm Template

        ↓

版本化应用发布
```

企业中：

```
Git 管理源码和配置

Registry 管理镜像

Helm 管理 Kubernetes 发布
```

这三者职责分离：

```
Git
 |
 | 代码
 |
 ↓

CI/CD

 |
 | 镜像
 |
 ↓

Registry

 |
 | 部署
 |
 ↓

Helm + Kubernetes
```

---
