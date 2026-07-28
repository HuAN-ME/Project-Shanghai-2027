```markdown
# Day40 - Kubernetes Service 深入：Endpoints、CoreDNS 与服务发现

> 从“会创建 Service”进入“理解 Kubernetes 服务通信机制”

---

# 一、今日目标

Day35 已经完成：

- Deployment
- Service
- NodePort
- Endpoints 基础查看

Day40 不重复创建 Service，而是在已有环境基础上深入理解：

- Service 如何找到 Pod
- Endpoints 如何动态维护
- Kubernetes DNS 如何解析 Service
- Pod 如何通过 Service 名访问应用

---

# 二、Service 回顾

Pod 最大的问题：

## Pod IP 不稳定

例如：

```

nginx-pod-abc

IP:

10.244.0.18

```

删除后：

```

nginx-pod-def

IP:

10.244.0.25

```

Pod 生命周期变化，IP也会变化。

因此：

不能直接依赖 Pod IP。

---

Kubernetes 引入：

```

Service

```

作为稳定访问入口。


结构：

```

Client

|

|

Service

ClusterIP

|

Endpoints

|

Pod IP

|

Container

````

---

# 三、Service 如何找到 Pod？

查看 Service：

```bash
kubectl describe svc nginx-service
````

重点：

```
Selector:

app=nginx
```

含义：

Service 不关注 Pod 名称。

它通过 Label 查找 Pod。

---

例如 Pod：

```yaml
metadata:

  labels:

    app: nginx
```

Service：

```yaml
selector:

  app: nginx
```

二者匹配。

---

流程：

```
Service

selector:
    app=nginx


        ↓


查询所有匹配 Label 的 Pod


        ↓


生成 Endpoints


        ↓


转发流量
```

---

# 四、Endpoints 原理

查看：

```bash
kubectl get endpoints
```

示例：

```
NAME             ENDPOINTS

nginx-service

10.244.0.18:80
10.244.0.16:80
10.244.0.19:80
```

Endpoints 就是真正提供服务的 Pod 地址。

类似传统负载均衡：

```
Load Balancer

Backend:

192.168.1.10
192.168.1.11
192.168.1.12
```

Kubernetes：

```
Service

Backend:

10.244.0.18
10.244.0.16
10.244.0.19
```

---

# 五、验证 Endpoints 动态变化

删除一个 Pod：

```bash
kubectl delete pod <pod-name>
```

观察：

```bash
kubectl get endpoints -w
```

变化：

旧 Pod：

```
10.244.0.18
```

消失。

新 Pod：

```
10.244.0.22
```

加入。

原因：

Deployment 创建新 Pod。

Service 自动更新 Endpoints。

---

# 六、Kubernetes DNS 服务发现

问题：

如果 Pod 不应该知道：

```
10.244.0.18
```

怎么办？

Kubernetes 提供：

```
CoreDNS
```

实现服务名称解析。

---

访问：

```bash
curl nginx-service
```

实际过程：

```
curl nginx-service

        |

        ↓

CoreDNS解析


        |

        ↓

nginx-service.default.svc.cluster.local


        |

        ↓

Service ClusterIP


        |

        ↓

Endpoints


        |

        ↓

Pod
```

---

# 七、创建测试 Pod

创建：

```yaml
apiVersion: v1

kind: Pod


metadata:

  name: curl-test


spec:

  containers:

  - name: curl

    image: docker.m.daocloud.io/library/alpine:latest

    command:

    - sleep

    - "3600"
```

---

部署：

```bash
kubectl apply -f curl-test.yaml
```

查看：

```bash
kubectl get pods
```

---

进入：

```bash
kubectl exec -it curl-test -- sh
```

安装 curl：

```bash
apk add curl
```

测试：

```bash
curl nginx-service
```

返回：

```
Welcome to nginx!
```

说明：

Pod 已经通过 Service 名访问 nginx。

---

# 八、查看 DNS 配置

进入测试 Pod：

```bash
cat /etc/resolv.conf
```

看到：

```
nameserver 10.96.0.10
```

该地址：

就是 Kubernetes CoreDNS 服务。

---

查看：

```bash
kubectl get pods -n kube-system
```

可以看到：

```
coredns-xxxx

Running
```

---

# 九、镜像拉取问题复盘

实验过程中：

curl 镜像出现：

```
ImagePullBackOff
```

原因：

kubelet/containerd 默认访问：

```
docker.io
```

但是 Docker Hub 网络不稳定。

解决：

使用国内镜像代理：

例如：

```
docker.m.daocloud.io/library/xxx
```

以后实验保持：

不要：

```yaml
image: nginx
```

推荐：

```yaml
image: docker.m.daocloud.io/library/nginx:latest
```

---

# 十、今日核心理解

Day35：

理解：

```
Service
    |
    ↓
Pod
```

Day40：

理解完整链路：

```
Pod请求

    ↓

Service Name

    ↓

CoreDNS

    ↓

Service ClusterIP

    ↓

Endpoints

    ↓

Pod IP

    ↓

Container
```

---

# 十一、知识升级

目前 Kubernetes 应用通信模型：

```
User

 ↓

Ingress（未来学习）

 ↓

Service

 ↓

Endpoints

 ↓

Pod

 ↓

Container
```

内部服务：

```
Pod A

 ↓

Service DNS

 ↓

Pod B
```

这就是 Kubernetes 微服务通信基础。

---

# Day40 总结

完成：

✅ 理解 Service selector 工作机制
✅ 理解 Endpoints 动态维护
✅ 验证 Pod 删除后的服务恢复
✅ 理解 CoreDNS 作用
✅ 使用 Service Name 访问应用
✅ 掌握 Kubernetes 内部服务发现流程
✅ 解决镜像拉取问题
