# Day27 - Multi-stage Build（多阶段构建）

## 今日目标

- 理解 Image Layer（镜像层）
- 理解 Build Cache（构建缓存）
- 学习 Multi-stage Build（多阶段构建）
- 理解 Builder 与 Runtime 分离思想
- 学会分析 Image Layer
- 为企业镜像优化打基础

---

# 一、为什么要优化镜像？

之前我们已经可以完成：

```
Containerfile

↓

Build Image

↓

Push GHCR
```

虽然镜像能够正常运行，但在企业环境中，仅仅"能运行"是不够的。

例如：

一个普通应用镜像可能包含：

- 编译器
- 构建工具
- 临时缓存
- 源代码
- 调试工具

最终导致：

```
Image Size

↓

1GB+
```

镜像越大：

- 下载越慢
- CI 时间越长
- 部署越慢
- 占用磁盘越多

因此企业都会优化镜像。

---

# 二、Image Layer

今天第一次真正观察：

```
podman history
```

Image 并不是一个整体文件。

实际上：

```
Layer1

↓

Layer2

↓

Layer3

↓

Layer4
```

每执行一条 Dockerfile / Containerfile 指令：

都会生成一个新的 Layer。

例如：

```
FROM nginx

↓

COPY index.html

↓

EXPOSE 80
```

对应：

```
Layer1

Layer2

Layer3
```

---

# 三、Build Cache

修改：

```
index.html
```

重新执行：

```bash
podman build
```

发现：

```
FROM nginx
```

没有重新下载。

原因：

Podman 使用了：

```
Layer Cache
```

前面的 Layer 没有变化。

因此直接复用。

只有：

```
COPY index.html
```

重新生成。

这也是容器构建速度越来越快的重要原因。

---

# 四、Containerfile

今天使用：

```Dockerfile
FROM nginx:latest

COPY index.html /usr/share/nginx/html/

EXPOSE 80
```

Build：

```bash
podman build -t day27-nginx:v1 .
```

查看：

```bash
podman history day27-nginx:v1
```

第一次观察：

Image Layer。

---

# 五、Inspect

学习：

```bash
podman inspect day27-nginx:v1
```

作用：

查看：

- Image ID
- Layer
- Environment
- Metadata
- Labels

了解到：

Image 并不仅仅保存文件，

还保存了大量元数据。

---

# 六、Build Cache 实验

修改：

```
index.html
```

重新：

```bash
podman build -t day27-nginx:v2 .
```

观察：

```
podman history
```

发现：

```
FROM nginx
```

没有重新下载。

说明：

Build Cache 生效。

---

# 七、Multi-stage Build

今天第一次接触：

```Dockerfile
FROM nginx AS builder

COPY index.html /tmp/index.html

FROM nginx

COPY --from=builder \
/tmp/index.html \
/usr/share/nginx/html/index.html

EXPOSE 80
```

重点学习：

```
COPY --from
```

表示：

从前一个 Stage 中复制文件。

虽然今天这个例子没有减少镜像体积，

但已经理解：

```
Builder

↓

Runtime
```

两个阶段。

企业开发中：

Builder：

负责：

- 编译
- 安装依赖
- 打包

Runtime：

只保留：

最终程序。

---

# 八、实验流程

今天完成：

```
创建实验目录

↓

编写 Containerfile

↓

Build Image

↓

Inspect

↓

History

↓

修改网页

↓

重新 Build

↓

观察 Cache

↓

体验 Multi-stage Build

↓

运行测试

↓

Git Push
```

整个流程完整体验了一次镜像构建优化。

---

# 九、今日踩坑记录

## 坑1：Image 与 Layer 混淆

最开始认为：

```
Image

=

一个文件
```

实际上：

```
Image

=

多个 Layer
```

组合而成。

---

## 坑2：Build 一定重新下载基础镜像

误区：

```
每次 Build

↓

重新 Pull nginx
```

实际上：

只要：

```
FROM nginx
```

没有变化，

Podman 会直接复用缓存。

---

## 坑3：Multi-stage 一定会减小镜像

今天实验：

```
nginx

↓

nginx
```

镜像大小变化不明显。

原因：

没有真正的编译阶段。

Multi-stage 的优势：

通常出现在：

- Go
- Java
- Rust
- C/C++
- Node.js

等需要编译的项目。

---

# 十、今日核心命令

Build：

```bash
podman build -t day27-nginx:v1 .
```

查看 Layer：

```bash
podman history day27-nginx:v1
```

查看详细信息：

```bash
podman inspect day27-nginx:v1
```

运行：

```bash
podman run -d \
--name day27-web \
-p 8080:80 \
day27-nginx:v1
```

停止：

```bash
podman stop day27-web
```

删除：

```bash
podman rm day27-web
```

---

# 十一、今日知识总结

Day27 学习了镜像构建优化的基础。

理解了：

```
Containerfile

↓

Layer

↓

Cache

↓

Multi-stage Build
```

Image 不只是一个文件，

而是：

多个 Layer。

Build 也不是：

每次重新开始，

而是：

充分利用缓存。

企业使用 Multi-stage Build：

主要目的：

- 减小镜像体积
- 提高安全性
- 提升 CI/CD 构建效率

---

# 今日记忆点

一句话：

> **镜像优化的核心不是让程序能运行，而是在保证功能不变的前提下，让镜像更小、更快、更适合生产环境。**

---

# Day27 完成 ✅

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

Multi-stage Build ✅
```
