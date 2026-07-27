```markdown id="day39-env-md"
# Day39 - Kubernetes Health Check 与实验环境生命周期管理

## 一、今日内容

学习 Kubernetes 健康检查机制：

- livenessProbe（存活探针）
- readinessProbe（就绪探针）
- Kubernetes 自动恢复机制
- minikube 实验环境正确关闭方式

---

# 二、为什么需要 Probe？

一个容易误解的问题：

```

Pod Running ≠ 应用正常

```

默认情况下：

```

Container启动成功
|
↓
Kubernetes认为正常

```

但是实际情况：

```

Pod Running

应用内部可能：

* 服务异常
* 接口报错
* 死锁
* 无法处理请求

```

因此 Kubernetes 需要主动检测应用状态。

---

# 三、Kubernetes 三种探针

## 1. livenessProbe（存活探针）

作用：

判断：

> 容器是否还活着


如果检测失败：

```

liveness失败

↓

kubelet杀死container

↓

重新启动container

````


示例：

```yaml
livenessProbe:

  httpGet:

    path: /

    port: 80

  initialDelaySeconds: 10

  periodSeconds: 5
````

参数：

* initialDelaySeconds

启动后等待多久开始检测

* periodSeconds

检测间隔时间

---

## 2. readinessProbe（就绪探针）

作用：

判断：

> Pod 是否可以接收流量

例如：

应用启动过程：

```
启动

↓

加载配置

↓

连接数据库

↓

初始化缓存

↓

准备完成
```

在准备完成前：

不能接受用户请求。

readiness失败：

```
Pod:

Running

但是：

Service不会转发流量
```

关系：

```
Pod Running

      |

readiness检测

      |

      +----失败

      |
 Service移除Endpoints


      +----成功

      |
 Service正常转发
```

---

## 3. startupProbe（启动探针）

用于：

> 启动时间较长的应用

例如：

Spring Boot：

```
启动JVM
加载依赖
初始化数据库
启动完成
```

如果没有 startupProbe：

liveness可能误判：

```
启动慢

↓

认为挂掉

↓

不断重启
```

startupProbe 给应用启动缓冲时间。

---

# 四、Day39 实验

创建：

```
nginx-probe-demo
```

Deployment：

包含：

* replicas
* livenessProbe
* readinessProbe

部署：

```bash
kubectl apply -f nginx-probe.yaml
```

查看：

```bash
kubectl get pods
```

---

# 五、验证 Kubernetes 自愈能力

实验现象：

Pod：

```
nginx-probe-demo-xxxx

READY   STATUS     RESTARTS

1/1     Running    1
```

重点：

```
RESTARTS = 1
```

说明：

容器曾经异常。

Kubernetes 自动：

```
Probe检测失败

↓

kubelet发现异常

↓

重启container

↓

重新健康检查

↓

恢复服务
```

---

# 六、Kubernetes 自愈机制理解升级

Day32：

ReplicaSet保证 Pod 数量：

```
Pod删除

↓

ReplicaSet创建新Pod
```

Day39：

Probe保证 Container 健康：

```
Container异常

↓

kubelet重启container
```

区别：

```
                Kubernetes

                     |

        +------------+------------+

        |                         |

 ReplicaSet                  kubelet

        |                         |

 Pod数量管理              Container健康管理

 Pod消失                  程序异常

 ↓                         ↓

创建Pod                   重启Container
```

---

# 七、minikube 实验环境管理

## 为什么关闭虚拟机变慢？

直接关闭：

```
关闭虚拟机

↓

systemd停止服务

↓

Podman停止容器

↓

containerd关闭

↓

Kubernetes组件退出

↓

保存状态

↓

虚拟机关机
```

因此耗时较长。

---

# 八、推荐关闭流程

实验结束：

先查看：

```bash
kubectl get pods -A
```

停止 Kubernetes：

```bash
minikube stop
```

确认：

```bash
podman ps
```

然后关闭 Rocky：

```bash
sudo poweroff
```

---

# 九、启动流程

开机后：

启动 minikube：

```bash
minikube start
```

检查：

```bash
kubectl get nodes
```

状态：

```
NAME       STATUS
minikube   Ready
```

之前创建的：

* Deployment
* Service
* ConfigMap
* Secret

都会恢复。

---

# 十、注意事项

不要随意：

```bash
minikube delete
```

区别：

## stop

暂停：

```
保留集群数据
```

适合：

日常关机。

## delete

删除：

```
Cluster
Pod
Deployment
Service
配置数据
```

适合：

重新初始化环境。

---

# Day39 总结

完成：

✅ 理解 Kubernetes Probe 机制
✅ 配置 livenessProbe
✅ 配置 readinessProbe
✅ 验证 Kubernetes 自动重启能力
✅ 理解 Pod 与 Container 两层恢复机制
✅ 学会 minikube 正确生命周期管理

当前 Kubernetes 能力链：

```
Pod
 ↓
ReplicaSet
 ↓
Deployment
 ↓
Service
 ↓
ConfigMap
 ↓
Secret
 ↓
Rolling Update
 ↓
Health Check
```
