```markdown
# Day31 - Kubernetes Pod 初体验：从 ErrImagePull 到 Running

日期：2026-07-19

阶段：

Phase 2 - Kubernetes Engineer

目标：

从“能够启动 Kubernetes 集群”

进入：

“能够使用 Kubernetes 管理应用”。

---

# 一、今日目标

学习 Kubernetes 最基础资源对象：

- Pod
- kubectl 基础操作
- YAML 声明式管理
- Pod 生命周期
- Kubernetes 镜像拉取机制


今日实验：

创建 nginx Pod。

---

# 二、环境确认

当前环境：

```

Rocky Linux 9.8

Minikube v1.38.1

Kubernetes v1.35.1

Driver:
podman

Runtime:
containerd

````

检查节点：

```bash
kubectl get nodes
````

结果：

```
NAME       STATUS   ROLES
minikube   Ready    control-plane
```

说明 Kubernetes 集群正常。

---

# 三、理解 Kubernetes 架构

Kubernetes 并不是直接管理 Container。

结构：

```
Kubernetes

    |
    |
   Pod

    |
    |
 Container Runtime

    |
    |
 Container
```

最小管理单位：

```
Pod
```

不是：

```
Container
```

---

# 四、创建第一个 Pod

目录：

```
k8s/labs/day31/
```

创建：

```
pod-nginx.yaml
```

内容：

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  containers:
    - name: nginx
      image: docker.m.daocloud.io/library/nginx:latest
      ports:
        - containerPort: 80
```

---

# 五、第一次部署失败

执行：

```bash
kubectl apply -f pod-nginx.yaml
```

查看：

```bash
kubectl get pods
```

结果：

```
NAME        READY   STATUS
nginx-pod   0/1     ErrImagePull
```

---

# 六、问题排查

查看 Pod 事件：

```bash
kubectl describe pod nginx-pod
```

发现：

```
Failed to pull image nginx:latest

docker.io/library/nginx

connect: connection refused
```

原因：

Kubernetes 节点访问 Docker Hub 失败。

---

# 七、关键知识点

## Podman 镜像 ≠ Kubernetes 镜像

宿主机：

```
Rocky Linux

Podman

nginx image
```

和：

```
Minikube Node

containerd

nginx image
```

是两个独立环境。

即：

```text
podman images

≠

containerd images
```

虽然：

```bash
podman pull nginx
```

成功。

但是：

Kubernetes 仍然无法使用。

---

# 八、解决方案

由于 Docker Hub 网络访问失败：

修改镜像源。

原：

```yaml
image: nginx:latest
```

修改：

```yaml
image: docker.m.daocloud.io/library/nginx:latest
```

重新部署：

删除旧 Pod：

```bash
kubectl delete pod nginx-pod
```

重新创建：

```bash
kubectl apply -f pod-nginx.yaml
```

查看：

```bash
kubectl get pods
```

最终：

```
NAME        READY   STATUS
nginx-pod   1/1     Running
```

---

# 九、Pod 常用命令

查看：

```bash
kubectl get pods
```

详细信息：

```bash
kubectl describe pod nginx-pod
```

日志：

```bash
kubectl logs nginx-pod
```

进入容器：

```bash
kubectl exec -it nginx-pod -- bash
```

删除：

```bash
kubectl delete pod nginx-pod
```

---

# 十、Minikube rootless Podman 问题记录

尝试：

```bash
minikube ssh
```

出现：

```
sudo: a password is required
```

原因：

Minikube CLI 部分状态检测逻辑尝试：

```
sudo podman
```

但是当前环境：

```
Podman rootless
```

实际：

```bash
podman ps -a
```

可以看到：

```
minikube container
```

因此：

集群正常。

后续 Kubernetes 管理：

使用：

```
kubectl
```

而不是依赖：

```
minikube ssh
```

---

# 十一、今日收获

## 1. Kubernetes 是声明式管理

用户描述：

```
我要一个 nginx Pod
```

Kubernetes 自动：

```
调度

拉镜像

创建容器

维护状态
```

---

## 2. 排查 Kubernetes 问题第一步：

永远：

```bash
kubectl describe
```

重点：

```
Events
```

---

## 3. ImagePullBackOff 排查流程

检查：

1. 镜像名称

2. Registry访问

3. 网络

4. 权限

5. 镜像源

---

# 十二、今日成果

完成：

[x] 创建 Kubernetes Pod

[x] 编写 YAML

[x] kubectl apply

[x] kubectl describe 排障

[x] 解决 ErrImagePull

[x] Pod Running

---

# Day31 总结

Day30：

完成 Kubernetes 集群搭建。

Day31：

第一次真正使用 Kubernetes 部署应用。

最大的收获：

不是创建 nginx。

而是第一次理解：

```
Kubernetes不是运行容器。

而是管理期望状态。
```
