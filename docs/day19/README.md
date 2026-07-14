# Day19 - 容器技术入门（Podman & Docker）

## 今日目标

- 理解容器技术产生的原因
- 理解 Image 与 Container 的区别
- 学习 Podman 基础命令
- 了解 Docker 与 Podman 的关系
- 完成第一个容器运行实验

---

# 今日实验

## 查看容器版本

```bash
docker --version
```

输出：

```text
Emulate Docker CLI using podman.
podman version 5.8.2
```

说明：

Rocky Linux 9 默认安装的是 **podman-docker**，`docker` 命令实际上由 Podman 接管。

---

## 查看 Docker 服务

```bash
systemctl status docker
```

输出：

```text
Unit docker.service could not be found.
```

原因：

当前系统没有安装 Docker Engine，因此不存在：

```
docker.service
```

---

## 查看 Podman 服务

```bash
systemctl status podman
```

输出：

```
Active: inactive (dead)
TriggeredBy: podman.socket
```

说明：

Podman 默认采用 **Daemonless（无守护进程）** 架构，只有需要 API 时才会启动 podman.service，因此 inactive 属于正常现象。

---

## 查看 Podman 信息

```bash
podman version
```

当前版本：

```
Podman Engine 5.8.2
```

---

## 查看系统信息

```bash
podman info
```

重点观察：

- Rootless 模式
- Cgroup v2
- Overlay 存储驱动
- OCI Runtime（crun）
- Registry 配置

其中：

```
rootless: true
```

说明当前容器以普通用户身份运行，而不是 root 用户。

---

## 第一个容器

运行：

```bash
podman run hello-world
```

输出：

```
Hello Podman World
```

整个过程：

```
Registry
    │
    ▼
Pull Image
    │
    ▼
Create Container
    │
    ▼
Run
    │
    ▼
Exit
```

---

## 查看镜像

```bash
podman images
```

输出：

```
quay.io/podman/hello
```

说明：

本地已经拥有一个镜像。

---

## 查看运行中的容器

```bash
podman ps
```

结果为空。

原因：

hello-world 容器执行结束后立即退出。

---

## 查看所有容器

```bash
podman ps -a
```

输出：

```
Exited (0)
```

说明：

虽然容器已经停止，但容器对象依然保留。

今天共运行了两次 hello-world，因此生成了两个停止状态的容器。

---

# 今日知识点

## Docker 与 Podman

Rocky Linux 9 默认使用：

```
Podman
```

而不是：

```
Docker Engine
```

安装：

```bash
dnf install docker
```

实际上安装的是：

```
podman-docker
```

它只是兼容 Docker CLI：

```
docker
    │
    ▼
podman
```

---

## Docker Engine 与 Podman 的区别

Docker：

```
docker CLI
      │
      ▼
dockerd
      │
docker.service
```

Podman：

```
podman
    │
    ▼
OCI Runtime(crun)
```

特点：

- 无守护进程
- Rootless
- 更符合 RHEL 企业环境

---

## Image 与 Container

Image：

类似于系统安装镜像（ISO）。

Container：

Image 创建出来的运行实例。

关系：

```
Image
   │
   ├── Container A
   ├── Container B
   ├── Container C
```

一个 Image 可以创建多个 Container。

---

# 今日踩坑

## 坑一：安装 Docker 实际安装的是 Podman

执行：

```bash
dnf install docker
```

安装结果：

```
podman-docker
```

原因：

Rocky Linux 官方默认推荐 Podman。

---

## 坑二：docker.service 不存在

执行：

```bash
systemctl start docker
```

提示：

```
Unit docker.service not found
```

原因：

没有安装 Docker Engine。

---

## 坑三：podman.service 未启动

查看：

```bash
systemctl status podman
```

状态：

```
inactive
```

并不是错误。

Podman 不依赖后台守护进程。

---

# 今日收获

掌握了：

- 容器技术产生原因
- Image 与 Container 的关系
- Podman 基础命令
- Docker 与 Podman 的区别
- Rootless Container
- Daemonless 架构

---

# 今日总结

今天正式进入容器化学习阶段。

虽然最初计划学习 Docker，但 Rocky Linux 默认使用 Podman，使我提前接触到了 Red Hat 企业生态。

通过今天的实践，已经理解：

```
Registry
      │
      ▼
Image
      │
podman run
      │
      ▼
Container
      │
      ▼
Running
      │
      ▼
Exited
```

也理解了：

- Image 是模板
- Container 是运行实例
- 一个 Image 可以创建多个 Container

为后续学习 Docker Engine、Docker Compose、Kubernetes 奠定了基础。
