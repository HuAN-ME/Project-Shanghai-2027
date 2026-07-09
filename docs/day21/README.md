# Day21 - Container Network 与 Port Mapping

## 今日目标

- 理解容器为什么默认无法被宿主机访问
- 理解 Linux Network Namespace 的概念
- 掌握 Podman 端口映射（Port Mapping）
- 学会查看容器端口映射和网络信息
- 理解宿主机与容器之间的通信流程

---

# 一、为什么容器启动了却访问不到？

昨天已经成功运行 nginx：

```bash
podman run -d --name web nginx
```

查看状态：

```bash
podman ps
```

显示：

```
STATUS
Up
```

说明：

nginx 已经正常运行。

但是：

```bash
curl localhost
```

或者浏览器访问：

```
http://localhost
```

却无法访问 nginx 页面。

---

## 原因

容器拥有独立的网络命名空间（Network Namespace）。

```
Host（Rocky Linux）

eth0
192.168.x.x
        │
────────┼──────────────
        │
Container

eth0
10.x.x.x
```

容器内部：

```
80
```

并不会自动暴露给宿主机。

因此：

```
Container 80

≠

Host 80
```

---

# 二、什么是端口映射（Port Mapping）

容器服务需要通过端口映射暴露给宿主机。

启动方式：

```bash
podman run -d --name web -p 8080:80 nginx
```

参数解释：

```
HostPort:ContainerPort
```

即：

```
8080:80
```

表示：

```
Host

8080

↓

Container

80
```

浏览器访问：

```
http://localhost:8080
```

实际上访问的是：

```
Container

80
```

---

# 三、-p 参数说明

格式：

```bash
-p 主机端口:容器端口
```

例如：

```bash
-p 8080:80
```

表示：

```
宿主机8080

↓

容器80
```

再例如：

```bash
-p 8888:80
```

浏览器：

```
localhost:8888
```

↓

访问：

```
Container 80
```

---

# 四、查看端口映射

查看运行中的容器：

```bash
podman ps
```

可以看到：

```
PORTS

0.0.0.0:8080->80/tcp
```

表示：

```
Host

8080

↓

Container

80
```

也可以查看指定容器：

```bash
podman port web
```

输出：

```
80/tcp -> 0.0.0.0:8080
```

说明端口映射已经建立。

---

# 五、验证服务是否正常

终端测试：

```bash
curl localhost:8080
```

如果成功，会返回：

```html
<html>
<title>Welcome to nginx!</title>
```

整个访问链路：

```
浏览器

↓

localhost:8080

↓

Host

↓

Port Mapping

↓

Container

↓

80

↓

nginx
```

---

# 六、查看容器网络信息

查看详细配置：

```bash
podman inspect web
```

输出内容很多。

关注：

```
IPAddress
```

例如：

```
10.88.0.15
```

说明：

容器拥有自己的 IP 地址。

需要注意：

容器 IP 会随着容器删除重建而变化。

因此生产环境一般不会直接访问容器 IP。

而是使用：

- Service
- DNS
- Kubernetes Service
- Ingress

等方式访问。

---

# 七、容器网络结构

理解整个网络关系：

```
Browser

↓

localhost:8080

↓

Rocky Linux Host

↓

Port Mapping

↓

Container

↓

nginx:80
```

可以理解为：

容器是一个拥有独立网络空间的小型 Linux 系统。

宿主机负责将外部请求转发到容器内部。

---

# 八、今日核心命令

删除旧容器：

```bash
podman rm -f web
```

启动并映射端口：

```bash
podman run -d --name web -p 8080:80 nginx
```

查看运行状态：

```bash
podman ps
```

查看端口映射：

```bash
podman port web
```

测试访问：

```bash
curl localhost:8080
```

查看容器信息：

```bash
podman inspect web
```

过滤查看 IP：

```bash
podman inspect web | grep IPAddress
```

---

# 九、今日知识总结

今天学习了容器网络最重要的基础知识：

- 容器拥有独立的 Network Namespace
- 宿主机无法直接访问容器内部端口
- 使用 `-p` 参数完成端口映射
- Host Port 与 Container Port 是两个不同概念
- 容器拥有独立 IP，但生产环境通常不会直接使用
- 浏览器访问的是宿主机端口，再由宿主机转发到容器内部服务

---

# 十、今日记忆点

## 容器网络

```
Host

↓

Port Mapping

↓

Container
```

## 端口映射格式

```
HostPort : ContainerPort
```

例如：

```
8080 : 80
```

## 一句话总结

> **容器默认是隔离的，只有通过端口映射（Port Mapping）才能让宿主机访问容器内部提供的服务。**
