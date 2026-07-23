````markdown
# Day35：从 Pod 到 Service —— Kubernetes 服务暴露与滚动更新实战

日期：2026-07-20

项目：Project-Shanghai-2027

---

# 一、今日目标

继续深入 Kubernetes 应用部署流程。

目标：

- 理解 Deployment 与 ReplicaSet 的关系
- 理解滚动更新机制
- 学习 Service 工作原理
- 使用 NodePort 暴露 Kubernetes 服务
- 完成 Kubernetes 内部网络访问链路


---

# 二、Deployment 滚动更新异常排查

## 1. 问题现象

执行：

```bash
kubectl get deployment
````

发现：

```
NAME               READY   UP-TO-DATE   AVAILABLE

nginx-deployment   3/3     1            3
```

异常：

* READY 正常
* AVAILABLE 正常
* UP-TO-DATE 异常

说明：

当前服务仍然可用，但是新的 Deployment 版本没有完全更新成功。

---

# 三、分析 ReplicaSet 状态

查看：

```bash
kubectl get rs
```

结果：

```
NAME                          DESIRED   CURRENT   READY

nginx-deployment-6f6c6b9458   3         3         3

nginx-deployment-b5d497498    1         1         0
```

发现存在两个 ReplicaSet：

```
Deployment

        |
        |
 ---------------------
 |                   |
旧 ReplicaSet        新 ReplicaSet

6f6c6b9458           b5d497498

3 Running            1 Failed
```

---

# 四、理解 Kubernetes 滚动更新机制

Deployment 默认策略：

```yaml
strategy:
  type: RollingUpdate
```

更新流程：

```
修改 Deployment
        |
        |
创建新的 ReplicaSet
        |
        |
启动新的 Pod
        |
        |
新 Pod Ready
        |
        |
逐渐替换旧 Pod
```

如果新版本失败：

```
旧版本继续提供服务

新版本停止推进
```

因此：

即使新版本失败：

```
用户服务不会立即中断
```

这也是 Kubernetes 发布安全机制。

---

# 五、新版本失败原因

查看 Pod：

```bash
kubectl describe pod
```

发现：

```
Back-off pulling image
```

原因：

镜像地址错误。

错误：

```yaml
image:
 docker.m.daocloud.io/libray/nginx:latest
```

注意：

```
libray
```

拼写错误。

正确：

```yaml
image:
 docker.m.daocloud.io/library/nginx:latest
```

修改后：

Deployment 自动创建新的 Pod。

---

# 六、Service 基础概念

Pod 存在的问题：

* IP 会变化
* Pod 重启后地址改变
* 不适合作为访问入口

Service 提供：

* 稳定访问地址
* 服务发现
* 负载均衡

结构：

```
用户

 |

Service

 |

----------------

Pod Pod Pod

```

---

# 七、创建 NodePort Service

查看 Service：

```bash
kubectl get svc
```

结果：

```
NAME             TYPE        PORT

nginx-nodeport   NodePort    80:30080

nginx-service    NodePort    80:31085
```

说明：

Service 类型：

```
NodePort
```

访问方式：

```
节点IP:NodePort
```

例如：

获取节点：

```bash
minikube ip
```

访问：

```
http://<minikube-ip>:30080
```

---

# 八、Service 工作流程

完整链路：

```
用户请求

    |

NodePort

    |

Service ClusterIP

    |

Selector匹配

    |

Pod Endpoint

    |

Container Port 80

```

---

# 九、查看 Service 后端

执行：

```bash
kubectl get endpoints
```

Service 会记录：

```
Pod IP:80
```

例如：

```
nginx-service

10.244.0.18:80
10.244.0.16:80
10.244.0.19:80
```

说明：

Service 已经成功发现后端 Pod。

---

# 十、Day35 知识总结

今天完成 Kubernetes 应用访问链路：

```
Container Image

        ↓

Pod

        ↓

ReplicaSet

        ↓

Deployment

        ↓

Service

        ↓

NodePort

        ↓

用户访问
```

---

# 十一、核心知识点

## Deployment

负责：

* 声明应用状态
* 管理 ReplicaSet
* 滚动更新

---

## ReplicaSet

负责：

* 保证 Pod 副本数量

例如：

```yaml
replicas: 3
```

表示：

始终保持三个 Pod。

---

## Service

负责：

* 服务发现
* 稳定入口
* 负载均衡

---

# 十二、今日踩坑总结

## 坑1：镜像仓库网络问题

现象：

```
registry-1.docker.io connection refused
```

解决：

使用国内镜像源。

---

## 坑2：镜像地址拼写错误

错误：

```
libray/nginx
```

正确：

```
library/nginx
```

---

## 坑3：Deployment 滚动更新暂停

现象：

```
READY 3/3

UP-TO-DATE 1
```

原因：

新 ReplicaSet 创建失败。

解决：

* 查看 ReplicaSet
* 查看 Pod Events
* 修复镜像

---

# 十三、Day35 总结

Day35 是 Kubernetes 学习的重要节点。

从今天开始：

不再只是运行容器。

开始理解 Kubernetes 的核心思想：

> 用户声明目标状态，控制器持续保证系统达到目标状态。

Kubernetes 不关心一次启动是否成功，

而是持续检测：

* Pod 是否存在
* 副本是否满足
* 网络是否正常
* 服务是否可访问

这正是 Kubernetes 自动化运维的核心。

---

# Day35 Status

完成：

✅ Deployment 滚动更新理解

✅ ReplicaSet 版本管理

✅ Service 创建

✅ NodePort 暴露服务

✅ Endpoint 服务发现

✅ Kubernetes 应用访问链路闭环

