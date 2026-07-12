# Day24 - Container Image Build 镜像构建

## 今日目标

- 理解 Container Image 的组成
- 理解 Image Layer 分层机制
- 学习 Dockerfile / Containerfile
- 使用 Podman 构建自定义 Image
- 运行自己的 Container Image
- 理解企业 DevOps 中 Image Build 流程

---

# 一、回顾之前的容器流程

之前：

```bash
podman pull nginx
```

实际上流程：

```
Registry

↓

nginx Image

↓

Container

↓

Running Service
```

我们一直是在使用别人制作好的 Image。

---

但是企业环境中：

通常不会直接使用：

```
nginx:latest
```

而是：

```
Base Image

+

Application Code

+

Configuration

+

Dependencies

↓

Custom Image

↓

Container
```

---

# 二、什么是 Image？

Image：

> 用于创建 Container 的模板。


关系：

```
Image

↓

Container

↓

Running Application
```

例如：

```
nginx Image

↓

nginx Container

↓

Web Service
```

---

# 三、Image Layer 镜像分层

Image 不是一个完整文件。

它由多个 Layer 组成：

```
Application Image


Layer 4
Startup Command


Layer 3
Configuration


Layer 2
Application Package


Layer 1
Base OS
```

---

## Layer 特点

### 1. 只保存变化

每一层只记录自己的修改。

---

### 2. 可以共享

多个 Image 可以共享基础 Layer。


例如：

```
App A

Linux Base
+
Python


App B

Linux Base
+
Python
```

其中：

```
Linux Base

Python
```

可以复用。

---

# 四、Dockerfile 与 Containerfile

构建 Image 的文件：

传统：

```
Dockerfile
```

Podman 推荐：

```
Containerfile
```

两者语法兼容。

---

目录结构：

```
day24-image/

├── Containerfile
└── index.html
```

---

# 五、创建第一个自定义 Image


创建目录：

```bash
mkdir ~/day24-image
```


进入：

```bash
cd ~/day24-image
```

---

创建：

```bash
vim Containerfile
```

内容：

```Dockerfile
FROM nginx

COPY index.html /usr/share/nginx/html/

EXPOSE 80
```

---

# 六、Containerfile 解析


## FROM

指定基础镜像：

```Dockerfile
FROM nginx
```


表示：

```
nginx Image

↓

Custom Image
```

---

## COPY

复制文件：

```Dockerfile
COPY index.html /usr/share/nginx/html/
```


作用：

将本地文件复制进入 Image。

---

## EXPOSE

声明服务端口：

```Dockerfile
EXPOSE 80
```


表示：

应用监听：

```
80
```

注意：

EXPOSE 不会自动开放端口。


真正访问需要：

```bash
-p
```

例如：

```
-p 8080:80
```

---

# 七、创建网页文件


创建：

```bash
echo "<h1>Project Shanghai Day24 Image Build</h1>" > index.html
```


查看：

```bash
cat index.html
```

---

# 八、Build 自定义 Image


执行：

```bash
podman build -t day24-nginx .
```


参数：

## build

构建 Image。


## -t

指定 Image 名称：

```
day24-nginx
```


## .

当前目录：

```
Containerfile
+
index.html
```

---

构建流程：

```
Containerfile

↓

Podman Build

↓

Create Layers

↓

Generate Image
```

---

# 九、查看 Image


查看：

```bash
podman images
```

应该看到：

```
day24-nginx
```

---

查看 Image 历史：

```bash
podman history day24-nginx
```


可以看到：

```
FROM nginx

COPY index.html

EXPOSE 80
```

---

# 十、运行自己的 Image


启动：

```bash
podman run -d \
--name day24-web \
-p 8080:80 \
day24-nginx
```


查看：

```bash
podman ps
```

---

测试：

```bash
curl localhost:8080
```


返回：

```html
<h1>Project Shanghai Day24 Image Build</h1>
```

说明：

自定义 Image 构建成功。

---

# 十一、查看 Image 信息


查看：

```bash
podman inspect day24-nginx
```


可以查看：

- Image ID
- Layer
- Environment
- Command
- Metadata

---

# 十二、完整实验流程


```
创建项目目录

↓

编写 Containerfile

↓

准备应用文件

↓

podman build

↓

生成 Custom Image

↓

podman run

↓

启动 Container

↓

访问服务
```

---

# 十三、常用命令总结


## 构建 Image

```bash
podman build -t image-name .
```


## 查看 Image

```bash
podman images
```


## 查看 Image 历史

```bash
podman history image-name
```


## 查看详细信息

```bash
podman inspect image-name
```


## 删除 Image

```bash
podman rmi image-name
```

---

# 十四、DevOps 中的 Image 流程


企业环境：

```
Developer

↓

Git Push

↓

CI Pipeline

↓

Build Image

↓

Push Registry

↓

Deploy Container
```

---

今天学习：

```
Containerfile

↓

Build Image
```

对应：

CI/CD 中的：

```
Build Stage
```

---

# 十五、今日踩坑记录


## 坑1：Container 和 Image 混淆


错误理解：

```
Image = Running Service
```


正确：

```
Image

↓

Container

↓

Service
```

---

## 坑2：EXPOSE 自动开放端口


错误：

```
EXPOSE 80

↓

外部可以访问
```


实际：

还需要：

```bash
-p 8080:80
```

---

## 坑3：修改 Container 不等于修改 Image


进入 Container：

```bash
podman exec
```

修改文件：

只改变：

```
Container Writable Layer
```


不会改变：

```
Image
```

---

# 十六、今日知识总结


Day24 学习了 Container Image Build。

核心：

```
Containerfile

↓

Image

↓

Container
```


Image 是：

```
应用模板
```


Container 是：

```
Image 的运行实例
```

---

# 今日记忆点

一句话：

> **Image 是应用交付的标准模板，Container 是 Image 的运行状态。**

---

# Day24 完成 ✅


当前 Project Shanghai 技术栈：

```
Linux

+

Git/GitHub

+

GitHub Actions

+

Podman Container

+

Network

+

Volume

+

Image Build
```

下一阶段：

Day25：

## Container Registry

学习：

- Image Push
- Image Pull
- GitHub Container Registry (GHCR)
- 企业镜像发布流程

进入真正的：

```
Build → Ship → Run
```

DevOps 生命周期。
