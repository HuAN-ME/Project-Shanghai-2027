````markdown
# Day30：我启动了 Kubernetes，然后 Kubernetes 把我拒之门外 🤡——一场从 NotReady 到 Ready 的凌晨鏖战

> Project Shanghai 2027
>
> Kubernetes First Cluster Milestone

---

## 今日里程碑

Day30 是 Project Shanghai 2027 的一个重要节点。

经过前29天：

- Linux基础
- Git/GitHub
- CI/CD
- Podman
- Container Image
- GHCR

今天正式进入 Kubernetes 时代。

目标：

> 在 Rocky Linux 9.8 环境中，使用 Podman rootless 运行 Minikube，并完成 Kubernetes 集群部署。

最终目标：

```bash
kubectl get nodes
````

得到：

```
minikube   Ready
```

---

# 一、环境信息

## Host

```
OS:
Rocky Linux 9.8

Kernel:
5.14.0-el9

Architecture:
x86_64
```

---

## Container Runtime

```
Podman rootless

containerd:
2.2.1
```

---

## Kubernetes

```
Minikube:
v1.38.1

Kubernetes:
v1.35.1
```

---

# 二、第一次启动 Kubernetes

最终使用命令：

```bash
minikube start \
--driver=podman \
--rootless=true \
--memory=2048 \
--container-runtime=containerd \
--base-image=registry.cn-hangzhou.aliyuncs.com/google_containers/kicbase:v0.0.50
```

---

# 三、第一关：国外镜像仓库访问失败

## 问题

Minikube启动过程中：

```
gcr.io
registry-1.docker.io
```

无法访问。

测试：

```bash
curl -I https://gcr.io/v2/
```

结果：

```
connection refused
```

Docker Hub：

```
registry-1.docker.io:443
connection refused
```

---

## 分析

Minikube默认依赖：

* gcr.io
* docker.io

但是当前网络环境无法访问国外 Registry。

导致：

基础镜像无法下载。

---

## 解决

切换国内镜像：

```
registry.cn-hangzhou.aliyuncs.com
docker.m.daocloud.io
```

例如：

```
registry.cn-hangzhou.aliyuncs.com/google_containers/kicbase
```

---

# 四、第二关：Minikube状态混乱

## 错误

反复出现：

```
Error:
no container with name or ID "minikube"
```

但是：

```
minikube profile
```

仍然存在。

---

## 原因

Minikube profile记录：

```
~/.minikube
```

和Podman实际容器状态：

```
podman ps
```

不一致。

---

## 解决

彻底清理：

```bash
minikube delete --all --purge
```

删除残留：

```bash
podman volume rm -f minikube
```

重新初始化。

---

# 五、第三关：rootless Podman + cgroup陷阱

## 错误

出现：

```
ERROR:
UserNS:
cpu controller needs to be delegated
```

---

## 原因

Rootless Kubernetes依赖：

systemd delegation

但是：

user service:

```
Delegate
```

没有包含：

```
cpu
```

导致容器无法启动。

---

## 排查

查看：

```bash
cat /sys/fs/cgroup/user.slice/user-xxx.service/cgroup.controllers
```

发现：

```
memory pids
```

缺少：

```
cpu
```

---

## 学到

Kubernetes运行环境不仅需要：

* CPU
* Memory

还需要：

Linux cgroup正确配置。

---

# 六、第四关：终于启动，但是 NotReady

启动成功：

```bash
kubectl get nodes
```

结果：

```
NAME
minikube

STATUS

NotReady
```

---

# 七、真正Boss出现：CNI网络插件失败

查看Pod：

```bash
kubectl get pods -A
```

发现：

```
kindnet

ErrImagePull
```

---

进一步：

```bash
kubectl describe pod kindnet -n kube-system
```

发现：

```
Failed to pull image

docker.io/kindest/kindnetd:v20260213-ea8e5717
```

---

原因：

Kubernetes网络插件仍然尝试访问：

```
docker.io
```

但是：

```
registry-1.docker.io:443

connection refused
```

---

# 八、理解 Kubernetes 网络

这一次真正理解：

Kubernetes启动：

```
Control Plane
        |
        |
        ↓
Network Plugin(CNI)
        |
        |
        ↓
Pod Network
        |
        |
        ↓
CoreDNS
        |
        |
        ↓
Node Ready
```

---

我的问题：

```
kindnet失败
```

导致：

```
Pod网络不存在
```

导致：

```
CoreDNS Pending
```

导致：

```
Node NotReady
```

---

# 九、解决 CNI问题

修改：

原：

```yaml
image:
docker.io/kindest/kindnetd:v20260213-ea8e5717
```

改：

```yaml
image:
docker.m.daocloud.io/kindest/kindnetd:v20260213-ea8e5717
```

---

删除旧Pod：

```bash
kubectl delete pod \
-n kube-system \
-l app=kindnet
```

DaemonSet自动创建。

---

# 十、最终胜利

查看：

```bash
kubectl get pods -A
```

结果：

```
coredns                  Running
etcd                     Running
kindnet                  Running
kube-apiserver           Running
kube-controller-manager  Running
kube-proxy               Running
scheduler                Running
storage-provisioner     Running
```

---

节点：

```bash
kubectl get nodes
```

最终：

```
NAME       STATUS
minikube   Ready
```

---

# Day30 最大收获

## 1. Kubernetes不是安装，是排障

第一次真正理解：

```
kubectl get pods
kubectl describe
kubectl get nodes
```

的重要性。

---

## 2. Node NotReady不代表Kubernetes挂了

控制面：

```
apiserver ✅
etcd ✅
scheduler ✅
controller ✅
```

全部正常。

问题：

```
CNI ❌
```

---

## 3. 镜像仓库是云原生基础设施的一部分

今天遇到：

* Docker Hub
* GCR
* 国内镜像
* Daocloud Mirror

理解：

> 云原生时代，Registry就是基础设施。

---

# Day30总结

今天完成：

✅ Minikube部署
✅ Podman rootless运行Kubernetes
✅ containerd runtime配置
✅ Kubernetes v1.35.1启动
✅ CNI网络故障排查
✅ Node NotReady修复
✅ 第一个Kubernetes集群Ready

---

# Project Shanghai 2027 Milestone

Day30意味着：

我不再只是运行容器。

我开始理解：

```
Container
    ↓
Image
    ↓
Runtime
    ↓
Orchestration
    ↓
Kubernetes Cluster
```

这是从 DevOps 入门走向 Cloud Native 的关键一步。

