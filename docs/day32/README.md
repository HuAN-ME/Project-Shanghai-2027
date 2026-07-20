````markdown
# Day32 Kubernetes Deployment 与声明式运维初体验

## 今日目标

理解 Kubernetes 的核心思想：

> 用户描述期望状态，Kubernetes 自动维护实际状态。

通过 Pod Replica 机制理解 Kubernetes 自动化管理能力。


---

# 一、从单个 Pod 到声明式管理

之前：

直接运行：

```bash
kubectl run nginx
````

本质：

创建一个单独 Pod。

问题：

如果：

* 容器崩溃
* Pod 删除
* 节点异常

服务可能消失。

---

# 二、Kubernetes 的核心思想

Kubernetes 不直接管理容器。

它管理：

```
Desired State
      |
      |
Controller
      |
      |
Actual State
```

用户声明：

"我希望三个 nginx 副本"

Kubernetes 自动保证：

```
nginx
nginx
nginx
```

一直存在。

---

# 三、Replica Controller 理解

例如：

Deployment：

```yaml
replicas: 3
```

表示：

期望状态：

```
3个Pod运行
```

如果：

```
Pod1
Pod2
Pod3
```

其中：

```
Pod2 crash
```

Kubernetes发现：

实际：

```
2个Pod
```

期望：

```
3个Pod
```

于是自动创建：

```
Pod4
```

恢复：

```
Pod1
Pod3
Pod4
```

这就是 Kubernetes 自愈能力。

---

# 四、Day31遇到的问题回顾

## 问题1：ErrImagePull

错误：

```
Failed to pull image nginx
```

原因：

Kubernetes节点访问Docker Hub失败。

解决：

确认网络问题。

学习：

Kubernetes 拉取镜像发生在：

```
Node节点
```

而不是：

```
宿主机Podman
```

---

# 五、Minikube环境理解

当前架构：

```
Rocky Linux

    |
    |
 Podman

    |
    |
 minikube container

    |
    |
 Kubernetes v1.35.1

    |
    |
 Pods
```

minikube本质：

一个运行 Kubernetes control-plane 的容器。

---

# 六、关闭电脑后的恢复

minikube默认不会自动启动。

重新启动：

```bash
minikube start
```

检查：

```bash
kubectl get nodes
```

恢复：

```
STATUS Ready
```

---

# 七、今日核心理解

以前：

```
我要启动一个容器
```

现在：

```
我要声明一个服务状态
```

区别：

Docker:

```
run container
```

Kubernetes:

```
describe desired state

↓

controller maintain

↓

system self-healing
```

---

# 八、阶段总结

Day30：

完成 Kubernetes 集群部署。

Day31：

完成 Pod 调度和镜像管理。

Day32：

理解 Kubernetes 声明式管理思想。

从今天开始：

Project Shanghai 2027 正式进入 Kubernetes 阶段。

```
