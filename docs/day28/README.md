# Day28 - Podman Compose（多容器编排）

## 今日目标

- 理解 Compose 的作用
- 学习 compose.yaml 文件结构
- 学习 Service 概念
- 学习多容器编排
- 使用 Podman Compose 一键启动多个容器
- 为 Kubernetes 学习打基础

---

# 一、为什么需要 Compose？

之前运行容器：

```bash
podman run nginx

podman run redis

podman run postgres
```

每增加一个服务：

就需要增加一条命令。

如果一个项目包含：

- Nginx
- Redis
- PostgreSQL
- Prometheus
- Grafana

管理起来将变得十分复杂。

因此出现：

```
Compose
```

Compose 用于：

统一描述整个应用。

---

# 二、Compose 是什么？

Compose 可以理解为：

```
Application

↓

Compose

↓

多个 Services

↓

多个 Containers
```

开发者无需逐个启动容器。

只需要：

```bash
podman compose up
```

即可启动整个应用。

---

# 三、实验目录

今天创建：

```
Project-Shanghai-2027/

└── containers/
    └── day28/
        ├── Containerfile
        ├── compose.yaml
        └── index.html
```

Containerfile：

负责：

构建 Web 镜像。

compose.yaml：

负责：

管理整个应用。

---

# 四、Containerfile

内容：

```Dockerfile
FROM nginx

COPY index.html /usr/share/nginx/html/

EXPOSE 80
```

作用：

构建自定义 Web 镜像。

---

# 五、compose.yaml

内容：

```yaml
services:

  web:

    build: .

    container_name: day28-web

    ports:
      - "8080:80"

  redis:

    image: redis:latest

    container_name: day28-redis
```

学习了：

```
services
```

表示：

整个应用包含哪些服务。

其中：

```
web
```

使用：

```
Containerfile
```

构建。

```
redis
```

直接使用官方镜像。

---

# 六、Compose 工作流程

执行：

```bash
podman compose up
```

Compose 自动完成：

```
Build Image

↓

Create Network

↓

Create Containers

↓

Start Services
```

整个过程无需手工执行多个：

```
podman run
```

命令。

---

# 七、实验验证

查看：

```bash
podman ps
```

看到：

```
day28-web

day28-redis
```

两个容器成功启动。

浏览器：

访问：

```
http://localhost:8080
```

成功显示：

```
Project Shanghai Day28
```

说明：

Web 服务正常运行。

---

# 八、停止应用

停止：

```bash
podman compose down
```

Compose 自动完成：

```
Stop Containers

↓

Remove Containers

↓

Remove Network
```

整个应用一次性关闭。

---

# 九、今日知识点

## 1、Service

Compose 管理的不是容器。

而是：

```
Service
```

例如：

```
web

redis

postgres
```

每一个 Service：

最终对应：

一个或多个 Container。

---

## 2、Build

```yaml
build: .
```

表示：

使用：

当前目录：

```
Containerfile
```

构建镜像。

---

## 3、Image

```yaml
image: redis:latest
```

表示：

直接使用已有镜像。

无需重新 Build。

---

## 4、Ports

```
8080:80
```

表示：

```
Host 8080

↓

Container 80
```

浏览器访问：

```
localhost:8080
```

实际上访问：

Container 内部：

80 端口。

---

# 十、今日实验流程

完成：

```
创建实验目录

↓

编写 index.html

↓

编写 Containerfile

↓

编写 compose.yaml

↓

podman compose up

↓

podman ps

↓

浏览器验证

↓

podman compose down
```

第一次完整体验了：

Compose 管理多个容器。

---

# 十一、今日踩坑

今天实验整体非常顺利。

没有遇到影响实验完成的问题。

说明：

前几天学习的：

- Podman
- Image
- Network
- Container
- GHCR

知识已经开始形成完整体系。

---

# 十二、核心命令

启动：

```bash
podman compose up
```

后台启动：

```bash
podman compose up -d
```

查看：

```bash
podman ps
```

停止：

```bash
podman compose down
```

查看日志：

```bash
podman compose logs
```

查看某个服务：

```bash
podman compose logs web
```

重新构建：

```bash
podman compose up --build
```

---

# 十三、今日总结

Day28 学习了：

Compose。

理解了：

```
Application

↓

Compose

↓

Services

↓

Containers
```

Compose 不再关注单个容器。

而是：

整个应用。

这也是企业部署 Web 系统的基本方式。

---

# 今日记忆点

一句话：

> **Compose 管理的不是一个容器，而是一整个应用。**

---

# Day28 完成 ✅

当前 Project Shanghai 技术栈：

```
Linux

+

Git / GitHub

+

GitHub Actions

+

Podman

+

Container

+

Network

+

Volume

+

Image Build

+

GHCR

+

CI（GitHub Actions）

+

Image Layer

+

Multi-stage Build

+

Podman Compose ✅
```
