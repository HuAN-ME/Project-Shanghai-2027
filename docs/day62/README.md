# Day62：CI Pipeline 接入 Docker Build

日期：2026/08/18

---

## 今日目标

在 Day61 CI 基础上，将 Docker Image 构建正式加入 GitHub Actions Pipeline。

目标：

```text
Git Push
    ↓
Checkout
    ↓
Application Test
    ↓
Docker Build
    ↓
Image
```

---

## 一、本地 Docker 镜像构建

创建 `Dockerfile`：

```dockerfile
FROM nginx:alpine

COPY app/health.txt /usr/share/nginx/html/health.txt

EXPOSE 80
```

应用结构：

```text
day61/
├── app/
│   └── health.txt
├── Dockerfile
└── .github/
    └── workflows/
        └── day61.yml
```

---

## 二、本地验证

构建镜像：

```bash
docker build -t day62-nginx:local .
```

运行：

```bash
docker run -d \
  --name day62-nginx \
  -p 8081:80 \
  day62-nginx:local
```

验证：

```bash
curl http://127.0.0.1:8081/health.txt
```

返回：

```text
OK
```

验证完成后清理：

```bash
docker rm -f day62-nginx
```

---

## 三、GitHub Actions 加入 Docker Build

在 Day61 Workflow 中增加 Docker Image 构建步骤：

```yaml
- name: Build Docker image
  run: |
    docker build -t day62-nginx:${{ github.sha }} .
```

Pipeline 由：

```text
Checkout
    ↓
Test
```

升级为：

```text
Checkout
    ↓
Test
    ↓
Docker Build
```

GitHub Actions 执行成功，Pipeline 全绿。

---

## 四、镜像版本管理

本次没有直接使用：

```text
latest
```

而是使用：

```text
${{ github.sha }}
```

作为 Image Tag。

示意：

```text
day62-nginx:<Git Commit SHA>
```

这样可以建立：

```text
Git Commit
    ↓
Docker Image
```

之间的对应关系，为后续 Registry 推送和版本追踪做好准备。

---

## 五、今日关键认识

Day61 的 CI 主要负责：

```text
验证代码
```

Day62 开始，CI 已经能够：

```text
验证代码
    ↓
生成 Docker Image
```

因此 CI 开始产生真正的 **Artifact（构建产物）**。

后续可以继续扩展：

```text
Git Push
    ↓
Test
    ↓
Build Image
    ↓
Push Registry
    ↓
Deploy Kubernetes
    ↓
Health Check
```

---

## 六、今日完成

* [x] 创建 Dockerfile
* [x] 本地构建 Docker Image
* [x] 本地运行 Container
* [x] HTTP Health Check
* [x] GitHub Actions 加入 Docker Build
* [x] 使用 Git SHA 作为 Image Tag
* [x] CI Pipeline 全绿

---

## 七、阶段进展

Day61：

```text
CI Test
```

Day62：

```text
CI Build
```

当前阶段：

```text
Source Code
    ↓
Test
    ↓
Docker Image
```

下一阶段：

```text
Docker Image
    ↓
Registry
```

---

## 总结

Day62 完成了从“CI 检查代码”到“CI 生成构建产物”的关键一步。

今天真正建立的是：

> **CI 不只是验证代码，也开始负责生产可交付的 Docker Artifact。**
