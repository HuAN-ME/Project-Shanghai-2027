```markdown
# Day33 Kubernetes Deployment 深入实践：从 Pod 到应用生命周期管理

> Project Shanghai 2027  
> Kubernetes Learning Log

日期：2026-07-20

---

# 一、今日目标

Day32 学习了 Kubernetes 的核心思想：

> 用户声明目标状态（Desired State），Kubernetes 自动维持目标状态。

Day33 进一步学习 Kubernetes 中最常用的应用管理对象：

- Deployment
- ReplicaSet
- Pod
- Replica
- Self-Healing
- Rolling Update

目标：

理解 Kubernetes 如何实现：

- 自动创建 Pod
- 自动维持副本数量
- Pod 故障自动恢复
- 应用版本更新


---

# 二、Deployment 与 Pod 的关系

之前直接创建 Pod：

```

Pod
|
Container

```

存在问题：

- Pod 删除后不会自动恢复
- 无法管理多个副本
- 无法进行版本更新


Deployment 引入后：

```

Deployment

```
  |
```

ReplicaSet

```
  |
```

---

Pod     Pod     Pod

```


关系：

```

Deployment
|
|
ReplicaSet
|
|
Pod
|
Container

```


Deployment 不直接管理 Pod。

它通过 ReplicaSet 控制 Pod 数量。


---

# 三、创建第一个 Deployment


文件：

```

nginx-deployment.yaml

````


内容：

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx-deployment

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
````

核心字段：

## replicas

```yaml
replicas: 3
```

表示：

期望运行 3 个 Pod。

## selector

```yaml
matchLabels:
  app: nginx
```

用于匹配需要管理的 Pod。

## template

定义 Pod 模板。

---

# 四、部署应用

执行：

```bash
kubectl apply -f nginx-deployment.yaml
```

查看 Deployment：

```bash
kubectl get deployment
```

结果：

```
NAME               READY
nginx-deployment   3/3
```

说明：

Deployment 创建成功。

---

# 五、查看 ReplicaSet

执行：

```bash
kubectl get rs
```

结果：

```
nginx-deployment-xxxxxx
```

ReplicaSet 负责：

* 创建 Pod
* 删除 Pod
* 保持副本数量

结构：

```
Deployment

nginx-deployment

        |

ReplicaSet

nginx-deployment-xxxx

        |

Pod1
Pod2
Pod3

```

---

# 六、验证 Kubernetes 自愈能力

删除一个 Pod：

```bash
kubectl delete pod nginx-deployment-xxxx
```

观察：

```bash
kubectl get pods
```

发现：

旧 Pod 删除：

```
Terminating
```

新的 Pod 创建：

```
ContainerCreating
```

最终：

```
3 Running
```

原因：

Deployment 声明：

```
replicas=3
```

Controller 检测：

实际状态：

```
2
```

目标状态：

```
3
```

产生差异：

```
Actual State != Desired State
```

Controller 自动修复。

这就是：

# Kubernetes Self-Healing

---

# 七、Day33 遇到的问题：ImagePullBackOff

创建 Deployment 后：

```bash
kubectl get deployment
```

发现：

```
READY 0/3
```

查看 Pod：

```bash
kubectl get pods
```

发现：

```
ImagePullBackOff
```

查看事件：

```bash
kubectl describe pod <pod-name>
```

错误：

```
Failed to pull image "nginx:latest"

registry-1.docker.io connection timeout
```

原因：

Kubernetes 使用：

```
minikube

    |

containerd

    |

docker.io
```

拉取镜像。

但是：

Docker Hub 网络不可达。

---

# 八、为什么 podman pull 成功但是 Kubernetes 失败？

执行：

```bash
podman pull nginx
```

成功。

但是：

```yaml
image: nginx:latest
```

仍然失败。

原因：

Podman 和 Kubernetes 使用不同运行环境。

结构：

```
Rocky Linux

podman
 |
本地镜像


----------------


minikube

containerd
 |
Kubernetes镜像
```

两个镜像环境隔离。

Podman 拉取成功：

不代表 Kubernetes 可以使用。

---

# 九、解决 ImagePullBackOff

修改：

```yaml
image: nginx:latest
```

改为：

```yaml
image: docker.m.daocloud.io/library/nginx:latest
```

重新应用：

```bash
kubectl apply -f nginx-deployment.yaml
```

Deployment 自动检测变化。

触发：

# Rolling Update

---

# 十、观察滚动更新

查看：

```bash
kubectl get pods
```

变化：

旧版本：

```
ImagePullBackOff
```

新版本：

```
ContainerCreating
```

最终：

```
Running
```

查看更新状态：

```bash
kubectl rollout status deployment nginx-deployment
```

---

# 十一、核心知识总结

## Deployment

作用：

管理应用生命周期。

负责：

* 创建 ReplicaSet
* 更新版本
* 扩缩容
* 回滚

---

## ReplicaSet

作用：

保证 Pod 副本数量。

例如：

```
replicas=3
```

保证：

```
永远存在三个 Pod
```

---

## Pod

Kubernetes 最小部署单位。

包含：

```
Pod

 |
Container
```

---

# 十二、今日理解升级

以前：

```
Docker

启动一个容器

docker run nginx
```

现在：

```
Kubernetes

声明：

我要三个 nginx

```

系统自动：

```
创建
监控
恢复
更新

```

---

# 十三、Day33 总结

今天完成：

✅ 创建 Deployment

✅ 理解 ReplicaSet

✅ 理解 Pod 生命周期

✅ 实验 Kubernetes Self-Healing

✅ 排查 ImagePullBackOff

✅ 理解镜像仓库与 Runtime 区别

✅ 体验 Rolling Update

---

# 今日关键词

```
Deployment

ReplicaSet

Replica

Controller

Desired State

Actual State

Self-Healing

ImagePullBackOff

Rolling Update

containerd

```

---


