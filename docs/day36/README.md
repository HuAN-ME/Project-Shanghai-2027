# Day36｜配置与代码分离：初识 Kubernetes ConfigMap

## 今日目标

学习 Kubernetes 中的 **ConfigMap**，理解为什么要将配置与镜像分离，并掌握 ConfigMap 的两种主要使用方式：

* Environment Variables（环境变量）
* Volume Mount（配置文件挂载）

---

# 一、为什么需要 ConfigMap？

在 Docker 中，我们通常把程序和配置一起打包进镜像。

例如：

```
nginx.conf
application.yml
database.properties
```

都会存在镜像内部。

这样虽然能够运行，但有一个明显的问题：

> **修改一个配置，需要重新构建镜像。**

例如：

```
Redis 地址变化
↓

修改 application.yml
↓

docker build
↓

重新部署
```

成本非常高。

Kubernetes 提出了新的理念：

> **镜像负责程序，配置单独管理。**

于是产生了 ConfigMap。

```
Application(Image)
        │
        │
        ▼
ConfigMap
        │
        ▼
Container
```

程序与配置彻底解耦。

---

# 二、实验一：环境变量方式

首先创建 ConfigMap：

```bash
kubectl create configmap app-config \
  --from-literal=APP_NAME=Project-Shanghai \
  --from-literal=VERSION=1.0
```

查看：

```bash
kubectl describe configmap app-config
```

结果：

```
APP_NAME=Project-Shanghai
VERSION=1.0
```

随后在 Pod 中引用：

```yaml
env:
- name: APP_NAME
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_NAME

- name: VERSION
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: VERSION
```

创建 Pod：

```bash
kubectl apply -f pod-configmap.yaml
```

进入容器：

```bash
kubectl exec -it nginx-config -- env
```

结果：

```
APP_NAME=Project-Shanghai
VERSION=1.0
```

证明 ConfigMap 已成功注入环境变量。

---

# 三、实验二：配置文件挂载（Volume）

创建配置文件：

```text
app.conf
```

内容：

```
APP_NAME=Project Shanghai 2027
VERSION=1.0
AUTHOR=Ajax
```

根据文件创建 ConfigMap：

```bash
kubectl create configmap app-config-file \
  --from-file=app.conf
```

查看：

```bash
kubectl describe configmap app-config-file
```

可以看到整个文件已经存入 Kubernetes。

随后编写 Pod：

```yaml
volumeMounts:
- name: config-volume
  mountPath: /etc/config

volumes:
- name: config-volume
  configMap:
    name: app-config-file
```

部署：

```bash
kubectl apply -f pod-configmap-volume.yaml
```

进入容器：

```bash
kubectl exec -it nginx-config-volume -- sh
```

查看：

```bash
cat /etc/config/app.conf
```

输出：

```
APP_NAME=Project Shanghai 2027
VERSION=1.0
AUTHOR=Ajax
```

说明 ConfigMap 已成功挂载为配置文件。

---

# 四、热更新实验

修改 ConfigMap：

```bash
kubectl edit configmap app-config-file
```

修改内容：

```
VERSION=2.0
MESSAGE=Hello Kubernetes
```

等待几十秒后再次进入容器：

```bash
cat /etc/config/app.conf
```

发现：

```
VERSION=2.0
MESSAGE=Hello Kubernetes
```

无需重新创建 Pod。

说明：

> ConfigMap 作为 Volume 挂载时，Kubernetes 会自动同步配置文件。

---

# 五、环境变量与文件挂载的区别

今天最大的收获就是理解了两种使用方式的区别。

### Environment Variables

```
ConfigMap
      │
      ▼
Environment
      │
      ▼
Container
```

特点：

* 启动时读取一次
* 修改 ConfigMap 不会自动更新
* 需要重新创建 Pod

通常需要：

```bash
kubectl rollout restart deployment xxx
```

或者：

```bash
kubectl delete pod xxx
```

重新创建 Pod。

---

### Volume Mount

```
ConfigMap
      │
      ▼
Volume
      │
      ▼
/etc/config
```

特点：

* ConfigMap 更新后自动同步
* 无需重新部署 Pod
* 企业中使用最广泛

---

# 六、今天真正理解的一件事

开始以为：

```
app.conf
↔
ConfigMap
```

二者是实时互通的。

后来理解了真正的数据流：

```
本地 app.conf
        │
kubectl create configmap
        │
        ▼
ConfigMap（保存在 Kubernetes）
        │
Volume
        ▼
容器中的 /etc/config/app.conf
```

真正自动同步的是：

```
ConfigMap
        │
        ▼
容器里的配置文件
```

而不是本地文件。

如果修改宿主机的 app.conf，

ConfigMap 并不会自动更新。

必须再次执行：

```bash
kubectl create configmap app-config-file \
--from-file=app.conf \
--dry-run=client -o yaml | kubectl apply -f -
```

这一点是今天最大的理解提升。

---

# 七、知识总结

今天掌握了：

* ConfigMap 的作用
* 配置与镜像解耦思想
* 创建 ConfigMap
* Environment Variables 注入
* Volume 挂载
* 配置热更新
* 环境变量与 Volume 的区别
* 企业为什么大量使用 ConfigMap

---

# 八、今日感悟

从 Day30 成功搭建 Minikube 开始，到今天学习 ConfigMap，我已经逐渐理解 Kubernetes 并不是简单的容器管理工具，而是一套完整的应用运行平台。

Docker 解决的是：

> **如何运行容器。**

而 Kubernetes 更进一步解决的是：

> **如何管理应用。**

Pod、Deployment、Service、ConfigMap，一步步串联起来，我终于开始理解 Kubernetes 为什么会成为云原生时代的事实标准。

今天不仅学会了命令，更重要的是理解了 Kubernetes 对“配置管理”的设计思想。这种将程序与配置彻底分离的理念，也让我第一次真正体会到企业级平台化运维的价值。
